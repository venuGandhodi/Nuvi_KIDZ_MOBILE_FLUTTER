import 'package:flutter/material.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_theme_ext.dart';

/// Dark ink pill with a check icon, e.g. "Added to bag" + "View bag".
class NuviToast {
  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    bool success = true,
  }) {
    final x = context.nuvi;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null || Scaffold.maybeOf(context) == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: success ? NuviColors.ink : NuviColors.sale,
          shape: const StadiumBorder(),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: const Duration(seconds: 2),
          // Snackbars with an action stay until tapped by default; this one
          // should always close by itself.
          persist: false,
          content: Row(
            children: [
              Icon(
                success
                    ? Icons.check_circle_rounded
                    : Icons.error_outline_rounded,
                color: success ? x.gold : NuviColors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: x.nunito(
                    14,
                    weight: FontWeight.w700,
                    color: NuviColors.cream,
                  ),
                ),
              ),
            ],
          ),
          action: actionLabel != null && onAction != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: x.gold,
                  onPressed: onAction,
                )
              : null,
        ),
      );
  }
}
