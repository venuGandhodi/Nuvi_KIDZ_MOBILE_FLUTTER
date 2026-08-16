import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/coupon_repository.dart';
import '../domain/coupon.dart';

final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  return MockCouponRepository();
});

final activeCouponsProvider = FutureProvider<List<Coupon>>((ref) {
  return ref.read(couponRepositoryProvider).getActiveCoupons();
});
