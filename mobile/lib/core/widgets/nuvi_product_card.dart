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
  });

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final info = NuviPriceInfo.from(
      price: price,
      salePrice: salePrice,
      compareAtPrice: compareAtPrice,
    );
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
                  NuviImage(url: imageUrl, tile: tile),
                  if (badgeText != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: NuviBadge.fromText(badgeText!, compact: true),
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
                  NuviPriceRow(info: info),
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
