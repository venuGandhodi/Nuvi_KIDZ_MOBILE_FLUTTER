import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';

/// Tappable search-bar-styled entry point on Home that pushes to the
/// dedicated Search screen, rather than an inline functional search field.
class HomeSearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const HomeSearchBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NuviRadii.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: NuviSpacing.md,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: NuviColors.fieldBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: NuviColors.border, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: NuviColors.onSurface.withValues(alpha: 0.55),
                size: 18,
              ),
              const SizedBox(width: NuviSpacing.sm),
              Text(
                'Search products, colors, and styles',
                style: NuviTypography.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: NuviColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
