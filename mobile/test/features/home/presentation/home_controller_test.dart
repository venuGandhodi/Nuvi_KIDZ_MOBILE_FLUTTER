import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/home/data/home_repository.dart';
import 'package:nuvi_kidz/features/home/domain/age_filter.dart';
import 'package:nuvi_kidz/features/home/domain/category.dart';
import 'package:nuvi_kidz/features/home/domain/product.dart';
import 'package:nuvi_kidz/features/home/presentation/home_controller.dart';

class FakeHomeRepository implements HomeRepository {
  @override
  Future<List<Category>> getCategories() async => [
    const Category(id: 'cat_1', name: 'Girls'),
  ];

  @override
  Future<List<AgeFilter>> getAgeFilters() async => [
    const AgeFilter(id: 'age_1', label: '0-3m'),
  ];

  @override
  Future<List<Product>> getBestSellers() async => [
    const Product(id: 'prod_1', title: 'Test Product', price: '\$10.00'),
  ];
}

void main() {
  group('HomeController', () {
    test('initial state loads home data and state transitions work', () async {
      final container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(FakeHomeRepository()),
        ],
      );
      addTearDown(container.dispose);

      // Trigger build and wait for async data load
      container.read(homeControllerProvider);
      await Future.delayed(Duration.zero);

      final state = container.read(homeControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.categories.length, 1);
      expect(state.bestSellers.length, 1);

      // Test selectAgeFilter
      container.read(homeControllerProvider.notifier).selectAgeFilter('age_1');
      expect(
        container.read(homeControllerProvider).selectedAgeFilterId,
        'age_1',
      );

      // Test toggleFavorite
      container.read(homeControllerProvider.notifier).toggleFavorite('prod_1');
      expect(
        container
            .read(homeControllerProvider)
            .favoriteProductIds
            .contains('prod_1'),
        isTrue,
      );

      // Test setBottomNavIndex
      container.read(homeControllerProvider.notifier).setBottomNavIndex(3);
      expect(container.read(homeControllerProvider).currentBottomNavIndex, 3);
    });
  });
}
