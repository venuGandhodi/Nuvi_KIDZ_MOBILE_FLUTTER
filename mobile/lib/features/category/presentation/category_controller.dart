import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/domain/product.dart';
import '../data/category_repository.dart';
import '../domain/category_detail.dart';
import '../domain/category_filter.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return MockCategoryRepository();
});

class CategoryState {
  final CategoryDetail? categoryDetail;
  final List<Product> products;
  final FilterState filterState;
  final SortOption sortOption;
  final Set<String> favoriteProductIds;
  final bool isLoading;
  final String? errorMessage;

  const CategoryState({
    this.categoryDetail,
    this.products = const [],
    this.filterState = const FilterState(),
    this.sortOption = SortOption.featured,
    this.favoriteProductIds = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  CategoryState copyWith({
    CategoryDetail? categoryDetail,
    List<Product>? products,
    FilterState? filterState,
    SortOption? sortOption,
    Set<String>? favoriteProductIds,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CategoryState(
      categoryDetail: categoryDetail ?? this.categoryDetail,
      products: products ?? this.products,
      filterState: filterState ?? this.filterState,
      sortOption: sortOption ?? this.sortOption,
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CategoryController extends Notifier<CategoryState> {
  late String _categoryId;

  @override
  CategoryState build() {
    return const CategoryState(isLoading: true);
  }

  Future<void> loadCategory(String categoryId) async {
    _categoryId = categoryId;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repository = ref.read(categoryRepositoryProvider);
      final detail = await repository.getCategoryDetail(categoryId);
      final products = await repository.getCategoryProducts(
        categoryId,
        filter: state.filterState,
        sort: state.sortOption,
      );
      state = state.copyWith(
        categoryDetail: detail,
        products: products,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load category products.',
      );
    }
  }

  Future<void> applyFilter(FilterState filter) async {
    state = state.copyWith(filterState: filter, isLoading: true);
    final repository = ref.read(categoryRepositoryProvider);
    final products = await repository.getCategoryProducts(
      _categoryId,
      filter: filter,
      sort: state.sortOption,
    );
    state = state.copyWith(products: products, isLoading: false);
  }

  Future<void> applySort(SortOption sort) async {
    state = state.copyWith(sortOption: sort, isLoading: true);
    final repository = ref.read(categoryRepositoryProvider);
    final products = await repository.getCategoryProducts(
      _categoryId,
      filter: state.filterState,
      sort: sort,
    );
    state = state.copyWith(products: products, isLoading: false);
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

  Future<void> resetFilters() async {
    await applyFilter(const FilterState());
  }
}

final categoryControllerProvider =
    NotifierProvider<CategoryController, CategoryState>(() {
      return CategoryController();
    });
