import 'package:flutter/material.dart';
import '../../product/domain/product_color.dart';
import '../../product/domain/product_review.dart';
import '../../product/domain/product_variant.dart';

class Product {
  final String id;
  final String? handle;
  final String title;
  final String price;
  final String? salePrice;
  final String? compareAtPrice;
  final String currencyCode;
  final double rating;
  final int reviewCount;
  final String? imageUrl;
  final String? assetPath;
  final String? badgeText;
  final bool isFavorite;
  final List<Color>? colorSwatches;
  final String? description;
  final List<String>? images;
  final List<ProductColor>? availableColors;
  final List<String>? availableSizes;
  final List<ProductVariant>? variants;
  final List<String>? fabricAndCare;
  final List<ProductReview>? reviews;

  const Product({
    required this.id,
    this.handle,
    required this.title,
    required this.price,
    this.salePrice,
    this.compareAtPrice,
    this.currencyCode = 'INR',
    this.rating = 0.0,
    this.reviewCount = 0,
    this.imageUrl,
    this.assetPath,
    this.badgeText,
    this.isFavorite = false,
    this.colorSwatches,
    this.description,
    this.images,
    this.availableColors,
    this.availableSizes,
    this.variants,
    this.fabricAndCare,
    this.reviews,
  });

  Product copyWith({
    String? id,
    String? handle,
    String? title,
    String? price,
    String? salePrice,
    String? compareAtPrice,
    String? currencyCode,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    String? assetPath,
    String? badgeText,
    bool? isFavorite,
    List<Color>? colorSwatches,
    String? description,
    List<String>? images,
    List<ProductColor>? availableColors,
    List<String>? availableSizes,
    List<ProductVariant>? variants,
    List<String>? fabricAndCare,
    List<ProductReview>? reviews,
  }) {
    return Product(
      id: id ?? this.id,
      handle: handle ?? this.handle,
      title: title ?? this.title,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      currencyCode: currencyCode ?? this.currencyCode,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      assetPath: assetPath ?? this.assetPath,
      badgeText: badgeText ?? this.badgeText,
      isFavorite: isFavorite ?? this.isFavorite,
      colorSwatches: colorSwatches ?? this.colorSwatches,
      description: description ?? this.description,
      images: images ?? this.images,
      availableColors: availableColors ?? this.availableColors,
      availableSizes: availableSizes ?? this.availableSizes,
      variants: variants ?? this.variants,
      fabricAndCare: fabricAndCare ?? this.fabricAndCare,
      reviews: reviews ?? this.reviews,
    );
  }
}
