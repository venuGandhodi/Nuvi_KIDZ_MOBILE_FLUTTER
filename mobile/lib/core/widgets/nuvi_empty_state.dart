import 'package:flutter/material.dart';

import '../theme/nuvi_spacing.dart';
import '../theme/nuvi_theme_ext.dart';
import 'nuvi_button.dart';
import 'nuvi_decor.dart';

/// Mascot illustration, Baloo heading, short text, primary button.
class NuviEmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final NuviButtonType actionType;
  final Widget? secondaryAction;
  final double mascotSize;

  const NuviEmptyState({
    super.key,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.actionType = NuviButtonType.primary,
    this.secondaryAction,
    this.mascotSize = 132,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: NuviSpacing.xl,
          vertical: NuviSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: mascotSize + 28,
                  height: mascotSize + 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: x.peachSoft,
                  ),
                  alignment: Alignment.center,
                  child: NuviMascot(size: mascotSize),
                ),
                Positioned(
                  top: 6,
                  right: 2,
                  child: NuviSparkle(size: 16, color: x.gold),
                ),
                Positioned(
                  bottom: 18,
                  left: -4,
                  child: NuviSparkle(size: 10, color: x.sage),
                ),
              ],
            ),
            const SizedBox(height: NuviSpacing.lg),
            Text(title, textAlign: TextAlign.center, style: x.h2),
            if (message != null) ...[
              const SizedBox(height: NuviSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: x.bodyMuted,
                ),
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: NuviSpacing.lg),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: NuviButton(
                  text: actionLabel!,
                  type: actionType,
                  onPressed: onAction,
                ),
              ),
            ],
            if (secondaryAction != null) ...[
              const SizedBox(height: NuviSpacing.sm),
              secondaryAction!,
            ],
          ],
        ),
      ),
    );
  }
}
