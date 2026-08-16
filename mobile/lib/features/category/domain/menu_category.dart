class MenuCategory {
  final String id;
  final String title;
  final String? imageUrl;
  final String? collectionHandle;
  final List<MenuCategory> items;

  const MenuCategory({
    required this.id,
    required this.title,
    this.imageUrl,
    this.collectionHandle,
    this.items = const [],
  });
}
