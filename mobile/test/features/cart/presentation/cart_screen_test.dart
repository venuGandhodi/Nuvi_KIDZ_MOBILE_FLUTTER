import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/cart/data/cart_repository.dart';
import 'package:nuvi_kidz/features/cart/data/mock_cart_data.dart';
import 'package:nuvi_kidz/features/cart/presentation/cart_controller.dart';
import 'package:nuvi_kidz/features/cart/presentation/cart_screen.dart';

import '../../../helpers/mock_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  Widget buildTestWidget({dynamic overrides}) {
    return ProviderScope(
      overrides: overrides ?? const [],
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
        final populatedRepo = MockCartRepository(
          initialItems: MockCartData.sampleCartItems,
        );

        await tester.pumpWidget(
          buildTestWidget(
            overrides: [
              cartRepositoryProvider.overrideWithValue(populatedRepo),
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
  });
}
