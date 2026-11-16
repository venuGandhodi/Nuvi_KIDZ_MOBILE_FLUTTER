import 'package:flutter/material.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_radii.dart';
import '../theme/nuvi_spacing.dart';
import '../theme/nuvi_theme_ext.dart';
import 'nuvi_icon_button.dart';

/// Cream sheet: 24pt top radius, grab handle, title row with close, a
/// scrollable body and an optional sticky footer.
class NuviSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? footer;
  final Widget? titleAction;
  final bool fullHeight;
  final bool scrollable;

  const NuviSheet({
    super.key,
    this.title,
    required this.child,
    this.footer,
    this.titleAction,
    this.fullHeight = false,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height * (fullHeight ? 0.92 : 0.85);

    final Widget body = scrollable
        ? SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              NuviSpacing.s20,
              0,
              NuviSpacing.s20,
              NuviSpacing.md,
            ),
            child: child,
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: NuviSpacing.s20),
            child: child,
          );

    return Material(
      color: NuviColors.cream,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(NuviRadii.sheet),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SizedBox(
          height: fullHeight ? maxHeight : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: NuviColors.ink.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(NuviRadii.pill),
                ),
              ),
              if (title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    NuviSpacing.s20,
                    NuviSpacing.sm,
                    NuviSpacing.sm,
                    NuviSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(title!, style: x.h3)),
                      ?titleAction,
                      NuviIconButton(
                        icon: Icons.close_rounded,
                        semanticLabel: 'Close',
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(height: NuviSpacing.md),
              if (fullHeight) Expanded(child: body) else Flexible(child: body),
              if (footer != null)
                Container(
                  padding: EdgeInsets.fromLTRB(
                    NuviSpacing.s20,
                    NuviSpacing.s12,
                    NuviSpacing.s20,
                    media.padding.bottom + NuviSpacing.s12,
                  ),
                  decoration: const BoxDecoration(
                    color: NuviColors.cream,
                    border: Border(top: BorderSide(color: NuviColors.line)),
                  ),
                  child: footer,
                )
              else
                SizedBox(height: media.padding.bottom + NuviSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

Future<T?> showNuviSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: NuviColors.scrim,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
      ),
      child: builder(sheetContext),
    ),
  );
}
