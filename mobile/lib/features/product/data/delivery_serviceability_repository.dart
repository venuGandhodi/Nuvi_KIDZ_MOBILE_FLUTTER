import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/delivery_serviceability.dart';

abstract class DeliveryServiceabilityRepository {
  Future<DeliveryServiceabilityResult> checkPincode(String pincode);
}

// Calls the delhivery-serviceability Supabase Edge Function, which is the
// only thing that ever talks to Delhivery. This app never holds a Delhivery
// token or calls Delhivery directly.
class SupabaseDeliveryServiceabilityRepository
    implements DeliveryServiceabilityRepository {
  final SupabaseClient? _supabase;

  SupabaseDeliveryServiceabilityRepository([this._supabase]);

  SupabaseClient? get _client {
    if (_supabase != null) return _supabase;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<DeliveryServiceabilityResult> checkPincode(String pincode) async {
    final client = _client;
    if (client == null) {
      throw const DeliveryCheckException(
        DeliveryCheckFailureReason.unavailable,
      );
    }

    try {
      final response = await client.functions.invoke(
        'delhivery-serviceability',
        body: {'pincode': pincode},
      );

      final data = response.data;
      if (response.status == 200 && data is Map) {
        return DeliveryServiceabilityResult.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      if (response.status == 400) {
        throw const DeliveryCheckException(
          DeliveryCheckFailureReason.invalidPincode,
        );
      }

      throw const DeliveryCheckException(
        DeliveryCheckFailureReason.unavailable,
      );
    } on DeliveryCheckException {
      rethrow;
    } catch (_) {
      throw const DeliveryCheckException(
        DeliveryCheckFailureReason.unavailable,
      );
    }
  }
}
