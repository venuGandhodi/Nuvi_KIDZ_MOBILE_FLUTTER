import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_bottom_sheet.dart';
import '../../../../core/widgets/nuvi_button.dart';
import '../../../../core/widgets/nuvi_chip.dart';
import '../../../../core/widgets/nuvi_size_pill.dart';
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
    return showNuviSheet(
      context,
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

  Widget _group(String title, Widget child) {
    final x = context.nuvi;
    return Padding(
      padding: const EdgeInsets.only(bottom: NuviSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: x.baloo(15.5, weight: FontWeight.w700)),
          const SizedBox(height: NuviSpacing.xs),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return NuviSheet(
      title: 'Filters & Sort',
      titleAction: NuviTextAction(text: 'Reset All', onTap: _reset),
      footer: Row(
        children: [
          Expanded(
            child: NuviButton(
              text: 'Cancel',
              type: NuviButtonType.outline,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: NuviSpacing.s12),
          Expanded(
            child: NuviButton(
              text: 'Apply Filters',
              type: NuviButtonType.primary,
              onPressed: _apply,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _group(
            'Sort By',
            Wrap(
              spacing: NuviSpacing.sm,
              children: SearchSortOption.values.map((sort) {
                return NuviChip(
                  label: sort.label,
                  selected: _selectedSort == sort,
                  onTap: () => setState(() => _selectedSort = sort),
                );
              }).toList(),
            ),
          ),
          _group(
            'Category',
            Wrap(
              spacing: NuviSpacing.sm,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return NuviChip(
                  label: category,
                  selected: isSelected,
                  onTap: () => setState(() {
                    _selectedCategory = isSelected ? null : category;
                  }),
                );
              }).toList(),
            ),
          ),
          _group(
            'Size',
            Wrap(
              spacing: NuviSpacing.xs,
              children: _sizes.map((size) {
                final isSelected = _selectedSize == size;
                return NuviSizePill(
                  label: size,
                  selected: isSelected,
                  onTap: () => setState(() {
                    _selectedSize = isSelected ? null : size;
                  }),
                );
              }).toList(),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'In Stock Only',
                      style: x.baloo(15.5, weight: FontWeight.w700),
                    ),
                    Text('Hide currently unavailable styles', style: x.small),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _inStockOnly,
                activeTrackColor: x.gold,
                onChanged: (val) => setState(() => _inStockOnly = val),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
