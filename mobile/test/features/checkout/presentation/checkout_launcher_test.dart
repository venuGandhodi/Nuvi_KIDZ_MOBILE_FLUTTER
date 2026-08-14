import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/checkout/presentation/checkout_launcher.dart';

void main() {
  group('ShopifyCheckoutLauncher Tests', () {
    test('isValidCheckoutUrl returns true for valid https URL', () {
      expect(
        ShopifyCheckoutLauncher.isValidCheckoutUrl(
          'https://muu1gj-t6.myshopify.com/cart/c/12345',
        ),
        isTrue,
      );
    });

    test('isValidCheckoutUrl returns true for valid http URL', () {
      expect(
        ShopifyCheckoutLauncher.isValidCheckoutUrl(
          'http://example.com/checkout',
        ),
        isTrue,
      );
    });

    test('isValidCheckoutUrl returns false for null or empty string', () {
      expect(ShopifyCheckoutLauncher.isValidCheckoutUrl(null), isFalse);
      expect(ShopifyCheckoutLauncher.isValidCheckoutUrl(''), isFalse);
      expect(ShopifyCheckoutLauncher.isValidCheckoutUrl('   '), isFalse);
    });

    test('isValidCheckoutUrl returns false for invalid schemes', () {
      expect(
        ShopifyCheckoutLauncher.isValidCheckoutUrl('invalid_url'),
        isFalse,
      );
      expect(
        ShopifyCheckoutLauncher.isValidCheckoutUrl('ftp://example.com'),
        isFalse,
      );
    });
  });
}
