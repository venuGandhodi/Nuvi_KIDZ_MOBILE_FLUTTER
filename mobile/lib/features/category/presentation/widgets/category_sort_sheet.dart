import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../domain/category_filter.dart';

class CategorySortSheet extends StatelessWidget {
  final SortOption currentSort;
  final ValueChanged<SortOption> onSelectSort;

  const CategorySortSheet({
    super.key,
    required this.currentSort,
    required this.onSelectSort,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: NuviColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          top: NuviSpacing.lg,
          left: NuviSpacing.lg,
          right: NuviSpacing.lg,
          bottom: MediaQuery.of(context).padding.bottom + NuviSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort By',
                style: NuviTypography.textTheme.headlineMedium?.copyWith(
                  color: NuviColors.primary,
                ),
              ),
              const SizedBox(height: NuviSpacing.md),
              ...SortOption.values.map((option) {
                final isSelected = option == currentSort;
                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      option.label,
                      style: NuviTypography.textTheme.labelLarge?.copyWith(
                        color: isSelected
                            ? NuviColors.secondary
                            : NuviColors.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: NuviColors.secondary)
                        : null,
                    onTap: () {
                      onSelectSort(option);
                      Navigator.pop(context);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
