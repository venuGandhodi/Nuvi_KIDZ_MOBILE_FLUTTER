import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/category/presentation/category_listing_screen.dart';

import '../../../helpers/mock_http_overrides.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  Widget buildTestWidget() {
    return const ProviderScope(
      child: MaterialApp(home: CategoryListingScreen(categoryId: 'toddler')),
    );
  }

  group('CategoryListingScreen Widget Tests', () {
    testWidgets('renders category header, filter button, and sort button', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Toddler Collection'), findsOneWidget);
      expect(find.text('Filter'), findsOneWidget);
      expect(find.text('Sort'), findsOneWidget);
    });

    testWidgets('renders product cards in 2-column grid', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Starry Mustard Dress'), findsOneWidget);
      expect(find.text('Forest Knit Cardigan'), findsOneWidget);
    });

    testWidgets('opens filter bottom sheet on tap', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      expect(find.text('Filter Products'), findsOneWidget);
      expect(find.text('Apply Filters'), findsOneWidget);
    });

    testWidgets('opens sort bottom sheet on tap', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();

      expect(find.text('Sort By'), findsOneWidget);
      expect(find.text('Highest Rated'), findsOneWidget);
    });
  });
}
