import '../../home/domain/product.dart';
import 'mock_product_detail_data.dart';

abstract class ProductRepository {
  Future<Product?> getProductById(String productId);
  Future<List<Product>> getRelatedProducts(String productId);
}

class MockProductRepository implements ProductRepository {
  @override
  Future<Product?> getProductById(String productId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final base = MockProductDetailData.defaultDreamRomper;
    return base.copyWith(
      id: productId,
      title: productId.contains('cardigan')
          ? 'Forest Knit Cardigan'
          : productId.contains('mustard')
          ? 'Starry Mustard Dress'
          : productId.contains('overalls')
          ? 'Terracotta Overalls'
          : 'Organic Cotton Dream Romper',
    );
  }

  @override
  Future<List<Product>> getRelatedProducts(String productId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return MockProductDetailData.relatedProducts;
  }
}
