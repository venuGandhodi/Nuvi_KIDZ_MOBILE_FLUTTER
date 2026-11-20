import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/nuvi_colors.dart';
import '../../../core/theme/nuvi_radii.dart';
import '../../../core/theme/nuvi_spacing.dart';
import '../../../core/theme/nuvi_theme_ext.dart';
import '../../../core/widgets/nuvi_empty_state.dart';
import '../../../core/widgets/nuvi_loading_indicator.dart';
import '../../../core/widgets/nuvi_pressable.dart';
import '../../../core/widgets/nuvi_skeleton.dart';
import '../domain/menu_category.dart';
import 'category_menu_controller.dart';

/// Shop tab: one large card per Shopify main-menu category (Girls, Boys,
/// New Born…) with its sub-categories and photo. Tapping a card opens that
/// category.
class ShopTabScreen extends ConsumerStatefulWidget {
  const ShopTabScreen({super.key});

  @override
  ConsumerState<ShopTabScreen> createState() => _ShopTabScreenState();
}

class _ShopTabScreenState extends ConsumerState<ShopTabScreen> {
  @override
  void initState() {
    super.initState();
    if (ref.read(categoryMenuControllerProvider).categories.isEmpty) {
      Future.microtask(
        () => ref.read(categoryMenuControllerProvider.notifier).loadMenu(),
      );
    }
  }

  void _open(MenuCategory c) {
    ref.read(categoryMenuControllerProvider.notifier).selectCategory(c.id);
    context.push('/category/${c.collectionHandle ?? c.id}');
  }

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final menu = ref.watch(categoryMenuControllerProvider);
    final categories = [
      for (final c in menu.categories)
        if (c.title.trim().toLowerCase() != 'home' &&
            (c.collectionHandle != null || c.items.isNotEmpty))
          c,
    ];

    Widget body;
    if (categories.isEmpty && menu.isLoading) {
      body = const Center(child: NuviLoadingIndicator());
    } else if (categories.isEmpty) {
      body = NuviEmptyState(
        title: menu.errorMessage != null
            ? 'We couldn’t load the shop'
            : 'Categories are on their way',
        message: menu.errorMessage ?? 'Please check back soon.',
        actionLabel: 'Retry',
        onAction: () =>
            ref.read(categoryMenuControllerProvider.notifier).loadMenu(),
      );
    } else {
      body = RefreshIndicator(
        color: NuviColors.ink,
        onRefresh: () =>
            ref.read(categoryMenuControllerProvider.notifier).loadMenu(),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            NuviSpacing.gutter,
            4,
            NuviSpacing.gutter,
            NuviSpacing.xl,
          ),
          itemCount: categories.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _ShopCard(
            category: categories[i],
            tone: _tones[i % _tones.length],
            onTap: () => _open(categories[i]),
          ),
        ),
      );
    }

    return Material(
      color: NuviColors.cream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              NuviSpacing.gutter,
              NuviSpacing.sm,
              NuviSpacing.gutter,
              NuviSpacing.s12,
            ),
            child: Text(
              'Shop',
              textAlign: TextAlign.center,
              style: x.baloo(
                22,
                weight: FontWeight.w700,
                color: NuviColors.nightGreen,
              ),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }

  /// Soft card tints, alternating warm and cool like the design.
  static const _tones = [
    NuviTone.peach,
    NuviTone.sky,
    NuviTone.cream,
    NuviTone.sage,
    NuviTone.pink,
  ];
}

class _ShopCard extends StatelessWidget {
  final MenuCategory category;
  final NuviTone tone;
  final VoidCallback onTap;

  const _ShopCard({
    required this.category,
    required this.tone,
    required this.onTap,
  });

  /// "Dresses, Tops, Co-ords & more" from the menu's sub-items.
  String? get _subtitle {
    final names = [for (final s in category.items) s.title.trim()];
    if (names.isEmpty) return null;
    if (names.length <= 3) return names.join(', ');
    return '${names.take(3).join(', ')} & more';
  }

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final subtitle = _subtitle;
    return NuviPressable(
      onTap: onTap,
      semanticLabel: 'Shop ${category.title}',
      child: Container(
        height: 104,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [tone.tint, Color.lerp(tone.tint, tone.blob, 0.35)!],
          ),
          borderRadius: BorderRadius.circular(NuviRadii.cardLarge),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F78461E),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: 150,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (r) => const LinearGradient(
                  colors: [Colors.transparent, Colors.black],
                  stops: [0, 0.35],
                ).createShader(r),
                child: NuviImage(url: category.imageUrl, tile: NuviTile.peach),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 150, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: x.baloo(
                      22,
                      weight: FontWeight.w700,
                      color: NuviColors.nightGreen,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: x.nunito(13, color: NuviColors.inkMuted),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
