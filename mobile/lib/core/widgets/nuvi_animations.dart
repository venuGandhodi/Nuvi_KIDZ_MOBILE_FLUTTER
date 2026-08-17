import 'dart:math' as math;

import 'package:flutter/material.dart';

enum NuviMascotLoop { float, wave }

/// Mascot avatar animation: scale/fade/rotate entrance settle (~0.7s),
/// then a continuous idle loop (gentle float or wave), matching the design
/// handoff's mascotEntrance + mascotFloat/mascotWave keyframes. Respects
/// reduced-motion: entrance becomes instant and the loop never starts.
class NuviMascotAnimated extends StatefulWidget {
  final Widget child;
  final NuviMascotLoop loop;

  const NuviMascotAnimated({
    super.key,
    required this.child,
    this.loop = NuviMascotLoop.float,
  });

  @override
  State<NuviMascotAnimated> createState() => _NuviMascotAnimatedState();
}

class _NuviMascotAnimatedState extends State<NuviMascotAnimated>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _entranceRotation;

  AnimationController? _loopController;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _entranceRotation = Tween<double>(begin: -0.14, end: 0.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    _entranceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) _startLoop();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.of(context).disableAnimations) {
        _entranceController.value = 1.0;
      } else {
        _entranceController.forward();
      }
    });
  }

  void _startLoop() {
    if (!mounted || MediaQuery.of(context).disableAnimations) return;
    final duration = widget.loop == NuviMascotLoop.float
        ? const Duration(milliseconds: 4200)
        : const Duration(milliseconds: 3600);
    final controller = AnimationController(vsync: this, duration: duration)
      ..repeat();
    setState(() => _loopController = controller);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _loopController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _loopController == null
          ? _entranceController
          : Listenable.merge([_entranceController, _loopController]),
      builder: (context, child) {
        double translateY = 0;
        double rotation = _entranceRotation.value;

        final loop = _loopController;
        if (loop != null) {
          final wave = math.sin(loop.value * 2 * math.pi);
          if (widget.loop == NuviMascotLoop.float) {
            translateY = -7.0 * wave;
            rotation = 0.035 * wave; // ~2deg
          } else {
            rotation = 0.105 * wave; // ~6deg
          }
        }

        return Opacity(
          opacity: _fade.value,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: Transform.rotate(
              angle: rotation,
              child: Transform.scale(scale: _scale.value, child: child),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Subtle floating/breathing loop for the Home header logo — matches the
/// design handoff's logoFloat keyframe (translateY ±3px, rotate ±1.5deg,
/// scale 1<->1.04, 3.8s ease-in-out), with a short entrance beforehand.
class NuviLogoAnimated extends StatefulWidget {
  final Widget child;

  const NuviLogoAnimated({super.key, required this.child});

  @override
  State<NuviLogoAnimated> createState() => _NuviLogoAnimatedState();
}

class _NuviLogoAnimatedState extends State<NuviLogoAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!MediaQuery.of(context).disableAnimations) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final wave = math.sin(_controller.value * 2 * math.pi);
        return Transform.translate(
          offset: Offset(0, -3.0 * wave),
          child: Transform.rotate(
            angle: 0.026 * wave, // ~1.5deg
            child: Transform.scale(scale: 1.0 + 0.02 * wave, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// One-shot fade-up entrance for text (opacity 0->1, translateY 10px->0),
/// with an optional stagger delay before it starts.
class NuviFadeUp extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const NuviFadeUp({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<NuviFadeUp> createState() => _NuviFadeUpState();
}

class _NuviFadeUpState extends State<NuviFadeUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (MediaQuery.of(context).disableAnimations) {
        _controller.value = 1.0;
        return;
      }
      if (widget.delay > Duration.zero) {
        await Future.delayed(widget.delay);
      }
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
