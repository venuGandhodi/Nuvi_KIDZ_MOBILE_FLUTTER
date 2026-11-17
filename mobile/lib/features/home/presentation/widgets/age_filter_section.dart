import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_spacing.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_decor.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
import '../../../../core/widgets/nuvi_section_header.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
import '../../domain/age_filter.dart';

/// "Shop by age" in the website's occasion style: two-column tiles with a
/// photo inside an organic blob, a round icon badge and a label, each in its
/// own tone.
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

  static const _icons = [
    Icons.child_friendly_outlined,
    Icons.toys_outlined,
    Icons.cruelty_free_outlined,
    Icons.directions_run_rounded,
    Icons.school_outlined,
    Icons.celebration_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: NuviSpacing.gutter),
          child: NuviSectionHeader(
            eyebrow: 'Little milestones',
            title: 'Shop by age',
            centered: true,
          ),
        ),
        const SizedBox(height: NuviSpacing.s12),
        SizedBox(
          height: 150 + 18 * (scale - 1),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.gutter),
            itemCount: filters.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final filter = filters[index];
              return SizedBox(
                width: 116,
                child: _AgeTile(
                  filter: filter,
                  tone: NuviTone.all[index % NuviTone.all.length],
                  icon: _icons[index % _icons.length],
                  seed: index,
                  selected: filter.id == selectedFilterId,
                  onTap: () => onFilterSelected?.call(filter.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AgeTile extends StatelessWidget {
  final AgeFilter filter;
  final NuviTone tone;
  final IconData icon;
  final int seed;
  final bool selected;
  final VoidCallback onTap;

  const _AgeTile({
    required this.filter,
    required this.tone,
    required this.icon,
    required this.seed,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return NuviPressable(
      onTap: onTap,
      semanticLabel: 'Shop age ${filter.label}',
      child: Container(
        decoration: BoxDecoration(
          color: tone.tint,
          borderRadius: BorderRadius.circular(NuviRadii.cardLarge),
          border: Border.all(
            color: selected ? tone.accent : Colors.transparent,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ClipPath(
                      clipper: NuviBlobClipper(seed: seed + 3),
                      child: ColoredBox(color: tone.blob),
                    ),
                  ),
                  Positioned.fill(
                    left: 8,
                    right: 8,
                    top: 8,
                    bottom: 6,
                    child: ClipPath(
                      clipper: NuviBlobClipper(seed: seed),
                      child: NuviImage(
                        url: filter.imageUrl,
                        tile: NuviTile.peach,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: NuviColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: tone.blob, width: 2),
                      ),
                      child: Icon(icon, size: 18, color: tone.accent),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filter.label,
              textAlign: TextAlign.center,
              style: x.baloo(16, weight: FontWeight.w700, color: tone.accent),
            ),
          ],
        ),
      ),
    );
  }
}
