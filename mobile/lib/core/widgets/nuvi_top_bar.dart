import 'package:flutter/material.dart';
import '../theme/nuvi_colors.dart';
import '../theme/nuvi_typography.dart';

class NuviTopBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final bool showCart;
  final int cartItemCount;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final VoidCallback? onCartTap;

  const NuviTopBar({
    super.key,
    this.leading,
    this.title,
    this.showCart = true,
    this.cartItemCount = 0,
    this.showBackButton = false,
    this.onBackTap,
    this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget = leading;
    if (leadingWidget == null) {
      if (showBackButton) {
        leadingWidget = IconButton(
          icon: const Icon(Icons.arrow_back, color: NuviColors.primary),
          onPressed: onBackTap ?? () => Navigator.of(context).maybePop(),
        );
      } else {
        leadingWidget = IconButton(
          icon: const Icon(Icons.menu, color: NuviColors.primary),
          onPressed: () {},
        );
      }
    }

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: leadingWidget,
      title:
          title ??
          Text(
            'Nuvi Kidz',
            style: NuviTypography.textTheme.headlineMedium?.copyWith(
              color: NuviColors.primary,
            ),
          ),
      centerTitle: true,
      actions: showCart
          ? [
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
            ]
          : [],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
