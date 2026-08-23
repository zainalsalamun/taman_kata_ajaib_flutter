import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_models.dart';
import '../widgets/vector_illustrations.dart';
import '../widgets/victory_dialog.dart';
import '../services/audio_service.dart';

class QuizScreen extends StatefulWidget {
  final Function(int starsAdded) onVictory;
  final VoidCallback onBack;

  const QuizScreen({
    super.key,
    required this.onVictory,
    required this.onBack,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<QuizQuestionData> _quizList = GameRepository.quizQuestions;
  int _currentIndex = 0;
  String? _selectedKey;
  bool _isAnswered = false;
  final AudioService _audio = AudioService();

  QuizQuestionData get _current => _quizList[_currentIndex];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startQuestion();
    });
  }

  void _startQuestion() {
    setState(() {
      _selectedKey = null;
      _isAnswered = false;
    });
    _audio.speak(_current.question);
  }

  void _onChoiceTapped(String choiceKey) {
    if (_isAnswered) return;

    setState(() {
      _selectedKey = choiceKey;
    });

    _audio.speak(choiceKey);

    if (choiceKey == _current.answerKey) {
      // Correct!
      setState(() {
        _isAnswered = true;
      });

      Future.delayed(const Duration(milliseconds: 350), () {
        _audio.speak('Benar! Ini ${_current.answerName}! Hebat!');
        widget.onVictory(3);

        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => VictoryDialog(
            title: 'Hebat! ${_current.answerName}!',
            subtitle: 'Kamu pintar sekali menemukan ${_current.answerName}!',
            onNext: () {
              setState(() {
                _currentIndex = (_currentIndex + 1) % _quizList.length;
              });
              _startQuestion();
            },
          ),
        );
      });
    } else {
      // Wrong
      Future.delayed(const Duration(milliseconds: 300), () {
        _audio.speak('Itu ${choiceKey.toUpperCase()}. ${_current.question}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Question Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFC084FC), width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF9333EA),
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _current.question,
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF6B21A8),
                  ),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: () => _audio.speak(_current.question),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDE047),
                      shape: BoxShape.circle,
                    ),
                    child: const VectorIconWidget(
                      icon: 'speaker',
                      size: 18,
                      color: Color(0xFF854D0E),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3 Big Choice Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _current.choices.map((key) {
              final isSelected = _selectedKey == key;
              final isCorrect = isSelected && key == _current.answerKey;
              final isWrong = isSelected && key != _current.answerKey;

              Color cardBg = Colors.white;
              Color borderColor = const Color(0xFFE2E8F0);
              Color shadowColor = const Color(0xFFCBD5E1);

              if (isCorrect) {
                cardBg = const Color(0xFFF0FDF4);
                borderColor = const Color(0xFF22C55E);
                shadowColor = const Color(0xFF16A34A);
              } else if (isWrong) {
                cardBg = const Color(0xFFFEF2F2);
                borderColor = const Color(0xFFEF4444);
                shadowColor = const Color(0xFFDC2626);
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GestureDetector(
                  onTap: () => _onChoiceTapped(key),
                  child: Container(
                    width: 200,
                    height: 190,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          offset: const Offset(0, 6),
                        ),
                        const BoxShadow(
                          color: Color(0x10000000),
                          blurRadius: 12,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ObjectIllustrationWidget(
                          illustrationKey: key,
                          size: 74,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          key.toUpperCase(),
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isCorrect
                                ? const Color(0xFF166534)
                                : const Color(0xFF1E293B),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Bottom Hint
          Text(
            'Pencet salah satu gambar di atas untuk menjawab!',
            style: GoogleFonts.fredoka(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
