import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_decorations.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../domain/home_hero.dart';

class HeroBannerSection extends StatelessWidget {
  final HomeHero? hero;
  final String? imageUrl;
  final VoidCallback? onShopCollectionPressed;

  const HeroBannerSection({
    super.key,
    this.hero,
    this.imageUrl,
    this.onShopCollectionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final displayImageUrl =
        hero?.imageUrl ??
        imageUrl ??
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAFpju392Q1xn2AJbOH6i84veMzV8CIixbhDvSfev46-u4_JZayJQIFnXhrHEVwvacS8R3Yqz5xKPu96JKK13KMhQKxFxLkLnJXz9NyUwcIZ4wn0co3f1eqH4Qpm3q-U4Ugpoqku-8t-1F7pb_aL95IXewiYYQ8_64qWmtarZhwe1gnvFEtqcpH2u82uIp_phTTft_zPdY8hPZjpq2y0BYUg1FsGCMEoLThIKZ_Q5E5vMJdLVJRJbMjsQ';

    final title = hero?.title ?? 'Autumn Adventures\nAwait';
    final description =
        hero?.description ??
        'Discover our new collection of cozy, organic cotton essentials designed for little explorers.';
    final buttonText = hero?.buttonText ?? 'Shop the Collection';

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
            Positioned.fill(
              child: Image.network(
                displayImageUrl,
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
                    stops: const [0.0, 0.78],
                    colors: [
                      const Color(0xFF9C8560).withValues(alpha: 0.05),
                      NuviColors.primary.withValues(alpha: 0.82),
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
                    title,
                    style: NuviTypography.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: NuviSpacing.sm),
                  Text(
                    description,
                    style: NuviTypography.textTheme.bodyMedium?.copyWith(
                      fontSize: 13.5,
                      color: Colors.white.withValues(alpha: 0.93),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: NuviSpacing.lg),
                  ElevatedButton(
                    onPressed: onShopCollectionPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NuviColors.secondary,
                      foregroundColor: NuviColors.onSecondary,
                      elevation: 2,
                      shadowColor: Colors.black.withValues(alpha: 0.25),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(NuviRadii.pill),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: NuviTypography.textTheme.labelLarge?.copyWith(
                        fontSize: 14,
                        color: NuviColors.onSecondary,
                        fontWeight: FontWeight.w800,
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
