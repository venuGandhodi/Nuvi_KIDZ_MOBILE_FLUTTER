import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/customer/data/shopify_customer_repository.dart';
import 'package:nuvi_kidz/features/customer/presentation/customer_controller.dart';
import 'package:nuvi_kidz/features/customer/presentation/order_details_screen.dart';
import 'package:nuvi_kidz/features/order/domain/shopify_order.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/mock_http_overrides.dart';

class FakeOrderRepository extends ShopifyCustomerRepository {
  ShopifyOrder? mockOrder;
  int remoteFetchCount = 0;
  bool shouldThrow = false;

  @override
  Future<CustomerSyncResult> getCustomerProfile() async {
    return const CustomerSyncResult(status: CustomerSyncStatus.linked);
  }

  @override
  Future<ShopifyOrder?> getCustomerOrder(String orderId) async {
    remoteFetchCount++;
    if (shouldThrow) {
      throw Exception('Network error');
    }
    return mockOrder;
  }
}

class PopulatedCustomerController extends CustomerController {
  final List<ShopifyOrder> initialOrders;

  PopulatedCustomerController(this.initialOrders);

  @override
  CustomerState build() {
    return CustomerState(
      orders: initialOrders,
      isAuthenticated: true,
      syncStatus: CustomerSyncStatus.linked,
      isLoading: false,
    );
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
    SharedPreferences.setMockInitialValues({});
  });

  final sampleOrder = ShopifyOrder(
    id: 'gid://shopify/Order/6104829104',
    name: '#1001',
    orderNumber: 1001,
    processedAt: DateTime(2026, 4, 15, 10, 30),
    financialStatus: 'PAID',
    fulfillmentStatus: 'FULFILLED',
    currentTotalPrice: const ShopifyOrderMoney(
      amount: 1499.0,
      currencyCode: 'INR',
    ),
    lineItems: [
      const ShopifyOrderLineItem(
        id: 'gid://shopify/LineItem/1',
        title: 'Boys Denim Shorts',
        quantity: 1,
        variantTitle: '4-5Y / Blue',
        originalTotalPrice: ShopifyOrderMoney(
          amount: 1499.0,
          currencyCode: 'INR',
        ),
      ),
    ],
  );

  Widget buildTestWidget({
    required String orderId,
    required FakeOrderRepository repo,
    List<ShopifyOrder> localOrders = const [],
  }) {
    return ProviderScope(
      overrides: [
        shopifyCustomerRepositoryProvider.overrideWithValue(repo),
        customerControllerProvider.overrideWith(
          () => PopulatedCustomerController(localOrders),
        ),
      ],
      child: MaterialApp(home: OrderDetailsScreen(orderId: orderId)),
    );
  }

  group('OrderDetailsScreen Tests', () {
    testWidgets('renders immediately when order is cached in local orders', (
      tester,
    ) async {
      final repo = FakeOrderRepository();

      await tester.pumpWidget(
        buildTestWidget(
          orderId: '6104829104',
          repo: repo,
          localOrders: [sampleOrder],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('#1001'), findsOneWidget);
      expect(find.text('₹1499'), findsWidgets);
      expect(find.text('Payment: PAID'), findsOneWidget);
      expect(find.text('Status: FULFILLED'), findsOneWidget);
      expect(find.text('Boys Denim Shorts'), findsOneWidget);
      expect(repo.remoteFetchCount, 0);
    });

    testWidgets('fetches remotely when order is not found locally in cache', (
      tester,
    ) async {
      final repo = FakeOrderRepository()..mockOrder = sampleOrder;

      await tester.pumpWidget(
        buildTestWidget(orderId: '6104829104', repo: repo, localOrders: []),
      );

      // Initial pump triggers frame callback
      await tester.pump();
      await tester.pumpAndSettle();

      expect(repo.remoteFetchCount, 1);
      expect(find.text('#1001'), findsOneWidget);
      expect(find.text('Boys Denim Shorts'), findsOneWidget);
    });

    testWidgets(
      'displays error state with retry button when remote fetch fails',
      (tester) async {
        final repo = FakeOrderRepository()..mockOrder = null;

        await tester.pumpWidget(
          buildTestWidget(orderId: '9999999999', repo: repo, localOrders: []),
        );

        await tester.pump();
        await tester.pumpAndSettle();

        expect(repo.remoteFetchCount, 1);
        expect(find.text('Order Not Found'), findsOneWidget);
        expect(find.text('TRY AGAIN'), findsOneWidget);
        expect(find.text('VIEW ALL ORDERS'), findsOneWidget);

        // Tapping TRY AGAIN re-triggers remote fetch
        await tester.tap(find.text('TRY AGAIN'));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(repo.remoteFetchCount, 2);
      },
    );
  });
}
