import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/home/domain/product.dart';
import 'package:nuvi_kidz/features/product/data/product_repository.dart';
import 'package:nuvi_kidz/features/wishlist/data/wishlist_repository.dart';

class FakeProductRepository implements ProductRepository {
  final Map<String, Product> productsById = {};

  @override
  Future<Product?> getProductById(String productId) async {
    return productsById[productId];
  }

  @override
  Future<List<Product>> getRelatedProducts(String productId) async => [];
}

void main() {
  late FakeProductRepository fakeProductRepo;
  late SupabaseWishlistRepository repository;

  const sampleProduct = Product(
    id: 'prod_dream_romper',
    title: 'Organic Cotton Dream Romper',
    price: '₹799',
  );

  setUp(() {
    fakeProductRepo = FakeProductRepository();
    fakeProductRepo.productsById['prod_dream_romper'] = sampleProduct;
    repository = SupabaseWishlistRepository(productRepository: fakeProductRepo);
  });

  group('SupabaseWishlistRepository Tests', () {
    test('1. Local fallback starts empty and stores added products', () async {
      expect(await repository.getWishlistProductIds(), isEmpty);

      await repository.addToWishlist('prod_dream_romper');
      final ids = await repository.getWishlistProductIds();

      expect(ids, contains('prod_dream_romper'));
      expect(ids.length, 1);
    });

    test('2. Removing a product removes it from local fallback set', () async {
      await repository.addToWishlist('prod_dream_romper');
      expect(
        await repository.getWishlistProductIds(),
        contains('prod_dream_romper'),
      );

      await repository.removeFromWishlist('prod_dream_romper');
      expect(await repository.getWishlistProductIds(), isEmpty);
    });

    test(
      '3. hydrateProducts converts IDs into Product models with isFavorite true',
      () async {
        final hydrated = await repository.hydrateProducts([
          'prod_dream_romper',
        ]);

        expect(hydrated.length, 1);
        expect(hydrated.first.id, 'prod_dream_romper');
        expect(hydrated.first.title, 'Organic Cotton Dream Romper');
        expect(hydrated.first.isFavorite, isTrue);
      },
    );

    test(
      '4. hydrateProducts gracefully handles missing/unavailable products',
      () async {
        final hydrated = await repository.hydrateProducts(['nonexistent_id']);

        expect(hydrated, isEmpty);
      },
    );
  });
}
