import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/checkout/presentation/order_confirmation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/mock_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestWidget({String? orderId}) {
    return ProviderScope(
      child: MaterialApp(home: OrderConfirmationScreen(orderId: orderId)),
    );
  }

  group('OrderConfirmationScreen Tests', () {
    testWidgets(
      'displays clean order number when given full Shopify GraphQL Order GID',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(orderId: 'gid://shopify/Order/6104829104'),
        );
        await tester.pumpAndSettle();

        expect(find.text('Order Confirmed!'), findsOneWidget);
        expect(find.text('Order #6104829104'), findsOneWidget);
        expect(find.text('VIEW MY ORDERS'), findsOneWidget);
        expect(find.text('CONTINUE SHOPPING'), findsOneWidget);
        expect(
          find.text('Thank you for shopping with Nuvi Kidz!'),
          findsOneWidget,
        );
      },
    );

    testWidgets('displays clean order number when given numerical string', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(orderId: '9876543210'));
      await tester.pumpAndSettle();

      expect(find.text('Order #9876543210'), findsOneWidget);
    });

    testWidgets(
      'displays fallback Confirmed badge when orderId is null or empty',
      (tester) async {
        await tester.pumpWidget(buildTestWidget(orderId: null));
        await tester.pumpAndSettle();

        expect(find.text('Order #Confirmed'), findsOneWidget);
      },
    );
  });
}
