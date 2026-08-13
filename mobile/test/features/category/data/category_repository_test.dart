import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/category/data/category_repository.dart';
import 'package:nuvi_kidz/features/category/domain/category_filter.dart';

void main() {
  late MockCategoryRepository repository;

  setUp(() {
    repository = MockCategoryRepository();
  });

  group('MockCategoryRepository Tests', () {
    test('getCategoryDetail returns valid category detail', () async {
      final detail = await repository.getCategoryDetail('toddler');
      expect(detail.id, equals('toddler'));
      expect(detail.title, equals('Toddler Collection'));
    });

    test('getCategoryProducts returns products list', () async {
      final products = await repository.getCategoryProducts('toddler');
      expect(products.isNotEmpty, isTrue);
      expect(products.first.title, contains('Mustard'));
    });

    test('getCategoryProducts supports sorting by priceLowToHigh', () async {
      final products = await repository.getCategoryProducts(
        'toddler',
        sort: SortOption.priceLowToHigh,
      );
      expect(products.first.title, equals('Terracotta Overalls'));
    });

    test('getCategoryProducts supports sorting by rating', () async {
      final products = await repository.getCategoryProducts(
        'toddler',
        sort: SortOption.rating,
      );
      expect(products.first.rating, equals(5.0));
      expect(products.first.title, equals('Forest Knit Cardigan'));
    });
  });
}
