import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_festival.dart';
import '../theme/nuvi_motion.dart';

/// Ambient festival particles drawn above the app. Never intercepts touches,
/// never exceeds 40 particles, pauses while the app is in the background and
/// is not drawn at all under Reduce Motion.
class NuviFestivalOverlay extends StatefulWidget {
  final NuviFestival festival;

  /// 1 (subtle) – 3 (busy).
  final int intensity;

  const NuviFestivalOverlay({
    super.key,
    required this.festival,
    this.intensity = 2,
  });

  @override
  State<NuviFestivalOverlay> createState() => _NuviFestivalOverlayState();
}

class _NuviFestivalOverlayState extends State<NuviFestivalOverlay>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Ticker _ticker;
  final ValueNotifier<double> _time = ValueNotifier(0);
  bool _foreground = true;
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      _time.value = elapsed.inMicroseconds / 1e6;
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _enabled = NuviMotion.ambient(context);
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _sync();
  }

  void _sync() {
    final shouldRun = _enabled && _foreground;
    if (shouldRun && !_ticker.isActive) {
      _ticker.start();
    } else if (!shouldRun && _ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_enabled) return const SizedBox.shrink();
    final count = (widget.intensity.clamp(1, 3) * 13).clamp(1, 40);
    return Positioned.fill(
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _ParticlePainter(
                time: _time,
                festival: widget.festival,
                count: count,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final ValueNotifier<double> time;
  final NuviFestival festival;
  final int count;
  final Paint _paint = Paint()..isAntiAlias = true;

  _ParticlePainter({
    required this.time,
    required this.festival,
    required this.count,
  }) : super(repaint: time);

  // Deterministic per-particle pseudo-random in [0, 1).
  static double _rand(int i, int salt) {
    final v = math.sin(i * 12.9898 + salt * 78.233) * 43758.5453;
    return v - v.floorToDouble();
  }

  List<Color> get _palette => [
    festival.gold,
    festival.peach,
    festival.sage,
    NuviColors.moonCream,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final t = time.value;
    switch (festival.effect) {
      case NuviFestivalEffect.snow:
        _falling(canvas, size, t, snow: true);
      case NuviFestivalEffect.confetti:
        _falling(canvas, size, t, confetti: true);
      case NuviFestivalEffect.petals:
        _falling(canvas, size, t);
      case NuviFestivalEffect.colourPuffs:
        _puffs(canvas, size, t);
      case NuviFestivalEffect.crackers:
        _crackers(canvas, size, t);
      case NuviFestivalEffect.moonStars:
        _stars(canvas, size, t);
    }
  }

  void _falling(
    Canvas canvas,
    Size size,
    double t, {
    bool snow = false,
    bool confetti = false,
  }) {
    for (var i = 0; i < count; i++) {
      final speed = 18 + _rand(i, 1) * 34;
      final travel = size.height + 40;
      final y = ((t * speed + _rand(i, 2) * travel) % travel) - 20;
      final sway = math.sin(t * (0.6 + _rand(i, 3)) + i) * 14;
      final x = _rand(i, 4) * size.width + sway;
      final opacity = 0.35 + _rand(i, 5) * 0.35;

      if (snow) {
        _paint.color = NuviColors.white.withValues(alpha: opacity + 0.2);
        canvas.drawCircle(Offset(x, y), 1.6 + _rand(i, 6) * 2.4, _paint);
        continue;
      }

      final color = _palette[i % _palette.length];
      _paint.color = color.withValues(alpha: opacity);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * (confetti ? 2.2 : 0.8) + i);
      if (confetti) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-3, -1.6, 6, 3.2),
            const Radius.circular(1),
          ),
          _paint,
        );
      } else {
        canvas.drawOval(const Rect.fromLTWH(-4.5, -2.4, 9, 4.8), _paint);
      }
      canvas.restore();
    }
  }

  void _puffs(Canvas canvas, Size size, double t) {
    final puffs = (count / 3).ceil();
    for (var i = 0; i < puffs; i++) {
      final period = 6 + _rand(i, 1) * 5;
      final phase = ((t + _rand(i, 2) * period) % period) / period;
      final x = _rand(i, 3) * size.width;
      final y = size.height * (1.05 - phase * 1.2);
      final radius = 10 + phase * 26;
      final alpha = math.sin(phase * math.pi) * 0.16;
      _paint
        ..color = _palette[i % 3].withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(x, y), radius, _paint);
    }
    _paint.maskFilter = null;
  }

  void _crackers(Canvas canvas, Size size, double t) {
    final bursts = math.max(1, count ~/ 10);
    const sparks = 9;
    for (var b = 0; b < bursts; b++) {
      final period = 3.2 + _rand(b, 1) * 1.6;
      final cycle = ((t + _rand(b, 2) * period) / period).floor();
      final phase = ((t + _rand(b, 2) * period) % period) / period;
      if (phase > 0.55) continue;
      final p = phase / 0.55;
      final center = Offset(
        (0.15 + _rand(b + cycle, 3) * 0.7) * size.width,
        (0.1 + _rand(b + cycle, 4) * 0.35) * size.height,
      );
      final color = _palette[(b + cycle) % 2];
      _paint.color = color.withValues(alpha: (1 - p) * 0.55);
      for (var s = 0; s < sparks; s++) {
        final angle = s / sparks * math.pi * 2;
        final dist = 6 + p * 34;
        canvas.drawCircle(
          center + Offset(math.cos(angle) * dist, math.sin(angle) * dist),
          1.8 * (1 - p) + 0.6,
          _paint,
        );
      }
    }
  }

  void _stars(Canvas canvas, Size size, double t) {
    _paint.color = festival.gold.withValues(alpha: 0.5);
    final moon = Offset(size.width - 34, 96);
    canvas.drawCircle(moon, 11, _paint);
    _paint.blendMode = BlendMode.dstOut;
    canvas.drawCircle(moon + const Offset(5, -3), 10, _paint);
    _paint.blendMode = BlendMode.srcOver;

    for (var i = 0; i < count; i++) {
      final twinkle = 0.5 + 0.5 * math.sin(t * (1 + _rand(i, 1) * 2) + i);
      final pos = Offset(
        _rand(i, 2) * size.width,
        _rand(i, 3) * size.height * 0.6,
      );
      final r = 1.2 + twinkle * 1.8;
      _paint.color = NuviColors.moonCream.withValues(
        alpha: 0.2 + twinkle * 0.35,
      );
      final path = Path()
        ..moveTo(pos.dx, pos.dy - r * 2)
        ..lineTo(pos.dx + r * 0.5, pos.dy - r * 0.5)
        ..lineTo(pos.dx + r * 2, pos.dy)
        ..lineTo(pos.dx + r * 0.5, pos.dy + r * 0.5)
        ..lineTo(pos.dx, pos.dy + r * 2)
        ..lineTo(pos.dx - r * 0.5, pos.dy + r * 0.5)
        ..lineTo(pos.dx - r * 2, pos.dy)
        ..lineTo(pos.dx - r * 0.5, pos.dy - r * 0.5)
        ..close();
      canvas.drawPath(path, _paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.festival.id != festival.id || oldDelegate.count != count;
}
