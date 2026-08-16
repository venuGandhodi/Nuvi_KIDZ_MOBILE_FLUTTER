import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/home_repository.dart';
import '../data/shopify_home_repository.dart';
import '../domain/age_filter.dart';
import '../domain/home_hero.dart';
import '../domain/product.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return ShopifyHomeRepository();
});

class HomeState {
  final HomeHero? hero;
  final List<AgeFilter> ageFilters;
  final List<Product> bestSellers;
  final String? selectedAgeFilterId;
  final String? selectedCategoryId;
  final Set<String> favoriteProductIds;
  final int currentBottomNavIndex;
  final int cartItemCount;
  final bool isLoading;
  final String? errorMessage;

  const HomeState({
    this.hero,
    this.ageFilters = const [],
    this.bestSellers = const [],
    this.selectedAgeFilterId,
    this.selectedCategoryId,
    this.favoriteProductIds = const {},
    this.currentBottomNavIndex = 0,
    this.cartItemCount = 2,
    this.isLoading = false,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeHero? hero,
    List<AgeFilter>? ageFilters,
    List<Product>? bestSellers,
    String? selectedAgeFilterId,
    String? selectedCategoryId,
    Set<String>? favoriteProductIds,
    int? currentBottomNavIndex,
    int? cartItemCount,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      hero: hero ?? this.hero,
      ageFilters: ageFilters ?? this.ageFilters,
      bestSellers: bestSellers ?? this.bestSellers,
      selectedAgeFilterId: selectedAgeFilterId ?? this.selectedAgeFilterId,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
      currentBottomNavIndex:
          currentBottomNavIndex ?? this.currentBottomNavIndex,
      cartItemCount: cartItemCount ?? this.cartItemCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() {
    final repository = ref.watch(homeRepositoryProvider);
    _loadInitialData(repository);
    return const HomeState(isLoading: true);
  }

  Future<void> _loadInitialData(HomeRepository repository) async {
    try {
      final hero = await repository.getHero();
      final ageFilters = await repository.getAgeFilters();
      final bestSellers = await repository.getBestSellers();

      state = state.copyWith(
        hero: hero,
        ageFilters: ageFilters,
        bestSellers: bestSellers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load home data.',
      );
    }
  }

  Future<void> loadHomeData() async {
    final repository = ref.read(homeRepositoryProvider);
    await _loadInitialData(repository);
  }

  void selectAgeFilter(String ageFilterId) {
    if (state.selectedAgeFilterId == ageFilterId) {
      state = state.copyWith(selectedAgeFilterId: null);
    } else {
      state = state.copyWith(selectedAgeFilterId: ageFilterId);
    }
  }

  void selectCategory(String categoryId) {
    if (state.selectedCategoryId == categoryId) {
      state = state.copyWith(selectedCategoryId: null);
    } else {
      state = state.copyWith(selectedCategoryId: categoryId);
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

  void setBottomNavIndex(int index) {
    state = state.copyWith(currentBottomNavIndex: index);
  }
}

final homeControllerProvider = NotifierProvider<HomeController, HomeState>(() {
  return HomeController();
});
