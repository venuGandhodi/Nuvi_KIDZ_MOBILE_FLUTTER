class CategoryDetail {
  final String id;
  final String title;
  final String? description;
  final int productsCount;
  final String? imageUrl;

  const CategoryDetail({
    required this.id,
    required this.title,
    this.description,
    this.productsCount = 0,
    this.imageUrl,
  });
}
