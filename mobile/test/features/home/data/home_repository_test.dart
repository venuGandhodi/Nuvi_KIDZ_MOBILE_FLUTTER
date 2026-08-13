import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/home/data/home_repository.dart';

void main() {
  late MockHomeRepository repository;

  setUp(() {
    repository = MockHomeRepository();
  });

  group('MockHomeRepository', () {
    test('getCategories returns categories list', () async {
      final categories = await repository.getCategories();
      expect(categories, isNotEmpty);
      expect(categories.any((c) => c.name == 'Girls'), isTrue);
      expect(categories.any((c) => c.name == 'Boys'), isTrue);
    });

    test('getAgeFilters returns age filters list', () async {
      final filters = await repository.getAgeFilters();
      expect(filters, isNotEmpty);
      expect(filters.any((f) => f.label == '0-3m'), isTrue);
    });

    test('getBestSellers returns best seller products', () async {
      final products = await repository.getBestSellers();
      expect(products, isNotEmpty);
      expect(products.first.title, contains('Romper'));
    });
  });
}
