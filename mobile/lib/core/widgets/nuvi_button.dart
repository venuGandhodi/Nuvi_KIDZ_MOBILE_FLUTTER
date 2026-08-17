import 'package:flutter/material.dart';
import '../theme/nuvi_colors.dart';
import '../theme/nuvi_radii.dart';
import '../theme/nuvi_typography.dart';

enum NuviButtonType { primary, secondary, social }

class NuviButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final NuviButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;

  const NuviButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = NuviButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
  });

  const NuviButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
  }) : type = NuviButtonType.primary;

  const NuviButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
  }) : type = NuviButtonType.secondary;

  const NuviButton.social({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
  }) : type = NuviButtonType.social;

  bool get isDisabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    switch (type) {
      case NuviButtonType.primary:
        backgroundColor = NuviColors.primary;
        textColor = NuviColors.onPrimary;
        break;
      case NuviButtonType.secondary:
        backgroundColor = Colors.transparent;
        textColor = NuviColors.primary;
        borderSide = const BorderSide(color: NuviColors.primary, width: 1);
        break;
      case NuviButtonType.social:
        backgroundColor = Colors.transparent;
        textColor = NuviColors.onSurface;
        borderSide = const BorderSide(color: NuviColors.primary, width: 1);
        break;
    }

    if (isDisabled && type == NuviButtonType.primary) {
      backgroundColor = NuviColors.primary.withValues(alpha: 0.5);
    } else if (isDisabled) {
      textColor = textColor.withValues(alpha: 0.5);
      if (borderSide != BorderSide.none) {
        borderSide = BorderSide(
          color: borderSide.color.withValues(alpha: 0.5),
          width: 1,
        );
      }
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NuviRadii.pill),
        side: borderSide,
      ),
    );

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: textColor,
              ),
            ),
          )
        else if (icon != null)
          Padding(padding: const EdgeInsets.only(right: 8.0), child: icon!),
        Text(
          text,
          style: NuviTypography.textTheme.labelLarge?.copyWith(
            color: textColor,
          ),
        ),
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: buttonStyle,
        child: content,
      ),
    );
  }
}
