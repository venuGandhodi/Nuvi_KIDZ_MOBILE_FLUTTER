import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/cart/data/shopify_cart_storage.dart';
import 'package:nuvi_kidz/features/cart/presentation/cart_controller.dart';
import 'package:nuvi_kidz/features/customer/domain/shopify_customer.dart';
import 'package:nuvi_kidz/features/customer/presentation/customer_controller.dart';
import 'package:nuvi_kidz/features/customer/presentation/order_details_screen.dart';
import 'package:nuvi_kidz/features/order/domain/shopify_order.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/mock_http_overrides.dart';

class FakeCartStorageForOrderDetails extends ShopifyCartStorage {
  @override
  Future<String?> getCartId() async => null;
}

class OrderDetailsCustomerController extends CustomerController {
  @override
  CustomerState build() {
    final testOrder = ShopifyOrder(
      id: 'ord_999',
      name: '#999',
      orderNumber: 999,
      processedAt: DateTime(2026, 8, 14, 15, 30),
      financialStatus: 'PAID',
      fulfillmentStatus: 'UNFULFILLED',
      currentTotalPrice: const ShopifyOrderMoney(
        amount: 2499.0,
        currencyCode: 'INR',
      ),
      currentTotalTax: const ShopifyOrderMoney(
        amount: 249.90,
        currencyCode: 'INR',
      ),
      totalShippingPrice: const ShopifyOrderMoney(
        amount: 0.0,
        currencyCode: 'INR',
      ),
      lineItems: const [
        ShopifyOrderLineItem(
          id: 'line_1',
          title: 'Nuvi Dream Romper',
          variantTitle: 'Sky Blue / 6-12M',
          quantity: 2,
          originalTotalPrice: ShopifyOrderMoney(
            amount: 2499.0,
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

  Widget buildTestWidget({required String orderId}) {
    return ProviderScope(
      overrides: [
        shopifyCartStorageProvider.overrideWithValue(
          FakeCartStorageForOrderDetails(),
        ),
        customerControllerProvider.overrideWith(
          () => OrderDetailsCustomerController(),
        ),
      ],
      child: MaterialApp(home: OrderDetailsScreen(orderId: orderId)),
    );
  }

  group('OrderDetailsScreen Widget Tests', () {
    testWidgets('renders full order details with line items and summary', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(orderId: '999'));
      await tester.pumpAndSettle();

      expect(find.text('#999'), findsOneWidget);
      expect(find.text('Items in this Order (1)'), findsOneWidget);
      expect(find.text('Nuvi Dream Romper'), findsOneWidget);
      expect(find.text('Sky Blue / 6-12M'), findsOneWidget);
      expect(find.text('Qty: 2'), findsOneWidget);
      expect(find.text('Payment Summary'), findsOneWidget);
      expect(find.text('BACK TO MY ORDERS'), findsOneWidget);
    });

    testWidgets('renders Order Not Found when id does not match', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(orderId: 'non_existent_id'));
      await tester.pumpAndSettle();

      expect(find.text('Order Not Found'), findsOneWidget);
      expect(find.text('VIEW ALL ORDERS'), findsOneWidget);
    });
  });
}
