import 'package:flutter/material.dart';
import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_bottom_sheet.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
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
    final x = context.nuvi;
    return NuviSheet(
      title: 'Sort By',
      child: Column(
        children: SortOption.values.map((option) {
          final isSelected = option == currentSort;
          return NuviPressable(
            onTap: () {
              onSelectSort(option);
              Navigator.pop(context);
            },
            pressedScale: 0.99,
            child: Semantics(
              selected: isSelected,
              child: Container(
                constraints: const BoxConstraints(minHeight: 52),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: NuviColors.line)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option.label,
                        style: isSelected
                            ? x.baloo(15.5, weight: FontWeight.w700)
                            : x.nunito(15, weight: FontWeight.w600),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: x.goldText),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
