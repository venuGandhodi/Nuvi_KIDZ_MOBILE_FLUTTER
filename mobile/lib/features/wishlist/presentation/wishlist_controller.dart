import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/domain/product.dart';
import '../data/wishlist_repository.dart';

class WishlistState {
  final Set<String> wishlistProductIds;
  final List<Product> wishlistProducts;
  final bool isLoading;
  final String? errorMessage;

  const WishlistState({
    this.wishlistProductIds = const {},
    this.wishlistProducts = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  bool isWishlisted(String productId) => wishlistProductIds.contains(productId);

  WishlistState copyWith({
    Set<String>? wishlistProductIds,
    List<Product>? wishlistProducts,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WishlistState(
      wishlistProductIds: wishlistProductIds ?? this.wishlistProductIds,
      wishlistProducts: wishlistProducts ?? this.wishlistProducts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return SupabaseWishlistRepository();
});

class WishlistController extends Notifier<WishlistState> {
  final WishlistRepository? _repositoryOverride;

  WishlistController([this._repositoryOverride]);

  WishlistRepository get _repository =>
      _repositoryOverride ?? ref.read(wishlistRepositoryProvider);

  @override
  WishlistState build() {
    return const WishlistState();
  }

  Future<void> loadWishlist() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final ids = await _repository.getWishlistProductIds();
      final products = await _repository.hydrateProducts(ids);

      state = state.copyWith(
        wishlistProductIds: ids.toSet(),
        wishlistProducts: products,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load wishlist items.',
      );
    }
  }

  Future<void> toggleWishlist(Product product) async {
    final isSaved = state.isWishlisted(product.id);
    final updatedIds = Set<String>.from(state.wishlistProductIds);
    final updatedProducts = List<Product>.from(state.wishlistProducts);

    if (isSaved) {
      updatedIds.remove(product.id);
      updatedProducts.removeWhere((p) => p.id == product.id);
      state = state.copyWith(
        wishlistProductIds: updatedIds,
        wishlistProducts: updatedProducts,
      );
      await _repository.removeFromWishlist(product.id);
    } else {
      updatedIds.add(product.id);
      if (!updatedProducts.any((p) => p.id == product.id)) {
        updatedProducts.add(product.copyWith(isFavorite: true));
      }
      state = state.copyWith(
        wishlistProductIds: updatedIds,
        wishlistProducts: updatedProducts,
      );
      await _repository.addToWishlist(product.id);
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    final updatedIds = Set<String>.from(state.wishlistProductIds)
      ..remove(productId);
    final updatedProducts = state.wishlistProducts
        .where((p) => p.id != productId)
        .toList();

    state = state.copyWith(
      wishlistProductIds: updatedIds,
      wishlistProducts: updatedProducts,
    );

    await _repository.removeFromWishlist(productId);
  }

  void clear() {
    state = const WishlistState();
  }
}

final wishlistControllerProvider =
    NotifierProvider<WishlistController, WishlistState>(WishlistController.new);
