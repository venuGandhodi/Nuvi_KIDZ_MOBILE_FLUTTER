import 'package:flutter/material.dart';

enum SortOption {
  featured('Featured'),
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  rating('Highest Rated'),
  newest('Newest Arrivals');

  final String label;
  const SortOption(this.label);
}

class FilterState {
  final Set<String> selectedCategoryIds;
  final Set<String> selectedAgeFilters;
  final RangeValues? selectedPriceRange;
  final bool inStockOnly;

  const FilterState({
    this.selectedCategoryIds = const {},
    this.selectedAgeFilters = const {},
    this.selectedPriceRange,
    this.inStockOnly = false,
  });

  bool get isEmpty =>
      selectedCategoryIds.isEmpty &&
      selectedAgeFilters.isEmpty &&
      selectedPriceRange == null &&
      !inStockOnly;

  FilterState copyWith({
    Set<String>? selectedCategoryIds,
    Set<String>? selectedAgeFilters,
    RangeValues? selectedPriceRange,
    bool? inStockOnly,
  }) {
    return FilterState(
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      selectedAgeFilters: selectedAgeFilters ?? this.selectedAgeFilters,
      selectedPriceRange: selectedPriceRange ?? this.selectedPriceRange,
      inStockOnly: inStockOnly ?? this.inStockOnly,
    );
  }
}
