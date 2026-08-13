import 'package:flutter/material.dart';
import '../../product/domain/product_color.dart';
import '../../product/domain/product_review.dart';

class Product {
  final String id;
  final String title;
  final String price;
  final String? salePrice;
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
  final List<String>? fabricAndCare;
  final List<ProductReview>? reviews;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    this.salePrice,
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
    this.fabricAndCare,
    this.reviews,
  });

  Product copyWith({
    String? id,
    String? title,
    String? price,
    String? salePrice,
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
    List<String>? fabricAndCare,
    List<ProductReview>? reviews,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
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
      fabricAndCare: fabricAndCare ?? this.fabricAndCare,
      reviews: reviews ?? this.reviews,
    );
  }
}
