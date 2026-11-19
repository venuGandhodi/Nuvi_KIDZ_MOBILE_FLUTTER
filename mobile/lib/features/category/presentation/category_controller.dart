import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/domain/product.dart';
import '../data/category_repository.dart';
import '../data/shopify_category_repository.dart';
import '../domain/category_detail.dart';
import '../domain/category_filter.dart';
import '../domain/collection_filter.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return ShopifyCategoryRepository();
});

class CategoryState {
  final String categoryId;
  final CategoryDetail? categoryDetail;

  /// Every product Shopify returned (after Gender / Occasion filters).
  final List<Product> allProducts;

  /// Filters Shopify offers for this collection (from the unfiltered load,
  /// so the options stay stable while the shopper narrows results).
  final List<CollectionFilter> availableFilters;
  final List<SelectedFilterValue> selectedFilters;
  final SortOption sortOption;
  final Set<String> favoriteProductIds;
  final bool isLoading;
  final String? errorMessage;

  const CategoryState({
    this.categoryId = '',
    this.categoryDetail,
    List<Product> products = const [],
    this.availableFilters = const [],
    this.selectedFilters = const [],
    this.sortOption = SortOption.featured,
    this.favoriteProductIds = const {},
    this.isLoading = false,
    this.errorMessage,
  }) : allProducts = products;

  /// Products shown: [allProducts] narrowed by Color / Age / Category.
  List<Product> get products =>
      filterProductsLocally(allProducts, selectedFilters);

  /// Boys / Girls collections hide the redundant Gender filter.
  bool get isGenderSpecific =>
      isGenderSpecificCollection(categoryDetail?.title, categoryId);

  /// Filter groups offered on this page, in display order.
  List<CollectionFilterKind> get filterKinds => [
    for (final k in CollectionFilterKind.values)
      if (!(k == CollectionFilterKind.gender && isGenderSpecific)) k,
  ];

  /// Values a shopper can pick for [kind]: price uses fixed bands; Color,
  /// Age and Category come from the products; the rest from Shopify.
  List<CollectionFilterValue> valuesFor(CollectionFilterKind kind) {
    if (kind == CollectionFilterKind.price) {
      return CollectionFilterValue.priceBands;
    }
    if (kind.fromProducts) return productFilterValues(kind, allProducts);
    final seen = <String>{};
    return [
      for (final f in availableFilters)
        if (f.kind == kind)
          for (final v in f.values)
            if (seen.add(v.id)) v,
    ];
  }

  Set<String> selectedIdsFor(CollectionFilterKind kind) => {
    for (final s in selectedFilters)
      if (s.kind == kind) s.value.id,
  };

  CategoryState copyWith({
    String? categoryId,
    CategoryDetail? categoryDetail,
    List<Product>? products,
    List<CollectionFilter>? availableFilters,
    List<SelectedFilterValue>? selectedFilters,
    SortOption? sortOption,
    Set<String>? favoriteProductIds,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CategoryState(
      categoryId: categoryId ?? this.categoryId,
      categoryDetail: categoryDetail ?? this.categoryDetail,
      products: products ?? allProducts,
      availableFilters: availableFilters ?? this.availableFilters,
      selectedFilters: selectedFilters ?? this.selectedFilters,
      sortOption: sortOption ?? this.sortOption,
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CategoryController extends Notifier<CategoryState> {
  @override
  CategoryState build() {
    return const CategoryState(isLoading: true);
  }

  Future<void> loadCategory(String categoryId) async {
    state = CategoryState(
      categoryId: categoryId,
      sortOption: state.sortOption,
      favoriteProductIds: state.favoriteProductIds,
      isLoading: true,
    );
    try {
      final repository = ref.read(categoryRepositoryProvider);
      final detail = await repository.getCategoryDetail(categoryId);
      final page = await repository.getCollectionPage(
        categoryId,
        sort: state.sortOption,
      );
      state = state.copyWith(
        categoryDetail: detail,
        products: page.products,
        availableFilters: page.filters,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load category products.',
      );
    }
  }

  /// Replaces the picked values of one filter group. Product-based groups
  /// filter on the device; the others ask Shopify again.
  Future<void> setFilterValues(
    CollectionFilterKind kind,
    List<CollectionFilterValue> values,
  ) => _select([
    for (final s in state.selectedFilters)
      if (s.kind != kind) s,
    for (final v in values) SelectedFilterValue(kind, v),
  ], refetch: !kind.fromProducts);

  Future<void> removeFilter(SelectedFilterValue value) => _select([
    for (final s in state.selectedFilters)
      if (s != value) s,
  ], refetch: !value.kind.fromProducts);

  Future<void> clearFilters() => _select(
    const [],
    refetch: state.selectedFilters.any((s) => !s.kind.fromProducts),
  );

  Future<void> _select(
    List<SelectedFilterValue> selected, {
    required bool refetch,
  }) async {
    if (!refetch) {
      state = state.copyWith(selectedFilters: selected);
      return;
    }
    await _reload(selected: selected);
  }

  Future<void> applySort(SortOption sort) => _reload(sort: sort);

  Future<void> _reload({
    List<SelectedFilterValue>? selected,
    SortOption? sort,
  }) async {
    state = state.copyWith(
      selectedFilters: selected,
      sortOption: sort,
      isLoading: true,
    );
    try {
      final page = await ref
          .read(categoryRepositoryProvider)
          .getCollectionPage(
            state.categoryId,
            filters: [
              for (final s in state.selectedFilters)
                if (!s.kind.fromProducts) s,
            ],
            sort: state.sortOption,
          );
      state = state.copyWith(products: page.products, isLoading: false);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load category products.',
      );
    }
  }

  void toggleFavorite(String productId) {
    final updatedFavorites = Set<String>.from(state.favoriteProductIds);
    if (updatedFavorites.contains(productId)) {
      updatedFavorites.remove(productId);
    } else {
      updatedFavorites.add(productId);
    }
    state = state.copyWith(favoriteProductIds: updatedFavorites);
  }
}

final categoryControllerProvider =
    NotifierProvider<CategoryController, CategoryState>(() {
      return CategoryController();
    });
