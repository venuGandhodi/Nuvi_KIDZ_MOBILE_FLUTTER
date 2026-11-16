import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_radii.dart';
import '../theme/nuvi_spacing.dart';
import '../theme/nuvi_theme_ext.dart';
import '../theme/nuvi_typography.dart';
import 'nuvi_decor.dart';
import 'nuvi_pressable.dart';

/// Coupon ticket with notched sides and a dashed divider. Tapping copies the
/// code and briefly shows "Copied!".
class NuviCouponTicket extends StatefulWidget {
  final String title;
  final String code;
  final String? condition;
  final ValueChanged<String>? onCopied;

  const NuviCouponTicket({
    super.key,
    required this.title,
    required this.code,
    this.condition,
    this.onCopied,
  });

  @override
  State<NuviCouponTicket> createState() => _NuviCouponTicketState();
}

class _NuviCouponTicketState extends State<NuviCouponTicket> {
  bool _copied = false;
  Timer? _reset;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.code));
    widget.onCopied?.call(widget.code);
    setState(() => _copied = true);
    _reset?.cancel();
    _reset = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return NuviPressable(
      onTap: _copy,
      semanticLabel: 'Copy coupon code ${widget.code}',
      child: Container(
        decoration: ShapeDecoration(
          color: NuviColors.card,
          shape: const _TicketBorder(),
          shadows: const [
            BoxShadow(
              color: Color(0x1478461E),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: NuviSpacing.s20,
          vertical: NuviSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: x.baloo(16, weight: FontWeight.w700),
            ),
            if (widget.condition != null) ...[
              const SizedBox(height: 2),
              Text(widget.condition!, style: x.small),
            ],
            const SizedBox(height: NuviSpacing.s12),
            const NuviDashedLine(color: NuviColors.line),
            const SizedBox(height: NuviSpacing.s12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: x.goldSoft,
                    borderRadius: BorderRadius.circular(NuviRadii.pill),
                  ),
                  child: Text(
                    widget.code,
                    style: TextStyle(
                      fontFamily: NuviTypography.monoFont,
                      fontFamilyFallback: NuviTypography.monoFallback,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: NuviColors.ink,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _copied ? 'Copied!' : 'Tap to copy',
                  style: x.nunito(
                    12.5,
                    weight: FontWeight.w800,
                    color: _copied ? NuviColors.leaf : NuviColors.inkMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketBorder extends ShapeBorder {
  const _TicketBorder();

  static const double _radius = NuviRadii.card;
  static const double _notch = 9;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final base = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(_radius)));
    final notchY = rect.top + rect.height * 0.62;
    final notches = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(rect.left, notchY), radius: _notch),
      )
      ..addOval(
        Rect.fromCircle(center: Offset(rect.right, notchY), radius: _notch),
      );
    return Path.combine(PathOperation.difference, base, notches);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
