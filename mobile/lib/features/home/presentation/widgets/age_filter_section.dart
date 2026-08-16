import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../domain/age_filter.dart';

class AgeFilterSection extends StatelessWidget {
  final List<AgeFilter> filters;
  final String? selectedFilterId;
  final ValueChanged<String>? onFilterSelected;

  const AgeFilterSection({
    super.key,
    required this.filters,
    this.selectedFilterId,
    this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.md),
          child: Text(
            'Shop by age',
            style: NuviTypography.textTheme.headlineMedium?.copyWith(
              color: NuviColors.primary,
            ),
          ),
        ),
        const SizedBox(height: NuviSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.md),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filters.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: NuviSpacing.lg,
              crossAxisSpacing: NuviSpacing.sm,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = filter.id == selectedFilterId;
              return GestureDetector(
                onTap: () => onFilterSelected?.call(filter.id),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? NuviColors.secondary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(NuviRadii.pill),
                          child: filter.imageUrl != null
                              ? Image.network(
                                  filter.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: NuviColors.surfaceVariant,
                                        child: const Icon(
                                          Icons.child_care,
                                          color: NuviColors.primary,
                                        ),
                                      ),
                                )
                              : Container(
                                  color: NuviColors.surfaceVariant,
                                  child: const Icon(
                                    Icons.child_care,
                                    color: NuviColors.primary,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: NuviSpacing.xs),
                    Text(
                      filter.label,
                      textAlign: TextAlign.center,
                      style: NuviTypography.textTheme.labelLarge?.copyWith(
                        color: isSelected
                            ? NuviColors.primary
                            : NuviColors.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
