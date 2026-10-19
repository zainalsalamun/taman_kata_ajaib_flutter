import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLogoWidget extends StatefulWidget {
  final double size;
  final bool showTitle;
  final bool showTagline;
  final bool isAnimated;

  const AppLogoWidget({
    super.key,
    this.size = 140,
    this.showTitle = true,
    this.showTagline = true,
    this.isAnimated = true,
  });

  @override
  State<AppLogoWidget> createState() => _AppLogoWidgetState();
}

class _AppLogoWidgetState extends State<AppLogoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    if (widget.isAnimated) {
      _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Curves.easeInOutSine,
        ),
      );
      _glowAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Curves.easeInOutSine,
        ),
      );
      _animController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final floatOffset = widget.isAnimated ? _floatAnimation.value : 0.0;
        final glowScale = widget.isAnimated ? _glowAnimation.value : 1.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating Emblem Badge
            Transform.translate(
              offset: Offset(0, floatOffset),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Outer Golden Glow Halo
                  Transform.scale(
                    scale: glowScale,
                    child: Container(
                      width: widget.size + 16,
                      height: widget.size + 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFDE047).withAlpha(110),
                            blurRadius: 28,
                            spreadRadius: 6,
                          ),
                          BoxShadow(
                            color: const Color(0xFFC084FC).withAlpha(100),
                            blurRadius: 36,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Official Logo Image Asset with Rounded Card Styling
                  Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.size * 0.22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x35000000),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: widget.size,
                      height: widget.size,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback in case asset is loading or missing
                        return Container(
                          color: const Color(0xFF7E22CE),
                          child: const Center(
                            child: Text('🐱✨', style: TextStyle(fontSize: 40)),
                          ),
                        );
                      },
                    ),
                  ),

                  // Twinkling Sparkle Badges
                  Positioned(
                    top: -6,
                    right: -6,
                    child: const Text('✨', style: TextStyle(fontSize: 22)),
                  ),
                  Positioned(
                    bottom: -2,
                    left: -6,
                    child: const Text('⭐', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),

            // Typography Title
            if (widget.showTitle) ...[
              const SizedBox(height: 14),
              // Line 1: TAMAN KATA (3D Styled)
              Text(
                'TAMAN KATA',
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: math.max(16.0, widget.size * 0.17),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                  color: const Color(0xFFD97706),
                  shadows: const [
                    Shadow(color: Color(0xFFB45309), offset: Offset(0, 3), blurRadius: 0),
                    Shadow(color: Color(0xFF78350F), offset: Offset(0, 5), blurRadius: 1),
                    Shadow(color: Color(0x30000000), offset: Offset(0, 7), blurRadius: 6),
                  ],
                ),
              ),

              // Line 2: AJAIB (Magic Violet Gradient & Sparkle)
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('✨', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF9333EA), Color(0xFFC026D3), Color(0xFF7E22CE)],
                    ).createShader(bounds),
                    child: Text(
                      'A J A I B',
                      style: GoogleFonts.fredoka(
                        fontSize: math.max(18.0, widget.size * 0.19),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                        color: Colors.white,
                        shadows: const [
                          Shadow(color: Color(0x30000000), offset: Offset(0, 3), blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('✨', style: TextStyle(fontSize: 16)),
                ],
              ),
            ],

            // Tagline Pill Badge
            if (widget.showTagline) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFEF3C7), Color(0xFFFDE047)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x15000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🌟', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 5),
                    Text(
                      'Petualangan Belajar Membaca Anak',
                      style: GoogleFonts.nunito(
                        fontSize: math.max(10.0, widget.size * 0.08),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text('🌟', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
