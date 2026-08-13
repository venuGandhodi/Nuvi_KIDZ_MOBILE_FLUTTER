import 'package:flutter/material.dart';
import '../theme/nuvi_colors.dart';
import '../theme/nuvi_decorations.dart';
import '../theme/nuvi_radii.dart';
import '../theme/nuvi_spacing.dart';
import '../theme/nuvi_typography.dart';

class NuviProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String? salePrice;
  final double rating;
  final bool isFavorite;
  final String? badgeText; // e.g. "NEW", "SALE"
  final String? imageUrl;
  final List<Color>? colorSwatches;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const NuviProductCard({
    super.key,
    required this.title,
    required this.price,
    this.salePrice,
    this.rating = 0.0,
    this.isFavorite = false,
    this.badgeText,
    this.imageUrl,
    this.colorSwatches,
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: NuviDecorations.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: NuviColors.surfaceVariant,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(NuviRadii.card),
                        topRight: Radius.circular(NuviRadii.card),
                      ),
                    ),
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(NuviRadii.card),
                        topRight: Radius.circular(NuviRadii.card),
                      ),
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.image_outlined,
                                    color: NuviColors.border,
                                    size: 48,
                                  ),
                            )
                          : const Icon(
                              Icons.image_outlined,
                              color: NuviColors.border,
                              size: 48,
                            ),
                    ),
                  ),
                  if (badgeText != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: NuviColors.secondary,
                          borderRadius: BorderRadius.circular(NuviRadii.small),
                        ),
                        child: Text(
                          badgeText!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: NuviColors.onSecondary,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: NuviColors.onSurface.withValues(alpha: 0.5),
                      ),
                      onPressed: onFavoriteToggle,
                    ),
                  ),
                ],
              ),
            ),
            // Details area
            Padding(
              padding: const EdgeInsets.all(NuviSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: NuviColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: NuviTypography.textTheme.labelLarge?.copyWith(
                          color: NuviColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: NuviSpacing.xs),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NuviTypography.textTheme.labelLarge,
                  ),
                  const SizedBox(height: NuviSpacing.xs),
                  Row(
                    children: [
                      Text(
                        salePrice ?? price,
                        style: NuviTypography.textTheme.labelLarge?.copyWith(
                          color: NuviColors.accent,
                        ),
                      ),
                      if (salePrice != null) ...[
                        const SizedBox(width: NuviSpacing.xs),
                        Text(
                          price,
                          style: NuviTypography.textTheme.bodySmall?.copyWith(
                            color: NuviColors.onSurface.withValues(alpha: 0.5),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (colorSwatches != null && colorSwatches!.isNotEmpty) ...[
                    const SizedBox(height: NuviSpacing.xs),
                    Row(
                      children: colorSwatches!.map((color) {
                        return Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: NuviColors.border,
                              width: 1,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
