import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/nuvi_colors.dart';

const String kNuviMascotAsset = 'assets/images/brand/nuvi_elephant_mascot.png';
const String kNuviLogoAsset = 'assets/images/brand/nuvi_kidz_logo.png';

/// The NUVI elephant. Decorative unless a [semanticLabel] is given.
class NuviMascot extends StatelessWidget {
  final double size;
  final String? semanticLabel;

  const NuviMascot({super.key, this.size = 120, this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      kNuviMascotAsset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      errorBuilder: (context, error, stackTrace) =>
          SizedBox(width: size, height: size),
    );
    return image;
  }
}

/// ✦ four-point sparkle.
class NuviSparkle extends StatelessWidget {
  final double size;
  final Color color;

  const NuviSparkle({super.key, this.size = 14, this.color = NuviColors.gold});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _SparklePainter(color),
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final Color color;

  _SparklePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w / 2, 0)
      ..quadraticBezierTo(w * 0.56, h * 0.44, w, h / 2)
      ..quadraticBezierTo(w * 0.56, h * 0.56, w / 2, h)
      ..quadraticBezierTo(w * 0.44, h * 0.56, 0, h / 2)
      ..quadraticBezierTo(w * 0.44, h * 0.44, w / 2, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Hand-drawn underline swoosh placed under key headings.
class NuviSwoosh extends StatelessWidget {
  final double width;
  final Color color;

  const NuviSwoosh({super.key, this.width = 96, this.color = NuviColors.gold});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(size: Size(width, 10), painter: _SwooshPainter(color)),
    );
  }
}

class _SwooshPainter extends CustomPainter {
  final Color color;

  _SwooshPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.02, h * 0.72)
      ..cubicTo(w * 0.3, h * 0.18, w * 0.62, h * 0.12, w * 0.98, h * 0.42);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SwooshPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Simple leaf, used as scattered decoration around sections.
class NuviLeaf extends StatelessWidget {
  final double size;
  final Color color;
  final double angle;

  const NuviLeaf({
    super.key,
    this.size = 22,
    this.color = NuviColors.sage,
    this.angle = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Transform.rotate(
        angle: angle,
        child: CustomPaint(
          size: Size(size, size * 0.6),
          painter: _LeafPainter(color),
        ),
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
  final Color color;

  _LeafPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(0, h / 2)
      ..quadraticBezierTo(w * 0.45, -h * 0.25, w, h / 2)
      ..quadraticBezierTo(w * 0.45, h * 1.25, 0, h / 2)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawLine(
      Offset(w * 0.08, h / 2),
      Offset(w * 0.86, h / 2),
      Paint()
        ..color = NuviColors.cream.withValues(alpha: 0.6)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _LeafPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Wavy bottom edge for banners.
class NuviWaveClipper extends CustomClipper<Path> {
  final double depth;
  final int waves;

  const NuviWaveClipper({this.depth = 12, this.waves = 3});

  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height - depth);
    final segment = size.width / waves;
    for (var i = 0; i < waves; i++) {
      final x0 = segment * i;
      path.quadraticBezierTo(
        x0 + segment / 4,
        size.height,
        x0 + segment / 2,
        size.height - depth,
      );
      path.quadraticBezierTo(
        x0 + segment * 3 / 4,
        size.height - depth * 2,
        x0 + segment,
        size.height - depth,
      );
    }
    path
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant NuviWaveClipper oldClipper) =>
      oldClipper.depth != depth || oldClipper.waves != waves;
}

/// Organic blob outline; [seed] varies the shape per tile.
class NuviBlobClipper extends CustomClipper<Path> {
  final int seed;

  const NuviBlobClipper({this.seed = 0});

  @override
  Path getClip(Size size) {
    const points = 8;
    final c = size.center(Offset.zero);
    final rx = size.width / 2;
    final ry = size.height / 2;
    final offsets = List.generate(points, (i) {
      final wobble = 0.88 + 0.12 * math.sin((i + 1) * 2.3 + seed * 1.7);
      final a = i / points * math.pi * 2 - math.pi / 2;
      return Offset(
        c.dx + math.cos(a) * rx * wobble,
        c.dy + math.sin(a) * ry * wobble,
      );
    });
    final path = Path();
    for (var i = 0; i < points; i++) {
      final p0 = offsets[i];
      final p1 = offsets[(i + 1) % points];
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      if (i == 0) {
        final prev = offsets[points - 1];
        path.moveTo((prev.dx + p0.dx) / 2, (prev.dy + p0.dy) / 2);
      }
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }
    return path..close();
  }

  @override
  bool shouldReclip(covariant NuviBlobClipper oldClipper) =>
      oldClipper.seed != seed;
}

/// Rolling sage hills for illustrated panels (login, newsletter).
class NuviHills extends StatelessWidget {
  final double height;
  final Color back;
  final Color front;

  const NuviHills({
    super.key,
    this.height = 90,
    this.back = const Color(0xFFDCE7C6),
    this.front = const Color(0xFFC9DAB0),
  });

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: _HillsPainter(back, front),
      ),
    );
  }
}

class _HillsPainter extends CustomPainter {
  final Color back;
  final Color front;

  _HillsPainter(this.back, this.front);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final backPath = Path()
      ..moveTo(0, h * 0.45)
      ..quadraticBezierTo(w * 0.28, h * 0.05, w * 0.6, h * 0.4)
      ..quadraticBezierTo(w * 0.82, h * 0.62, w, h * 0.3)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    final frontPath = Path()
      ..moveTo(0, h * 0.78)
      ..quadraticBezierTo(w * 0.3, h * 0.42, w * 0.58, h * 0.72)
      ..quadraticBezierTo(w * 0.8, h * 0.94, w, h * 0.66)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(backPath, Paint()..color = back);
    canvas.drawPath(frontPath, Paint()..color = front);
  }

  @override
  bool shouldRepaint(covariant _HillsPainter oldDelegate) =>
      oldDelegate.back != back || oldDelegate.front != front;
}

/// Horizontal dashed rule (coupon tickets, summaries).
class NuviDashedLine extends StatelessWidget {
  final Color color;
  final Axis axis;

  const NuviDashedLine({
    super.key,
    this.color = NuviColors.line,
    this.axis = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: axis == Axis.horizontal
          ? const Size(double.infinity, 1.5)
          : const Size(1.5, double.infinity),
      painter: _DashPainter(color, axis),
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  final Axis axis;

  _DashPainter(this.color, this.axis);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    const dash = 5.0;
    const gap = 4.0;
    final length = axis == Axis.horizontal ? size.width : size.height;
    for (double d = 0; d < length; d += dash + gap) {
      final end = math.min(d + dash, length);
      if (axis == Axis.horizontal) {
        canvas.drawLine(Offset(d, 0.75), Offset(end, 0.75), paint);
      } else {
        canvas.drawLine(Offset(0.75, d), Offset(0.75, end), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter oldDelegate) =>
      oldDelegate.color != color;
}
