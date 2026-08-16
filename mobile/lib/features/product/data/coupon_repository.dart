import '../domain/coupon.dart';

abstract class CouponRepository {
  Future<List<Coupon>> getActiveCoupons();
}

// Shopify's Storefront API has no query for active discount codes — that data
// only exists via the Admin API, so this stays mock until a Supabase edge
// function action (like shopify-customer-sync) is added to fetch it.
class MockCouponRepository implements CouponRepository {
  @override
  Future<List<Coupon>> getActiveCoupons() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return const [
      Coupon(code: 'HS75', description: 'Flat ₹75 off on orders above ₹1399'),
      Coupon(code: 'WELCOME10', description: '10% off on your first order'),
      Coupon(
        code: 'FREESHIP',
        description: 'Free shipping on orders above ₹999',
      ),
    ];
  }
}
