import 'package:flutter/material.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_motion.dart';
import '../theme/nuvi_spacing.dart';
import '../theme/nuvi_theme_ext.dart';
import 'nuvi_pressable.dart';

/// Accordion row: optional icon, title, chevron that rotates 180°, hairline
/// divider below.
class NuviAccordion extends StatefulWidget {
  final String title;
  final Widget content;
  final bool initiallyExpanded;
  final IconData? icon;
  final bool divider;
  final String? trailingText;

  const NuviAccordion({
    super.key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
    this.icon,
    this.divider = true,
    this.trailingText,
  });

  @override
  State<NuviAccordion> createState() => _NuviAccordionState();
}

class _NuviAccordionState extends State<NuviAccordion> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final duration = NuviMotion.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NuviPressable(
          onTap: () => setState(() => _expanded = !_expanded),
          pressedScale: 0.99,
          haptic: false,
          child: Semantics(
            expanded: _expanded,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 20, color: NuviColors.ink),
                    const SizedBox(width: NuviSpacing.s12),
                  ],
                  Expanded(
                    child: Text(
                      widget.title,
                      style: x.baloo(15.5, weight: FontWeight.w600),
                    ),
                  ),
                  if (widget.trailingText != null) ...[
                    Text(widget.trailingText!, style: x.small),
                    const SizedBox(width: NuviSpacing.sm),
                  ],
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: duration,
                    curve: NuviMotion.curve,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: NuviColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: duration,
          curve: NuviMotion.curve,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(bottom: NuviSpacing.md),
                  child: DefaultTextStyle.merge(
                    style: x.bodyMuted,
                    child: widget.content,
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        if (widget.divider) const Divider(height: 1, color: NuviColors.line),
      ],
    );
  }
}
