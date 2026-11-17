import 'package:flutter/material.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_motion.dart';
import 'nuvi_decor.dart';

/// Loading placeholder in a tile tint with a soft shimmer (static under
/// Reduce Motion).
class NuviSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final double radius;
  final NuviTile tile;

  const NuviSkeleton({
    super.key,
    this.width,
    this.height,
    this.radius = 12,
    this.tile = NuviTile.sage,
  });

  @override
  State<NuviSkeleton> createState() => _NuviSkeletonState();
}

class _NuviSkeletonState extends State<NuviSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (NuviMotion.ambient(context)) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = NuviGradients.colors(widget.tile);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * 2 - 0.5;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + t * 2, -0.3),
              end: Alignment(t * 2, 0.3),
              colors: [colors[0], colors[1], colors[0]],
              stops: const [0.1, 0.5, 0.9],
            ),
          ),
        );
      },
    );
  }
}

/// Network image with a tinted skeleton while loading and a soft mascot
/// placeholder when it fails or is missing.
class NuviImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final NuviTile tile;
  final double? width;
  final double? height;
  final String? semanticLabel;
  final Alignment alignment;

  const NuviImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.tile = NuviTile.sage,
    this.width,
    this.height,
    this.semanticLabel,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = _Placeholder(tile: tile);
    final src = url;
    if (src == null || src.isEmpty || !src.startsWith('http')) {
      return SizedBox(width: width, height: height, child: placeholder);
    }
    return Image.network(
      src,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : NuviSkeleton(width: width, height: height, radius: 0, tile: tile),
      errorBuilder: (context, error, stackTrace) =>
          SizedBox(width: width, height: height, child: placeholder),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final NuviTile tile;

  const _Placeholder({required this.tile});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: NuviGradients.tile(tile)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.biggest.shortestSide;
          final size = (side.isFinite ? side : 80) * 0.42;
          return Center(
            child: Opacity(
              opacity: 0.35,
              child: NuviMascot(size: size.clamp(16, 96)),
            ),
          );
        },
      ),
    );
  }
}
