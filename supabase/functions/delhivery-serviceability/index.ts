import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const CACHE_TTL_SECONDS = 15 * 60; // 15 minutes
const DELHIVERY_TIMEOUT_MS = 8000;

interface RequestPayload {
  pincode: string;
}

interface NormalizedResult {
  serviceable: boolean;
  pincode: string;
  codAvailable: boolean;
  prepaidAvailable: boolean;
  estimatedDeliveryDate: string | null;
  remarks: string | null;
}

function jsonResponse(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function isValidIndianPincode(value: string): boolean {
  return /^\d{6}$/.test(value);
}

async function fetchWithTimeout(
  url: string,
  headers: Record<string, string>,
): Promise<Response> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), DELHIVERY_TIMEOUT_MS);
  try {
    return await fetch(url, { method: "GET", headers, signal: controller.signal });
  } finally {
    clearTimeout(timeout);
  }
}

class DelhiveryUnavailableError extends Error {}

/**
 * Calls Delhivery's B2C Pincode Serviceability API.
 * Endpoint/method/header/param confirmed directly against the live
 * Delhivery Developer Portal (documents/b2c/) on 2026-08-16:
 *   GET {base}/c/api/pin-codes/json/?filter_codes=<pincode>
 *   Authorization: Token <token>
 * Docs confirm: an empty `delivery_codes` list means non-serviceable (NSZ),
 * and a remark of "Embargo" means temporary non-serviceability.
 *
 * NOTE ON RESPONSE PARSING: Delhivery's portal does not publish a sample
 * response body for this endpoint. The `delivery_codes[].postal_code`
 * shape parsed below is the long-standing, widely-documented shape of this
 * specific legacy endpoint (unchanged for years across the Delhivery
 * ecosystem), but it has NOT been confirmed against a live authenticated
 * response for this account. If Delhivery's actual shape differs, parsing
 * intentionally fails closed into DelhiveryUnavailableError rather than
 * guessing serviceable/non-serviceable — this must be verified against a
 * real response before this function is considered production-final.
 */
async function checkPincodeServiceability(
  baseUrl: string,
  token: string,
  pincode: string,
): Promise<{
  serviceable: boolean;
  codAvailable: boolean;
  prepaidAvailable: boolean;
  remarks: string | null;
}> {
  const url = `${baseUrl}/c/api/pin-codes/json/?filter_codes=${encodeURIComponent(pincode)}`;

  let response: Response;
  try {
    response = await fetchWithTimeout(url, { Authorization: `Token ${token}` });
  } catch (err) {
    console.error("[DELHIVERY] Pincode serviceability request failed:", String(err));
    throw new DelhiveryUnavailableError("Pincode serviceability request failed");
  }

  console.log(`[DELHIVERY] Pincode serviceability httpStatus=${response.status}`);

  if (!response.ok) {
    throw new DelhiveryUnavailableError(
      `Pincode serviceability HTTP error ${response.status}`,
    );
  }

  let data: unknown;
  try {
    data = await response.json();
  } catch (err) {
    console.error("[DELHIVERY] Pincode serviceability malformed JSON:", String(err));
    throw new DelhiveryUnavailableError("Malformed serviceability response");
  }

  const deliveryCodes = (data as any)?.delivery_codes;

  if (!Array.isArray(deliveryCodes)) {
    // Response doesn't match the known shape at all — fail closed rather
    // than guess. See NOTE above.
    console.error("[DELHIVERY] Unrecognized serviceability response shape");
    throw new DelhiveryUnavailableError("Unrecognized serviceability response shape");
  }

  if (deliveryCodes.length === 0) {
    return { serviceable: false, codAvailable: false, prepaidAvailable: false, remarks: null };
  }

  const postalCode = deliveryCodes[0]?.postal_code ?? {};
  const remarks: string | null = postalCode.remarks || null;
  const isEmbargoed = typeof remarks === "string" && remarks.toLowerCase().includes("embargo");

  if (isEmbargoed) {
    return { serviceable: false, codAvailable: false, prepaidAvailable: false, remarks };
  }

  return {
    serviceable: true,
    codAvailable: postalCode.cod === "Y",
    prepaidAvailable: postalCode.pre_paid === "Y",
    remarks,
  };
}

/**
 * Calls Delhivery's Expected TAT API.
 * Endpoint/method/params confirmed directly against the live Delhivery
 * Developer Portal (documents/b2c/) on 2026-08-16:
 *   GET {base}/api/dc/expected_tat?origin_pin=...&destination_pin=...&mot=...&expected_pickup_date=...
 *   Authorization: Token <token>
 * Docs confirm the API itself adjusts the expected delivery date forward
 * past holidays/Sundays — we do not compute that ourselves.
 *
 * NOTE ON RESPONSE PARSING: no sample response body is published for this
 * endpoint anywhere we could verify (it's a newer endpoint, not covered by
 * the long-standing public documentation the way pin-codes/json/ is). The
 * candidate field names below are a best-effort guess at common Delhivery
 * naming conventions and are UNVERIFIED. If none match, this intentionally
 * returns null (serviceable-but-date-unknown) rather than fabricating a
 * delivery estimate. This must be confirmed against a real authenticated
 * response before the feature can be called production-final.
 */
async function fetchExpectedTat(
  baseUrl: string,
  token: string,
  originPincode: string,
  destinationPincode: string,
  mot: string,
): Promise<string | null> {
  const expectedPickupDate = formatPickupDate(new Date());
  const url =
    `${baseUrl}/api/dc/expected_tat?origin_pin=${encodeURIComponent(originPincode)}` +
    `&destination_pin=${encodeURIComponent(destinationPincode)}` +
    `&mot=${encodeURIComponent(mot)}` +
    `&expected_pickup_date=${encodeURIComponent(expectedPickupDate)}`;

  let response: Response;
  try {
    response = await fetchWithTimeout(url, {
      Authorization: `Token ${token}`,
      Accept: "application/json",
    });
  } catch (err) {
    console.error("[DELHIVERY] Expected TAT request failed:", String(err));
    return null;
  }

  console.log(`[DELHIVERY] Expected TAT httpStatus=${response.status}`);

  if (!response.ok) {
    return null;
  }

  let data: unknown;
  try {
    data = await response.json();
  } catch (err) {
    console.error("[DELHIVERY] Expected TAT malformed JSON:", String(err));
    return null;
  }

  return extractEstimatedDeliveryDate(data, new Date());
}

function formatPickupDate(date: Date): string {
  const yyyy = date.getUTCFullYear();
  const mm = String(date.getUTCMonth() + 1).padStart(2, "0");
  const dd = String(date.getUTCDate()).padStart(2, "0");
  const hh = String(date.getUTCHours()).padStart(2, "0");
  const min = String(date.getUTCMinutes()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd} ${hh}:${min}`;
}

/** UNVERIFIED — see NOTE on fetchExpectedTat above. */
function extractEstimatedDeliveryDate(data: unknown, pickupDate: Date): string | null {
  const root = data as Record<string, unknown> | null;
  if (!root || typeof root !== "object") return null;

  const dateCandidates = [
    "expected_delivery_date",
    "delivery_date",
    "edd",
    "tat_date",
  ];
  for (const key of dateCandidates) {
    const value = root[key];
    if (typeof value === "string" && value.trim().length > 0) {
      return value.trim();
    }
  }

  const dayCountCandidates = ["tat", "expected_tat", "days"];
  for (const key of dayCountCandidates) {
    const value = root[key];
    const days = typeof value === "number" ? value : Number(value);
    if (Number.isFinite(days) && days >= 0) {
      const estimated = new Date(pickupDate);
      estimated.setUTCDate(estimated.getUTCDate() + days);
      return estimated.toISOString().slice(0, 10);
    }
  }

  return null;
}

serve(async (req: Request) => {
  console.log("[NUVI-EDGE] delhivery-serviceability START");

  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  let payload: RequestPayload;
  try {
    payload = await req.json();
  } catch (_) {
    return jsonResponse({ error: "Invalid request body" }, 400);
  }

  const pincode = (payload?.pincode ?? "").trim();
  if (!isValidIndianPincode(pincode)) {
    return jsonResponse({ error: "INVALID_PINCODE" }, 400);
  }

  const token = Deno.env.get("DELHIVERY_API_TOKEN") ?? "";
  const baseUrl = (Deno.env.get("DELHIVERY_API_BASE_URL") ?? "").replace(/\/+$/, "");
  const originPincode = Deno.env.get("DELHIVERY_ORIGIN_PINCODE") ?? "";
  const mot = Deno.env.get("DELHIVERY_MOT") ?? "S";

  if (!token || !baseUrl || !originPincode) {
    console.error(
      "[NUVI-EDGE] Missing Delhivery configuration:",
      `tokenSet=${Boolean(token)} baseUrlSet=${Boolean(baseUrl)} originPincodeSet=${Boolean(originPincode)}`,
    );
    return jsonResponse({ error: "DELIVERY_CHECK_UNAVAILABLE" }, 503);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  const supabaseAdminClient = createClient(supabaseUrl, supabaseServiceRoleKey);

  const cacheKey = `${pincode}:${originPincode}:${mot}`;

  try {
    const { data: cached } = await supabaseAdminClient
      .from("delhivery_serviceability_cache")
      .select("response, expires_at")
      .eq("cache_key", cacheKey)
      .maybeSingle();

    if (cached && new Date(cached.expires_at) > new Date()) {
      console.log("[NUVI-EDGE] Cache hit");
      return jsonResponse(cached.response, 200);
    }

    const serviceability = await checkPincodeServiceability(baseUrl, token, pincode);

    let result: NormalizedResult;

    if (!serviceability.serviceable) {
      result = {
        serviceable: false,
        pincode,
        codAvailable: false,
        prepaidAvailable: false,
        estimatedDeliveryDate: null,
        remarks: serviceability.remarks,
      };
    } else {
      const estimatedDeliveryDate = await fetchExpectedTat(
        baseUrl,
        token,
        originPincode,
        pincode,
        mot,
      );

      result = {
        serviceable: true,
        pincode,
        codAvailable: serviceability.codAvailable,
        prepaidAvailable: serviceability.prepaidAvailable,
        estimatedDeliveryDate,
        remarks: serviceability.remarks,
      };
    }

    const expiresAt = new Date(Date.now() + CACHE_TTL_SECONDS * 1000).toISOString();
    const { error: cacheWriteError } = await supabaseAdminClient
      .from("delhivery_serviceability_cache")
      .upsert({ cache_key: cacheKey, response: result, expires_at: expiresAt });

    if (cacheWriteError) {
      console.error("[NUVI-EDGE] Cache write failed:", cacheWriteError.message);
    }

    return jsonResponse(result, 200);
  } catch (err) {
    if (err instanceof DelhiveryUnavailableError) {
      console.error("[NUVI-EDGE] Delhivery unavailable:", err.message);
      return jsonResponse({ error: "DELIVERY_CHECK_UNAVAILABLE" }, 502);
    }
    console.error("[NUVI-EDGE] Unhandled error in delhivery-serviceability:", String(err));
    return jsonResponse({ error: "DELIVERY_CHECK_UNAVAILABLE" }, 500);
  }
});
