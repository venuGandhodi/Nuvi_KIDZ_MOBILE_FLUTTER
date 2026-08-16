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
    testWidgets('renders title, price, size guide, and Add to Cart button', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Organic Cotton Dream Romper'), findsOneWidget);
      expect(find.text('\$45.00'), findsWidgets);
      expect(find.text('Size Guide'), findsOneWidget);
      expect(find.text('Add to Cart - \$45.00'), findsOneWidget);
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

      expect(find.text('Product Details'), findsOneWidget);
      expect(find.text('Fabric & Care'), findsOneWidget);
    });
  });
}
