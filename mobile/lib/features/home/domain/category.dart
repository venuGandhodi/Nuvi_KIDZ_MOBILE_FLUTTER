class Category {
  final String id;
  final String name;
  final String? imageUrl;
  final String? assetPath;
  final String? handle;

  const Category({
    required this.id,
    required this.name,
    this.imageUrl,
    this.assetPath,
    this.handle,
  });
}
