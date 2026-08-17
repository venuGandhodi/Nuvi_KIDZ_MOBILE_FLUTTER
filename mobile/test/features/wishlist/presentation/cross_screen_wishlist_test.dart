import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/core/widgets/nuvi_product_card.dart';
import 'package:nuvi_kidz/features/home/domain/product.dart';
import 'package:nuvi_kidz/features/home/presentation/widgets/best_sellers_section.dart';
import 'package:nuvi_kidz/features/wishlist/data/wishlist_repository.dart';
import 'package:nuvi_kidz/features/wishlist/presentation/wishlist_controller.dart';
import 'package:nuvi_kidz/features/wishlist/presentation/wishlist_screen.dart';

/// Mirrors how live screens (e.g. CategoryListingScreen) wire a product
/// grid's favorite toggle to the centralized WishlistController.
class _WishlistAwareBestSellers extends ConsumerWidget {
  final List<Product> products;

  const _WishlistAwareBestSellers({required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistState = ref.watch(wishlistControllerProvider);
    return BestSellersSection(
      products: products,
      favoriteProductIds: wishlistState.wishlistProductIds,
      onToggleFavorite: (productId) {
        final product = products.firstWhere((p) => p.id == productId);
        ref.read(wishlistControllerProvider.notifier).toggleWishlist(product);
      },
    );
  }
}

class MockWishlistRepository implements WishlistRepository {
  List<String> mockIds = [];
  List<Product> mockProducts = [];

  @override
  Future<List<String>> getWishlistProductIds() async => mockIds;

  @override
  Future<void> addToWishlist(String productId, {String? variantId}) async {
    if (!mockIds.contains(productId)) mockIds.add(productId);
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    mockIds.remove(productId);
    mockProducts.removeWhere((p) => p.id == productId);
  }

  @override
  Future<List<Product>> hydrateProducts(List<String> productIds) async =>
      mockProducts;
}

void main() {
  late MockWishlistRepository mockRepo;

  const sampleProduct = Product(
    id: 'gid://shopify/Product/100',
    title: 'Boys Ethnic Kurta',
    price: '₹1,299',
    salePrice: '₹999',
    rating: 4.8,
    isFavorite: false,
  );

  setUp(() {
    mockRepo = MockWishlistRepository();
  });

  group('Cross-Screen Wishlist Synchronization Tests', () {
    testWidgets(
      '1. Toggling favorite in BestSellersSection updates centralized WishlistState',
      (tester) async {
        mockRepo.mockProducts = [sampleProduct];

        final container = ProviderContainer(
          overrides: [wishlistRepositoryProvider.overrideWithValue(mockRepo)],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                // BestSellersSection is always used inside a scrollable
                // container in the app, which gives its GridView unbounded
                // height — match that here instead of a fixed viewport.
                body: SingleChildScrollView(
                  child: _WishlistAwareBestSellers(products: [sampleProduct]),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final heartIcons = find.byIcon(Icons.favorite_border);
        expect(heartIcons, findsWidgets);

        // Ensure visible and tap the first heart icon
        await tester.ensureVisible(heartIcons.first);
        await tester.pumpAndSettle();

        await tester.tap(heartIcons.first);
        await tester.pumpAndSettle();

        // Verify WishlistController has the item
        final wishlistState = container.read(wishlistControllerProvider);
        expect(wishlistState.wishlistProductIds.isNotEmpty, isTrue);
      },
    );

    testWidgets(
      '2. Wishlist screen reflects products added from other screens',
      (tester) async {
        mockRepo.mockIds = ['gid://shopify/Product/100'];
        mockRepo.mockProducts = [sampleProduct];

        final container = ProviderContainer(
          overrides: [wishlistRepositoryProvider.overrideWithValue(mockRepo)],
        );

        // Initialize wishlist
        await container
            .read(wishlistControllerProvider.notifier)
            .loadWishlist();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: WishlistScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(NuviProductCard), findsOneWidget);
        expect(find.text('Boys Ethnic Kurta'), findsOneWidget);
      },
    );
  });
}
