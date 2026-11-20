import 'package:flutter/material.dart';

import '../../../../core/theme/nuvi_colors.dart';
import '../../../../core/theme/nuvi_motion.dart';
import '../../../../core/theme/nuvi_theme_ext.dart';
import '../../../../core/widgets/nuvi_icon_button.dart';
import '../../../../core/widgets/nuvi_skeleton.dart';

/// Full-screen, pinch/double-tap zoomable viewer over [images].
void openProductImageViewer(
  BuildContext context,
  List<String> images,
  int index,
) {
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
