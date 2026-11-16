import 'package:flutter/material.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_motion.dart';
import '../theme/nuvi_radii.dart';
import '../theme/nuvi_spacing.dart';
import '../theme/nuvi_theme_ext.dart';
import 'nuvi_pressable.dart';

/// Rounded chip: sage-soft fill, selected = ink fill + cream text. With
/// [onRemove] it renders as a removable active-filter chip.
class NuviChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final IconData? icon;
  final bool dense;

  const NuviChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.onRemove,
    this.icon,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final fg = selected ? NuviColors.cream : NuviColors.ink;
    final chip = AnimatedContainer(
      duration: NuviMotion.of(context, NuviMotion.fast),
      curve: NuviMotion.curve,
      constraints: BoxConstraints(minHeight: dense ? 32 : 36),
      padding: EdgeInsets.symmetric(horizontal: dense ? 12 : 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? NuviColors.ink : x.sageSoft,
        borderRadius: BorderRadius.circular(NuviRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: x.nunito(
                dense ? 12.5 : 13.5,
                weight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 4),
            Icon(Icons.close_rounded, size: 15, color: fg),
          ],
        ],
      ),
    );

    return NuviPressable(
      onTap: onRemove ?? onTap,
      semanticLabel: onRemove != null ? 'Remove $label' : null,
      child: Semantics(
        selected: selected,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: NuviSpacing.minTouchTarget,
          ),
          child: Center(widthFactor: 1, child: chip),
        ),
      ),
    );
  }
}
