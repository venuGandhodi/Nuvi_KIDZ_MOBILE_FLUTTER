import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/core/widgets/nuvi_product_card.dart';
import 'package:nuvi_kidz/features/home/domain/product.dart';
import 'package:nuvi_kidz/features/wishlist/data/wishlist_repository.dart';
import 'package:nuvi_kidz/features/wishlist/presentation/wishlist_controller.dart';
import 'package:nuvi_kidz/features/wishlist/presentation/wishlist_screen.dart';

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
    id: 'prod_dream_romper',
    title: 'Organic Cotton Dream Romper',
    price: '₹799',
    salePrice: '₹799',
    rating: 5.0,
    isFavorite: true,
  );

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [wishlistRepositoryProvider.overrideWithValue(mockRepo)],
      child: const MaterialApp(home: WishlistScreen()),
    );
  }

  setUp(() {
    mockRepo = MockWishlistRepository();
  });

  group('WishlistScreen Widget Tests', () {
    testWidgets('1. Renders empty state when wishlist is empty', (
      tester,
    ) async {
      mockRepo.mockIds = [];
      mockRepo.mockProducts = [];

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Your Wishlist is Empty'), findsOneWidget);
      expect(find.text('Explore Products'), findsOneWidget);
      expect(find.byType(NuviProductCard), findsNothing);
    });

    testWidgets('2. Renders populated product grid when items exist', (
      tester,
    ) async {
      mockRepo.mockIds = ['prod_dream_romper'];
      mockRepo.mockProducts = [sampleProduct];

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('1 saved style'), findsOneWidget);
      expect(find.byType(NuviProductCard), findsOneWidget);
      expect(find.text('Organic Cotton Dream Romper'), findsOneWidget);
      expect(find.text('₹799'), findsWidgets);
    });

    testWidgets('3. Tapping favorite heart icon toggles item removal', (
      tester,
    ) async {
      mockRepo.mockIds = ['prod_dream_romper'];
      mockRepo.mockProducts = [sampleProduct];

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(NuviProductCard), findsOneWidget);

      final favoriteButton = find.byIcon(Icons.favorite);
      expect(favoriteButton, findsOneWidget);
      await tester.tap(favoriteButton);
      await tester.pumpAndSettle();

      expect(find.text('Your Wishlist is Empty'), findsOneWidget);
      expect(find.byType(NuviProductCard), findsNothing);
    });
  });
}
