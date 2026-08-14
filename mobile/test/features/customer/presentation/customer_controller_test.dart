import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/customer/data/shopify_customer_repository.dart';
import 'package:nuvi_kidz/features/customer/domain/shopify_customer.dart';
import 'package:nuvi_kidz/features/customer/presentation/customer_controller.dart';
import 'package:nuvi_kidz/features/order/domain/shopify_order.dart';

class FakeCustomerRepository extends ShopifyCustomerRepository {
  CustomerSyncResult mockProfileResult = const CustomerSyncResult(
    status: CustomerSyncStatus.unauthenticated,
  );
  CustomerOrdersResult mockOrdersResult = const CustomerOrdersResult(
    status: CustomerSyncStatus.unauthenticated,
  );

  @override
  Future<CustomerSyncResult> getCustomerProfile() async => mockProfileResult;

  @override
  Future<CustomerOrdersResult> getCustomerOrders({
    int first = 20,
    String? after,
  }) async => mockOrdersResult;

  @override
  Future<ShopifyAddress> createAddress(Map<String, dynamic> addressData) async {
    return const ShopifyAddress(
      id: 'gid://shopify/MailingAddress/1',
      address1: '123 Test St',
      city: 'Hyderabad',
    );
  }

  @override
  Future<ShopifyAddress> updateAddress(
    String addressId,
    Map<String, dynamic> addressData,
  ) async {
    return const ShopifyAddress(
      id: 'gid://shopify/MailingAddress/1',
      address1: '456 Updated St',
      city: 'Hyderabad',
    );
  }

  @override
  Future<void> deleteAddress(String addressId) async {}

  @override
  Future<ShopifyAddress?> setDefaultAddress(String addressId) async {
    return const ShopifyAddress(
      id: 'gid://shopify/MailingAddress/1',
      address1: '123 Test St',
      city: 'Hyderabad',
    );
  }
}

void main() {
  group('CustomerController Tests', () {
    test(
      'initial load with unauthenticated session sets unauthenticated state',
      () async {
        final fakeRepo = FakeCustomerRepository();
        fakeRepo.mockProfileResult = const CustomerSyncResult(
          status: CustomerSyncStatus.unauthenticated,
        );

        final container = ProviderContainer(
          overrides: [
            shopifyCustomerRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        );

        final controller = container.read(customerControllerProvider.notifier);
        await controller.loadCustomer();

        final state = container.read(customerControllerProvider);
        expect(state.isLoading, isFalse);
        expect(state.isAuthenticated, isFalse);
        expect(state.syncStatus, CustomerSyncStatus.unauthenticated);
        expect(state.customer, isNull);
      },
    );

    test(
      'loadCustomer when linked populates customer profile and orders',
      () async {
        final fakeRepo = FakeCustomerRepository();
        fakeRepo.mockProfileResult = const CustomerSyncResult(
          status: CustomerSyncStatus.linked,
          customer: ShopifyCustomer(
            id: 'gid://shopify/Customer/123',
            firstName: 'Mokshith',
            lastName: 'Parent',
            displayName: 'Mokshith Parent',
            email: 'parent@nuvikidz.com',
            ordersCount: 1,
          ),
        );
        fakeRepo.mockOrdersResult = CustomerOrdersResult(
          status: CustomerSyncStatus.linked,
          orders: [
            ShopifyOrder(
              id: 'gid://shopify/Order/777',
              name: '#777',
              orderNumber: 777,
              processedAt: DateTime(2026, 8, 14),
              currentTotalPrice: const ShopifyOrderMoney(
                amount: 1499.0,
                currencyCode: 'INR',
              ),
            ),
          ],
          hasNextPage: false,
        );

        final container = ProviderContainer(
          overrides: [
            shopifyCustomerRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        );

        final controller = container.read(customerControllerProvider.notifier);
        await controller.loadCustomer();

        final state = container.read(customerControllerProvider);
        expect(state.isLoading, isFalse);
        expect(state.isAuthenticated, isTrue);
        expect(state.syncStatus, CustomerSyncStatus.linked);
        expect(state.customer?.fullName, 'Mokshith Parent');
        expect(state.orders.length, 1);
        expect(state.orders.first.name, '#777');

        // Test getOrderById
        final order = controller.getOrderById('777');
        expect(order, isNotNull);
        expect(order!.name, '#777');
      },
    );

    test(
      'loadCustomer when notLinked sets notLinked status and keeps user authenticated',
      () async {
        final fakeRepo = FakeCustomerRepository();
        fakeRepo.mockProfileResult = const CustomerSyncResult(
          status: CustomerSyncStatus.notLinked,
          message: 'No existing Shopify customer found.',
        );

        final container = ProviderContainer(
          overrides: [
            shopifyCustomerRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        );

        final controller = container.read(customerControllerProvider.notifier);
        await controller.loadCustomer();

        final state = container.read(customerControllerProvider);
        expect(state.isLoading, isFalse);
        expect(state.isAuthenticated, isTrue);
        expect(state.syncStatus, CustomerSyncStatus.notLinked);
        expect(state.customer, isNull);
      },
    );

    test('clear resets state to unauthenticated', () async {
      final fakeRepo = FakeCustomerRepository();
      fakeRepo.mockProfileResult = const CustomerSyncResult(
        status: CustomerSyncStatus.linked,
        customer: ShopifyCustomer(id: '1', email: 'test@example.com'),
      );

      final container = ProviderContainer(
        overrides: [
          shopifyCustomerRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );

      final controller = container.read(customerControllerProvider.notifier);
      await controller.loadCustomer();

      expect(
        container.read(customerControllerProvider).isAuthenticated,
        isTrue,
      );

      controller.clear();

      final state = container.read(customerControllerProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.syncStatus, CustomerSyncStatus.unauthenticated);
      expect(state.customer, isNull);
    });

    test(
      'createAddress calls repository and refreshes customer profile',
      () async {
        final fakeRepo = FakeCustomerRepository();
        fakeRepo.mockProfileResult = const CustomerSyncResult(
          status: CustomerSyncStatus.linked,
          customer: ShopifyCustomer(
            id: 'gid://shopify/Customer/100',
            email: 'test@example.com',
          ),
        );

        final container = ProviderContainer(
          overrides: [
            shopifyCustomerRepositoryProvider.overrideWithValue(fakeRepo),
          ],
        );

        final controller = container.read(customerControllerProvider.notifier);
        final success = await controller.createAddress({
          'address1': '123 Test St',
        });

        expect(success, isTrue);
        expect(
          container.read(customerControllerProvider).customer?.id,
          'gid://shopify/Customer/100',
        );
      },
    );

    test('updateAddress calls repository and refreshes state', () async {
      final fakeRepo = FakeCustomerRepository();
      fakeRepo.mockProfileResult = const CustomerSyncResult(
        status: CustomerSyncStatus.linked,
        customer: ShopifyCustomer(
          id: 'gid://shopify/Customer/100',
          email: 'test@example.com',
        ),
      );

      final container = ProviderContainer(
        overrides: [
          shopifyCustomerRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );

      final controller = container.read(customerControllerProvider.notifier);
      final success = await controller.updateAddress(
        'gid://shopify/MailingAddress/1',
        {'address1': '456 Updated St'},
      );

      expect(success, isTrue);
    });

    test('deleteAddress calls repository and refreshes state', () async {
      final fakeRepo = FakeCustomerRepository();
      fakeRepo.mockProfileResult = const CustomerSyncResult(
        status: CustomerSyncStatus.linked,
        customer: ShopifyCustomer(
          id: 'gid://shopify/Customer/100',
          email: 'test@example.com',
        ),
      );

      final container = ProviderContainer(
        overrides: [
          shopifyCustomerRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );

      final controller = container.read(customerControllerProvider.notifier);
      final success = await controller.deleteAddress(
        'gid://shopify/MailingAddress/1',
      );

      expect(success, isTrue);
    });

    test('setDefaultAddress calls repository and refreshes state', () async {
      final fakeRepo = FakeCustomerRepository();
      fakeRepo.mockProfileResult = const CustomerSyncResult(
        status: CustomerSyncStatus.linked,
        customer: ShopifyCustomer(
          id: 'gid://shopify/Customer/100',
          email: 'test@example.com',
        ),
      );

      final container = ProviderContainer(
        overrides: [
          shopifyCustomerRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );

      final controller = container.read(customerControllerProvider.notifier);
      final success = await controller.setDefaultAddress(
        'gid://shopify/MailingAddress/1',
      );

      expect(success, isTrue);
    });
  });
}
