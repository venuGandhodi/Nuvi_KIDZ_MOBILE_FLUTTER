import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/category/presentation/category_menu_controller.dart';
import '../theme/nuvi_colors.dart';
import '../theme/nuvi_radii.dart';
import '../theme/nuvi_spacing.dart';
import '../theme/nuvi_theme_ext.dart';
import 'nuvi_decor.dart';
import 'nuvi_pressable.dart';
import 'nuvi_skeleton.dart';

/// Side menu opened from the header: the Shopify main-menu categories, then
/// shortcuts to existing screens.
class NuviMenuDrawer extends ConsumerStatefulWidget {
  const NuviMenuDrawer({super.key});

  @override
  ConsumerState<NuviMenuDrawer> createState() => _NuviMenuDrawerState();
}

class _NuviMenuDrawerState extends ConsumerState<NuviMenuDrawer> {
  @override
  void initState() {
    super.initState();
    if (ref.read(categoryMenuControllerProvider).categories.isEmpty) {
      Future.microtask(
        () => ref.read(categoryMenuControllerProvider.notifier).loadMenu(),
      );
    }
  }

  void _go(String location, {bool push = false}) {
    Navigator.of(context).pop();
    if (push) {
      context.push(location);
    } else {
      context.go(location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final categories = ref
        .watch(categoryMenuControllerProvider)
        .categories
        .where((c) => c.title.trim().toLowerCase() != 'home')
        .toList();

    Widget link(IconData icon, String label, VoidCallback onTap) =>
        NuviPressable(
          onTap: onTap,
          pressedScale: 0.99,
          child: SizedBox(
            height: 52,
            child: Row(
              children: [
                Icon(icon, size: 22, color: NuviColors.ink),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: x.nunito(15.5, weight: FontWeight.w700),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: NuviColors.inkFaint,
                ),
              ],
            ),
          ),
        );

    return Drawer(
      backgroundColor: NuviColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(NuviRadii.sheet),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Center(
              child: Image.asset(kNuviLogoAsset, height: 72, cacheHeight: 288),
            ),
            const SizedBox(height: NuviSpacing.md),
            if (categories.isNotEmpty) ...[
              Text('Shop', style: x.h3),
              const SizedBox(height: NuviSpacing.xs),
              for (var i = 0; i < categories.length; i++)
                NuviPressable(
                  onTap: () => _go(
                    '/category/${categories[i].collectionHandle ?? categories[i].id}',
                    push: true,
                  ),
                  pressedScale: 0.99,
                  semanticLabel: categories[i].title,
                  child: SizedBox(
                    height: 56,
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: NuviGradients.tile(
                              NuviGradients.forLabel(categories[i].title, i),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: NuviImage(url: categories[i].imageUrl),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            categories[i].title,
                            style: x.nunito(15.5, weight: FontWeight.w700),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: NuviColors.inkFaint,
                        ),
                      ],
                    ),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: NuviSpacing.sm),
                child: Divider(color: NuviColors.line),
              ),
            ],
            link(
              Icons.receipt_long_outlined,
              'My Orders',
              () => _go('/orders'),
            ),
            link(
              Icons.favorite_outline_rounded,
              'Wishlist',
              () => _go('/wishlist'),
            ),
            link(Icons.shopping_bag_outlined, 'Bag', () => _go('/cart')),
            link(
              Icons.person_outline_rounded,
              'Account',
              () => _go('/account'),
            ),
          ],
        ),
      ),
    );
  }
}
