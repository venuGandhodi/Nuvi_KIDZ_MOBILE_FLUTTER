import 'package:flutter/material.dart';
import '../../category/domain/category_detail.dart';
import '../../home/domain/category.dart';
import '../../home/domain/home_hero.dart';
import '../../home/domain/product.dart';
import '../../product/domain/product_color.dart';
import '../../product/domain/product_variant.dart';

class ShopifyProductMapper {
  static const String fallbackImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCHXb3W4c6V3Qv0qXmZ-HffbZfE-bYtFf7_Pj1s4rN-f8U9v6Z_W2gP0e7K1Q_d8j4k1b0c9s-mN6X_Y2_p0s9e-8b_X4w_Z7_o-f0=w800';

  static const String fallbackHeroImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAFpju392Q1xn2AJbOH6i84veMzV8CIixbhDvSfev46-u4_JZayJQIFnXhrHEVwvacS8R3Yqz5xKPu96JKK13KMhQKxFxLkLnJXz9NyUwcIZ4wn0co3f1eqH4Qpm3q-U4Ugpoqku-8t-1F7pb_aL95IXewiYYQ8_64qWmtarZhwe1gnvFEtqcpH2u82uIp_phTTft_zPdY8hPZjpq2y0BYUg1FsGCMEoLThIKZ_Q5E5vMJdLVJRJbMjsQ';

  static Product mapToProduct(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final title = json['title'] as String? ?? 'Untitled Product';
    final handle = json['handle'] as String? ?? '';
    final descriptionHtml = json['descriptionHtml'] as String? ?? '';

    // Extract images
    final imagesList = <String>[];
    if (json['images'] != null && json['images']['edges'] != null) {
      final edges = json['images']['edges'] as List<dynamic>;
      for (final edge in edges) {
        if (edge is Map<String, dynamic> && edge['node'] != null) {
          final url = edge['node']['url'] as String?;
          if (url != null && url.isNotEmpty) {
            imagesList.add(url);
          }
        }
      }
    }

    final imageUrl = imagesList.isNotEmpty
        ? imagesList.first
        : fallbackImageUrl;
    final displayImages = imagesList.isNotEmpty
        ? imagesList
        : [fallbackImageUrl];

    // Extract variants
    final variantsList = <ProductVariant>[];
    double? minPrice;
    double? minCompareAtPrice;
    String currencyCode = 'INR';

    if (json['variants'] != null && json['variants']['edges'] != null) {
      final edges = json['variants']['edges'] as List<dynamic>;
      for (final edge in edges) {
        if (edge is Map<String, dynamic> && edge['node'] != null) {
          final node = edge['node'] as Map<String, dynamic>;
          final vId = node['id'] as String? ?? '';
          final vTitle = node['title'] as String? ?? '';
          final vAvailable = node['availableForSale'] as bool? ?? true;

          double vPrice = 0.0;
          if (node['price'] != null) {
            vPrice =
                double.tryParse(node['price']['amount']?.toString() ?? '0') ??
                0.0;
            currencyCode = node['price']['currencyCode'] as String? ?? 'INR';
          }

          double? vCompareAt;
          if (node['compareAtPrice'] != null &&
              node['compareAtPrice']['amount'] != null) {
            vCompareAt = double.tryParse(
              node['compareAtPrice']['amount'].toString(),
            );
          }

          final selectedOptionsMap = <String, String>{};
          String? size;
          String? color;

          if (node['selectedOptions'] != null) {
            final options = node['selectedOptions'] as List<dynamic>;
            for (final opt in options) {
              if (opt is Map<String, dynamic>) {
                final name = opt['name']?.toString() ?? '';
                final value = opt['value']?.toString() ?? '';
                selectedOptionsMap[name] = value;

                final lowerName = name.toLowerCase();
                if (lowerName == 'size') {
                  size = value;
                } else if (lowerName == 'color' || lowerName == 'colour') {
                  color = value;
                }
              }
            }
          }

          if (minPrice == null || vPrice < minPrice) {
            minPrice = vPrice;
            minCompareAtPrice = vCompareAt;
          }

          variantsList.add(
            ProductVariant(
              id: vId,
              title: vTitle,
              priceAmount: vPrice,
              currencyCode: currencyCode,
              compareAtPriceAmount: vCompareAt,
              selectedOptions: selectedOptionsMap,
              availableForSale: vAvailable,
              size: size,
              color: color,
            ),
          );
        }
      }
    }

    final priceStr = _formatCurrency(minPrice ?? 0.0, currencyCode);
    final salePriceStr =
        (minCompareAtPrice != null && minCompareAtPrice > (minPrice ?? 0.0))
        ? priceStr
        : null;
    final compareAtPriceStr =
        (minCompareAtPrice != null && minCompareAtPrice > (minPrice ?? 0.0))
        ? _formatCurrency(minCompareAtPrice, currencyCode)
        : null;

    final availableColors = _extractColors(variantsList);
    final availableSizes = _extractSizes(variantsList);

    return Product(
      id: handle.isNotEmpty ? handle : id,
      handle: handle,
      title: title,
      price: priceStr,
      salePrice: salePriceStr,
      compareAtPrice: compareAtPriceStr,
      currencyCode: currencyCode,
      rating: 5.0, // Default brand presentation rating
      reviewCount: 12,
      imageUrl: imageUrl,
      images: displayImages,
      badgeText: salePriceStr != null ? 'SALE' : null,
      description: _stripHtml(descriptionHtml),
      availableColors: availableColors.isNotEmpty ? availableColors : null,
      availableSizes: availableSizes.isNotEmpty ? availableSizes : null,
      variants: variantsList.isNotEmpty ? variantsList : null,
    );
  }

  static String _formatCurrency(double amount, String currencyCode) {
    final formatted = amount.toStringAsFixed(
      amount.truncateToDouble() == amount ? 0 : 2,
    );
    if (currencyCode == 'INR') {
      return '₹$formatted';
    }
    return '$currencyCode $formatted';
  }

  static List<ProductColor> _extractColors(List<ProductVariant> variants) {
    final map = <String, Color>{};
    for (final v in variants) {
      if (v.color != null && v.color!.isNotEmpty) {
        map[v.color!] = _colorFromName(v.color!);
      }
    }
    return map.entries
        .map(
          (e) => ProductColor(
            id: e.key.toLowerCase().replaceAll(' ', '_'),
            name: e.key,
            color: e.value,
          ),
        )
        .toList();
  }

  static List<String> _extractSizes(List<ProductVariant> variants) {
    final set = <String>{};
    for (final v in variants) {
      if (v.size != null && v.size!.isNotEmpty) {
        set.add(v.size!);
      }
    }
    return set.toList();
  }

  static Color _colorFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('red')) {
      return const Color(0xFFD32F2F);
    }
    if (lower.contains('blue')) {
      return const Color(0xFF1976D2);
    }
    if (lower.contains('green') || lower.contains('sage')) {
      return const Color(0xFF388E3C);
    }
    if (lower.contains('yellow') || lower.contains('mustard')) {
      return const Color(0xFFFBC02D);
    }
    if (lower.contains('pink')) {
      return const Color(0xFFE91E63);
    }
    if (lower.contains('white') || lower.contains('cream')) {
      return const Color(0xFFF5F5F5);
    }
    if (lower.contains('black')) {
      return const Color(0xFF212121);
    }
    if (lower.contains('terracotta') || lower.contains('brown')) {
      return const Color(0xFFE06D53);
    }
    return const Color(0xFF8E8E93); // Muted neutral
  }

  static CategoryDetail mapToCategoryDetail(
    Map<String, dynamic> json,
    int productCount,
  ) {
    final id = json['id'] as String? ?? '';
    final title = json['title'] as String? ?? 'Collection';
    final handle = json['handle'] as String? ?? '';
    final description = json['description'] as String? ?? '';

    return CategoryDetail(
      id: handle.isNotEmpty ? handle : id,
      title: title,
      description: description.isNotEmpty
          ? description
          : 'Discover our exclusive collection of tiny styles.',
      productsCount: productCount,
    );
  }

  static Category mapToCategory(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final title = json['title'] as String? ?? 'Collection';
    final handle = json['handle'] as String? ?? '';

    String? imageUrl;
    if (json['image'] != null && json['image'] is Map) {
      imageUrl = json['image']['url'] as String?;
    }

    return Category(
      id: handle.isNotEmpty ? handle : id,
      name: title,
      handle: handle.isNotEmpty ? handle : null,
      imageUrl: imageUrl,
    );
  }

  static HomeHero mapToHomeHero(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? 'hero_default';
    String title = 'Autumn Adventures\nAwait';
    String description =
        'Discover our new collection of cozy, organic cotton essentials designed for little explorers.';
    String? imageUrl = fallbackHeroImageUrl;
    String buttonText = 'Shop the Collection';
    String collectionHandle = 'new-arrivals';
    bool isActive = true;

    if (json['fields'] != null && json['fields'] is List) {
      final fields = json['fields'] as List<dynamic>;
      for (final field in fields) {
        if (field is Map<String, dynamic>) {
          final key = field['key'] as String?;
          final value = field['value'] as String?;
          final reference = field['reference'] as Map<String, dynamic>?;

          if (key == 'title' && value != null && value.isNotEmpty) {
            title = value;
          } else if (key == 'description' &&
              value != null &&
              value.isNotEmpty) {
            description = value;
          } else if (key == 'button_text' || key == 'buttonText') {
            if (value != null && value.isNotEmpty) buttonText = value;
          } else if (key == 'collection_handle' || key == 'collectionHandle') {
            if (value != null && value.isNotEmpty) collectionHandle = value;
          } else if (key == 'is_active' || key == 'isActive') {
            isActive = value == 'true' || value == '1';
          } else if (key == 'image') {
            if (reference != null &&
                reference['image'] != null &&
                reference['image']['url'] != null) {
              imageUrl = reference['image']['url'] as String;
            } else if (value != null && value.startsWith('http')) {
              imageUrl = value;
            }
          }
        }
      }
    }

    return HomeHero(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl ?? fallbackHeroImageUrl,
      buttonText: buttonText,
      collectionHandle: collectionHandle,
      isActive: isActive,
    );
  }

  static String _stripHtml(String html) {
    final exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return html.replaceAll(exp, '').replaceAll('&nbsp;', ' ').trim();
  }
}
