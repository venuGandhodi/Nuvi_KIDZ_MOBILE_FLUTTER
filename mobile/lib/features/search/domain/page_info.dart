class PageInfo {
  final bool hasNextPage;
  final String? endCursor;

  const PageInfo({required this.hasNextPage, this.endCursor});

  factory PageInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PageInfo(hasNextPage: false);
    }
    return PageInfo(
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      endCursor: json['endCursor'] as String?,
    );
  }
}
