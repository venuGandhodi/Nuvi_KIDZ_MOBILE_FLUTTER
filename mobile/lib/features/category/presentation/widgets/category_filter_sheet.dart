import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../../../core/widgets/nuvi_button.dart';
import '../../../../core/widgets/nuvi_pill_selector.dart';
import '../../domain/category_filter.dart';

class CategoryFilterSheet extends StatefulWidget {
  final FilterState initialFilterState;
  final ValueChanged<FilterState> onApply;

  const CategoryFilterSheet({
    super.key,
    required this.initialFilterState,
    required this.onApply,
  });

  @override
  State<CategoryFilterSheet> createState() => _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends State<CategoryFilterSheet> {
  late Set<String> _selectedCategoryIds;
  late Set<String> _selectedAgeFilters;
  late bool _inStockOnly;

  @override
  void initState() {
    super.initState();
    _selectedCategoryIds = Set<String>.from(
      widget.initialFilterState.selectedCategoryIds,
    );
    _selectedAgeFilters = Set<String>.from(
      widget.initialFilterState.selectedAgeFilters,
    );
    _inStockOnly = widget.initialFilterState.inStockOnly;
  }

  void _toggleCategory(String id) {
    setState(() {
      if (_selectedCategoryIds.contains(id)) {
        _selectedCategoryIds.remove(id);
      } else {
        _selectedCategoryIds.add(id);
      }
    });
  }

  void _toggleAge(String id) {
    setState(() {
      if (_selectedAgeFilters.contains(id)) {
        _selectedAgeFilters.remove(id);
      } else {
        _selectedAgeFilters.add(id);
      }
    });
  }

  void _reset() {
    setState(() {
      _selectedCategoryIds.clear();
      _selectedAgeFilters.clear();
      _inStockOnly = false;
    });
  }

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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Products',
                    style: NuviTypography.textTheme.headlineMedium?.copyWith(
                      color: NuviColors.primary,
                    ),
                  ),
                  TextButton(
                    onPressed: _reset,
                    child: Text(
                      'Clear All',
                      style: NuviTypography.textTheme.labelLarge?.copyWith(
                        color: NuviColors.secondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NuviSpacing.md),

              // Categories
              Text(
                'Categories',
                style: NuviTypography.textTheme.labelLarge?.copyWith(
                  color: NuviColors.primary,
                ),
              ),
              const SizedBox(height: NuviSpacing.sm),
              Wrap(
                spacing: NuviSpacing.sm,
                runSpacing: NuviSpacing.sm,
                children:
                    [
                      ('cat_girls', 'Girls'),
                      ('cat_boys', 'Boys'),
                      ('cat_baby', 'Baby'),
                      ('cat_footwear', 'Footwear'),
                    ].map((cat) {
                      final isSelected = _selectedCategoryIds.contains(cat.$1);
                      return NuviPillSelector(
                        label: cat.$2,
                        isSelected: isSelected,
                        onTap: () => _toggleCategory(cat.$1),
                      );
                    }).toList(),
              ),
              const SizedBox(height: NuviSpacing.lg),

              // Age / Size
              Text(
                'Age / Size',
                style: NuviTypography.textTheme.labelLarge?.copyWith(
                  color: NuviColors.primary,
                ),
              ),
              const SizedBox(height: NuviSpacing.sm),
              Wrap(
                spacing: NuviSpacing.sm,
                runSpacing: NuviSpacing.sm,
                children: ['0-3m', '3-6m', '6-12m', '1-2y', '3-5y', '6-8y'].map(
                  (age) {
                    final isSelected = _selectedAgeFilters.contains(age);
                    return NuviPillSelector(
                      label: age,
                      isSelected: isSelected,
                      onTap: () => _toggleAge(age),
                    );
                  },
                ).toList(),
              ),
              const SizedBox(height: NuviSpacing.lg),

              // In Stock switch
              Material(
                color: Colors.transparent,
                child: SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  activeTrackColor: NuviColors.secondary,
                  title: Text(
                    'In Stock Only',
                    style: NuviTypography.textTheme.labelLarge?.copyWith(
                      color: NuviColors.primary,
                    ),
                  ),
                  value: _inStockOnly,
                  onChanged: (val) => setState(() => _inStockOnly = val),
                ),
              ),
              const SizedBox(height: NuviSpacing.lg),

              // Apply button
              NuviButton(
                text: 'Apply Filters',
                type: NuviButtonType.primary,
                onPressed: () {
                  widget.onApply(
                    FilterState(
                      selectedCategoryIds: _selectedCategoryIds,
                      selectedAgeFilters: _selectedAgeFilters,
                      inStockOnly: _inStockOnly,
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
