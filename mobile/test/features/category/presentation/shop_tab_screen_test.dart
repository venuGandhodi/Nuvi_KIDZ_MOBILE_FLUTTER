import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nuvi_kidz/features/category/data/category_repository.dart';
import 'package:nuvi_kidz/features/category/domain/menu_category.dart';
import 'package:nuvi_kidz/features/category/presentation/category_controller.dart';
import 'package:nuvi_kidz/features/category/presentation/shop_tab_screen.dart';

import '../../../helpers/mock_http_overrides.dart';

class _MenuRepo extends MockCategoryRepository {
  @override
  Future<List<MenuCategory>> getCategoryMenu({
    String handle = 'main-menu',
  }) async => const [
    MenuCategory(id: 'h', title: 'Home', collectionHandle: 'frontpage'),
    MenuCategory(
      id: 'g',
      title: 'Girls',
      collectionHandle: 'girls',
      items: [
        MenuCategory(id: 'g1', title: 'Dresses'),
        MenuCategory(id: 'g2', title: 'Tops'),
        MenuCategory(id: 'g3', title: 'Co-ords'),
        MenuCategory(id: 'g4', title: 'Skirts'),
      ],
    ),
    MenuCategory(id: 'b', title: 'Boys', collectionHandle: 'boys'),
  ];
}

void main() {
  setUpAll(() => HttpOverrides.global = TestHttpOverrides());

  testWidgets('lists main-menu categories and opens one on tap', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/shop',
      routes: [
        GoRoute(path: '/shop', builder: (_, _) => const ShopTabScreen()),
        GoRoute(
          path: '/category/:id',
          builder: (_, s) =>
              Scaffold(body: Text('Category ${s.pathParameters['id']}')),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [categoryRepositoryProvider.overrideWithValue(_MenuRepo())],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Girls'), findsOneWidget);
    expect(find.text('Dresses, Tops, Co-ords & more'), findsOneWidget);
    expect(find.text('Boys'), findsOneWidget);
    expect(find.text('Home'), findsNothing);

    await tester.tap(find.text('Girls'));
    await tester.pumpAndSettle();
    expect(find.text('Category girls'), findsOneWidget);
  });
}
