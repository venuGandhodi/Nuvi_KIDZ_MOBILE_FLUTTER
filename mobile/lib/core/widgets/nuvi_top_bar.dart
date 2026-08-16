import 'package:flutter/material.dart';
import '../theme/nuvi_colors.dart';
import '../theme/nuvi_typography.dart';

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
    Widget? leadingWidget = leading;
    if (leadingWidget == null && showBackButton) {
      leadingWidget = IconButton(
        icon: const Icon(Icons.arrow_back, color: NuviColors.primary),
        onPressed: onBackTap ?? () => Navigator.of(context).maybePop(),
      );
    }

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: leadingWidget,
      automaticallyImplyLeading: false,
      title:
          title ??
          Text(
            'Nuvi Kidz',
            style: NuviTypography.textTheme.headlineMedium?.copyWith(
              color: NuviColors.primary,
            ),
          ),
      centerTitle: centerTitle,
      actions: [
        if (showCart)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: NuviColors.primary,
                  ),
                  onPressed: onCartTap,
                ),
                if (cartItemCount > 0)
                  Positioned(
                    right: 4,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: NuviColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          '$cartItemCount',
                          style: const TextStyle(
                            color: NuviColors.onSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (showProfile)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(
                Icons.person_outline,
                color: NuviColors.primary,
              ),
              onPressed: onProfileTap,
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
