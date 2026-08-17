import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/delivery_serviceability_repository.dart';

final deliveryServiceabilityRepositoryProvider =
    Provider<DeliveryServiceabilityRepository>((ref) {
      return SupabaseDeliveryServiceabilityRepository();
    });
