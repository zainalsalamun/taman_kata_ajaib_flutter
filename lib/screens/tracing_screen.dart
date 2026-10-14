import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_models.dart';
import '../widgets/vector_illustrations.dart';
import '../widgets/victory_dialog.dart';
import '../services/audio_service.dart';

class CrayonColor {
  final String name;
  final Color innerColor;
  final Color glowColor;
  final String emoji;

  const CrayonColor({
    required this.name,
    required this.innerColor,
    required this.glowColor,
    required this.emoji,
  });
}

const List<CrayonColor> _kCrayons = [
  CrayonColor(name: 'Oranye Mentari', innerColor: Color(0xFFF97316), glowColor: Color(0xFFFDE047), emoji: '☀️'),
  CrayonColor(name: 'Biru Langit', innerColor: Color(0xFF0284C7), glowColor: Color(0xFFBAE6FD), emoji: '🌊'),
  CrayonColor(name: 'Hijau Daun', innerColor: Color(0xFF16A34A), glowColor: Color(0xFFBBF7D0), emoji: '🌱'),
  CrayonColor(name: 'Merah Ceri', innerColor: Color(0xFFE11D48), glowColor: Color(0xFFFECDD3), emoji: '🍒'),
  CrayonColor(name: 'Ungu Ajaib', innerColor: Color(0xFF9333EA), glowColor: Color(0xFFE9D5FF), emoji: '💜'),
];

class TracingScreen extends StatefulWidget {
  final Function(int starsAdded) onVictory;
  final VoidCallback onBack;

  const TracingScreen({
    super.key,
    required this.onVictory,
    required this.onBack,
  });

  @override
  State<TracingScreen> createState() => _TracingScreenState();
}

class _TracingScreenState extends State<TracingScreen> with SingleTickerProviderStateMixin {
  final List<LetterTracingData> _letters = GameRepository.letters;
  int _currentIndex = 0;
  final List<Offset> _userStrokes = [];
  bool _isCompleted = false;
  final AudioService _audio = AudioService();
  final ScrollController _scrollController = ScrollController();
  int _selectedCrayonIndex = 0;
  late AnimationController _guideAnimController;

  CrayonColor get _selectedCrayon => _kCrayons[_selectedCrayonIndex];
  LetterTracingData get _current => _letters[_currentIndex];

  @override
  void initState() {
    super.initState();
    _guideAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLetter();
    });
  }

  @override
  void dispose() {
    _guideAnimController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startLetter() {
    setState(() {
      _userStrokes.clear();
      _isCompleted = false;
    });
    _guideAnimController.reset();
    _guideAnimController.repeat(reverse: true);
    _audio.speak('Huruf ${_current.letter}! ${_current.word}');
  }

  void _selectLetter(int index) {
    setState(() {
      _currentIndex = index;
    });
    _startLetter();
    _scrollToCurrentLetter();
  }

  void _scrollToCurrentLetter() {
    if (_scrollController.hasClients) {
      final target = (_currentIndex * 42.0) - 100.0;
      _scrollController.animateTo(
        target.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuad,
      );
    }
  }

  void _onPanUpdate(DragUpdateDetails details, RenderBox box) {
    if (_isCompleted) return;
    final localPos = box.globalToLocal(details.globalPosition);

    setState(() {
      _userStrokes.add(localPos);
    });

    _checkProgress();
  }

  void _checkProgress() {
    if (_userStrokes.length < 20) return;

    int hits = 0;
    const radius = 50.0;

    for (final gp in _current.guidePoints) {
      final isHit = _userStrokes.any((pt) => (pt - gp).distance < radius);
      if (isHit) hits++;
    }

    final rate = hits / _current.guidePoints.length;
    if (rate >= 0.75 && !_isCompleted) {
      _isCompleted = true;
      _audio.speakPraise();
      widget.onVictory(3);

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => VictoryDialog(
          title: 'Huruf ${_current.letter} Berhasil!',
          subtitle: 'Hebat sekali! Huruf ${_current.letter} untuk ${_current.word}!',
          onNext: () {
            _selectLetter((_currentIndex + 1) % _letters.length);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // Top Letter Selector Ribbon & Reset
          Row(
            children: [
              // Scrollable Ribbon
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(220),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    ),
                    child: Row(
                      children: List.generate(_letters.length, (idx) {
                        final isSel = idx == _currentIndex;
                        return GestureDetector(
                          onTap: () => _selectLetter(idx),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFFFACC15) : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel ? const Color(0xFFEAB308) : const Color(0xFFCBD5E1),
                                width: 2,
                              ),
                              boxShadow: isSel
                                  ? [const BoxShadow(color: Color(0xFFCA8A04), offset: Offset(0, 2))]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                _letters[idx].letter,
                                style: GoogleFonts.fredoka(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Reset Button
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _userStrokes.clear();
                  });
                },
                icon: const VectorIconWidget(icon: 'reload', size: 16, color: Color(0xFFEA580C)),
                label: Text(
                  'Hapus',
                  style: GoogleFonts.fredoka(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFEA580C),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFF97316), width: 2),
                  ),
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Tracing Layout
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left Guide Card
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _audio.speak('${_current.letter}! ${_current.word}!');
                  },
                  child: Container(
                    width: 210,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFBAE6FD), width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x10000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Speaker Audio Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFBAE6FD)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.volume_up_rounded, size: 14, color: Color(0xFF0284C7)),
                              const SizedBox(width: 4),
                              Text(
                                'Dengar Suara',
                                style: GoogleFonts.fredoka(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0369A1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ObjectIllustrationWidget(
                          illustrationKey: _current.illustrationKey,
                          size: 64,
                        ),
                        Column(
                          children: [
                            Text(
                              '${_current.letter} - ${_current.word}',
                              style: GoogleFonts.fredoka(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0284C7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _current.hint,
                              style: GoogleFonts.fredoka(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        // Prev / Next Navigation Arrows
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                                color: _currentIndex > 0 ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1),
                                onPressed: _currentIndex > 0 ? () => _selectLetter(_currentIndex - 1) : null,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              Text(
                                '${_currentIndex + 1} / ${_letters.length}',
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0369A1),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                                color: _currentIndex < _letters.length - 1 ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1),
                                onPressed: _currentIndex < _letters.length - 1 ? () => _selectLetter(_currentIndex + 1) : null,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Center Drawing Canvas with Animated Guide Hand
                Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: _selectedCrayon.glowColor, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: _selectedCrayon.innerColor.withAlpha(40),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return GestureDetector(
                          onPanUpdate: (d) => _onPanUpdate(d, context.findRenderObject() as RenderBox),
                          child: AnimatedBuilder(
                            animation: _guideAnimController,
                            builder: (context, _) {
                              return CustomPaint(
                                size: Size(constraints.maxWidth, constraints.maxHeight),
                                painter: _CanvasTracingPainter(
                                  letter: _current.letter,
                                  strokes: _userStrokes,
                                  startPoint: _current.guidePoints.isNotEmpty ? _current.guidePoints[0] : null,
                                  guidePoints: _current.guidePoints,
                                  innerColor: _selectedCrayon.innerColor,
                                  glowColor: _selectedCrayon.glowColor,
                                  guideProgress: _guideAnimController.value,
                                  showGuideHand: _userStrokes.isEmpty,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Right Crayon Color Rack
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x10000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Krayon',
                        style: GoogleFonts.fredoka(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(_kCrayons.length, (idx) {
                        final crayon = _kCrayons[idx];
                        final isSel = idx == _selectedCrayonIndex;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedCrayonIndex = idx;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            width: isSel ? 44 : 36,
                            height: isSel ? 44 : 36,
                            decoration: BoxDecoration(
                              color: crayon.innerColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel ? Colors.white : crayon.glowColor,
                                width: isSel ? 3.5 : 2,
                              ),
                              boxShadow: isSel
                                  ? [
                                      BoxShadow(
                                        color: crayon.innerColor.withAlpha(160),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                crayon.emoji,
                                style: TextStyle(fontSize: isSel ? 18 : 13),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CanvasTracingPainter extends CustomPainter {
  final String letter;
  final List<Offset> strokes;
  final Offset? startPoint;
  final List<Offset> guidePoints;
  final Color innerColor;
  final Color glowColor;
  final double guideProgress;
  final bool showGuideHand;

  _CanvasTracingPainter({
    required this.letter,
    required this.strokes,
    this.startPoint,
    required this.guidePoints,
    required this.innerColor,
    required this.glowColor,
    required this.guideProgress,
    required this.showGuideHand,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base Stencil Letter
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: 220,
          fontWeight: FontWeight.bold,
          foreground: Paint()
            ..color = const Color(0xFFF1F5F9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 34
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textOffset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2 - 10,
    );
    textPainter.paint(canvas, textOffset);

    // 2. Inner Dotted / Guide Outline
    final innerDotted = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: 220,
          fontWeight: FontWeight.bold,
          foreground: Paint()
            ..color = const Color(0xFF38BDF8).withAlpha(140)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    innerDotted.paint(canvas, textOffset);

    // 3. Start Point Marker ("1")
    if (startPoint != null) {
      if (showGuideHand) {
        final haloRadius = 13.0 + 7.0 * guideProgress;
        canvas.drawCircle(
          startPoint!,
          haloRadius,
          Paint()..color = innerColor.withAlpha((100 * (1.0 - guideProgress)).toInt()),
        );
      }

      canvas.drawCircle(
        startPoint!,
        12,
        Paint()..color = innerColor,
      );
      final numP = TextPainter(
        text: const TextSpan(
          text: '1',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      numP.paint(canvas, Offset(startPoint!.dx - 4, startPoint!.dy - 7));
    }

    // 4. Animated Guided Hand / Arrow Pointer (when child hasn't started drawing)
    if (showGuideHand && guidePoints.length >= 2) {
      final p1 = guidePoints[0];
      final p2 = guidePoints[1];
      final currentGuidePos = Offset.lerp(p1, p2, guideProgress)!;

      // Glow halo
      canvas.drawCircle(
        currentGuidePos,
        14,
        Paint()..color = glowColor.withAlpha(180),
      );
      // Center finger/pointer dot
      canvas.drawCircle(
        currentGuidePos,
        8,
        Paint()..color = innerColor,
      );

      // Cute animated pointing finger icon
      final pointerText = TextPainter(
        text: const TextSpan(
          text: '👆',
          style: TextStyle(fontSize: 20),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      pointerText.paint(canvas, Offset(currentGuidePos.dx + 4, currentGuidePos.dy + 4));
    }

    // 5. Drawn Strokes with Selected Crayon Color
    if (strokes.length > 1) {
      final outerGlow = Paint()
        ..color = glowColor
        ..strokeWidth = 26
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final innerStroke = Paint()
        ..color = innerColor
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path()..moveTo(strokes[0].dx, strokes[0].dy);
      for (int i = 1; i < strokes.length; i++) {
        path.lineTo(strokes[i].dx, strokes[i].dy);
      }

      canvas.drawPath(path, outerGlow);
      canvas.drawPath(path, innerStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasTracingPainter oldDelegate) => true;
}
