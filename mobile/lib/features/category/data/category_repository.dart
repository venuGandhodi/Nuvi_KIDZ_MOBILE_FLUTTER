import '../../home/domain/product.dart';
import '../domain/category_detail.dart';
import '../domain/category_filter.dart';
import 'mock_category_data.dart';

abstract class CategoryRepository {
  Future<CategoryDetail> getCategoryDetail(String categoryId);
  Future<List<Product>> getCategoryProducts(
    String categoryId, {
    FilterState? filter,
    SortOption? sort,
  });
}

class MockCategoryRepository implements CategoryRepository {
  @override
  Future<CategoryDetail> getCategoryDetail(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return MockCategoryData.categories[categoryId] ??
        CategoryDetail(
          id: categoryId,
          title: 'Toddler Collection',
          description: 'Playful & cozy styles for little explorers.',
          productsCount: MockCategoryData.products.length,
        );
  }

  @override
  Future<List<Product>> getCategoryProducts(
    String categoryId, {
    FilterState? filter,
    SortOption? sort,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    List<Product> result = List.from(MockCategoryData.products);

    // Apply filtering logic
    if (filter != null && !filter.isEmpty) {
      if (filter.selectedCategoryIds.isNotEmpty) {
        // filter by category ID if applicable
      }
      if (filter.inStockOnly) {
        // filter in stock
      }
    }

    // Apply sorting logic
    if (sort != null) {
      switch (sort) {
        case SortOption.priceLowToHigh:
          result.sort((a, b) => _parsePrice(a).compareTo(_parsePrice(b)));
          break;
        case SortOption.priceHighToLow:
          result.sort((a, b) => _parsePrice(b).compareTo(_parsePrice(a)));
          break;
        case SortOption.rating:
          result.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case SortOption.newest:
          result.sort((a, b) {
            final aNew = a.badgeText == 'NEW' ? 1 : 0;
            final bNew = b.badgeText == 'NEW' ? 1 : 0;
            return bNew.compareTo(aNew);
          });
          break;
        case SortOption.featured:
          break;
      }
    }

    return result;
  }

  double _parsePrice(Product p) {
    final str = p.salePrice ?? p.price;
    final cleanStr = str.replaceAll('\$', '').trim();
    return double.tryParse(cleanStr) ?? 0.0;
  }
}
