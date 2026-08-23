import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'vector_illustrations.dart';
import '../services/audio_service.dart';

class UiHeader extends StatefulWidget {
  final String mascotText;
  final int stars;
  final VoidCallback onHomePressed;
  final VoidCallback onStickersPressed;
  final VoidCallback onParentalPressed;

  const UiHeader({
    super.key,
    required this.mascotText,
    required this.stars,
    required this.onHomePressed,
    required this.onStickersPressed,
    required this.onParentalPressed,
  });

  @override
  State<UiHeader> createState() => _UiHeaderState();
}

class _UiHeaderState extends State<UiHeader> {
  final AudioService _audio = AudioService();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(235),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Home + Mascot
          Row(
            children: [
              _buildRoundButton(
                onTap: widget.onHomePressed,
                bgColor: const Color(0xFFFEF08A),
                child: const VectorIconWidget(icon: 'home', size: 20, color: Color(0xFFB45309)),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _audio.speak(widget.mascotText),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFDE68A), width: 2),
                  ),
                  child: Row(
                    children: [
                      const MascotWidget(size: 36),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 240),
                        child: Text(
                          widget.mascotText,
                          style: GoogleFonts.fredoka(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD97706),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Right: Stars + Sound + Stickers + Parental Gate
          Row(
            children: [
              // Stars
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFEF08A), Color(0xFFFDE047)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFACC15), width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFD97706), offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    const VectorIconWidget(icon: 'star', size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.stars}',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Sound
              _buildRoundButton(
                onTap: () {
                  setState(() {
                    _audio.toggleMute();
                  });
                },
                bgColor: const Color(0xFFDCFCE7),
                child: VectorIconWidget(
                  icon: _audio.isMuted ? 'soundOff' : 'soundOn',
                  size: 20,
                  color: const Color(0xFF15803D),
                ),
              ),
              const SizedBox(width: 8),
              // Stickers
              _buildRoundButton(
                onTap: widget.onStickersPressed,
                bgColor: const Color(0xFFFCE7F3),
                child: const VectorIconWidget(icon: 'stickers', size: 20, color: Color(0xFFBE185D)),
              ),
              const SizedBox(width: 8),
              // Parental Gate
              _buildRoundButton(
                onTap: widget.onParentalPressed,
                bgColor: const Color(0xFFEDE9FE),
                child: const VectorIconWidget(icon: 'parental', size: 20, color: Color(0xFF6D28D9)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundButton({
    required VoidCallback onTap,
    required Color bgColor,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x20000000),
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
