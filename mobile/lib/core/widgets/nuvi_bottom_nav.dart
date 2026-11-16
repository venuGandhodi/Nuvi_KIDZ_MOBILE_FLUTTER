import 'package:flutter/material.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_motion.dart';
import '../theme/nuvi_theme_ext.dart';
import 'nuvi_badge.dart';
import 'nuvi_icons.dart';
import 'nuvi_pressable.dart';

/// White tab bar with a hairline top: ink icons, active = ink Baloo label +
/// small gold dot; count badges on Wishlist and Bag.
class NuviBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int cartCount;
  final int wishlistCount;

  const NuviBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartCount = 0,
    this.wishlistCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: NuviColors.white,
        border: Border(top: BorderSide(color: NuviColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _item(
                context,
                0,
                (c) => NuviIcons.home(color: c, size: 22),
                'Home',
              ),
              _item(
                context,
                1,
                (c) => NuviIcons.orders(color: c, size: 22),
                'Orders',
              ),
              _item(
                context,
                2,
                (c) => NuviIcons.bag(color: c, size: 23),
                'Bag',
                badge: cartCount,
              ),
              _item(
                context,
                3,
                (c) => NuviIcons.wishlist(color: c, size: 22),
                'Wishlist',
                badge: wishlistCount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    int index,
    Widget Function(Color color) icon,
    String label, {
    int badge = 0,
  }) {
    final x = context.nuvi;
    final selected = currentIndex == index;
    final color = selected ? NuviColors.ink : NuviColors.inkMuted;
    return Expanded(
      child: NuviPressable(
        onTap: () => onTap(index),
        semanticLabel: badge > 0 ? '$label, $badge items' : label,
        child: Semantics(
          selected: selected,
          child: ExcludeSemantics(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    icon(color),
                    if (badge > 0)
                      Positioned(
                        top: -7,
                        right: -12,
                        child: NuviCountBadge(count: badge),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: selected
                      ? x.tabLabel.copyWith(
                          color: NuviColors.ink,
                          fontWeight: FontWeight.w700,
                        )
                      : x.nunito(11, weight: FontWeight.w600, color: color),
                ),
                const SizedBox(height: 2),
                AnimatedContainer(
                  duration: NuviMotion.of(context, NuviMotion.fast),
                  width: selected ? 5 : 0,
                  height: selected ? 5 : 0,
                  decoration: BoxDecoration(
                    color: x.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
