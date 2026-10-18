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
  final VoidCallback? onDailyRewardPressed;
  final VoidCallback? onTrophyPressed;
  final VoidCallback? onDictionaryPressed;
  final bool hasDailyReward;

  const UiHeader({
    super.key,
    required this.mascotText,
    required this.stars,
    required this.onHomePressed,
    required this.onStickersPressed,
    required this.onParentalPressed,
    this.onDailyRewardPressed,
    this.onTrophyPressed,
    this.onDictionaryPressed,
    this.hasDailyReward = false,
  });

  @override
  State<UiHeader> createState() => _UiHeaderState();
}

class _UiHeaderState extends State<UiHeader> {
  final AudioService _audio = AudioService();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isNarrow = screenWidth < 480;

    final headerHeight = isNarrow ? 56.0 : (isMobile ? 60.0 : 64.0);
    final buttonSize = isNarrow ? 32.0 : (isMobile ? 36.0 : 40.0);
    final iconSize = isNarrow ? 16.0 : (isMobile ? 18.0 : 20.0);
    final buttonSpacing = isNarrow ? 4.0 : (isMobile ? 6.0 : 8.0);

    return Container(
      height: headerHeight,
      padding: EdgeInsets.symmetric(horizontal: isNarrow ? 8 : 14),
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
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRoundButton(
                  onTap: widget.onHomePressed,
                  bgColor: const Color(0xFFFEF08A),
                  size: buttonSize,
                  child: VectorIconWidget(icon: 'home', size: iconSize, color: const Color(0xFFB45309)),
                ),
                SizedBox(width: buttonSpacing),
                if (isNarrow)
                  // Compact Mascot Icon on Narrow Screens
                  GestureDetector(
                    onTap: () => _audio.speak(widget.mascotText),
                    child: Container(
                      width: buttonSize,
                      height: buttonSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFDE68A), width: 2),
                        boxShadow: const [
                          BoxShadow(color: Color(0x10000000), offset: Offset(0, 2)),
                        ],
                      ),
                      child: Center(
                        child: MascotWidget(size: buttonSize - 6),
                      ),
                    ),
                  )
                else
                  // Mascot Speech Bubble on Tablet / Web / Wide Mobile
                  Flexible(
                    child: GestureDetector(
                      onTap: () => _audio.speak(widget.mascotText),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFFDE68A), width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MascotWidget(size: isMobile ? 28 : 34),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                widget.mascotText,
                                style: GoogleFonts.fredoka(
                                  fontSize: isMobile ? 12 : 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFD97706),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(width: buttonSpacing),

          // Right: Stars + Sound + Stickers + Parental Gate
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Daily Spin Gift Button
                if (widget.onDailyRewardPressed != null) ...[
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildRoundButton(
                        onTap: widget.onDailyRewardPressed!,
                        bgColor: const Color(0xFFFEF3C7),
                        size: buttonSize,
                        child: VectorIconWidget(
                          icon: 'gift',
                          size: iconSize,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                      if (widget.hasDailyReward)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: buttonSpacing),
                ],

                // Trophy Room Button
                if (widget.onTrophyPressed != null) ...[
                  _buildRoundButton(
                    onTap: widget.onTrophyPressed!,
                    bgColor: const Color(0xFFFEF08A),
                    size: buttonSize,
                    child: Text('🏆', style: TextStyle(fontSize: iconSize - 2)),
                  ),
                  SizedBox(width: buttonSpacing),
                ],

                // Stars Badge (Tappable to also open Trophy Room!)
                GestureDetector(
                  onTap: widget.onTrophyPressed,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isNarrow ? 8 : (isMobile ? 10 : 12),
                      vertical: isNarrow ? 4 : 6,
                    ),
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
                        VectorIconWidget(icon: 'star', size: iconSize),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.stars}',
                          style: GoogleFonts.nunito(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: buttonSpacing),

                // Sound
                _buildRoundButton(
                  onTap: () {
                    setState(() {
                      _audio.toggleMute();
                    });
                  },
                  bgColor: const Color(0xFFDCFCE7),
                  size: buttonSize,
                  child: VectorIconWidget(
                    icon: _audio.isMuted ? 'soundOff' : 'soundOn',
                    size: iconSize,
                    color: const Color(0xFF15803D),
                  ),
                ),
                SizedBox(width: buttonSpacing),

                // Music (BGM)
                _buildRoundButton(
                  onTap: () {
                    setState(() {
                      _audio.toggleBgm();
                    });
                  },
                  bgColor: const Color(0xFFE0E7FF),
                  size: buttonSize,
                  child: VectorIconWidget(
                    icon: (_audio.isBgmMuted || _audio.isMuted) ? 'musicOff' : 'musicOn',
                    size: iconSize,
                    color: const Color(0xFF4338CA),
                  ),
                ),
                SizedBox(width: buttonSpacing),

                // Stickers
                _buildRoundButton(
                  onTap: widget.onStickersPressed,
                  bgColor: const Color(0xFFFCE7F3),
                  size: buttonSize,
                  child: VectorIconWidget(icon: 'stickers', size: iconSize, color: const Color(0xFFBE185D)),
                ),
                SizedBox(width: buttonSpacing),

                // Dictionary
                if (widget.onDictionaryPressed != null) ...[
                  _buildRoundButton(
                    onTap: widget.onDictionaryPressed!,
                    bgColor: const Color(0xFFE0F2FE),
                    size: buttonSize,
                    child: Text('📚', style: TextStyle(fontSize: iconSize - 2)),
                  ),
                  SizedBox(width: buttonSpacing),
                ],

                // Parental Gate
                _buildRoundButton(
                  onTap: widget.onParentalPressed,
                  bgColor: const Color(0xFFEDE9FE),
                  size: buttonSize,
                  child: VectorIconWidget(icon: 'parental', size: iconSize, color: const Color(0xFF6D28D9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundButton({
    required VoidCallback onTap,
    required Color bgColor,
    required Widget child,
    double size = 40,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
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
