import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../home/domain/product.dart';
import '../data/product_repository.dart';
import '../data/shopify_product_repository.dart';
import '../domain/product_color.dart';
import '../domain/product_variant.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ShopifyProductRepository();
});

class ProductDetailState {
  final Product? product;
  final List<Product> relatedProducts;
  final int selectedImageIndex;
  final ProductColor? selectedColor;
  final String? selectedSize;
  final ProductVariant? selectedVariant;
  final int quantity;
  final bool isFavorite;
  final bool isLoading;
  final bool isAddingToCart;
  final bool addedToCartSuccess;
  final String? errorMessage;

  const ProductDetailState({
    this.product,
    this.relatedProducts = const [],
    this.selectedImageIndex = 0,
    this.selectedColor,
    this.selectedSize,
    this.selectedVariant,
    this.quantity = 1,
    this.isFavorite = false,
    this.isLoading = false,
    this.isAddingToCart = false,
    this.addedToCartSuccess = false,
    this.errorMessage,
  });

  bool get isSelectedVariantAvailable =>
      selectedVariant == null || selectedVariant!.availableForSale;

  ProductDetailState copyWith({
    Product? product,
    List<Product>? relatedProducts,
    int? selectedImageIndex,
    ProductColor? selectedColor,
    String? selectedSize,
    ProductVariant? selectedVariant,
    int? quantity,
    bool? isFavorite,
    bool? isLoading,
    bool? isAddingToCart,
    bool? addedToCartSuccess,
    String? errorMessage,
  }) {
    return ProductDetailState(
      product: product ?? this.product,
      relatedProducts: relatedProducts ?? this.relatedProducts,
      selectedImageIndex: selectedImageIndex ?? this.selectedImageIndex,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      quantity: quantity ?? this.quantity,
      isFavorite: isFavorite ?? this.isFavorite,
      isLoading: isLoading ?? this.isLoading,
      isAddingToCart: isAddingToCart ?? this.isAddingToCart,
      addedToCartSuccess: addedToCartSuccess ?? this.addedToCartSuccess,
      errorMessage: errorMessage,
    );
  }
}

class ProductController extends Notifier<ProductDetailState> {
  @override
  ProductDetailState build() {
    return const ProductDetailState(isLoading: true);
  }

  Future<void> loadProduct(String productId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(productRepositoryProvider);
      final product = await repo.getProductById(productId);
      final related = await repo.getRelatedProducts(productId);

      final firstColor =
          (product?.availableColors != null &&
              product!.availableColors!.isNotEmpty)
          ? product.availableColors!.first
          : null;
      final firstSize =
          (product?.availableSizes != null &&
              product!.availableSizes!.isNotEmpty)
          ? product.availableSizes!.first
          : null;

      final variant = _findVariant(product, firstColor?.name, firstSize);

      state = state.copyWith(
        product: product,
        relatedProducts: related,
        selectedColor: firstColor,
        selectedSize: firstSize,
        selectedVariant: variant,
        isFavorite: product?.isFavorite ?? false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load product details.',
      );
    }
  }

  void selectImage(int index) {
    state = state.copyWith(selectedImageIndex: index);
  }

  void selectColor(ProductColor color) {
    final variant = _findVariant(state.product, color.name, state.selectedSize);
    state = state.copyWith(selectedColor: color, selectedVariant: variant);
  }

  void selectSize(String size) {
    final variant = _findVariant(
      state.product,
      state.selectedColor?.name,
      size,
    );
    state = state.copyWith(selectedSize: size, selectedVariant: variant);
  }

  ProductVariant? _findVariant(
    Product? product,
    String? colorName,
    String? size,
  ) {
    if (product?.variants == null || product!.variants!.isEmpty) return null;
    final variants = product.variants!;

    for (final v in variants) {
      bool colorMatch =
          colorName == null ||
          v.color == null ||
          v.color!.toLowerCase() == colorName.toLowerCase();
      bool sizeMatch =
          size == null ||
          v.size == null ||
          v.size!.toLowerCase() == size.toLowerCase();
      if (colorMatch && sizeMatch) {
        return v;
      }
    }

    return variants.first;
  }

  void toggleFavorite() {
    state = state.copyWith(isFavorite: !state.isFavorite);
  }

  Future<bool> addToCart() async {
    if (state.product?.availableColors != null &&
        state.product!.availableColors!.isNotEmpty &&
        state.selectedColor == null) {
      state = state.copyWith(errorMessage: 'Please select a color.');
      return false;
    }
    if (state.product?.availableSizes != null &&
        state.product!.availableSizes!.isNotEmpty &&
        state.selectedSize == null) {
      state = state.copyWith(errorMessage: 'Please select a size.');
      return false;
    }

    if (!state.isSelectedVariantAvailable) {
      state = state.copyWith(
        errorMessage: 'Selected variant is currently unavailable.',
      );
      return false;
    }

    state = state.copyWith(
      isAddingToCart: true,
      addedToCartSuccess: false,
      errorMessage: null,
    );

    if (state.product != null) {
      // Use variant unit price if available
      final unitPrice = state.selectedVariant?.priceAmount;

      await ref
          .read(cartControllerProvider.notifier)
          .addItem(
            product: state.product!,
            selectedColor: state.selectedColor,
            selectedSize: state.selectedSize,
            quantity: state.quantity,
            unitPrice: unitPrice,
            shopifyVariantId: state.selectedVariant?.id,
          );
    }

    state = state.copyWith(isAddingToCart: false, addedToCartSuccess: true);
    return true;
  }
}

final productControllerProvider =
    NotifierProvider<ProductController, ProductDetailState>(() {
      return ProductController();
    });
