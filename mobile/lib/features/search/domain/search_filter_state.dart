enum SearchSortOption {
  relevance('Relevance', 'RELEVANCE', false),
  priceLowHigh('Price: Low to High', 'PRICE', false),
  priceHighLow('Price: High to Low', 'PRICE', true),
  newest('Newest Arrivals', 'CREATED_AT', true),
  bestSelling('Best Selling', 'BEST_SELLING', false);

  final String label;
  final String shopifySortKey;
  final bool shopifyReverse;

  const SearchSortOption(this.label, this.shopifySortKey, this.shopifyReverse);
}

class SearchFilterState {
  final String query;
  final String? category;
  final String? size;
  final String? color;
  final double? minPrice;
  final double? maxPrice;
  final bool inStockOnly;
  final SearchSortOption sortOption;

  const SearchFilterState({
    this.query = '',
    this.category,
    this.size,
    this.color,
    this.minPrice,
    this.maxPrice,
    this.inStockOnly = false,
    this.sortOption = SearchSortOption.relevance,
  });

  bool get hasActiveFilters =>
      category != null ||
      size != null ||
      color != null ||
      minPrice != null ||
      maxPrice != null ||
      inStockOnly ||
      sortOption != SearchSortOption.relevance;

  int get activeFilterCount {
    int count = 0;
    if (category != null) count++;
    if (size != null) count++;
    if (color != null) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (inStockOnly) count++;
    if (sortOption != SearchSortOption.relevance) count++;
    return count;
  }

  SearchFilterState copyWith({
    String? query,
    String? category,
    bool clearCategory = false,
    String? size,
    bool clearSize = false,
    String? color,
    bool clearColor = false,
    double? minPrice,
    bool clearMinPrice = false,
    double? maxPrice,
    bool clearMaxPrice = false,
    bool? inStockOnly,
    SearchSortOption? sortOption,
  }) {
    return SearchFilterState(
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
      size: clearSize ? null : (size ?? this.size),
      color: clearColor ? null : (color ?? this.color),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      inStockOnly: inStockOnly ?? this.inStockOnly,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  String toShopifyQueryString() {
    final terms = <String>[];

    if (query.trim().isNotEmpty) {
      terms.add(query.trim());
    }

    if (category != null && category!.isNotEmpty) {
      terms.add('product_type:${_escapeQuery(category!)}');
    }

    if (color != null && color!.isNotEmpty) {
      terms.add('tag:${_escapeQuery(color!)}');
    }

    if (inStockOnly) {
      terms.add('available_for_sale:true');
    }

    return terms.join(' ');
  }

  static String _escapeQuery(String text) {
    if (text.contains(' ')) {
      return '"$text"';
    }
    return text;
  }
}
