import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/cart/data/shopify_cart_storage.dart';
import 'package:nuvi_kidz/features/cart/presentation/cart_controller.dart';
import 'package:nuvi_kidz/features/customer/domain/shopify_customer.dart';
import 'package:nuvi_kidz/features/customer/presentation/customer_controller.dart';
import 'package:nuvi_kidz/features/customer/presentation/my_orders_screen.dart';
import 'package:nuvi_kidz/features/order/domain/shopify_order.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/mock_http_overrides.dart';

class FakeCartStorageForOrders extends ShopifyCartStorage {
  @override
  Future<String?> getCartId() async => null;
}

class EmptyCustomerController extends CustomerController {
  @override
  CustomerState build() {
    return const CustomerState(
      customer: ShopifyCustomer(
        id: '1',
        email: 'empty@example.com',
        orders: [],
      ),
      orders: [],
      isLoading: false,
      isAuthenticated: true,
    );
  }
}

class PopulatedCustomerOrdersController extends CustomerController {
  @override
  CustomerState build() {
    final testOrder = ShopifyOrder(
      id: 'gid://shopify/Order/1001',
      name: '#1001',
      orderNumber: 1001,
      processedAt: DateTime(2026, 8, 14),
      financialStatus: 'PAID',
      fulfillmentStatus: 'FULFILLED',
      currentTotalPrice: const ShopifyOrderMoney(
        amount: 1499.0,
        currencyCode: 'INR',
      ),
      lineItems: const [
        ShopifyOrderLineItem(
          id: '1',
          title: 'Nuvi Dream Romper',
          quantity: 1,
          originalTotalPrice: ShopifyOrderMoney(
            amount: 1499.0,
            currencyCode: 'INR',
          ),
        ),
      ],
    );

    return CustomerState(
      customer: ShopifyCustomer(
        id: '1',
        email: 'parent@example.com',
        orders: [testOrder],
        ordersCount: 1,
      ),
      orders: [testOrder],
      isLoading: false,
      isAuthenticated: true,
    );
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestWidget({List<dynamic>? overrides}) {
    return ProviderScope(
      overrides: [
        shopifyCartStorageProvider.overrideWithValue(
          FakeCartStorageForOrders(),
        ),
        ...?overrides,
      ],
      child: const MaterialApp(home: MyOrdersScreen()),
    );
  }

  group('MyOrdersScreen Widget Tests', () {
    testWidgets('renders empty state when there are no orders', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            customerControllerProvider.overrideWith(
              () => EmptyCustomerController(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No orders yet'), findsOneWidget);
      expect(find.text('START SHOPPING'), findsOneWidget);
    });

    testWidgets('renders orders list when customer has past orders', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            customerControllerProvider.overrideWith(
              () => PopulatedCustomerOrdersController(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Order History'), findsOneWidget);
      expect(find.text('#1001'), findsOneWidget);
      expect(find.text('₹1499'), findsOneWidget);
      expect(find.text('PAID'), findsOneWidget);
      expect(find.text('FULFILLED'), findsOneWidget);
    });
  });
}
