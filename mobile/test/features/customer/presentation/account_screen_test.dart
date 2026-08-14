import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/cart/data/shopify_cart_storage.dart';
import 'package:nuvi_kidz/features/cart/presentation/cart_controller.dart';
import 'package:nuvi_kidz/features/customer/domain/shopify_customer.dart';
import 'package:nuvi_kidz/features/customer/presentation/account_screen.dart';
import 'package:nuvi_kidz/features/customer/presentation/customer_controller.dart';
import 'package:nuvi_kidz/features/order/domain/shopify_order.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/mock_http_overrides.dart';

class FakeCartStorage extends ShopifyCartStorage {
  @override
  Future<String?> getCartId() async => null;
}

class PopulatedCustomerController extends CustomerController {
  @override
  CustomerState build() {
    final testOrder = ShopifyOrder(
      id: 'ord_1',
      name: '#1001',
      orderNumber: 1001,
      processedAt: DateTime(2026, 8, 14),
      currentTotalPrice: const ShopifyOrderMoney(
        amount: 1999.0,
        currencyCode: 'INR',
      ),
    );

    return CustomerState(
      customer: ShopifyCustomer(
        id: '1',
        firstName: 'Sarah',
        lastName: 'Connor',
        displayName: 'Sarah Connor',
        email: 'sarah@example.com',
        orders: [testOrder],
        ordersCount: 1,
      ),
      orders: [testOrder],
      isAuthenticated: true,
      isLoading: false,
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
        shopifyCartStorageProvider.overrideWithValue(FakeCartStorage()),
        ...?overrides,
      ],
      child: const MaterialApp(home: AccountScreen()),
    );
  }

  group('AccountScreen Widget Tests', () {
    testWidgets('renders customer profile information and action items', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [
            customerControllerProvider.overrideWith(
              () => PopulatedCustomerController(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sarah Connor'), findsOneWidget);
      expect(find.text('sarah@example.com'), findsOneWidget);
      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('Saved Addresses'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('LOG OUT'), findsOneWidget);
    });
  });
}
