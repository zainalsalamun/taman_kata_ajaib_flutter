import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_models.dart';
import '../widgets/vector_illustrations.dart';
import '../widgets/victory_dialog.dart';
import '../services/audio_service.dart';

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

class _TracingScreenState extends State<TracingScreen> {
  final List<LetterTracingData> _letters = GameRepository.letters;
  int _currentIndex = 0;
  final List<Offset> _userStrokes = [];
  bool _isCompleted = false;
  final AudioService _audio = AudioService();

  LetterTracingData get _current => _letters[_currentIndex];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLetter();
    });
  }

  void _startLetter() {
    setState(() {
      _userStrokes.clear();
      _isCompleted = false;
    });
    _audio.speak('Huruf ${_current.letter}! ${_current.word}');
  }

  void _selectLetter(int index) {
    setState(() {
      _currentIndex = index;
    });
    _startLetter();
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
    if (rate >= 0.85 && !_isCompleted) {
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
            setState(() {
              _currentIndex = (_currentIndex + 1) % _letters.length;
            });
            _startLetter();
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
          // Top Letter Selector & Reset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(220),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: List.generate(_letters.length, (idx) {
                    final isSel = idx == _currentIndex;
                    return GestureDetector(
                      onTap: () => _selectLetter(idx),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 38,
                        height: 38,
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

              // Reset Button
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _userStrokes.clear();
                  });
                },
                icon: const VectorIconWidget(icon: 'reload', size: 16, color: Color(0xFFEA580C)),
                label: Text(
                  'Hapus Jejak',
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
                  onTap: () => _audio.speak('${_current.letter}! ${_current.word}!'),
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.all(16),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sentuh untuk suara',
                          style: GoogleFonts.fredoka(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ObjectIllustrationWidget(
                          illustrationKey: _current.illustrationKey,
                          size: 70,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${_current.letter} - ${_current.word}',
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(height: 6),
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
                  ),
                ),
                const SizedBox(width: 24),

                // Center Drawing Canvas
                Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFFDE047), width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x15000000),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return GestureDetector(
                          onPanUpdate: (d) => _onPanUpdate(d, context.findRenderObject() as RenderBox),
                          child: CustomPaint(
                            size: Size(constraints.maxWidth, constraints.maxHeight),
                            painter: _CanvasTracingPainter(
                              letter: _current.letter,
                              strokes: _userStrokes,
                              startPoint: _current.guidePoints.isNotEmpty ? _current.guidePoints[0] : null,
                            ),
                          ),
                        );
                      },
                    ),
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

  _CanvasTracingPainter({
    required this.letter,
    required this.strokes,
    this.startPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
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

    final innerDotted = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: 220,
          fontWeight: FontWeight.bold,
          foreground: Paint()
            ..color = const Color(0xFF38BDF8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    innerDotted.paint(canvas, textOffset);

    if (startPoint != null) {
      canvas.drawCircle(
        startPoint!,
        12,
        Paint()..color = const Color(0xFFEA580C),
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

    if (strokes.length > 1) {
      final outerGlow = Paint()
        ..color = const Color(0xFFFDE047)
        ..strokeWidth = 26
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final innerStroke = Paint()
        ..color = const Color(0xFFF97316)
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
