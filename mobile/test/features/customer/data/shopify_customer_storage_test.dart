import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/customer/data/shopify_customer_storage.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('ShopifyCustomerStorage Tests', () {
    test('saveCustomerToken saves token and expiry', () async {
      final storage = ShopifyCustomerStorage();
      final expires = DateTime.now().add(const Duration(days: 14));

      await storage.saveCustomerToken('tok_test_123', expires);

      final token = await storage.getCustomerToken();
      final savedExpires = await storage.getTokenExpiresAt();
      final isExpired = await storage.isTokenExpired();

      expect(token, equals('tok_test_123'));
      expect(savedExpires?.year, equals(expires.year));
      expect(isExpired, isFalse);
    });

    test('isTokenExpired returns true for past dates', () async {
      final storage = ShopifyCustomerStorage();
      final pastDate = DateTime.now().subtract(const Duration(days: 1));

      await storage.saveCustomerToken('tok_old', pastDate);

      expect(await storage.isTokenExpired(), isTrue);
    });

    test('clearCustomerToken removes all token keys', () async {
      final storage = ShopifyCustomerStorage();
      await storage.saveCustomerToken(
        'tok_del',
        DateTime.now().add(const Duration(days: 5)),
      );

      await storage.clearCustomerToken();

      expect(await storage.getCustomerToken(), isNull);
      expect(await storage.getTokenExpiresAt(), isNull);
      expect(await storage.isTokenExpired(), isTrue);
    });
  });
}
