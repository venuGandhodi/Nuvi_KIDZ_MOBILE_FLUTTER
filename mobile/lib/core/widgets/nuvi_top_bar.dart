import 'package:flutter/material.dart';
import '../theme/nuvi_colors.dart';
import '../theme/nuvi_typography.dart';

class NuviTopBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final bool showCart;
  final int cartItemCount;

  const NuviTopBar({
    super.key,
    this.leading,
    this.title,
    this.showCart = true,
    this.cartItemCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading:
          leading ??
          IconButton(
            icon: const Icon(Icons.menu, color: NuviColors.primary),
            onPressed: () {},
          ),
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
                      onPressed: () {},
                    ),
                    if (cartItemCount > 0)
                      Positioned(
                        right: 4,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: NuviColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$cartItemCount',
                            style: const TextStyle(
                              color: NuviColors.onSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
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
