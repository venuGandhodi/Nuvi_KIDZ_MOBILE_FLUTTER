import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/product/data/product_repository.dart';

void main() {
  late MockProductRepository repository;

  setUp(() {
    repository = MockProductRepository();
  });

  group('MockProductRepository Tests', () {
    test('getProductById returns product detail with fallbacks', () async {
      final product = await repository.getProductById('prod_dream_romper');
      expect(product, isNotNull);
      expect(product!.title, contains('Dream Romper'));
      expect(product.availableColors, isNotNull);
      expect(product.availableSizes, isNotNull);
    });

    test('getRelatedProducts returns list of products', () async {
      final related = await repository.getRelatedProducts('prod_dream_romper');
      expect(related.isNotEmpty, isTrue);
      expect(related.first.title, contains('Beanie'));
    });
  });
}
