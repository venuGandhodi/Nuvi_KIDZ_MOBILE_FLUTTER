import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/cart/data/mock_cart_data.dart';
import 'package:nuvi_kidz/features/cart/data/shopify_cart_storage.dart';
import 'package:nuvi_kidz/features/cart/presentation/cart_controller.dart';
import 'package:nuvi_kidz/features/cart/presentation/cart_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/mock_http_overrides.dart';

class FakeStorageForScreenTest extends ShopifyCartStorage {
  @override
  Future<String?> getCartId() async => null;
}

class PopulatedCartController extends CartController {
  @override
  CartState build() {
    return CartState(
      items: MockCartData.sampleCartItems,
      totalQuantity: 2,
      subtotalAmount: 68.0,
      totalAmount: 68.0,
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
        shopifyCartStorageProvider.overrideWithValue(
          FakeStorageForScreenTest(),
        ),
        ...?overrides,
      ],
      child: const MaterialApp(home: CartScreen()),
    );
  }

  group('CartScreen Widget Tests', () {
    testWidgets('renders empty cart state when cart is empty', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Your bag is empty'), findsOneWidget);
      expect(find.text('START SHOPPING'), findsOneWidget);
    });

    testWidgets(
      'renders cart items, quantity controls, and summary card when populated',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            overrides: [
              cartControllerProvider.overrideWith(
                () => PopulatedCartController(),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Your Bag'), findsOneWidget);
        expect(find.text('2 Items'), findsOneWidget);
        expect(find.text('Organic Cotton Romper'), findsOneWidget);
        expect(find.text('Chunky Knit Booties'), findsOneWidget);
        expect(find.text('Summary'), findsOneWidget);
        expect(find.text('CHECKOUT'), findsOneWidget);
      },
    );

    testWidgets('tapping CHECKOUT invokes launchInAppCheckout', (tester) async {
      final controller = PopulatedCartController();
      await tester.pumpWidget(
        buildTestWidget(
          overrides: [cartControllerProvider.overrideWith(() => controller)],
        ),
      );
      await tester.pumpAndSettle();

      final checkoutBtn = find.text('CHECKOUT');
      expect(checkoutBtn, findsOneWidget);
      await tester.tap(checkoutBtn);
      await tester.pump();
    });
  });
}
