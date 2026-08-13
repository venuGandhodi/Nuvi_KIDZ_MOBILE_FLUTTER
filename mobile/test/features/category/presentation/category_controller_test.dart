import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/category/domain/category_filter.dart';
import 'package:nuvi_kidz/features/category/presentation/category_controller.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('CategoryController Tests', () {
    test('initial state has loading true', () {
      final state = container.read(categoryControllerProvider);
      expect(state.isLoading, isTrue);
    });

    test('loadCategory populates products and detail', () async {
      final controller = container.read(categoryControllerProvider.notifier);
      await controller.loadCategory('toddler');
      final state = container.read(categoryControllerProvider);

      expect(state.isLoading, isFalse);
      expect(state.categoryDetail?.title, equals('Toddler Collection'));
      expect(state.products.length, greaterThan(0));
    });

    test('toggleFavorite adds and removes product ID', () {
      final controller = container.read(categoryControllerProvider.notifier);
      controller.toggleFavorite('prod_1');
      var state = container.read(categoryControllerProvider);
      expect(state.favoriteProductIds.contains('prod_1'), isTrue);

      controller.toggleFavorite('prod_1');
      state = container.read(categoryControllerProvider);
      expect(state.favoriteProductIds.contains('prod_1'), isFalse);
    });

    test('applySort updates sort option and reloads products', () async {
      final controller = container.read(categoryControllerProvider.notifier);
      await controller.loadCategory('toddler');
      await controller.applySort(SortOption.rating);

      final state = container.read(categoryControllerProvider);
      expect(state.sortOption, equals(SortOption.rating));
      expect(state.products.first.rating, equals(5.0));
    });
  });
}
