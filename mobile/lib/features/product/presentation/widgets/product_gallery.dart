import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_motion.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';
import 'product_image_carousel.dart';

/// Rounded product photo you swipe through by touch, with wishlist and
/// share buttons, a "1/4" counter that opens the zoom viewer, and a row of
/// thumbnails underneath.
class ProductGallery extends StatefulWidget {
  final List<String> images;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onShare;

  const ProductGallery({
    super.key,
    required this.images,
    required this.currentIndex,
    required this.onPageChanged,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onShare,
  });

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  late final PageController _pages = PageController(
    initialPage: widget.currentIndex,
  );

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _goTo(int index) => _pages.animateToPage(
    index,
    duration: NuviMotion.of(context, const Duration(milliseconds: 300)),
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final images = widget.images;
    final count = images.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 1 / 0.82,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(NuviRadii.cardLarge),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (images.isEmpty)
                  const NuviImage(url: null, tile: NuviTile.peach)
                else
                  PageView.builder(
                    controller: _pages,
                    itemCount: count,
                    onPageChanged: widget.onPageChanged,
                    itemBuilder: (context, i) => GestureDetector(
                      onTap: () => openProductImageViewer(context, images, i),
                      child: NuviImage(
                        url: images[i],
                        tile: NuviTile.peach,
                        semanticLabel: 'Product photo ${i + 1} of $count',
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Column(
                    children: [
                      _RoundButton(
                        icon: widget.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: NuviColors.sale,
                        label: widget.isFavorite
                            ? 'Remove from wishlist'
                            : 'Save to wishlist',
                        onTap: widget.onToggleFavorite,
                      ),
                      const SizedBox(height: 10),
                      _RoundButton(
                        icon: Icons.share_outlined,
                        color: NuviColors.ink,
                        label: 'Share product',
                        onTap: widget.onShare,
                      ),
                    ],
                  ),
                ),
                if (count > 0)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: NuviPressable(
                      onTap: () => openProductImageViewer(
                        context,
                        images,
                        widget.currentIndex,
                      ),
                      semanticLabel: 'Zoom photo',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: NuviColors.ink.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(NuviRadii.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.zoom_in_rounded,
                              size: 15,
                              color: NuviColors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.currentIndex + 1} / $count',
                              style: x.nunito(
                                12.5,
                                weight: FontWeight.w700,
                                color: NuviColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (count > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 78,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: count,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final selected = i == widget.currentIndex;
                return NuviPressable(
                  onTap: () => _goTo(i),
                  semanticLabel: 'Show photo ${i + 1}',
                  child: AnimatedContainer(
                    duration: NuviMotion.of(context, NuviMotion.fast),
                    width: 92,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(NuviRadii.image),
                      border: Border.all(
                        color: selected ? x.leaf : NuviColors.orderBorder,
                        width: selected ? 2.5 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: NuviImage(url: images[i], tile: NuviTile.peach),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _RoundButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => NuviPressable(
    onTap: onTap,
    semanticLabel: label,
    child: Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: NuviColors.photoButton,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 21, color: color),
    ),
  );
}
