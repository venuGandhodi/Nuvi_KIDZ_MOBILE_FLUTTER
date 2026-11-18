import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/category/data/category_repository.dart';
import 'package:nuvi_kidz/features/category/domain/category_detail.dart';
import 'package:nuvi_kidz/features/category/domain/category_filter.dart';
import 'package:nuvi_kidz/features/category/domain/menu_category.dart';
import 'package:nuvi_kidz/features/category/presentation/category_controller.dart';
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
  Future<List<Category>> getCategories() async => [];

  @override
  Future<List<AgeFilter>> getAgeFilters() async => [
    const AgeFilter(
      id: 'a1',
      label: '0-3m',
      sortOrder: 1,
      collectionHandle: 'newborn-clothing',
    ),
    const AgeFilter(id: 'a2', label: '3-6m', sortOrder: 2),
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

class MockHomeRepoNoAgeFilters extends MockHomeRepo {
  @override
  Future<List<AgeFilter>> getAgeFilters() async => [];
}

class MockCategoryMenuRepo implements CategoryRepository {
  @override
  Future<List<MenuCategory>> getCategoryMenu({
    String handle = 'main-menu',
  }) async => [
    const MenuCategory(
      id: 'c1',
      title: 'Girls',
      collectionHandle: 'girls-clothing',
    ),
    const MenuCategory(
      id: 'c2',
      title: 'Boys',
      collectionHandle: 'boys-clothing',
      items: [
        MenuCategory(
          id: 'c2_1',
          title: 'Shirts',
          collectionHandle: 'boys-shirts',
        ),
        MenuCategory(
          id: 'c2_2',
          title: 'Polo Shirt',
          collectionHandle: 'polo-shirts',
        ),
      ],
    ),
  ];

  @override
  Future<CategoryDetail> getCategoryDetail(String categoryId) async =>
      const CategoryDetail(id: 'c', title: 'Category', description: '');

  @override
  Future<List<Product>> getCategoryProducts(
    String categoryId, {
    FilterState? filter,
    SortOption? sort,
  }) async => [];
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
        overrides: [
          homeRepositoryProvider.overrideWithValue(MockHomeRepo()),
          categoryRepositoryProvider.overrideWithValue(MockCategoryMenuRepo()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Initial pump & settle
    await tester.pumpAndSettle();

    // Verify sections render
    // The hero shows the Shopify image and CTA only, no overlaid text.
    expect(find.text('Autumn Adventures\nAwait'), findsNothing);
    expect(find.text('Shop the Collection'), findsOneWidget);
    // Category row is now populated from the Shopify menu (Content / Menus),
    // not the flat collection list.
    expect(find.text('Girls'), findsOneWidget);
    expect(find.text('Boys'), findsOneWidget);
    expect(find.text('Shop by age'), findsNothing);
    expect(find.text('Bestsellers'), findsOneWidget);
    expect(find.text('Forest Elephant Romper'), findsOneWidget);
  });

  testWidgets(
    'HomeScreen renders normally when Shopify returns no age categories',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeRepositoryProvider.overrideWithValue(
              MockHomeRepoNoAgeFilters(),
            ),
            categoryRepositoryProvider.overrideWithValue(
              MockCategoryMenuRepo(),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Shop by age'), findsNothing);
      // The rest of the screen still renders normally.
      expect(find.text('Shop the Collection'), findsOneWidget);
      expect(find.text('Bestsellers'), findsOneWidget);
    },
  );
}
