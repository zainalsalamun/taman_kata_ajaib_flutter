import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';
import '../widgets/app_logo_widget.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({
    super.key,
    required this.onFinish,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  late AnimationController _raysController;
  late AnimationController _progressController;

  final AudioService _audio = AudioService();
  String _loadingMessage = '🐱 Memanggil Miko si Kucing Ajaib...';
  bool _hasStartedTransition = false;

  @override
  void initState() {
    super.initState();

    // 1. Logo Entry Animation
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeIn,
    );

    // 2. Rotating Background Magic Rays
    _raysController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // 3. Progress Bar Animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _progressController.addListener(() {
      final val = _progressController.value;
      if (val < 0.3) {
        if (_loadingMessage != '🐱 Memanggil Miko si Kucing Ajaib...') {
          setState(() => _loadingMessage = '🐱 Memanggil Miko si Kucing Ajaib...');
        }
      } else if (val < 0.65) {
        if (_loadingMessage != '⛵ Menyiapkan Peta Kepulauan Kata...') {
          setState(() => _loadingMessage = '⛵ Menyiapkan Peta Kepulauan Kata...');
        }
      } else if (val < 0.9) {
        if (_loadingMessage != '📖 Mengumpulkan Bintang & Huruf A–Z...') {
          setState(() => _loadingMessage = '📖 Mengumpulkan Bintang & Huruf A–Z...');
        }
      } else {
        if (_loadingMessage != '🌟 Siap Berpetualang!') {
          setState(() => _loadingMessage = '🌟 Siap Berpetualang!');
        }
      }
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _finishSplash();
      }
    });

    // Start Sequences
    _entryController.forward();
    _progressController.forward();

    // Play greeting sound
    _playGreetingSequence();
  }

  void _playGreetingSequence() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _audio.playSfx('star');
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _audio.speak('Selamat datang di Taman Kata Ajaib! Ayo berpetualang dan belajar membaca bersama Miko!');
  }

  void _finishSplash() {
    if (_hasStartedTransition) return;
    _hasStartedTransition = true;
    HapticFeedback.mediumImpact();
    widget.onFinish();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _raysController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isNarrow = screenSize.width < 500;
    final isLandscape = screenSize.width > screenSize.height;
    final logoSize = isLandscape ? 120.0 : (isNarrow ? 135.0 : 160.0);

    return Scaffold(
      body: GestureDetector(
        onTap: _finishSplash, // Tap to immediately skip into app
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE0F2FE), // Sky Blue
                Color(0xFFFEF9C3), // Soft Sunny Yellow
                Color(0xFFDCFCE7), // Fresh Meadow Green
              ],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Rotating Golden Sunshine Spotlight Rays
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _raysController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _SplashRaysPainter(rotation: _raysController.value * 2 * math.pi),
                    );
                  },
                ),
              ),

              // 2. Floating Clouds & Stars in Background
              Positioned(
                top: 40,
                left: 30,
                child: const Text('☁️', style: TextStyle(fontSize: 38)),
              ),
              Positioned(
                top: 80,
                right: 40,
                child: const Text('☁️', style: TextStyle(fontSize: 32)),
              ),
              Positioned(
                bottom: 120,
                left: 45,
                child: const Text('🎈', style: TextStyle(fontSize: 26)),
              ),
              Positioned(
                bottom: 140,
                right: 50,
                child: const Text('✨', style: TextStyle(fontSize: 30)),
              ),

              // 3. Central Brand Logo & Typography
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Brand Logo Widget with Glow
                            AppLogoWidget(
                              size: logoSize,
                              showTitle: true,
                              showTagline: !isLandscape || screenSize.height > 500,
                              isAnimated: true,
                            ),
                            const SizedBox(height: 24),

                            // Progress Bar Container
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 320),
                              child: Column(
                                children: [
                                  // Candy Striped Progress Indicator
                                  AnimatedBuilder(
                                    animation: _progressController,
                                    builder: (context, child) {
                                      return Container(
                                        height: 14,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: const Color(0xFFFBBF24), width: 2),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x15000000),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: FractionallySizedBox(
                                              widthFactor: _progressController.value.clamp(0.05, 1.0),
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFFF59E0B),
                                                      Color(0xFFEAB308),
                                                      Color(0xFF22C55E),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 10),

                                  // Dynamic Loading Status Text
                                  Text(
                                    _loadingMessage,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF854D0E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // "Ketuk untuk Langsung Mulai" Prompt
                            AnimatedOpacity(
                              opacity: _progressController.value > 0.4 ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 400),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(200),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: Text(
                                  'Ketuk layar untuk langsung mulai ▶',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Version & Copyright Footer
              Positioned(
                bottom: 12,
                child: Text(
                  'v1.0.0 • Edukasi Literasi Anak Indonesia',
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashRaysPainter extends CustomPainter {
  final double rotation;
  const _SplashRaysPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.max(size.width, size.height) * 0.9;
    final numRays = 18;

    final paint = Paint()
      ..color = const Color(0xFFFDE047).withAlpha(35)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rotation);

    for (int i = 0; i < numRays; i++) {
      final a1 = i * (2 * math.pi / numRays);
      final a2 = (i + 0.5) * (2 * math.pi / numRays);

      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(radius * math.cos(a1), radius * math.sin(a1))
        ..lineTo(radius * math.cos(a2), radius * math.sin(a2))
        ..close();

      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SplashRaysPainter oldDelegate) =>
      oldDelegate.rotation != rotation;
}
