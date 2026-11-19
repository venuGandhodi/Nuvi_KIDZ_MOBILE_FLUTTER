import 'package:flutter/material.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_decorations.dart';
import '../theme/nuvi_motion.dart';
import '../theme/nuvi_radii.dart';
import '../theme/nuvi_theme_ext.dart';
import 'nuvi_badge.dart';
import 'nuvi_button.dart';
import 'nuvi_pressable.dart';
import 'nuvi_price.dart';
import 'nuvi_size_pill.dart';
import 'nuvi_skeleton.dart';

/// Collection-style product card: white, radius 16, soft shadow; image with
/// heart top-right and a corner pill; 2-line title; price row with
/// compare-at + % off; optional size chips and Add to Cart.
class NuviProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String? salePrice;
  final String? compareAtPrice;
  final double rating;
  final bool isFavorite;
  final String? badgeText;
  final String? imageUrl;
  final List<Color>? colorSwatches;
  final List<String>? sizes;
  final Set<String> soldOutSizes;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final NuviTile tile;

  /// Collection-page style: the whole photo fits on white (no cropping),
  /// colour dots sit on the photo, an "x% Off" pill and a "Sale" badge show
  /// when the product is discounted and has no other badge.
  final bool discountPill;

  /// Shows a "+" button on the photo (e.g. to pick a size and add to bag).
  final VoidCallback? onQuickAdd;

  const NuviProductCard({
    super.key,
    required this.title,
    required this.price,
    this.salePrice,
    this.compareAtPrice,
    this.rating = 0.0,
    this.isFavorite = false,
    this.badgeText,
    this.imageUrl,
    this.colorSwatches,
    this.sizes,
    this.soldOutSizes = const {},
    this.onFavoriteToggle,
    this.onTap,
    this.onAddToCart,
    this.tile = NuviTile.sage,
    this.discountPill = false,
    this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final info = NuviPriceInfo.from(
      price: price,
      salePrice: salePrice,
      compareAtPrice: compareAtPrice,
    );
    final badge =
        badgeText ?? (discountPill && info.percentOff != null ? 'Sale' : null);
    final titleStyle = x.nunito(13.5, weight: FontWeight.w600, height: 1.3);
    final titleHeight =
        MediaQuery.textScalerOf(context).scale(13.5) * 1.3 * 2 + 1;

    return NuviPressable(
      onTap: onTap,
      semanticLabel: title,
      child: Container(
        decoration: BoxDecoration(
          color: NuviColors.card,
          borderRadius: BorderRadius.circular(NuviRadii.card),
          boxShadow: NuviShadows.productCard,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (discountPill)
                    ColoredBox(
                      color: NuviColors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: NuviImage(
                          url: imageUrl,
                          tile: tile,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  else
                    NuviImage(url: imageUrl, tile: tile),
                  if (discountPill &&
                      colorSwatches != null &&
                      colorSwatches!.isNotEmpty)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: _SwatchRow(colors: colorSwatches!),
                    ),
                  if (onQuickAdd != null)
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: _QuickAddButton(
                        onTap: onQuickAdd!,
                        productTitle: title,
                      ),
                    ),
                  if (badge != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: NuviBadge.fromText(badge, compact: true),
                    ),
                  if (onFavoriteToggle != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: _HeartButton(
                        isFavorite: isFavorite,
                        onTap: onFavoriteToggle!,
                        productTitle: title,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: titleHeight,
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  NuviPriceRow(info: info, discountPill: discountPill),
                  if (sizes != null && sizes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 26,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: sizes!.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 4),
                        itemBuilder: (context, i) => NuviSizePill(
                          label: sizes![i],
                          soldOut: soldOutSizes.contains(sizes![i]),
                          dense: true,
                        ),
                      ),
                    ),
                  ],
                  if (onAddToCart != null) ...[
                    const SizedBox(height: 10),
                    NuviButton(
                      text: 'Add to Cart',
                      type: NuviButtonType.dark,
                      height: 40,
                      onPressed: onAddToCart,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Up to four colour dots (with "+n") on a soft white pill.
class _SwatchRow extends StatelessWidget {
  final List<Color> colors;

  const _SwatchRow({required this.colors});

  @override
  Widget build(BuildContext context) {
    final shown = colors.take(4).toList();
    final extra = colors.length - shown.length;
    return Semantics(
      label: '${colors.length} colours',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
          color: NuviColors.photoButton,
          borderRadius: BorderRadius.circular(NuviRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, c) in shown.indexed) ...[
              if (i > 0) const SizedBox(width: 4),
              Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(color: NuviColors.borderStrong),
                ),
              ),
            ],
            if (extra > 0) ...[
              const SizedBox(width: 4),
              Text(
                '+$extra',
                style: context.nuvi.nunito(10.5, weight: FontWeight.w700),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final VoidCallback onTap;
  final String productTitle;

  const _QuickAddButton({required this.onTap, required this.productTitle});

  @override
  Widget build(BuildContext context) {
    return NuviPressable(
      onTap: onTap,
      semanticLabel: 'Add $productTitle to bag',
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.nuvi.leaf,
              shape: BoxShape.circle,
              boxShadow: NuviShadows.floating,
            ),
            child: const Icon(
              Icons.add_rounded,
              size: 20,
              color: NuviColors.cream,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeartButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  final String productTitle;

  const _HeartButton({
    required this.isFavorite,
    required this.onTap,
    required this.productTitle,
  });

  @override
  State<_HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<_HeartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: NuviMotion.medium,
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 45),
    TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 55),
  ]).animate(CurvedAnimation(parent: _pop, curve: NuviMotion.curve));

  @override
  void didUpdateWidget(covariant _HeartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite &&
        !NuviMotion.reduced(context)) {
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NuviPressable(
      onTap: widget.onTap,
      semanticLabel: widget.isFavorite
          ? 'Remove ${widget.productTitle} from wishlist'
          : 'Save ${widget.productTitle} to wishlist',
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: NuviColors.photoButton,
              shape: BoxShape.circle,
              boxShadow: NuviShadows.floating,
            ),
            alignment: Alignment.center,
            child: ScaleTransition(
              scale: _scale,
              child: Icon(
                widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 19,
                color: widget.isFavorite ? NuviColors.sale : NuviColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
