import 'package:flutter/material.dart';
import '../theme/nuvi_colors.dart';
import '../theme/nuvi_radii.dart';
import '../theme/nuvi_typography.dart';

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
      decoration: BoxDecoration(
        color: NuviColors.surface,
        boxShadow: [
          BoxShadow(
            color: NuviColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(
                1,
                Icons.shopping_bag_outlined,
                Icons.shopping_bag,
                'Shop',
              ),
              _buildNavItem(2, Icons.search_outlined, Icons.search, 'Search'),
              _buildNavItem(
                3,
                Icons.favorite_outline,
                Icons.favorite,
                'Wishlist',
              ),
              _buildNavItem(4, Icons.person_outline, Icons.person, 'Account'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData outlineIcon,
    IconData filledIcon,
    String label,
  ) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? NuviColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(NuviRadii.pill),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              color: isSelected
                  ? NuviColors.onSecondary
                  : NuviColors.onSurface.withValues(alpha: 0.7),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: NuviTypography.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? NuviColors.onSecondary
                    : NuviColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
