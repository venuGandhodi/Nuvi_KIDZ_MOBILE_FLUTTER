class AgeFilter {
  final String id;
  final String label;
  final String? imageUrl;

  const AgeFilter({required this.id, required this.label, this.imageUrl});

  static const List<AgeFilter> defaultFilters = [
    AgeFilter(id: '0-3m', label: '0-3m'),
    AgeFilter(id: '3-6m', label: '3-6m'),
    AgeFilter(id: '6-12m', label: '6-12m'),
    AgeFilter(id: '1-2y', label: '1-2y'),
    AgeFilter(id: '3-5y', label: '3-5y'),
    AgeFilter(id: '6-8y', label: '6-8y'),
  ];
}
