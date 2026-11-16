import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_decorations.dart';
import '../../../../core/theme/nuvi_motion.dart';
import '../../../../core/theme/nuvi_radii.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_icon_button.dart';
import '../../../../core/widgets/nuvi_pressable.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';

/// Full-bleed product gallery (max 72% of the screen) with floating back and
/// expand buttons, rating + "Similar" chips and page dots.
class ProductImageCarousel extends StatelessWidget {
  final List<String> images;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback? onBack;
  final String? ratingLabel;
  final VoidCallback? onSimilar;

  const ProductImageCarousel({
    super.key,
    required this.images,
    required this.currentIndex,
    required this.onPageChanged,
    this.onBack,
    this.ratingLabel,
    this.onSimilar,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final height = (media.size.width * 1.25).clamp(
      0.0,
      media.size.height * 0.72,
    );
    final top = media.padding.top;

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (images.isEmpty)
            const NuviImage(url: null, tile: NuviTile.peach)
          else
            PageView.builder(
              itemCount: images.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => _openViewer(context, index),
                child: NuviImage(
                  url: images[index],
                  tile: NuviTile.values[index % NuviTile.values.length],
                  semanticLabel:
                      'Product photo ${index + 1} of ${images.length}',
                ),
              ),
            ),
          Positioned(
            top: top + 8,
            left: 12,
            child: NuviIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              iconSize: 18,
              onPhoto: true,
              semanticLabel: 'Back',
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            ),
          ),
          if (images.isNotEmpty)
            Positioned(
              top: top + 8,
              right: 12,
              child: NuviIconButton(
                icon: Icons.open_in_full_rounded,
                iconSize: 18,
                onPhoto: true,
                semanticLabel: 'View photos full screen',
                onPressed: () => _openViewer(context, currentIndex),
              ),
            ),
          Positioned(
            left: 12,
            bottom: 14,
            child: Row(
              children: [
                if (ratingLabel != null)
                  _PhotoChip(label: ratingLabel!, star: true),
                if (onSimilar != null) ...[
                  const SizedBox(width: 6),
                  _PhotoChip(label: 'Similar', onTap: onSimilar),
                ],
              ],
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 22,
              right: 16,
              child: Row(
                children: List.generate(images.length, (index) {
                  final selected = index == currentIndex;
                  return AnimatedContainer(
                    duration: NuviMotion.of(context, NuviMotion.fast),
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: selected ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(NuviRadii.pill),
                      color: selected
                          ? NuviColors.ink
                          : NuviColors.white.withValues(alpha: 0.85),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  void _openViewer(BuildContext context, int index) {
    if (images.isEmpty) return;
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: NuviColors.nightGreen,
        transitionDuration: NuviMotion.of(context),
        reverseTransitionDuration: NuviMotion.of(context),
        pageBuilder: (context, animation, _) => FadeTransition(
          opacity: animation,
          child: _ZoomViewer(images: images, initialIndex: index),
        ),
      ),
    );
  }
}

class _PhotoChip extends StatelessWidget {
  final String label;
  final bool star;
  final VoidCallback? onTap;

  const _PhotoChip({required this.label, this.star = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final chip = Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: NuviColors.photoButton,
        borderRadius: BorderRadius.circular(NuviRadii.pill),
        boxShadow: NuviShadows.floating,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (star) ...[
            Icon(Icons.star_rounded, size: 16, color: x.gold),
            const SizedBox(width: 3),
          ],
          Text(label, style: x.nunito(12.5, weight: FontWeight.w800)),
        ],
      ),
    );
    if (onTap == null) return chip;
    return NuviPressable(
      onTap: onTap,
      semanticLabel: 'Show similar styles',
      child: chip,
    );
  }
}

class _ZoomViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ZoomViewer({required this.images, required this.initialIndex});

  @override
  State<_ZoomViewer> createState() => _ZoomViewerState();
}

class _ZoomViewerState extends State<_ZoomViewer> {
  late final PageController _pages = PageController(
    initialPage: widget.initialIndex,
  );
  final TransformationController _zoom = TransformationController();
  double _dragOffset = 0;
  late int _index = widget.initialIndex;

  bool get _zoomed => _zoom.value.getMaxScaleOnAxis() > 1.01;

  void _toggleZoom(TapDownDetails details) {
    if (_zoomed) {
      _zoom.value = Matrix4.identity();
    } else {
      final p = details.localPosition;
      _zoom.value = Matrix4.identity()
        ..translateByDouble(-p.dx, -p.dy, 0, 1)
        ..scaleByDouble(2.0, 2.0, 1, 1);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _pages.dispose();
    _zoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onVerticalDragUpdate: _zoomed
            ? null
            : (d) => setState(() => _dragOffset += d.delta.dy),
        onVerticalDragEnd: _zoomed
            ? null
            : (d) {
                if (_dragOffset > 120 || (d.primaryVelocity ?? 0) > 700) {
                  Navigator.of(context).pop();
                } else {
                  setState(() => _dragOffset = 0);
                }
              },
        child: Stack(
          children: [
            Transform.translate(
              offset: Offset(0, _dragOffset.clamp(0, double.infinity)),
              child: PageView.builder(
                controller: _pages,
                physics: _zoomed ? const NeverScrollableScrollPhysics() : null,
                itemCount: widget.images.length,
                onPageChanged: (i) {
                  _zoom.value = Matrix4.identity();
                  setState(() => _index = i);
                },
                itemBuilder: (context, i) => GestureDetector(
                  onDoubleTapDown: _toggleZoom,
                  onDoubleTap: () {},
                  child: InteractiveViewer(
                    transformationController: _zoom,
                    minScale: 1,
                    maxScale: 4,
                    onInteractionEnd: (_) => setState(() {}),
                    child: Center(
                      child: NuviImage(
                        url: widget.images[i],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: top + 8,
              right: 12,
              child: NuviIconButton(
                icon: Icons.close_rounded,
                onPhoto: true,
                semanticLabel: 'Close photos',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              top: top + 18,
              left: 20,
              child: Text(
                '${_index + 1} / ${widget.images.length}',
                style: x.baloo(15, color: NuviColors.moonCream),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
