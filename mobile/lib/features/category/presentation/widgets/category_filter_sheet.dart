import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_accordion.dart';
import '../../../../core/widgets/nuvi_bottom_sheet.dart';
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

  int get _count =>
      _selectedCategoryIds.length +
      _selectedAgeFilters.length +
      (_inStockOnly ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return NuviSheet(
      title: 'Filter Products',
      fullHeight: true,
      footer: Row(
        children: [
          NuviTextAction(text: 'Clear all', onTap: _reset),
          const SizedBox(width: NuviSpacing.md),
          Expanded(
            child: NuviButton(
              text: _count == 0 ? 'Apply Filters' : 'Apply Filters ($_count)',
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NuviAccordion(
            title: 'Categories',
            icon: Icons.category_outlined,
            initiallyExpanded: true,
            trailingText: _selectedCategoryIds.isEmpty
                ? null
                : '${_selectedCategoryIds.length} selected',
            content: Wrap(
              spacing: NuviSpacing.sm,
              runSpacing: 2,
              children: kCategoryFilterOptions.entries.map((cat) {
                return NuviPillSelector(
                  label: cat.value,
                  isSelected: _selectedCategoryIds.contains(cat.key),
                  onTap: () => _toggleCategory(cat.key),
                );
              }).toList(),
            ),
          ),
          NuviAccordion(
            title: 'Age / Size',
            icon: Icons.straighten_rounded,
            initiallyExpanded: true,
            trailingText: _selectedAgeFilters.isEmpty
                ? null
                : '${_selectedAgeFilters.length} selected',
            content: Wrap(
              spacing: NuviSpacing.sm,
              runSpacing: 2,
              children: kAgeFilterOptions.map((age) {
                return NuviPillSelector(
                  label: age,
                  isSelected: _selectedAgeFilters.contains(age),
                  onTap: () => _toggleAge(age),
                );
              }).toList(),
            ),
          ),
          NuviAccordion(
            title: 'Availability',
            icon: Icons.inventory_2_outlined,
            initiallyExpanded: true,
            content: Row(
              children: [
                Expanded(
                  child: Text(
                    'In Stock Only',
                    style: x.nunito(15, weight: FontWeight.w700),
                  ),
                ),
                Switch.adaptive(
                  value: _inStockOnly,
                  activeTrackColor: x.gold,
                  onChanged: (val) => setState(() => _inStockOnly = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const Map<String, String> kCategoryFilterOptions = {
  'cat_girls': 'Girls',
  'cat_boys': 'Boys',
  'cat_baby': 'Baby',
  'cat_footwear': 'Footwear',
};

const List<String> kAgeFilterOptions = [
  '0-3m',
  '3-6m',
  '6-12m',
  '1-2y',
  '3-5y',
  '6-8y',
];
