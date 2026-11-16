import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_theme_ext.dart';
import 'nuvi_icon_button.dart';
import 'nuvi_icons.dart';

/// Cream header for screens outside the app shell: back chevron, Baloo
/// title, optional bag (with count) and account actions.
class NuviTopBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final bool showCart;
  final int cartItemCount;
  final bool showProfile;
  final bool showBackButton;
  final bool centerTitle;
  final VoidCallback? onBackTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onProfileTap;

  const NuviTopBar({
    super.key,
    this.leading,
    this.title,
    this.showCart = true,
    this.cartItemCount = 0,
    this.showProfile = false,
    this.showBackButton = false,
    this.centerTitle = true,
    this.onBackTap,
    this.onCartTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    Widget? leadingWidget = leading;
    if (leadingWidget == null && showBackButton) {
      leadingWidget = NuviIconButton(
        icon: Icons.arrow_back_ios_new_rounded,
        iconSize: 19,
        semanticLabel: 'Back',
        onPressed: onBackTap ?? () => Navigator.of(context).maybePop(),
      );
    }

    return AppBar(
      backgroundColor: NuviColors.cream,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: leadingWidget,
      leadingWidth: 56,
      automaticallyImplyLeading: false,
      titleSpacing: leadingWidget == null ? 16 : 0,
      title: DefaultTextStyle.merge(
        style: x.h3,
        child: title ?? Text('Nuvi Kidz', style: x.h3),
      ),
      centerTitle: centerTitle,
      actions: [
        if (showCart)
          NuviIconButton(
            semanticLabel: 'Bag',
            badgeCount: cartItemCount,
            onPressed: onCartTap,
            child: NuviIcons.bag(color: NuviColors.ink, size: 22),
          ),
        if (showProfile)
          NuviIconButton(
            semanticLabel: 'Account',
            onPressed: onProfileTap,
            child: NuviIcons.person(color: NuviColors.ink, size: 22),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
