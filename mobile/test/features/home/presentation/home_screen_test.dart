import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/home/data/home_repository.dart';
import 'package:nuvi_kidz/features/home/domain/age_filter.dart';
import 'package:nuvi_kidz/features/home/domain/category.dart';
import 'package:nuvi_kidz/features/home/domain/home_hero.dart';
import 'package:nuvi_kidz/features/home/domain/product.dart';
import 'package:nuvi_kidz/features/home/presentation/home_controller.dart';
import 'package:nuvi_kidz/features/home/presentation/home_screen.dart';

import '../../../helpers/mock_http_overrides.dart';

class MockHomeRepo implements HomeRepository {
  @override
  Future<HomeHero?> getHero() async => const HomeHero(
    id: 'hero_1',
    title: 'Autumn Adventures\nAwait',
    description:
        'Discover our new collection of cozy, organic cotton essentials designed for little explorers.',
    buttonText: 'Shop the Collection',
    collectionHandle: 'toddler',
  );

  @override
  Future<List<Category>> getCategories() async => [
    const Category(id: 'c1', name: 'Girls', handle: 'girls-clothing'),
    const Category(id: 'c2', name: 'Boys', handle: 'boys-clothing'),
  ];

  @override
  Future<List<AgeFilter>> getAgeFilters() async => [
    const AgeFilter(id: 'a1', label: '0-3m'),
    const AgeFilter(id: 'a2', label: '3-6m'),
  ];

  @override
  Future<List<Product>> getBestSellers() async => [
    const Product(
      id: 'p1',
      title: 'Forest Elephant Romper',
      price: '₹799',
      rating: 4.5,
      badgeText: 'NEW',
    ),
  ];
}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  testWidgets('HomeScreen renders sections and handles tab selection', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [homeRepositoryProvider.overrideWithValue(MockHomeRepo())],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Initial pump & settle
    await tester.pumpAndSettle();

    // Verify sections render
    expect(find.text('Autumn Adventures\nAwait'), findsOneWidget);
    expect(find.text('Shop the Collection'), findsOneWidget);
    expect(find.text('Shop tiny styles'), findsOneWidget);
    expect(find.text('Shop by age'), findsOneWidget);
    expect(find.text('Bestsellers'), findsOneWidget);
    expect(find.text('Forest Elephant Romper'), findsOneWidget);

    // Verify Age filter tap
    final pill = find.text('0-3m');
    expect(pill, findsOneWidget);
    await tester.tap(pill, warnIfMissed: false);
    await tester.pumpAndSettle();
  });
}
