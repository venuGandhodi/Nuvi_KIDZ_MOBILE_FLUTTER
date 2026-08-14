import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/home/domain/product.dart';
import 'package:nuvi_kidz/features/wishlist/data/wishlist_repository.dart';
import 'package:nuvi_kidz/features/wishlist/presentation/wishlist_controller.dart';

class FakeWishlistRepository implements WishlistRepository {
  List<String> mockIds = [];
  Map<String, Product> mockProducts = {};
  bool shouldThrow = false;

  @override
  Future<List<String>> getWishlistProductIds() async {
    if (shouldThrow) throw Exception('Network error');
    return List.from(mockIds);
  }

  @override
  Future<void> addToWishlist(String productId, {String? variantId}) async {
    if (!mockIds.contains(productId)) mockIds.add(productId);
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    mockIds.remove(productId);
  }

  @override
  Future<List<Product>> hydrateProducts(List<String> productIds) async {
    if (shouldThrow) throw Exception('Network error');
    return productIds
        .where((id) => mockProducts.containsKey(id))
        .map((id) => mockProducts[id]!)
        .toList();
  }
}

void main() {
  late FakeWishlistRepository fakeRepo;
  late ProviderContainer container;

  const sampleProduct = Product(
    id: 'prod_dream_romper',
    title: 'Organic Cotton Dream Romper',
    price: '₹799',
  );

  setUp(() {
    fakeRepo = FakeWishlistRepository();
    fakeRepo.mockIds = ['prod_dream_romper'];
    fakeRepo.mockProducts['prod_dream_romper'] = sampleProduct;

    container = ProviderContainer(
      overrides: [wishlistRepositoryProvider.overrideWithValue(fakeRepo)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('WishlistController Tests', () {
    test(
      '1. Initial load populates wishlisted IDs and hydrated products',
      () async {
        final controller = container.read(wishlistControllerProvider.notifier);
        await controller.loadWishlist();

        final state = container.read(wishlistControllerProvider);
        expect(state.isLoading, isFalse);
        expect(state.wishlistProductIds, contains('prod_dream_romper'));
        expect(state.wishlistProducts.length, 1);
        expect(
          state.wishlistProducts.first.title,
          'Organic Cotton Dream Romper',
        );
      },
    );

    test('2. toggleWishlist removes existing item', () async {
      final controller = container.read(wishlistControllerProvider.notifier);
      await controller.loadWishlist();

      expect(
        container
            .read(wishlistControllerProvider)
            .isWishlisted('prod_dream_romper'),
        isTrue,
      );

      await controller.toggleWishlist(sampleProduct);

      final state = container.read(wishlistControllerProvider);
      expect(state.isWishlisted('prod_dream_romper'), isFalse);
      expect(state.wishlistProducts, isEmpty);
      expect(fakeRepo.mockIds, isEmpty);
    });

    test('3. toggleWishlist adds new item when not present', () async {
      fakeRepo.mockIds.clear();
      final controller = container.read(wishlistControllerProvider.notifier);
      await controller.loadWishlist();

      expect(
        container
            .read(wishlistControllerProvider)
            .isWishlisted('prod_dream_romper'),
        isFalse,
      );

      await controller.toggleWishlist(sampleProduct);

      final state = container.read(wishlistControllerProvider);
      expect(state.isWishlisted('prod_dream_romper'), isTrue);
      expect(state.wishlistProducts.length, 1);
      expect(fakeRepo.mockIds, contains('prod_dream_romper'));
    });

    test('4. clear resets state to empty', () async {
      final controller = container.read(wishlistControllerProvider.notifier);
      await controller.loadWishlist();

      expect(
        container.read(wishlistControllerProvider).wishlistProducts,
        isNotEmpty,
      );

      controller.clear();

      final state = container.read(wishlistControllerProvider);
      expect(state.wishlistProductIds, isEmpty);
      expect(state.wishlistProducts, isEmpty);
    });

    test('5. Error during load sets friendly errorMessage', () async {
      fakeRepo.shouldThrow = true;
      final controller = container.read(wishlistControllerProvider.notifier);
      await controller.loadWishlist();

      final state = container.read(wishlistControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, 'Failed to load wishlist items.');
    });
  });
}
