import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/checkout/presentation/checkout_screen.dart';
import 'package:nuvi_kidz/features/checkout/presentation/order_confirmation_screen.dart';

import '../../../helpers/mock_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  group('Checkout & Order Confirmation Widget Tests', () {
    testWidgets('renders Checkout screen headings, form fields, and summary', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: CheckoutScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Checkout'), findsOneWidget);
      expect(find.text('Delivery Details'), findsOneWidget);
      expect(find.text('Shipping Method'), findsOneWidget);
      expect(find.text('Payment'), findsOneWidget);
      expect(find.text('Summary'), findsOneWidget);
      expect(find.text('Place Order'), findsOneWidget);
    });

    testWidgets('renders OrderConfirmationScreen with confirmation card', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: OrderConfirmationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Order Confirmed!'), findsOneWidget);
      expect(find.text('CONTINUE SHOPPING'), findsOneWidget);
    });
  });
}
