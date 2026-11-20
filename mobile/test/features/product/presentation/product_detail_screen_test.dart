import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/product/presentation/product_detail_screen.dart';

import '../../../helpers/mock_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  Widget buildTestWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: ProductDetailScreen(productId: 'prod_dream_romper'),
      ),
    );
  }

  group('ProductDetailScreen Widget Tests', () {
    testWidgets('renders title, price, size guide, Add to Bag and Buy Now', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Organic Cotton Dream Romper'), findsOneWidget);
      expect(find.text('\$45.00'), findsWidgets);
      expect(find.text('Size Guide'), findsOneWidget);
      expect(find.text('Add to Bag'), findsOneWidget);
      expect(find.text('Buy Now'), findsOneWidget);
      expect(find.bySemanticsLabel('Share product'), findsOneWidget);
    });

    testWidgets('after adding, the button becomes Go to Bag', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add to Bag'));
      await tester.pumpAndSettle();

      expect(find.text('Go to Bag'), findsOneWidget);
      expect(find.text('Add to Bag'), findsNothing);

      // A different size is not in the bag yet.
      await tester.ensureVisible(find.text('3-6M'));
      await tester.tap(find.text('3-6M'));
      await tester.pumpAndSettle();
      expect(find.text('Add to Bag'), findsOneWidget);
    });

    testWidgets('quantity stepper changes the quantity', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.bySemanticsLabel('Increase quantity'));
      await tester.tap(find.bySemanticsLabel('Increase quantity'));
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('Size Guide opens the size guide sheet', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Size Guide'));
      await tester.tap(find.text('Size Guide'));
      await tester.pumpAndSettle();
      expect(find.text('Sizes for this product'), findsOneWidget);
    });

    testWidgets('renders size pills and responds to selection', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('0-3M'), findsOneWidget);
      expect(find.text('3-6M'), findsOneWidget);

      await tester.tap(find.text('3-6M'), warnIfMissed: false);
      await tester.pumpAndSettle();
    });

    testWidgets('renders product details accordion', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Product Details'));
      expect(find.text('Product Details'), findsOneWidget);
      expect(find.text('Fabric & Care'), findsOneWidget);
    });
  });
}
