import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/auth/data/auth_repository.dart';
import 'package:nuvi_kidz/features/auth/presentation/auth_controller.dart';
import 'package:nuvi_kidz/features/cart/data/shopify_cart_storage.dart';
import 'package:nuvi_kidz/features/cart/presentation/cart_controller.dart';
import 'package:nuvi_kidz/features/customer/presentation/customer_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthRepo extends AuthRepository {
  bool signedOut = false;

  MockAuthRepo() : super();

  @override
  Future<void> signOut() async {
    signedOut = true;
  }
}

class TestCartStorage extends ShopifyCartStorage {
  String? cartId = 'cart_id_active';

  @override
  Future<String?> getCartId() async => cartId;

  @override
  Future<void> clearCartId() async {
    cartId = null;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Logout Integration Flow Tests', () {
    test(
      'signOut clears customer controller state, clears cart, and signs out of auth',
      () async {
        final mockAuth = MockAuthRepo();
        final testCartStorage = TestCartStorage();

        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuth),
            shopifyCartStorageProvider.overrideWithValue(testCartStorage),
          ],
        );

        final authController = container.read(authControllerProvider.notifier);
        await authController.signOut();

        expect(mockAuth.signedOut, isTrue);
        expect(testCartStorage.cartId, isNull);

        final customerState = container.read(customerControllerProvider);
        expect(customerState.isAuthenticated, isFalse);
        expect(customerState.customer, isNull);

        final cartState = container.read(cartControllerProvider);
        expect(cartState.items, isEmpty);
      },
    );
  });
}
