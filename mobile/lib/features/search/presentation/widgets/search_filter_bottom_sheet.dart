import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_typography.dart';
import '../../../../core/widgets/nuvi_button.dart';
import '../../domain/search_filter_state.dart';

class SearchFilterBottomSheet extends StatefulWidget {
  final SearchFilterState initialFilter;
  final ValueChanged<SearchFilterState> onApply;

  const SearchFilterBottomSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required SearchFilterState initialFilter,
    required ValueChanged<SearchFilterState> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchFilterBottomSheet(
        initialFilter: initialFilter,
        onApply: onApply,
      ),
    );
  }

  @override
  State<SearchFilterBottomSheet> createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  late SearchSortOption _selectedSort;
  late String? _selectedCategory;
  late String? _selectedSize;
  late bool _inStockOnly;

  static const List<String> _categories = [
    'Rompers',
    'Dresses',
    'Cardigans',
    'Overalls',
    'Tops',
    'Sets',
  ];

  static const List<String> _sizes = ['0-6M', '6-12M', '1-2Y', '2-4Y', '4-6Y'];

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.initialFilter.sortOption;
    _selectedCategory = widget.initialFilter.category;
    _selectedSize = widget.initialFilter.size;
    _inStockOnly = widget.initialFilter.inStockOnly;
  }

  void _reset() {
    setState(() {
      _selectedSort = SearchSortOption.relevance;
      _selectedCategory = null;
      _selectedSize = null;
      _inStockOnly = false;
    });
  }

  void _apply() {
    final updated = widget.initialFilter.copyWith(
      sortOption: _selectedSort,
      category: _selectedCategory,
      clearCategory: _selectedCategory == null,
      size: _selectedSize,
      clearSize: _selectedSize == null,
      inStockOnly: _inStockOnly,
    );
    widget.onApply(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NuviColors.surface,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(NuviRadii.card),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: NuviSpacing.lg,
          left: NuviSpacing.lg,
          right: NuviSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + NuviSpacing.xl,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar & Header
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: NuviColors.border,
                    borderRadius: BorderRadius.circular(NuviRadii.pill),
                  ),
                ),
              ),
              const SizedBox(height: NuviSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters & Sort',
                    style: NuviTypography.textTheme.headlineMedium?.copyWith(
                      color: NuviColors.primary,
                    ),
                  ),
                  TextButton(
                    onPressed: _reset,
                    child: Text(
                      'Reset All',
                      style: NuviTypography.textTheme.labelMedium?.copyWith(
                        color: NuviColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: NuviColors.border),
              const SizedBox(height: NuviSpacing.sm),

              // Sort Section
              Text(
                'Sort By',
                style: NuviTypography.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: NuviColors.primary,
                ),
              ),
              const SizedBox(height: NuviSpacing.sm),
              Wrap(
                spacing: NuviSpacing.xs,
                runSpacing: NuviSpacing.xs,
                children: SearchSortOption.values.map((sort) {
                  final isSelected = _selectedSort == sort;
                  return ChoiceChip(
                    label: Text(sort.label),
                    selected: isSelected,
                    selectedColor: NuviColors.secondary,
                    backgroundColor: NuviColors.surfaceVariant,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? NuviColors.onSecondary
                          : NuviColors.onSurface,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NuviRadii.pill),
                      side: BorderSide(
                        color: isSelected
                            ? NuviColors.secondary
                            : NuviColors.border,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedSort = sort);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: NuviSpacing.lg),

              // Category Section
              Text(
                'Category',
                style: NuviTypography.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: NuviColors.primary,
                ),
              ),
              const SizedBox(height: NuviSpacing.sm),
              Wrap(
                spacing: NuviSpacing.xs,
                runSpacing: NuviSpacing.xs,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: NuviColors.secondary,
                    backgroundColor: NuviColors.surfaceVariant,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? NuviColors.onSecondary
                          : NuviColors.onSurface,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NuviRadii.pill),
                      side: BorderSide(
                        color: isSelected
                            ? NuviColors.secondary
                            : NuviColors.border,
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: NuviSpacing.lg),

              // Size Section
              Text(
                'Size',
                style: NuviTypography.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: NuviColors.primary,
                ),
              ),
              const SizedBox(height: NuviSpacing.sm),
              Wrap(
                spacing: NuviSpacing.xs,
                runSpacing: NuviSpacing.xs,
                children: _sizes.map((size) {
                  final isSelected = _selectedSize == size;
                  return FilterChip(
                    label: Text(size),
                    selected: isSelected,
                    selectedColor: NuviColors.secondary,
                    backgroundColor: NuviColors.surfaceVariant,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? NuviColors.onSecondary
                          : NuviColors.onSurface,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NuviRadii.pill),
                      side: BorderSide(
                        color: isSelected
                            ? NuviColors.secondary
                            : NuviColors.border,
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedSize = selected ? size : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: NuviSpacing.lg),

              // In-stock switch
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'In Stock Only',
                  style: NuviTypography.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: NuviColors.primary,
                  ),
                ),
                subtitle: Text(
                  'Hide currently unavailable styles',
                  style: NuviTypography.textTheme.bodySmall?.copyWith(
                    color: NuviColors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                value: _inStockOnly,
                activeThumbColor: NuviColors.secondary,
                onChanged: (val) => setState(() => _inStockOnly = val),
              ),
              const SizedBox(height: NuviSpacing.xl),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: NuviButton(
                      text: 'Cancel',
                      type: NuviButtonType.secondary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: NuviSpacing.md),
                  Expanded(
                    child: NuviButton(
                      text: 'Apply Filters',
                      type: NuviButtonType.primary,
                      onPressed: _apply,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
