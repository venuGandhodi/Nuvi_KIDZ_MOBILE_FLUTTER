import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/domain/product.dart';
import '../data/search_repository.dart';
import '../domain/search_filter_state.dart';

class SearchState {
  final String query;
  final List<Product> products;
  final SearchFilterState selectedFilters;
  final SearchSortOption sortOption;
  final bool hasNextPage;
  final String? endCursor;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool isInitialState;

  const SearchState({
    this.query = '',
    this.products = const [],
    this.selectedFilters = const SearchFilterState(),
    this.sortOption = SearchSortOption.relevance,
    this.hasNextPage = false,
    this.endCursor,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.isInitialState = true,
  });

  SearchState copyWith({
    String? query,
    List<Product>? products,
    SearchFilterState? selectedFilters,
    SearchSortOption? sortOption,
    bool? hasNextPage,
    String? endCursor,
    bool clearEndCursor = false,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    bool? isInitialState,
  }) {
    return SearchState(
      query: query ?? this.query,
      products: products ?? this.products,
      selectedFilters: selectedFilters ?? this.selectedFilters,
      sortOption: sortOption ?? this.sortOption,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      endCursor: clearEndCursor ? null : (endCursor ?? this.endCursor),
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isInitialState: isInitialState ?? this.isInitialState,
    );
  }
}

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return ShopifySearchRepository();
});

class NuviSearchController extends Notifier<SearchState> {
  final SearchRepository? _repositoryOverride;
  Timer? _debounceTimer;

  NuviSearchController([this._repositoryOverride]);

  SearchRepository get _repository =>
      _repositoryOverride ?? ref.read(searchRepositoryProvider);

  @override
  SearchState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return const SearchState();
  }

  void search(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty && !state.selectedFilters.hasActiveFilters) {
      state = state.copyWith(
        query: '',
        products: const [],
        isInitialState: true,
        isLoading: false,
        clearError: true,
        clearEndCursor: true,
        hasNextPage: false,
      );
      return;
    }

    state = state.copyWith(
      query: query,
      isInitialState: false,
      isLoading: true,
      clearError: true,
    );

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  void searchImmediately(String query) {
    _debounceTimer?.cancel();
    state = state.copyWith(
      query: query,
      isInitialState: false,
      isLoading: true,
      clearError: true,
    );
    _performSearch();
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    state = const SearchState();
  }

  void applyFilters(SearchFilterState newFilters) {
    _debounceTimer?.cancel();
    state = state.copyWith(
      selectedFilters: newFilters,
      sortOption: newFilters.sortOption,
      isInitialState: false,
      isLoading: true,
      clearError: true,
      clearEndCursor: true,
    );
    _performSearch();
  }

  void changeSort(SearchSortOption sort) {
    final updatedFilters = state.selectedFilters.copyWith(sortOption: sort);
    applyFilters(updatedFilters);
  }

  Future<void> _performSearch() async {
    final filter = state.selectedFilters.copyWith(
      query: state.query,
      sortOption: state.sortOption,
    );

    try {
      final result = await _repository.search(filterState: filter);
      state = state.copyWith(
        products: result.products,
        hasNextPage: result.pageInfo.hasNextPage,
        endCursor: result.pageInfo.endCursor,
        isLoading: false,
        clearError: true,
        isInitialState: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "We couldn't load products right now.",
        isInitialState: false,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading ||
        state.isLoadingMore ||
        !state.hasNextPage ||
        state.endCursor == null) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    final filter = state.selectedFilters.copyWith(
      query: state.query,
      sortOption: state.sortOption,
    );

    try {
      final result = await _repository.search(
        filterState: filter,
        after: state.endCursor,
      );

      state = state.copyWith(
        products: [...state.products, ...result.products],
        hasNextPage: result.pageInfo.hasNextPage,
        endCursor: result.pageInfo.endCursor,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void retry() {
    state = state.copyWith(isLoading: true, clearError: true);
    _performSearch();
  }
}

final searchControllerProvider =
    NotifierProvider<NuviSearchController, SearchState>(
      NuviSearchController.new,
    );
