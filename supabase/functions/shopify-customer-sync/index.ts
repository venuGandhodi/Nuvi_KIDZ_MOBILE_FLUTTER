import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface RequestPayload {
  action:
    | "GET_CUSTOMER"
    | "GET_ORDERS"
    | "GET_ORDER"
    | "CREATE_ADDRESS"
    | "UPDATE_ADDRESS"
    | "DELETE_ADDRESS"
    | "SET_DEFAULT_ADDRESS";
  first?: number;
  after?: string;
  orderId?: string;
  addressId?: string;
  address?: {
    firstName?: string;
    lastName?: string;
    company?: string;
    address1?: string;
    address2?: string;
    city?: string;
    province?: string;
    provinceCode?: string;
    country?: string;
    countryCode?: string;
    zip?: string;
    phone?: string;
  };
}

serve(async (req: Request) => {
  console.log("[NUVI-EDGE] shopify-customer-sync START");

  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      console.log("[NUVI-EDGE] Missing Authorization header");
      return new Response(
        JSON.stringify({ error: "Missing Authorization header" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const shopifyDomain = Deno.env.get("SHOPIFY_STORE_DOMAIN") ?? "muu1gj-t6.myshopify.com";
    const shopifyAdminToken = Deno.env.get("SHOPIFY_ADMIN_ACCESS_TOKEN") ?? "";

    // 1. Verify authenticated Supabase User
    const supabaseUserClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const {
      data: { user },
      error: userError,
    } = await supabaseUserClient.auth.getUser();

    if (userError || !user) {
      console.log("[NUVI-EDGE] Supabase user authentication failed");
      return new Response(
        JSON.stringify({ error: "Unauthorized: Invalid or expired session" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    console.log("[NUVI-EDGE] Supabase user authenticated=true");

    const supabaseUserId = user.id;
    const verifiedEmail = user.email?.trim().toLowerCase();

    if (!verifiedEmail) {
      console.log("[NUVI-EDGE] User has no verified email");
      return new Response(
        JSON.stringify({ error: "User has no verified email address" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 2. Service role client for secure mapping queries/inserts
    const supabaseAdminClient = createClient(supabaseUrl, supabaseServiceRoleKey);

    // Helper for executing GraphQL against Shopify Admin API
    const runShopifyAdminGraphQL = async (query: string, variables: Record<string, unknown> = {}) => {
      if (!shopifyAdminToken) {
        throw new Error("SHOPIFY_ADMIN_ACCESS_TOKEN secret is not configured on the server.");
      }

      console.log("[NUVI-EDGE] Shopify Admin GraphQL REQUEST START");
      const response = await fetch(
        `https://${shopifyDomain}/admin/api/2026-04/graphql.json`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-Shopify-Access-Token": shopifyAdminToken,
          },
          body: JSON.stringify({ query, variables }),
        }
      );

      console.log(`[NUVI-EDGE] Shopify Admin GraphQL RESPONSE RECEIVED (HTTP ${response.status})`);

      if (!response.ok) {
        const text = await response.text();
        throw new Error(`Shopify Admin API HTTP error ${response.status}: ${text}`);
      }

      const json = await response.json();
      if (json.errors && json.errors.length > 0) {
        throw new Error(`Shopify GraphQL errors: ${JSON.stringify(json.errors)}`);
      }
      return json.data;
    };

    // 3. Parse request payload
    let payload: RequestPayload = { action: "GET_CUSTOMER" };
    if (req.method === "POST") {
      try {
        payload = await req.json();
      } catch (_) {
        payload = { action: "GET_CUSTOMER" };
      }
    }

    console.log(`[NUVI-EDGE] Executing action=${payload.action}`);

    // 4. Resolve or Lazily Provision Customer Mapping in shopify_customer_links
    console.log("[NUVI-EDGE] Customer mapping lookup START");
    const { data: existingMapping, error: mappingError } = await supabaseAdminClient
      .from("shopify_customer_links")
      .select("shopify_customer_id, shopify_customer_email")
      .eq("supabase_user_id", supabaseUserId)
      .maybeSingle();

    if (mappingError) {
      console.error("[NUVI-EDGE] Database mapping lookup error:", mappingError);
      return new Response(
        JSON.stringify({ error: "Database error resolving customer link" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let shopifyCustomerId = existingMapping?.shopify_customer_id;

    if (!shopifyCustomerId) {
      console.log("[NUVI-EDGE] Shopify customer email lookup START");
      const searchData = await runShopifyAdminGraphQL(
        `query FindCustomerByExactEmail($query: String!) {
          customers(first: 5, query: $query) {
            edges {
              node {
                id
                email
                firstName
                lastName
                displayName
                phone
              }
            }
          }
        }`,
        { query: `email:"${verifiedEmail}"` }
      );

      const customerEdges = searchData?.customers?.edges ?? [];
      const exactMatches = customerEdges.filter((edge: any) => {
        const candidateEmail = edge.node?.email?.trim().toLowerCase();
        return candidateEmail === verifiedEmail;
      });

      if (exactMatches.length > 1) {
        console.log("[NUVI-EDGE] Shopify customer MATCH AMBIGUOUS");
        return new Response(
          JSON.stringify({
            status: "CUSTOMER_MAPPING_AMBIGUOUS",
            message: "Multiple Shopify customer records matched this email.",
            customer: null,
          }),
          { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      if (exactMatches.length === 1) {
        console.log("[NUVI-EDGE] Existing Shopify customer MATCHED");
        const matchedNode = exactMatches[0].node;
        shopifyCustomerId = matchedNode.id;

        // Persist verified mapping
        const { error: insertError } = await supabaseAdminClient
          .from("shopify_customer_links")
          .insert({
            supabase_user_id: supabaseUserId,
            shopify_customer_id: shopifyCustomerId,
            shopify_customer_email: verifiedEmail,
          });

        if (insertError) {
          console.error("[NUVI-EDGE] Failed to insert shopify_customer_link:", insertError);
          return new Response(
            JSON.stringify({ error: "Failed to persist customer link mapping" }),
            { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }
      } else {
        // 0 matches found in Shopify
        if (payload.action === "CREATE_ADDRESS") {
          console.log("[NUVI-EDGE] Provisioning new Shopify customer for CREATE_ADDRESS");
          const meta = user.user_metadata ?? {};
          const firstName =
            payload.address?.firstName ||
            meta.full_name?.split(" ")[0] ||
            meta.name?.split(" ")[0] ||
            "";
          const lastName =
            payload.address?.lastName ||
            meta.full_name?.split(" ").slice(1).join(" ") ||
            "";

          const createCustomerData = await runShopifyAdminGraphQL(
            `mutation CreateShopifyCustomer($input: CustomerInput!) {
              customerCreate(input: $input) {
                customer {
                  id
                  email
                  firstName
                  lastName
                }
                userErrors {
                  field
                  message
                }
              }
            }`,
            {
              input: {
                email: verifiedEmail,
                firstName: firstName,
                lastName: lastName,
                phone: payload.address?.phone,
              },
            }
          );

          const createResult = createCustomerData?.customerCreate;
          if (createResult?.userErrors && createResult.userErrors.length > 0) {
            console.error("[NUVI-EDGE] Customer creation userErrors:", createResult.userErrors);
            return new Response(
              JSON.stringify({
                status: "CUSTOMER_CREATION_FAILED",
                error: createResult.userErrors.map((e: any) => e.message).join(", "),
              }),
              { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
          }

          const newCustomerId = createResult?.customer?.id;
          if (!newCustomerId) {
            return new Response(
              JSON.stringify({
                status: "CUSTOMER_CREATION_FAILED",
                error: "Failed to obtain created customer ID from Shopify",
              }),
              { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
          }

          // Persist verified mapping
          const { error: insertError } = await supabaseAdminClient
            .from("shopify_customer_links")
            .insert({
              supabase_user_id: supabaseUserId,
              shopify_customer_id: newCustomerId,
              shopify_customer_email: verifiedEmail,
            });

          if (insertError) {
            console.error("[NUVI-EDGE] Failed to insert shopify_customer_link after customerCreate:", insertError);
            return new Response(
              JSON.stringify({
                status: "CUSTOMER_CREATION_FAILED",
                error: "Failed to persist customer link mapping after creation",
              }),
              { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
          }

          shopifyCustomerId = newCustomerId;
          console.log("[NUVI-EDGE] Successfully provisioned Shopify customer and saved mapping");
        } else {
          console.log("[NUVI-EDGE] Shopify customer NOT FOUND (lazy provisioning not triggered)");
          return new Response(
            JSON.stringify({
              status: "CUSTOMER_NOT_LINKED",
              message: "No existing Shopify customer account found for this email.",
              customer: null,
            }),
            { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }
      }
    } else {
      console.log("[NUVI-EDGE] Existing Shopify customer mapping FOUND");
    }

    // 5. Execute Requested Action
    switch (payload.action) {
      case "GET_CUSTOMER": {
        const customerData = await runShopifyAdminGraphQL(
          `query GetCustomerProfile($id: ID!) {
            customer(id: $id) {
              id
              firstName
              lastName
              displayName
              email
              phone
              defaultAddress {
                id
                address1
                address2
                city
                province
                zip
                country
                phone
              }
              addresses(first: 10) {
                edges {
                  node {
                    id
                    address1
                    address2
                    city
                    province
                    zip
                    country
                    phone
                  }
                }
              }
              ordersCount
            }
          }`,
          { id: shopifyCustomerId }
        );

        const rawCustomer = customerData?.customer;
        if (!rawCustomer) {
          return new Response(
            JSON.stringify({
              status: "CUSTOMER_NOT_FOUND",
              message: "Customer record could not be found in Shopify.",
              customer: null,
            }),
            { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }

        const addresses = (rawCustomer.addresses?.edges ?? []).map((e: any) => e.node);

        const sanitizedCustomer = {
          id: rawCustomer.id,
          firstName: rawCustomer.firstName,
          lastName: rawCustomer.lastName,
          displayName: rawCustomer.displayName,
          email: rawCustomer.email,
          phone: rawCustomer.phone,
          defaultAddress: rawCustomer.defaultAddress,
          addresses: addresses,
          ordersCount: rawCustomer.ordersCount ?? 0,
        };

        return new Response(
          JSON.stringify({
            status: "LINKED",
            customer: sanitizedCustomer,
          }),
          { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      case "GET_ORDERS": {
        const first = Math.min(payload.first ?? 20, 50);
        const after = payload.after ?? null;

        const ordersData = await runShopifyAdminGraphQL(
          `query GetCustomerOrders($id: ID!, $first: Int!, $after: String) {
            customer(id: $id) {
              id
              orders(first: $first, after: $after, sortKey: PROCESSED_AT, reverse: true) {
                pageInfo {
                  hasNextPage
                  endCursor
                }
                edges {
                  cursor
                  node {
                    id
                    name
                    orderNumber
                    processedAt
                    createdAt
                    displayFinancialStatus
                    displayFulfillmentStatus
                    currentTotalPriceSet {
                      shopMoney {
                        amount
                        currencyCode
                      }
                    }
                    currentTotalTaxSet {
                      shopMoney {
                        amount
                        currencyCode
                      }
                    }
                    totalShippingPriceSet {
                      shopMoney {
                        amount
                        currencyCode
                      }
                    }
                    lineItems(first: 50) {
                      edges {
                        node {
                          id
                          title
                          quantity
                          originalTotalPriceSet {
                            shopMoney {
                              amount
                              currencyCode
                            }
                          }
                          variant {
                            id
                            title
                            image {
                              url
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }`,
          { id: shopifyCustomerId, first, after }
        );

        const orderEdges = ordersData?.customer?.orders?.edges ?? [];
        const pageInfo = ordersData?.customer?.orders?.pageInfo ?? {
          hasNextPage: false,
          endCursor: null,
        };

        const sanitizedOrders = orderEdges.map((edge: any) => {
          const node = edge.node;
          const lineItems = (node.lineItems?.edges ?? []).map((liEdge: any) => {
            const liNode = liEdge.node;
            return {
              id: liNode.id,
              title: liNode.title,
              quantity: liNode.quantity,
              variantTitle: liNode.variant?.title,
              originalTotalPrice: {
                amount: parseFloat(liNode.originalTotalPriceSet?.shopMoney?.amount ?? "0.0"),
                currencyCode: liNode.originalTotalPriceSet?.shopMoney?.currencyCode ?? "INR",
              },
              imageUrl: liNode.variant?.image?.url ?? null,
            };
          });

          return {
            id: node.id,
            name: node.name,
            orderNumber: node.orderNumber,
            processedAt: node.processedAt ?? node.createdAt,
            financialStatus: node.displayFinancialStatus,
            fulfillmentStatus: node.displayFulfillmentStatus,
            currentTotalPrice: {
              amount: parseFloat(node.currentTotalPriceSet?.shopMoney?.amount ?? "0.0"),
              currencyCode: node.currentTotalPriceSet?.shopMoney?.currencyCode ?? "INR",
            },
            currentTotalTax: node.currentTotalTaxSet
              ? {
                  amount: parseFloat(node.currentTotalTaxSet.shopMoney?.amount ?? "0.0"),
                  currencyCode: node.currentTotalTaxSet.shopMoney?.currencyCode ?? "INR",
                }
              : null,
            totalShippingPrice: node.totalShippingPriceSet
              ? {
                  amount: parseFloat(node.totalShippingPriceSet.shopMoney?.amount ?? "0.0"),
                  currencyCode: node.totalShippingPriceSet.shopMoney?.currencyCode ?? "INR",
                }
              : null,
            lineItems: lineItems,
          };
        });

        return new Response(
          JSON.stringify({
            status: "LINKED",
            orders: sanitizedOrders,
            pageInfo: pageInfo,
          }),
          { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      case "GET_ORDER": {
        const orderId = payload.orderId;
        if (!orderId) {
          return new Response(
            JSON.stringify({ error: "Missing orderId parameter" }),
            { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }

        const formattedOrderId = orderId.startsWith("gid://shopify/Order/")
          ? orderId
          : `gid://shopify/Order/${orderId}`;

        const singleOrderData = await runShopifyAdminGraphQL(
          `query GetSingleOrderDetails($id: ID!) {
            order(id: $id) {
              id
              name
              orderNumber
              processedAt
              createdAt
              displayFinancialStatus
              displayFulfillmentStatus
              customer {
                id
              }
              currentTotalPriceSet {
                shopMoney {
                  amount
                  currencyCode
                }
              }
              currentTotalTaxSet {
                shopMoney {
                  amount
                  currencyCode
                }
              }
              totalShippingPriceSet {
                shopMoney {
                  amount
                  currencyCode
                }
              }
              shippingAddress {
                address1
                address2
                city
                province
                zip
                country
              }
              lineItems(first: 50) {
                edges {
                  node {
                    id
                    title
                    quantity
                    originalTotalPriceSet {
                      shopMoney {
                        amount
                        currencyCode
                      }
                    }
                    variant {
                      id
                      title
                      image {
                        url
                      }
                    }
                  }
                }
              }
            }
          }`,
          { id: formattedOrderId }
        );

        const orderNode = singleOrderData?.order;

        if (!orderNode) {
          return new Response(
            JSON.stringify({ error: "Order not found" }),
            { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }

        // Strict Authorization: Verify the order belongs to the authenticated user's mapped Shopify customer
        if (orderNode.customer?.id !== shopifyCustomerId) {
          return new Response(
            JSON.stringify({ error: "Forbidden: Order does not belong to the authenticated customer" }),
            { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }

        const lineItems = (orderNode.lineItems?.edges ?? []).map((liEdge: any) => {
          const liNode = liEdge.node;
          return {
            id: liNode.id,
            title: liNode.title,
            quantity: liNode.quantity,
            variantTitle: liNode.variant?.title,
            originalTotalPrice: {
              amount: parseFloat(liNode.originalTotalPriceSet?.shopMoney?.amount ?? "0.0"),
              currencyCode: liNode.originalTotalPriceSet?.shopMoney?.currencyCode ?? "INR",
            },
            imageUrl: liNode.variant?.image?.url ?? null,
          };
        });

        const sanitizedOrder = {
          id: orderNode.id,
          name: orderNode.name,
          orderNumber: orderNode.orderNumber,
          processedAt: orderNode.processedAt ?? orderNode.createdAt,
          financialStatus: orderNode.displayFinancialStatus,
          fulfillmentStatus: orderNode.displayFulfillmentStatus,
          currentTotalPrice: {
            amount: parseFloat(orderNode.currentTotalPriceSet?.shopMoney?.amount ?? "0.0"),
            currencyCode: orderNode.currentTotalPriceSet?.shopMoney?.currencyCode ?? "INR",
          },
          currentTotalTax: orderNode.currentTotalTaxSet
            ? {
                amount: parseFloat(orderNode.currentTotalTaxSet.shopMoney?.amount ?? "0.0"),
                currencyCode: orderNode.currentTotalTaxSet.shopMoney?.currencyCode ?? "INR",
              }
            : null,
          totalShippingPrice: orderNode.totalShippingPriceSet
            ? {
                amount: parseFloat(orderNode.totalShippingPriceSet.shopMoney?.amount ?? "0.0"),
                currencyCode: orderNode.totalShippingPriceSet.shopMoney?.currencyCode ?? "INR",
              }
            : null,
          lineItems: lineItems,
        };

        return new Response(
          JSON.stringify({
            status: "LINKED",
            order: sanitizedOrder,
          }),
          { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      case "CREATE_ADDRESS": {
        if (!payload.address) {
          return new Response(
            JSON.stringify({ error: "Missing address payload" }),
            { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }

        const createData = await runShopifyAdminGraphQL(
          `mutation CreateCustomerAddress($customerId: ID!, $address: MailingAddressInput!) {
            customerAddressCreate(customerId: $customerId, address: $address) {
              customerAddress {
                id
                address1
                address2
                city
                province
                zip
                country
                phone
              }
              userErrors {
                field
                message
              }
            }
          }`,
          {
            customerId: shopifyCustomerId,
            address: {
              firstName: payload.address.firstName,
              lastName: payload.address.lastName,
              company: payload.address.company,
              address1: payload.address.address1,
              address2: payload.address.address2,
              city: payload.address.city,
              province: payload.address.province,
              zip: payload.address.zip,
              country: payload.address.country ?? "India",
              phone: payload.address.phone,
            },
          }
        );

        const result = createData?.customerAddressCreate;
        if (result?.userErrors && result.userErrors.length > 0) {
          return new Response(
            JSON.stringify({
              status: "ERROR",
              error: result.userErrors.map((e: any) => e.message).join(", "),
            }),
            { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }

        return new Response(
          JSON.stringify({
            status: "SUCCESS",
            address: result?.customerAddress,
          }),
          { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      case "UPDATE_ADDRESS": {
        if (!payload.addressId || !payload.address) {
          return new Response(
            JSON.stringify({ error: "Missing addressId or address payload" }),
            { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }

        // Verify address ownership
        const ownershipCheck = await runShopifyAdminGraphQL(
          `query VerifyAddressOwnership($customerId: ID!) {
            customer(id: $customerId) {
              addresses(first: 20) {
                edges {
                  node {
                    id
                  }
                }
              }
            }
          }`,
          { customerId: shopifyCustomerId }
        );

        const ownedAddresses = (ownershipCheck?.customer?.addresses?.edges ?? []).map((e: any) => e.node?.id);
        if (!ownedAddresses.includes(payload.addressId)) {
          return new Response(
            JSON.stringify({ error: "Forbidden: Address does not belong to authenticated customer" }),
            { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }

        const updateData = await runShopifyAdminGraphQL(
          `mutation UpdateCustomerAddress($id: ID!, $customerId: ID!, $address: MailingAddressInput!) {
            customerAddressUpdate(id: $id, customerId: $customerId, address: $address) {
              customerAddress {
                id
                address1
                address2
                city
                province
                zip
                country
                phone
              }
              userErrors {
                field
                message
              }
            }
          }`,
          {
            id: payload.addressId,
            customerId: shopifyCustomerId,
            address: {
              firstName: payload.address.firstName,
              lastName: payload.address.lastName,
              company: payload.address.company,
              address1: payload.address.address1,
              address2: payload.address.address2,
              city: payload.address.city,
              province: payload.address.province,
              zip: payload.address.zip,
              country: payload.address.country ?? "India",
              phone: payload.address.phone,
            },
          }
        );

        const updateResult = updateData?.customerAddressUpdate;
        if (updateResult?.userErrors && updateResult.userErrors.length > 0) {
          return new Response(
            JSON.stringify({
              status: "ERROR",
              error: updateResult.userErrors.map((e: any) => e.message).join(", "),
            }),
            { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }

        return new Response(
          JSON.stringify({
            status: "SUCCESS",
            address: updateResult?.customerAddress,
          }),
          { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      case "DELETE_ADDRESS": {
        if (!payload.addressId) {
          return new Response(
            JSON.stringify({ error: "Missing addressId" }),
            { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }

        // Verify address ownership
        const ownershipCheck = await runShopifyAdminGraphQL(
          `query VerifyAddressOwnership($customerId: ID!) {
            customer(id: $customerId) {
              addresses(first: 20) {
                edges {
                  node {
                    id
                  }
                }
              }
            }
          }`,
          { customerId: shopifyCustomerId }
        );

        const ownedAddresses = (ownershipCheck?.customer?.addresses?.edges ?? []).map((e: any) => e.node?.id);
        if (!ownedAddresses.includes(payload.addressId)) {
          return new Response(
            JSON.stringify({ error: "Forbidden: Address does not belong to authenticated customer" }),
            { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }

        const deleteData = await runShopifyAdminGraphQL(
          `mutation DeleteCustomerAddress($id: ID!, $customerId: ID!) {
            customerAddressDelete(id: $id, customerId: $customerId) {
              deletedCustomerAddressId
              userErrors {
                field
                message
              }
            }
          }`,
          {
            id: payload.addressId,
            customerId: shopifyCustomerId,
          }
        );

        const deleteResult = deleteData?.customerAddressDelete;
        if (deleteResult?.userErrors && deleteResult.userErrors.length > 0) {
          return new Response(
            JSON.stringify({
              status: "ERROR",
              error: deleteResult.userErrors.map((e: any) => e.message).join(", "),
            }),
            { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }

        return new Response(
          JSON.stringify({
            status: "SUCCESS",
            deletedId: deleteResult?.deletedCustomerAddressId,
          }),
          { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      case "SET_DEFAULT_ADDRESS": {
        if (!payload.addressId) {
          return new Response(
            JSON.stringify({ error: "Missing addressId" }),
            { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }

        // Verify address ownership
        const ownershipCheck = await runShopifyAdminGraphQL(
          `query VerifyAddressOwnership($customerId: ID!) {
            customer(id: $customerId) {
              addresses(first: 20) {
                edges {
                  node {
                    id
                  }
                }
              }
            }
          }`,
          { customerId: shopifyCustomerId }
        );

        const ownedAddresses = (ownershipCheck?.customer?.addresses?.edges ?? []).map((e: any) => e.node?.id);
        if (!ownedAddresses.includes(payload.addressId)) {
          return new Response(
            JSON.stringify({ error: "Forbidden: Address does not belong to authenticated customer" }),
            { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }

        const defaultData = await runShopifyAdminGraphQL(
          `mutation SetDefaultCustomerAddress($customerId: ID!, $addressId: ID!) {
            customerDefaultAddressUpdate(customerId: $customerId, addressId: $addressId) {
              customer {
                id
                defaultAddress {
                  id
                  address1
                  address2
                  city
                  province
                  zip
                  country
                  phone
                }
              }
              userErrors {
                field
                message
              }
            }
          }`,
          {
            customerId: shopifyCustomerId,
            addressId: payload.addressId,
          }
        );

        const defaultResult = defaultData?.customerDefaultAddressUpdate;
        if (defaultResult?.userErrors && defaultResult.userErrors.length > 0) {
          return new Response(
            JSON.stringify({
              status: "ERROR",
              error: defaultResult.userErrors.map((e: any) => e.message).join(", "),
            }),
            { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
          );
        }

        return new Response(
          JSON.stringify({
            status: "SUCCESS",
            defaultAddress: defaultResult?.customer?.defaultAddress,
          }),
          { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      default:
        return new Response(
          JSON.stringify({ error: `Unknown action: ${payload.action}` }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
    }
  } catch (err: any) {
    console.error("[NUVI-EDGE] Unhandled error in shopify-customer-sync function:", err);
    return new Response(
      JSON.stringify({ error: err.message ?? "Internal Server Error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
