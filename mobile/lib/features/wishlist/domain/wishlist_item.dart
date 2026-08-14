class WishlistItem {
  final String id;
  final String userId;
  final String shopifyProductId;
  final String? shopifyVariantId;
  final DateTime createdAt;

  const WishlistItem({
    required this.id,
    required this.userId,
    required this.shopifyProductId,
    this.shopifyVariantId,
    required this.createdAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      shopifyProductId: json['shopify_product_id'] as String? ?? '',
      shopifyVariantId: json['shopify_variant_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'shopify_product_id': shopifyProductId,
      if (shopifyVariantId != null) 'shopify_variant_id': shopifyVariantId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
