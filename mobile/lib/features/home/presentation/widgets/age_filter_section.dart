import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../../../core/widgets/nuvi_pill_selector.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Shop by age',
                style: NuviTypography.textTheme.headlineMedium?.copyWith(
                  color: NuviColors.primary,
                ),
              ),
              const SizedBox(width: NuviSpacing.xs),
              const Icon(Icons.favorite, size: 20, color: NuviColors.primary),
            ],
          ),
          const SizedBox(height: NuviSpacing.md),
          Wrap(
            spacing: NuviSpacing.sm,
            runSpacing: NuviSpacing.sm,
            children: filters.map((filter) {
              final isSelected = filter.id == selectedFilterId;
              return NuviPillSelector(
                label: filter.label,
                isSelected: isSelected,
                onTap: () => onFilterSelected?.call(filter.id),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
