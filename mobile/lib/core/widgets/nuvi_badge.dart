import 'package:flutter/material.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_motion.dart';
import '../theme/nuvi_radii.dart';
import '../theme/nuvi_theme_ext.dart';

enum NuviBadgeKind { bestseller, newArrival, sale, neutral }

/// Corner pill: Bestseller (gold), New, Sale / "% OFF".
class NuviBadge extends StatelessWidget {
  final String label;
  final NuviBadgeKind kind;
  final bool compact;

  const NuviBadge({
    super.key,
    required this.label,
    this.kind = NuviBadgeKind.neutral,
    this.compact = false,
  });

  /// Maps a product's badge text (e.g. "SALE", "NEW") to a badge.
  factory NuviBadge.fromText(String text, {bool compact = false}) {
    final t = text.toLowerCase();
    final kind = t.contains('sale') || t.contains('off')
        ? NuviBadgeKind.sale
        : t.contains('new')
        ? NuviBadgeKind.newArrival
        : t.contains('best')
        ? NuviBadgeKind.bestseller
        : NuviBadgeKind.neutral;
    final label = switch (kind) {
      NuviBadgeKind.sale => text.length <= 4 ? 'Sale' : text,
      NuviBadgeKind.newArrival => 'NEW',
      NuviBadgeKind.bestseller => 'Bestseller',
      NuviBadgeKind.neutral => text,
    };
    return NuviBadge(label: label, kind: kind, compact: compact);
  }

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final (Color bg, Color fg) = switch (kind) {
      NuviBadgeKind.bestseller => (x.gold, x.onGold),
      NuviBadgeKind.newArrival => (NuviColors.newBadge, NuviColors.white),
      NuviBadgeKind.sale => (NuviColors.sale, NuviColors.white),
      NuviBadgeKind.neutral => (NuviColors.ink, NuviColors.cream),
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(NuviRadii.pill),
      ),
      child: Text(
        label,
        style: x.baloo(
          compact ? 10.5 : 11.5,
          weight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

/// Gold dot with an ink number that "pops" whenever the count changes.
class NuviCountBadge extends StatelessWidget {
  final int count;

  const NuviCountBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return AnimatedSwitcher(
      duration: NuviMotion.of(context),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.25), weight: 60),
          TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 40),
        ]).animate(animation),
        child: child,
      ),
      child: Container(
        key: ValueKey(count),
        constraints: const BoxConstraints(minWidth: 18),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: x.gold,
          borderRadius: BorderRadius.circular(NuviRadii.pill),
          border: Border.all(color: NuviColors.cream, width: 1.5),
        ),
        child: SizedBox(
          height: 15,
          child: Center(
            widthFactor: 1,
            child: Text(
              count > 99 ? '99+' : '$count',
              style: x
                  .baloo(10.5, weight: FontWeight.w800, color: x.onGold)
                  .copyWith(height: 1.1),
            ),
          ),
        ),
      ),
    );
  }
}
