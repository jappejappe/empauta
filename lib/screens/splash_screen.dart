import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/app_logo.dart';

/// An animated splash screen that reveals the Empauta brand before
/// transitioning into the main content.
///
/// The animation sequence:
///   1. A radial gradient background pulses softly.
///   2. The [AppLogo] scales, slides up, and fades in.
///   3. A tagline fades in below the logo.
///   4. Everything fades out and [onFinished] is called.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ───────────────────────────────────────────────────────
  late final AnimationController _bgController;
  late final AnimationController _logoController;
  late final AnimationController _taglineController;
  late final AnimationController _exitController;

  // ── Animations ────────────────────────────────────────────────────────
  late final Animation<double> _bgPulse;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _taglineFade;
  late final Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();

    // Background subtle pulse — loops while splash is visible.
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _bgPulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOut),
    );

    // Logo entrance.
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    // Tagline entrance.
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _taglineFade = CurvedAnimation(
      parent: _taglineController,
      curve: Curves.easeOut,
    );

    // Exit fade.
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Small initial pause to let the screen settle.
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // 1 — Logo enters.
    await _logoController.forward();

    // 2 — Tagline fades in.
    await Future<void>.delayed(const Duration(milliseconds: 150));
    await _taglineController.forward();

    // 3 — Hold for a beat.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    // 4 — Fade everything out.
    await _exitController.forward();

    widget.onFinished();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _taglineController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _bgPulse,
        _logoFade,
        _logoScale,
        _logoSlide,
        _taglineFade,
        _exitFade,
      ]),
      builder: (context, _) {
        return FadeTransition(
          opacity: _exitFade,
          child: ColoredBox(
            color: const Color(0xFF0E100F),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Animated radial gradient background ──
                _AnimatedBackground(pulse: _bgPulse.value),

                // ── Centered content ──
                DefaultTextStyle(
                  style: const TextStyle(decoration: TextDecoration.none),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App logo
                        SlideTransition(
                          position: _logoSlide,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: FadeTransition(
                              opacity: _logoFade,
                              child: const AppLogo(fontSize: 48),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Tagline
                        FadeTransition(
                          opacity: _taglineFade,
                          child: const Text(
                            'Sua pauta. Sua tela.',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Draws a subtle, pulsing radial gradient that breathes life into
/// the dark splash background.
class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground({required this.pulse});

  final double pulse;

  @override
  Widget build(BuildContext context) {
    // Interpolate the gradient radius with the pulse value.
    final radius = 0.5 + pulse * 0.18;
    final opacity = 0.08 + pulse * 0.06;

    return CustomPaint(painter: _GradientPainter(radius: radius, opacity: opacity));
  }
}

class _GradientPainter extends CustomPainter {
  _GradientPainter({required this.radius, required this.opacity});

  final double radius;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.48);
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: radius,
        colors: [
          const Color(0xFFE34B36).withValues(alpha: opacity),
          const Color(0xFFE34B36).withValues(alpha: opacity * 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: math.max(size.width, size.height) * radius,
        ),
      );

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_GradientPainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.opacity != opacity;
}
