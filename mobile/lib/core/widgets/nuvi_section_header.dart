import 'package:flutter/material.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_spacing.dart';
import '../theme/nuvi_theme_ext.dart';
import 'nuvi_button.dart';
import 'nuvi_decor.dart';

/// Gold uppercase eyebrow with short 2pt rules either side.
class NuviEyebrow extends StatelessWidget {
  final String text;
  final bool lines;
  final Color? color;

  const NuviEyebrow(this.text, {super.key, this.lines = true, this.color});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final c = color ?? x.goldText;
    Widget rule() => Container(
      width: 14,
      height: 2,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(2),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (lines) ...[rule(), const SizedBox(width: 8)],
        Flexible(
          child: Text(
            text.toUpperCase(),
            style: x.eyebrow.copyWith(color: c),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (lines) ...[const SizedBox(width: 8), rule()],
      ],
    );
  }
}

/// Eyebrow + Baloo heading (+ subtitle, "View all ›"). Centred on Home.
class NuviSectionHeader extends StatelessWidget {
  final String title;
  final String? eyebrow;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool centered;
  final bool swoosh;
  final TextStyle? titleStyle;

  const NuviSectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.centered = false,
    this.swoosh = false,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final align = centered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.start;

    final heading = Column(
      crossAxisAlignment: align,
      children: [
        if (eyebrow != null) ...[
          NuviEyebrow(eyebrow!, lines: centered),
          const SizedBox(height: 6),
        ],
        Text(title, textAlign: textAlign, style: titleStyle ?? x.h2),
        if (swoosh) ...[
          const SizedBox(height: 2),
          NuviSwoosh(width: 84, color: x.gold),
        ],
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!, textAlign: textAlign, style: x.small),
        ],
      ],
    );

    final action = actionLabel != null
        ? NuviTextAction(
            text: actionLabel!,
            onTap: onAction,
            chevron: true,
            color: NuviColors.ink,
          )
        : null;

    if (centered) {
      return Column(
        children: [
          heading,
          if (action != null) ...[
            const SizedBox(height: NuviSpacing.xs),
            action,
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: heading),
        ?action,
      ],
    );
  }
}
