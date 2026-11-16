import 'package:flutter/material.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_motion.dart';
import '../theme/nuvi_theme_ext.dart';
import 'nuvi_pressable.dart';

/// Compact size option: selected = 2pt ink border + light fill, recommended
/// = gold ring, sold out = dimmed with a diagonal strike.
class NuviSizePill extends StatelessWidget {
  final String label;
  final bool selected;
  final bool recommended;
  final bool soldOut;
  final bool dense;
  final VoidCallback? onTap;

  const NuviSizePill({
    super.key,
    required this.label,
    this.selected = false,
    this.recommended = false,
    this.soldOut = false,
    this.dense = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final borderColor = selected
        ? NuviColors.ink
        : recommended
        ? x.gold
        : NuviColors.line;
    final pill = AnimatedContainer(
      duration: NuviMotion.of(context, NuviMotion.fast),
      constraints: BoxConstraints(
        minWidth: dense ? 30 : 52,
        minHeight: dense ? 24 : 40,
      ),
      padding: EdgeInsets.symmetric(horizontal: dense ? 7 : 12),
      decoration: BoxDecoration(
        color: selected ? x.sageSoft : NuviColors.card,
        borderRadius: BorderRadius.circular(dense ? 7 : 10),
        border: Border.all(
          color: borderColor,
          width: selected || recommended ? 2 : 1.2,
        ),
      ),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Text(
          label,
          maxLines: 1,
          style: x.nunito(
            dense ? 11 : 13.5,
            weight: FontWeight.w700,
            color: soldOut ? NuviColors.inkFaint : NuviColors.ink,
          ),
        ),
      ),
    );

    final content = Opacity(
      opacity: soldOut ? 0.55 : 1,
      child: soldOut
          ? CustomPaint(foregroundPainter: _StrikePainter(), child: pill)
          : pill,
    );

    if (onTap == null) {
      return Semantics(
        label: soldOut ? '$label, sold out' : label,
        child: ExcludeSemantics(child: content),
      );
    }

    return NuviPressable(
      onTap: onTap,
      semanticLabel: soldOut ? '$label, sold out' : 'Size $label',
      child: Semantics(
        selected: selected,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
          child: Center(widthFactor: 1, child: content),
        ),
      ),
    );
  }
}

class _StrikePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.85),
      Offset(size.width * 0.88, size.height * 0.15),
      Paint()
        ..color = NuviColors.inkFaint
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
