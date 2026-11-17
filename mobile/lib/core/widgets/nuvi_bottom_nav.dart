import 'package:flutter/material.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_motion.dart';
import '../theme/nuvi_theme_ext.dart';
import 'nuvi_pressable.dart';

class _Tab {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _Tab(this.icon, this.activeIcon, this.label);
}

/// Cream tab bar with a hairline top: Home · Shop · Styled · NUVI World ·
/// Account. Active tab = leaf-green filled icon, label and dot.
class NuviBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NuviBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _tabs = [
    _Tab(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _Tab(Icons.grid_view_outlined, Icons.grid_view_rounded, 'Shop'),
    _Tab(Icons.auto_awesome_outlined, Icons.auto_awesome, 'Styled'),
    _Tab(Icons.menu_book_outlined, Icons.menu_book_rounded, 'NUVI World'),
    _Tab(Icons.person_outline_rounded, Icons.person_rounded, 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: NuviColors.cream,
        border: Border(top: BorderSide(color: NuviColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: NuviPressable(
                    onTap: () => onTap(i),
                    semanticLabel: _tabs[i].label,
                    child: Semantics(
                      selected: currentIndex == i,
                      child: ExcludeSemantics(
                        child: _buildTab(
                          context,
                          x,
                          _tabs[i],
                          currentIndex == i,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    NuviThemeX x,
    _Tab tab,
    bool selected,
  ) {
    final color = selected ? x.leaf : NuviColors.ink;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(selected ? tab.activeIcon : tab.icon, size: 25, color: color),
        const SizedBox(height: 2),
        Text(
          tab.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: selected
              ? x.baloo(12, weight: FontWeight.w700, color: color)
              : x.nunito(11.5, weight: FontWeight.w600, color: color),
        ),
        const SizedBox(height: 2),
        AnimatedContainer(
          duration: NuviMotion.of(context, NuviMotion.fast),
          width: selected ? 5 : 0,
          height: selected ? 5 : 0,
          decoration: BoxDecoration(color: x.leaf, shape: BoxShape.circle),
        ),
      ],
    );
  }
}
