class AgeFilter {
  final String id;
  final String label;
  final String? imageUrl;
  final int sortOrder;
  final String? collectionHandle;
  final bool active;

  const AgeFilter({
    required this.id,
    required this.label,
    this.imageUrl,
    this.sortOrder = 0,
    this.collectionHandle,
    this.active = true,
  });
}
