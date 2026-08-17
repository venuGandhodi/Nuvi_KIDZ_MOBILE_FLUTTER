import 'package:flutter/material.dart';
import '../theme/nuvi_colors.dart';
import '../theme/nuvi_radii.dart';
import '../theme/nuvi_typography.dart';
import 'nuvi_icons.dart';

class NuviBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NuviBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NuviColors.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: NuviColors.surfaceVariant,
              borderRadius: BorderRadius.circular(NuviRadii.pill),
              boxShadow: [
                BoxShadow(
                  color: NuviColors.textTertiary.withValues(alpha: 0.14),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  0,
                  (color) => NuviIcons.home(color: color, size: 21),
                  'Home',
                ),
                _buildNavItem(
                  1,
                  (color) => NuviIcons.orders(color: color, size: 23),
                  'Orders',
                ),
                _buildNavItem(
                  2,
                  (color) => NuviIcons.cart(color: color, size: 23),
                  'Cart',
                ),
                _buildNavItem(
                  3,
                  (color) => NuviIcons.wishlist(color: color, size: 23),
                  'Wishlist',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    Widget Function(Color color) iconBuilder,
    String label,
  ) {
    final isSelected = currentIndex == index;
    final inactiveColor = NuviColors.textSecondary;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: isSelected
                ? Container(
                    decoration: const BoxDecoration(
                      color: NuviColors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: iconBuilder(NuviColors.onPrimary),
                  )
                : Center(child: iconBuilder(inactiveColor)),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: NuviTypography.textTheme.bodySmall?.copyWith(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
              color: isSelected ? NuviColors.onSurface : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
