import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_bottom_sheet.dart';
import '../../../../core/widgets/nuvi_button.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
import '../../domain/collection_filter.dart';

const _kQuickKinds = [
  CollectionFilterKind.age,
  CollectionFilterKind.price,
  CollectionFilterKind.color,
];

/// Top row of the collection page: Age · Price · Color · Sort pills and the
/// Filter button that shows or hides the extra filter options.
class CollectionFilterBar extends StatelessWidget {
  final Set<CollectionFilterKind> activeKinds;
  final bool sortActive;
  final bool optionsOpen;
  final ValueChanged<CollectionFilterKind> onOpenKind;
  final VoidCallback onOpenSort;
  final VoidCallback onToggleOptions;

  const CollectionFilterBar({
    super.key,
    required this.activeKinds,
    required this.sortActive,
    required this.optionsOpen,
    required this.onOpenKind,
    required this.onOpenSort,
    required this.onToggleOptions,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Container(
      color: NuviColors.cream,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            for (final kind in _kQuickKinds) ...[
              Expanded(
                flex: kind == CollectionFilterKind.age ? 10 : 11,
                child: _Pill(
                  leading: _KindIcon(kind: kind, size: 16),
                  label: kind.label,
                  active: activeKinds.contains(kind),
                  onTap: () => onOpenKind(kind),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Expanded(
              flex: 10,
              child: _Pill(
                leading: const Icon(
                  Icons.swap_vert_rounded,
                  size: 16,
                  color: NuviColors.ink,
                ),
                label: 'Sort',
                active: sortActive,
                onTap: onOpenSort,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 11,
              child: NuviPressable(
                onTap: onToggleOptions,
                semanticLabel: optionsOpen
                    ? 'Hide filter options'
                    : 'Show filter options',
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: optionsOpen ? NuviColors.leafDark : x.leaf,
                    borderRadius: BorderRadius.circular(NuviRadii.pill),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.tune_rounded,
                          size: 16,
                          color: NuviColors.cream,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Filter',
                          style: x.nunito(
                            13.5,
                            weight: FontWeight.w700,
                            color: NuviColors.cream,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final Widget leading;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Pill({
    required this.leading,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return NuviPressable(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: active ? x.goldSoft : NuviColors.white,
          borderRadius: BorderRadius.circular(NuviRadii.pill),
          border: Border.all(
            color: active ? x.gold : NuviColors.orderBorder,
            width: active ? 1.5 : 1,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            children: [
              leading,
              const SizedBox(width: 4),
              Text(label, style: x.nunito(13.5, weight: FontWeight.w600)),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: NuviColors.ink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The extra filter cards shown after tapping Filter.
class CollectionFilterOptions extends StatelessWidget {
  final List<CollectionFilterKind> kinds;
  final Set<CollectionFilterKind> activeKinds;
  final ValueChanged<CollectionFilterKind> onOpenKind;

  const CollectionFilterOptions({
    super.key,
    required this.kinds,
    required this.activeKinds,
    required this.onOpenKind,
  });

  static const double _gap = 6;
  static const double _minCard = 52;

  @override
  Widget build(BuildContext context) {
    // Price already has its own pill in the top row.
    final shown = [
      for (final k in kinds)
        if (k != CollectionFilterKind.price) k,
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fit =
              (constraints.maxWidth - _gap * (shown.length - 1)) / shown.length;
          Widget card(CollectionFilterKind k) => _OptionCard(
            kind: k,
            active: activeKinds.contains(k),
            onTap: () => onOpenKind(k),
          );
          // All cards share the row; on narrow panes they scroll instead.
          if (fit >= _minCard) {
            return SizedBox(
              height: 66,
              child: Row(
                children: [
                  for (final (i, k) in shown.indexed) ...[
                    if (i > 0) const SizedBox(width: _gap),
                    Expanded(child: card(k)),
                  ],
                ],
              ),
            );
          }
          return SizedBox(
            height: 66,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: shown.length,
              separatorBuilder: (_, _) => const SizedBox(width: _gap),
              itemBuilder: (_, i) =>
                  SizedBox(width: _minCard + 8, child: card(shown[i])),
            ),
          );
        },
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final CollectionFilterKind kind;
  final bool active;
  final VoidCallback onTap;

  const _OptionCard({
    required this.kind,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return NuviPressable(
      onTap: onTap,
      semanticLabel: '${kind.label} filter',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: active ? x.goldSoft : NuviColors.white,
          borderRadius: BorderRadius.circular(NuviRadii.image),
          border: Border.all(
            color: active ? x.gold : NuviColors.orderBorder,
            width: active ? 1.5 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F78461E),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _KindIcon(kind: kind, size: 20),
            const SizedBox(height: 3),
            Text(
              kind.label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: x.nunito(10.5, weight: FontWeight.w600, height: 1.1),
            ),
          ],
        ),
      ),
    );
  }
}

/// "N Products · Clear All · [Age: 0 – 2Y ✕] …"
class CollectionFilterSummary extends StatelessWidget {
  final int productCount;
  final List<SelectedFilterValue> selected;
  final ValueChanged<SelectedFilterValue> onRemove;
  final VoidCallback onClearAll;

  const CollectionFilterSummary({
    super.key,
    required this.productCount,
    required this.selected,
    required this.onRemove,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 12, 4),
      child: SizedBox(
        height: 32,
        child: Row(
          children: [
            Text(
              '$productCount ${productCount == 1 ? 'Product' : 'Products'}',
              style: x.nunito(
                13,
                weight: FontWeight.w600,
                color: NuviColors.leafDark,
              ),
            ),
            if (selected.isNotEmpty) ...[
              const SizedBox(width: 12),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    NuviPressable(
                      onTap: onClearAll,
                      semanticLabel: 'Clear all filters',
                      child: Center(
                        child: Text(
                          'Clear All',
                          style: x
                              .nunito(13, weight: FontWeight.w600)
                              .copyWith(decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                    for (final s in selected) ...[
                      const SizedBox(width: 8),
                      _FilterChip(sel: s, onRemove: () => onRemove(s)),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final SelectedFilterValue sel;
  final VoidCallback onRemove;

  const _FilterChip({required this.sel, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return NuviPressable(
      onTap: onRemove,
      semanticLabel: 'Remove ${sel.chipLabel}',
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
        decoration: BoxDecoration(
          color: NuviColors.sageSoft,
          borderRadius: BorderRadius.circular(NuviRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(sel.chipLabel, style: x.nunito(12, weight: FontWeight.w600)),
            const SizedBox(width: 4),
            const Icon(Icons.close_rounded, size: 13, color: NuviColors.ink),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet listing a filter group's values from Shopify. Price allows
/// one band; other groups allow several values.
class CollectionFilterSheet extends StatefulWidget {
  final CollectionFilterKind kind;
  final List<CollectionFilterValue> values;
  final Set<String> selectedIds;
  final ValueChanged<List<CollectionFilterValue>> onApply;

  const CollectionFilterSheet({
    super.key,
    required this.kind,
    required this.values,
    required this.selectedIds,
    required this.onApply,
  });

  @override
  State<CollectionFilterSheet> createState() => _CollectionFilterSheetState();
}

class _CollectionFilterSheetState extends State<CollectionFilterSheet> {
  late final Set<String> _picked = {...widget.selectedIds};

  bool get _single => widget.kind == CollectionFilterKind.price;

  void _toggle(String id) => setState(() {
    if (_picked.contains(id)) {
      _picked.remove(id);
    } else {
      if (_single) _picked.clear();
      _picked.add(id);
    }
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return NuviSheet(
      title: widget.kind.label,
      titleAction: _picked.isEmpty
          ? null
          : NuviPressable(
              onTap: () => setState(_picked.clear),
              child: Text(
                'Clear',
                style: x
                    .nunito(13.5, weight: FontWeight.w700)
                    .copyWith(decoration: TextDecoration.underline),
              ),
            ),
      footer: widget.values.isEmpty
          ? null
          : NuviButton(
              text: 'Apply',
              type: NuviButtonType.leaf,
              onPressed: () {
                widget.onApply([
                  for (final v in widget.values)
                    if (_picked.contains(v.id)) v,
                ]);
                Navigator.pop(context);
              },
            ),
      child: widget.values.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No ${widget.kind.label.toLowerCase()} options for this '
                'collection yet.',
                textAlign: TextAlign.center,
                style: x.nunito(14, color: NuviColors.inkMuted),
              ),
            )
          : Column(
              children: [
                for (final v in widget.values)
                  NuviPressable(
                    onTap: () => _toggle(v.id),
                    pressedScale: 0.99,
                    child: Semantics(
                      selected: _picked.contains(v.id),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 50),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: NuviColors.line),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _picked.contains(v.id)
                                  ? (_single
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.check_box_rounded)
                                  : (_single
                                        ? Icons.radio_button_off_rounded
                                        : Icons
                                              .check_box_outline_blank_rounded),
                              color: _picked.contains(v.id)
                                  ? x.leaf
                                  : NuviColors.inkFaint,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                v.label,
                                style: x.nunito(15, weight: FontWeight.w600),
                              ),
                            ),
                            if (v.count > 0)
                              Text('(${v.count})', style: x.small),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

/// Icon per filter group, matching the design's coral / leaf palette.
class _KindIcon extends StatelessWidget {
  final CollectionFilterKind kind;
  final double size;

  const _KindIcon({required this.kind, required this.size});

  @override
  Widget build(BuildContext context) {
    final leaf = context.nuvi.leaf;
    const coral = NuviBagColors.coral;
    return switch (kind) {
      CollectionFilterKind.color =>
        size < 18
            ? _ColorDots(size: size)
            : Icon(Icons.palette_outlined, size: size, color: coral),
      CollectionFilterKind.age => Icon(
        Icons.child_care_outlined,
        size: size,
        color: coral,
      ),
      CollectionFilterKind.price => Text(
        '₹',
        style: context.nuvi.nunito(size - 1, weight: FontWeight.w700),
      ),
      CollectionFilterKind.gender => Icon(
        Icons.male_rounded,
        size: size,
        color: leaf,
      ),
      CollectionFilterKind.occasion => Icon(
        Icons.event_outlined,
        size: size,
        color: coral,
      ),
      CollectionFilterKind.category => Icon(
        Icons.grid_view_rounded,
        size: size,
        color: leaf,
      ),
      CollectionFilterKind.delivery => Icon(
        Icons.local_shipping_outlined,
        size: size,
        color: leaf,
      ),
    };
  }
}

/// Four overlapping colour dots for the Color pill.
class _ColorDots extends StatelessWidget {
  final double size;

  const _ColorDots({required this.size});

  static const _dots = [
    (0.0, 0.33, NuviColors.gold),
    (0.45, 0.33, NuviColors.skyBlue),
    (0.22, 0.0, NuviColors.sale),
    (0.22, 0.55, NuviColors.leaf),
  ];

  @override
  Widget build(BuildContext context) {
    final d = size * 0.5;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            for (final (dx, dy, c) in _dots)
              Positioned(
                left: dx * size,
                top: dy * size,
                child: Container(
                  width: d,
                  height: d,
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
