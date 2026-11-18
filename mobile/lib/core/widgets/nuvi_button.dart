import 'package:flutter/material.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_motion.dart';
import '../theme/nuvi_radii.dart';
import '../theme/nuvi_spacing.dart';
import '../theme/nuvi_theme_ext.dart';
import 'nuvi_pressable.dart';

/// primary = gold fill, dark = ink fill, outline = 1.5pt ink border,
/// leaf = Add to Bag green, bag = bag-screen olive. `secondary` and `social`
/// are kept as outline aliases for existing call sites.
enum NuviButtonType {
  primary,
  secondary,
  social,
  dark,
  outline,
  leaf,
  bag,
  coral,
}

class NuviButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final NuviButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final Widget? trailingIcon;
  final double height;

  const NuviButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = NuviButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.trailingIcon,
    this.height = NuviSpacing.buttonHeight,
  });

  const NuviButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.trailingIcon,
    this.height = NuviSpacing.buttonHeight,
  }) : type = NuviButtonType.primary;

  const NuviButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.trailingIcon,
    this.height = NuviSpacing.buttonHeight,
  }) : type = NuviButtonType.secondary;

  const NuviButton.social({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.trailingIcon,
    this.height = NuviSpacing.buttonHeight,
  }) : type = NuviButtonType.social;

  bool get isDisabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    Color background;
    Color foreground;
    BorderSide border = BorderSide.none;

    switch (type) {
      case NuviButtonType.primary:
        background = x.gold;
        foreground = x.onGold;
      case NuviButtonType.dark:
        background = NuviColors.ink;
        foreground = NuviColors.cream;
      case NuviButtonType.leaf:
        background = x.leaf;
        foreground = NuviColors.cream;
      case NuviButtonType.bag:
        background = x.bagAccent;
        foreground = NuviColors.white;
      case NuviButtonType.coral:
        background = NuviColors.sale;
        foreground = NuviColors.white;
      case NuviButtonType.secondary:
      case NuviButtonType.social:
      case NuviButtonType.outline:
        background = Colors.transparent;
        foreground = NuviColors.ink;
        border = const BorderSide(color: NuviColors.ink, width: 1.5);
    }

    final content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(right: NuviSpacing.sm),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foreground,
              ),
            ),
          )
        else if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: NuviSpacing.sm),
            child: IconTheme(
              data: IconThemeData(color: foreground, size: 18),
              child: icon!,
            ),
          ),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: x.button.copyWith(color: foreground),
          ),
        ),
        if (trailingIcon != null && !isLoading)
          Padding(
            padding: const EdgeInsets.only(left: NuviSpacing.sm),
            child: IconTheme(
              data: IconThemeData(color: foreground, size: 18),
              child: trailingIcon!,
            ),
          ),
      ],
    );

    return NuviPressable(
      onTap: isDisabled ? null : onPressed,
      child: AnimatedOpacity(
        opacity: isDisabled && !isLoading ? 0.5 : 1,
        duration: NuviMotion.of(context, NuviMotion.fast),
        child: Container(
          width: isFullWidth ? double.infinity : null,
          constraints: BoxConstraints(minHeight: height),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(NuviRadii.pill),
            border: Border.fromBorderSide(border),
          ),
          child: content,
        ),
      ),
    );
  }
}

/// Underlined text action ("View all ›", "Continue Shopping").
class NuviTextAction extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color? color;
  final bool chevron;

  const NuviTextAction({
    super.key,
    required this.text,
    this.onTap,
    this.color,
    this.chevron = false,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return NuviPressable(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: NuviSpacing.minTouchTarget,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: x.baloo(14, color: color ?? NuviColors.ink)),
            if (chevron)
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: color ?? NuviColors.ink,
              ),
          ],
        ),
      ),
    );
  }
}
