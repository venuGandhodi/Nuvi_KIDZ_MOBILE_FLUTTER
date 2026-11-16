import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/nuvi_motion.dart';

/// Press feedback used across the app: scale to 0.97 while pressed, light
/// haptic on tap. Ripple-free to match the website's calm feel.
class NuviPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool isButton;
  final bool haptic;
  final double pressedScale;

  const NuviPressable({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.isButton = true,
    this.haptic = true,
    this.pressedScale = NuviMotion.pressScale,
  });

  @override
  State<NuviPressable> createState() => _NuviPressableState();
}

class _NuviPressableState extends State<NuviPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: widget.isButton,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: enabled
            ? () {
                if (widget.haptic) HapticFeedback.lightImpact();
                widget.onTap!();
              }
            : null,
        child: AnimatedScale(
          scale: _pressed ? widget.pressedScale : 1,
          duration: NuviMotion.of(context, NuviMotion.fast),
          curve: NuviMotion.curve,
          child: widget.child,
        ),
      ),
    );
  }
}
