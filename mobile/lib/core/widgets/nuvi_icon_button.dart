import 'package:flutter/material.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_decorations.dart';
import '../theme/nuvi_spacing.dart';
import 'nuvi_badge.dart';
import 'nuvi_pressable.dart';

/// Round icon button with a 44pt touch target. `onPhoto` gives the white 92%
/// disc with a shadow used over imagery.
class NuviIconButton extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final double size;
  final double iconSize;
  final bool onPhoto;
  final Color? color;
  final Color? background;
  final int badgeCount;

  const NuviIconButton({
    super.key,
    this.icon,
    this.child,
    required this.onPressed,
    required this.semanticLabel,
    this.size = 40,
    this.iconSize = 22,
    this.onPhoto = false,
    this.color,
    this.background,
    this.badgeCount = 0,
  }) : assert(icon != null || child != null);

  @override
  Widget build(BuildContext context) {
    final visual = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            background ??
            (onPhoto ? NuviColors.photoButton : Colors.transparent),
        boxShadow: onPhoto ? NuviShadows.floating : null,
      ),
      alignment: Alignment.center,
      child:
          child ?? Icon(icon, size: iconSize, color: color ?? NuviColors.ink),
    );

    return NuviPressable(
      onTap: onPressed,
      semanticLabel: badgeCount > 0
          ? '$semanticLabel, $badgeCount'
          : semanticLabel,
      child: SizedBox(
        width: size < NuviSpacing.minTouchTarget
            ? NuviSpacing.minTouchTarget
            : size,
        height: size < NuviSpacing.minTouchTarget
            ? NuviSpacing.minTouchTarget
            : size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            ExcludeSemantics(child: visual),
            if (badgeCount > 0)
              Positioned(
                top: 2,
                right: 0,
                child: ExcludeSemantics(
                  child: NuviCountBadge(count: badgeCount),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
