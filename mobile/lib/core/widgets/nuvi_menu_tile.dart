import 'package:flutter/material.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_theme_ext.dart';
import 'nuvi_pressable.dart';

/// White rounded row: tinted icon tile, bold title, muted subtitle and a
/// chevron (or a custom [trailing], e.g. a switch). Used on Account, Help &
/// Support and Settings.
class NuviMenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color tint;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const NuviMenuTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.tint,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final row = Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: NuviColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F78461E),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: x.nunito(
                    16,
                    weight: FontWeight.w800,
                    color: NuviColors.nightGreen,
                    height: 1.25,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: x.nunito(13.5, color: NuviColors.inkMuted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing ??
              const Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: NuviColors.ink,
              ),
        ],
      ),
    );
    if (onTap == null) return row;
    return NuviPressable(onTap: onTap, semanticLabel: title, child: row);
  }
}
