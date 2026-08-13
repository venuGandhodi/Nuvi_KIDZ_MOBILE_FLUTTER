import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_decorations.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';

class HeroBannerSection extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onShopCollectionPressed;

  const HeroBannerSection({
    super.key,
    this.imageUrl,
    this.onShopCollectionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 410,
      margin: const EdgeInsets.symmetric(
        horizontal: NuviSpacing.md,
        vertical: NuviSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: NuviColors.primaryContainer,
        borderRadius: BorderRadius.circular(NuviRadii.card),
        boxShadow: NuviShadows.subtle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(NuviRadii.card),
        child: Stack(
          children: [
            // Background Image with fallback
            if (imageUrl != null)
              Positioned.fill(
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: NuviColors.primaryContainer),
                ),
              ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      NuviColors.primary.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),
            // Text content
            Padding(
              padding: const EdgeInsets.all(NuviSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Autumn Adventures\nAwait',
                    style: NuviTypography.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: NuviSpacing.sm),
                  Text(
                    'Discover our new collection of cozy, organic cotton essentials designed for little explorers.',
                    style: NuviTypography.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: NuviSpacing.lg),
                  ElevatedButton(
                    onPressed: onShopCollectionPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NuviColors.secondary,
                      foregroundColor: NuviColors.primary,
                      elevation: 2,
                      shadowColor: Colors.black.withValues(alpha: 0.25),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(NuviRadii.pill),
                      ),
                    ),
                    child: Text(
                      'Shop the Collection',
                      style: NuviTypography.textTheme.labelLarge?.copyWith(
                        color: NuviColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
