import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_models.dart';
import '../models/dictionary_models.dart';
import '../widgets/vector_illustrations.dart';
import '../widgets/victory_dialog.dart';
import '../widgets/level_milestone_dialog.dart';
import '../widgets/island_mastery_dialog.dart';
import '../widgets/level_selector_ribbon.dart';
import '../widgets/interactive_fireworks.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

enum SpeedRushType {
  imagePromptWordChoices,
  wordPromptImageChoices,
}

class SpeedRushQuestion {
  final String prompt;
  final String illustrationKey;
  final String answer;
  final List<String> choices;
  final SpeedRushType type;

  SpeedRushQuestion({
    required this.prompt,
    required this.illustrationKey,
    required this.answer,
    required this.choices,
    required this.type,
  });
}

class QuizScreen extends StatefulWidget {
  final Function(int starsAdded) onVictory;
  final VoidCallback onBack;
  final bool startInSpeedMode;

  const QuizScreen({
    super.key,
    required this.onVictory,
    required this.onBack,
    this.startInSpeedMode = false,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with TickerProviderStateMixin {
  int _currentLevel = 1;
  int _unlockedLevel = 1;
  int _currentIndex = 0;
  List<QuizQuestionData> _quizList = GameRepository.getQuizQuestions(1);
  String? _selectedKey;
  String? _wobbleKey;
  bool _isAnswered = false;
  final AudioService _audio = AudioService();
  late AnimationController _wobbleController;

  // Speed Rush Mode State
  bool _isSpeedMode = false;
  Timer? _rushTimer;
  int _rushSecondsRemaining = 60;
  int _rushScore = 0;
  int _rushStreak = 0;
  int _rushBestStreak = 0;
  int _rushHighScore = 0;
  int _rushBestCombo = 0;
  bool _isRushAnswered = false;
  String? _rushSelectedKey;
  String? _rushWobbleKey;
  SpeedRushQuestion? _currentRushQuestion;
  late AnimationController _rushWobbleController;
  late AnimationController _comboScaleController;
  late Animation<double> _comboScaleAnimation;

  QuizQuestionData get _current => _currentIndex < _quizList.length
      ? _quizList[_currentIndex]
      : _quizList[0];

  @override
  void initState() {
    super.initState();
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _rushWobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _comboScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _comboScaleAnimation = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _comboScaleController, curve: Curves.elasticOut),
    );

    _loadLevelData();
  }

  void _loadLevelData() async {
    final lvl = await StorageService.getGameLevel('quiz');
    final unl = await StorageService.getUnlockedGameLevel('quiz');
    final idx = await StorageService.getGameLevelIndex('quiz', lvl);
    final questions = GameRepository.getQuizQuestions(lvl);
    final high = await StorageService.getSpeedRushHighScore();
    final combo = await StorageService.getSpeedRushBestCombo();

    if (mounted) {
      setState(() {
        _currentLevel = lvl;
        _unlockedLevel = unl;
        _quizList = questions;
        _currentIndex = (idx < questions.length) ? idx : 0;
        _rushHighScore = high;
        _rushBestCombo = combo;
        if (widget.startInSpeedMode) {
          _isSpeedMode = true;
        }
      });

      if (widget.startInSpeedMode) {
        _startSpeedRushSession();
      } else {
        _startQuestion();
      }
    }
  }

  void _switchLevel(int newLevel) async {
    final questions = GameRepository.getQuizQuestions(newLevel);
    final idx = await StorageService.getGameLevelIndex('quiz', newLevel);
    await StorageService.saveGameLevel('quiz', newLevel);

    setState(() {
      _currentLevel = newLevel;
      _quizList = questions;
      _currentIndex = (idx < questions.length) ? idx : 0;
    });

    _startQuestion();
    final titles = {
      1: 'Tunas Ajaib',
      2: 'Petualang Kata',
      3: 'Master Literasi'
    };
    _audio.speak('Tingkat $_currentLevel: ${titles[_currentLevel]}! ${_current.question}');
  }

  @override
  void dispose() {
    _rushTimer?.cancel();
    _wobbleController.dispose();
    _rushWobbleController.dispose();
    _comboScaleController.dispose();
    super.dispose();
  }

  void _startQuestion() {
    setState(() {
      _selectedKey = null;
      _wobbleKey = null;
      _isAnswered = false;
    });
    _audio.speak(_current.question);
  }

  void _onChoiceTapped(String choiceKey) {
    if (_isAnswered) return;

    HapticFeedback.lightImpact();

    setState(() {
      _selectedKey = choiceKey;
    });

    if (choiceKey == _current.answerKey) {
      // Correct!
      HapticFeedback.mediumImpact();
      _audio.playSfx('ding');
      StorageService.updateDailyMissionProgress('quiz', 1);
      setState(() {
        _isAnswered = true;
      });

      Future.delayed(const Duration(milliseconds: 350), () async {
        final solvedQuestion = _current;
        _audio.speak('Benar! Ini ${solvedQuestion.answerName}! Hebat!');

        if (!mounted) return;

        final hasMoreInLevel = _currentIndex + 1 < _quizList.length;

        if (hasMoreInLevel) {
          widget.onVictory(3);

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => VictoryDialog(
              title: 'Hebat! ${solvedQuestion.answerName}!',
              subtitle:
                  'Kamu pintar sekali menemukan ${solvedQuestion.answerName}!',
              onNext: () {
                setState(() {
                  _currentIndex++;
                });
                StorageService.saveGameLevelIndex(
                    'quiz', _currentLevel, _currentIndex);
                _startQuestion();
              },
            ),
          );
        } else if (_currentLevel >= 3) {
          // ISLAND CONQUERED! FULL MASTERY CELEBRATION!
          widget.onVictory(30);
          await StorageService.addTrophy('quiz_l3');
          await StorageService.addTrophy('quiz_master');
          await StorageService.saveGameLevelIndex('quiz', _currentLevel, 0);

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => IslandMasteryDialog(
              islandTitle: 'Kuil Sentuh Pintar',
              islandRoute: 'quiz',
              bonusStars: 30,
              onReplay: () {
                setState(() {
                  _currentIndex = 0;
                });
                _startQuestion();
              },
              onBackToMap: widget.onBack,
            ),
          );
        } else {
          // LEVEL GRADUATION / MILESTONE CEREMONY!
          widget.onVictory(15);
          final nextLvl = _currentLevel + 1;
          if (nextLvl <= 3) {
            await StorageService.saveUnlockedGameLevel('quiz', nextLvl);
            if (nextLvl > _unlockedLevel) {
              setState(() {
                _unlockedLevel = nextLvl;
              });
            }
          }
          await StorageService.addTrophy('quiz_l$_currentLevel');
          await StorageService.saveGameLevelIndex('quiz', _currentLevel, 0);

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => LevelMilestoneDialog(
              gameTitle: 'Kuis Sentuh Pintar',
              completedLevel: _currentLevel,
              onNextLevel: () {
                _switchLevel(_currentLevel + 1);
              },
              onReplay: () {
                setState(() {
                  _currentIndex = 0;
                });
                _startQuestion();
              },
              onBackToMap: widget.onBack,
            ),
          );
        }
      });
    } else {
      // Wrong choice - Gentle wobble shake & encouraging voice guidance
      HapticFeedback.lightImpact();
      setState(() {
        _wobbleKey = choiceKey;
      });
      _wobbleController.forward(from: 0.0);

      Future.delayed(const Duration(milliseconds: 250), () {
        _audio.speak(
            'Itu gambar ${choiceKey.toUpperCase()}. Coba cari ${_current.answerName} ya!');
      });
    }
  }

  Widget _buildQuestionBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
          Flexible(
            child: Text(
              _current.question,
              style: GoogleFonts.fredoka(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF6B21A8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _audio.speak(_current.question);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE047),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFCA8A04),
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const VectorIconWidget(
                    icon: 'speaker',
                    size: 16,
                    color: Color(0xFF854D0E),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Dengar',
                    style: GoogleFonts.fredoka(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF854D0E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceCard(String key, {bool isHorizontal = false}) {
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

    return AnimatedBuilder(
      animation: _wobbleController,
      builder: (context, child) {
        double wobbleOffset = 0.0;
        if (_wobbleKey == key && _wobbleController.isAnimating) {
          final val = _wobbleController.value;
          // 3 full sine cycles decaying smoothly to 0
          wobbleOffset = math.sin(val * math.pi * 6) * 10.0 * (1.0 - val);
        }
        return Transform.translate(
          offset: Offset(wobbleOffset, 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () => _onChoiceTapped(key),
        child: isHorizontal
            ? Container(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 3.5),
                  boxShadow: [
                    BoxShadow(color: shadowColor, offset: const Offset(0, 4)),
                    const BoxShadow(color: Color(0x0C000000), blurRadius: 8, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: ObjectIllustrationWidget(
                        illustrationKey: key,
                        size: 52,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        key.toUpperCase(),
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isCorrect ? const Color(0xFF166534) : const Color(0xFF1E293B),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? const Color(0xFF22C55E)
                            : (isWrong ? const Color(0xFFEF4444) : const Color(0xFFF1F5F9)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCorrect ? Icons.check : (isWrong ? Icons.close : Icons.touch_app_rounded),
                        size: 18,
                        color: isCorrect || isWrong ? Colors.white : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                width: 190,
                height: 180,
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
                      size: 70,
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
  }

  // ==========================================
  // TANTANGAN KILAT KATA 60 DETIK (SPEED RUSH)
  // ==========================================

  void _generateNextRushQuestion() {
    final rand = math.Random();
    final words = List<DictionaryWordItem>.from(DictionaryRepository.allWords);
    words.shuffle(rand);

    final target = words.first;
    final distractors = words.skip(1).take(2).toList();
    final type = rand.nextBool()
        ? SpeedRushType.imagePromptWordChoices
        : SpeedRushType.wordPromptImageChoices;

    final choices = [
      target.illustrationKey.toLowerCase(),
      distractors[0].illustrationKey.toLowerCase(),
      distractors[1].illustrationKey.toLowerCase(),
    ];
    choices.shuffle(rand);

    if (mounted) {
      setState(() {
        _currentRushQuestion = SpeedRushQuestion(
          prompt: target.word.toLowerCase(),
          illustrationKey: target.illustrationKey.toLowerCase(),
          answer: target.illustrationKey.toLowerCase(),
          choices: choices,
          type: type,
        );
        _rushSelectedKey = null;
        _rushWobbleKey = null;
        _isRushAnswered = false;
      });

      if (type == SpeedRushType.imagePromptWordChoices) {
        _audio.speak('Benda apa ini?');
      } else {
        _audio.speak('Sentuh ${target.word.toLowerCase()}!');
      }
    }
  }

  void _startSpeedRushSession() {
    _rushTimer?.cancel();
    setState(() {
      _rushSecondsRemaining = 60;
      _rushScore = 0;
      _rushStreak = 0;
      _rushBestStreak = 0;
      _isRushAnswered = false;
      _rushSelectedKey = null;
      _rushWobbleKey = null;
    });

    _generateNextRushQuestion();
    _audio.speak('Tantangan Kilat 60 Detik! Siap, mulai!');

    _rushTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_rushSecondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _rushSecondsRemaining = 0;
        });
        _finishSpeedRush();
      } else {
        setState(() {
          _rushSecondsRemaining--;
        });
        if (_rushSecondsRemaining == 10) {
          _audio.speak('Sepuluh detik lagi!');
        } else if (_rushSecondsRemaining == 5) {
          _audio.speak('Lima!');
        }
      }
    });
  }

  void _onRushChoiceTapped(String choice) async {
    if (_isRushAnswered || _rushSecondsRemaining <= 0 || _currentRushQuestion == null) {
      return;
    }

    HapticFeedback.lightImpact();

    final isCorrect = choice == _currentRushQuestion!.answer;

    if (isCorrect) {
      setState(() {
        _isRushAnswered = true;
        _rushSelectedKey = choice;
        _rushScore++;
        _rushStreak++;
        if (_rushStreak > _rushBestStreak) {
          _rushBestStreak = _rushStreak;
        }
      });

      _comboScaleController.forward(from: 0.0);

      if (_rushStreak == 3) {
        _audio.speak('Bagus!');
      } else if (_rushStreak == 5) {
        _audio.speak('Hebat!');
      } else if (_rushStreak == 10) {
        _audio.speak('Super kilat!');
      } else if (_rushStreak % 5 == 0 && _rushStreak > 10) {
        _audio.speak('Luar biasa!');
      }

      await Future.delayed(const Duration(milliseconds: 280));
      if (mounted && _rushSecondsRemaining > 0 && _isSpeedMode) {
        _generateNextRushQuestion();
      }
    } else {
      setState(() {
        _rushWobbleKey = choice;
        _rushStreak = 0;
      });
      _rushWobbleController.forward(from: 0.0);
      await Future.delayed(const Duration(milliseconds: 350));
      if (mounted) {
        setState(() {
          _rushWobbleKey = null;
        });
      }
    }
  }

  void _finishSpeedRush() async {
    _rushTimer?.cancel();
    HapticFeedback.heavyImpact();

    final isNewHigh = await StorageService.saveSpeedRushHighScore(_rushScore);
    await StorageService.saveSpeedRushBestCombo(_rushBestStreak);

    if (_rushScore >= 10) {
      await StorageService.unlockTrophy('trophy_speed_rush');
    }

    if (_rushScore > 0) {
      widget.onVictory(_rushScore);
    }

    final updatedHigh = await StorageService.getSpeedRushHighScore();
    final updatedCombo = await StorageService.getSpeedRushBestCombo();

    if (mounted) {
      setState(() {
        _rushHighScore = updatedHigh;
        _rushBestCombo = updatedCombo;
      });

      _audio.speak(
        _rushScore >= 10
            ? 'Waktu habis! Keren banget! Kamu dapat $_rushScore bintang!'
            : 'Waktu habis! Hebat, kamu berhasil menjawab $_rushScore kata!',
      );

      _showSpeedRushResultDialog(isNewHigh, updatedHigh);
    }
  }

  void _showSpeedRushResultDialog(bool isNewHigh, int updatedHigh) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 440,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFDE047), Color(0xFFF59E0B)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x66F59E0B),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '⚡',
                          style: TextStyle(fontSize: 38),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Tantangan Kilat Selesai!',
                      style: GoogleFonts.fredoka(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _rushScore >= 10
                          ? 'Kecepatan membaca dan refleksmu luar biasa!'
                          : 'Hebat! Terus berlatih agar makin cepat!',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatItem('Kata Benar', '$_rushScore ⭐', const Color(0xFFF59E0B)),
                        const SizedBox(width: 8),
                        _buildStatItem('Best Combo', '🔥 $_rushBestStreak', const Color(0xFFEF4444)),
                        const SizedBox(width: 8),
                        _buildStatItem('Rekor Kilat', '🏆 $updatedHigh', const Color(0xFF8B5CF6)),
                      ],
                    ),
                    if (isNewHigh) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFBBF24)),
                        ),
                        child: Text(
                          '🎉 REKOR BARU TERCIPTA! 🎉',
                          style: GoogleFonts.fredoka(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                    if (_rushScore >= 10) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF22C55E)),
                        ),
                        child: Text(
                          '🏆 Piala Kilat Terbuka di Lemari Piala!',
                          style: GoogleFonts.fredoka(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _startSpeedRushSession();
                            },
                            icon: const Icon(Icons.replay_rounded, color: Colors.white, size: 20),
                            label: Text(
                              'Main Lagi ⚡',
                              style: GoogleFonts.fredoka(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF59E0B),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              setState(() {
                                _isSpeedMode = false;
                              });
                              _startQuestion();
                            },
                            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF64748B), size: 20),
                            label: Text(
                              'Kuis Biasa 🎯',
                              style: GoogleFonts.fredoka(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF475569),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_rushScore >= 5)
                const Positioned.fill(
                  child: IgnorePointer(
                    child: InteractiveFireworksOverlay(
                      autoLaunch: true,
                      tapEnabled: false,
                      child: SizedBox.expand(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.fredoka(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTogglePill() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPillButton(
            title: 'Petualangan 🎯',
            isActive: !_isSpeedMode,
            activeColor: const Color(0xFF7C3AED),
            onTap: () {
              if (_isSpeedMode) {
                _rushTimer?.cancel();
                setState(() {
                  _isSpeedMode = false;
                });
                _startQuestion();
              }
            },
          ),
          const SizedBox(width: 4),
          _buildPillButton(
            title: 'Kilat 60 Detik ⚡',
            isActive: _isSpeedMode,
            activeColor: const Color(0xFFF59E0B),
            onTap: () {
              if (!_isSpeedMode) {
                setState(() {
                  _isSpeedMode = true;
                });
                _startSpeedRushSession();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPillButton({
    required String title,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: GoogleFonts.fredoka(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildRushWobbleWrapper(String key, Widget child) {
    if (_rushWobbleKey == key) {
      return AnimatedBuilder(
        animation: _rushWobbleController,
        builder: (context, child) {
          final val = math.sin(_rushWobbleController.value * math.pi * 4) * 8.0;
          return Transform.translate(
            offset: Offset(val, 0),
            child: child,
          );
        },
        child: child,
      );
    }
    return child;
  }

  Widget _buildRushWordChoiceCard(String choiceKey, {required bool isHorizontal}) {
    final isSelected = _rushSelectedKey == choiceKey;
    final isWrong = _rushWobbleKey == choiceKey;

    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFE2E8F0);
    Color textColor = const Color(0xFF1E293B);

    if (isSelected) {
      bgColor = const Color(0xFFDCFCE7);
      borderColor = const Color(0xFF22C55E);
      textColor = const Color(0xFF15803D);
    } else if (isWrong) {
      bgColor = const Color(0xFFFEE2E2);
      borderColor = const Color(0xFFEF4444);
      textColor = const Color(0xFFB91C1C);
    }

    return _buildRushWobbleWrapper(
      choiceKey,
      GestureDetector(
        onTap: () => _onRushChoiceTapped(choiceKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: isSelected ? 3 : 2),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: isHorizontal ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                choiceKey.toUpperCase(),
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: 2,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 22),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRushImageChoiceCard(String choiceKey, {required bool isHorizontal}) {
    final isSelected = _rushSelectedKey == choiceKey;
    final isWrong = _rushWobbleKey == choiceKey;

    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFE2E8F0);

    if (isSelected) {
      bgColor = const Color(0xFFDCFCE7);
      borderColor = const Color(0xFF22C55E);
    } else if (isWrong) {
      bgColor = const Color(0xFFFEE2E2);
      borderColor = const Color(0xFFEF4444);
    }

    return _buildRushWobbleWrapper(
      choiceKey,
      GestureDetector(
        onTap: () => _onRushChoiceTapped(choiceKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: isHorizontal ? 100 : 135,
          height: isHorizontal ? 105 : 135,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor, width: isSelected ? 3 : 2),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ObjectIllustrationWidget(
                illustrationKey: choiceKey,
                size: isHorizontal ? 52 : 68,
              ),
              const SizedBox(height: 4),
              Text(
                choiceKey.toUpperCase(),
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? const Color(0xFF15803D) : const Color(0xFF475569),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRushPromptCard(SpeedRushQuestion question, {required bool isPortrait}) {
    final isWordPrompt = question.type == SpeedRushType.wordPromptImageChoices;

    if (isWordPrompt) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFDDD6FE), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF7C3AED), size: 26),
              onPressed: () {
                _audio.speak('Sentuh ${question.prompt}!');
              },
            ),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SENTUH GAMBAR:',
                  style: GoogleFonts.fredoka(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8B5CF6),
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  question.prompt.toUpperCase(),
                  style: GoogleFonts.nunito(
                    fontSize: isPortrait ? 24 : 26,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E293B),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFDDD6FE), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ObjectIllustrationWidget(
              illustrationKey: question.illustrationKey,
              size: isPortrait ? 90 : 80,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF7C3AED), size: 18),
                  onPressed: () {
                    _audio.speak('Benda apa ini?');
                  },
                ),
                Text(
                  'Benda apa ini?',
                  style: GoogleFonts.fredoka(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSpeedRushPortraitLayout(SpeedRushQuestion question) {
    final isWordPrompt = question.type == SpeedRushType.wordPromptImageChoices;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildRushPromptCard(question, isPortrait: true),
        const SizedBox(height: 10),
        if (isWordPrompt)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: question.choices
                  .map((c) => _buildRushImageChoiceCard(c, isHorizontal: true))
                  .toList(),
            ),
          )
        else
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: question.choices
                  .map((c) => _buildRushWordChoiceCard(c, isHorizontal: true))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildSpeedRushLandscapeLayout(SpeedRushQuestion question) {
    final isWordPrompt = question.type == SpeedRushType.wordPromptImageChoices;

    if (isWordPrompt) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildRushPromptCard(question, isPortrait: false),
          const SizedBox(height: 6),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: question.choices
                      .map((c) => _buildRushImageChoiceCard(c, isHorizontal: false))
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: Center(
              child: _buildRushPromptCard(question, isPortrait: false),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 6,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: question.choices
                      .map((c) => _buildRushWordChoiceCard(c, isHorizontal: true))
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildSpeedRushView(bool isPortrait) {
    if (_currentRushQuestion == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final question = _currentRushQuestion!;
    final timerFraction = (_rushSecondsRemaining / 60.0).clamp(0.0, 1.0);
    final timerColor = _rushSecondsRemaining <= 10
        ? const Color(0xFFEF4444)
        : (_rushSecondsRemaining <= 25
            ? const Color(0xFFF59E0B)
            : const Color(0xFF10B981));

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isPortrait ? 14 : 20,
        vertical: 8,
      ),
      child: Column(
        children: [
          // 1. Top Header Row: Mode Pill + Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: _buildModeTogglePill(),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Score Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFBBF24)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              '$_rushScore',
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Combo Streak with scale animation
                      ScaleTransition(
                        scale: _comboScaleAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _rushStreak > 1
                                ? const Color(0xFFFEE2E2)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _rushStreak > 1
                                  ? const Color(0xFFF87171)
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _rushStreak > 1 ? '🔥' : '✨',
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_rushStreak}x',
                                style: GoogleFonts.fredoka(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _rushStreak > 1
                                      ? const Color(0xFFB91C1C)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // High score indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFC4B5FD)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🏆', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              '$_rushHighScore',
                              style: GoogleFonts.fredoka(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6D28D9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 2. Countdown Timer Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  _rushSecondsRemaining <= 10 ? '🚨' : '⏱️',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      tween: Tween<double>(begin: timerFraction, end: timerFraction),
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 12,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${_rushSecondsRemaining}s',
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: timerColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 3. Question & Choices Area
          Expanded(
            child: isPortrait
                ? _buildSpeedRushPortraitLayout(question)
                : _buildSpeedRushLandscapeLayout(question),
          ),

          // 4. Bottom Hint
          Text(
            question.type == SpeedRushType.imagePromptWordChoices
                ? 'Pilih kata yang sesuai dengan gambar secepat kilat! ⚡'
                : 'Sentuh gambar yang tepat sesuai tulisan kata! ⚡',
            style: GoogleFonts.fredoka(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    if (_isSpeedMode) {
      return _buildSpeedRushView(isPortrait);
    }

    if (isPortrait) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          children: [
            // Mode Switcher Pill
            _buildModeTogglePill(),
            const SizedBox(height: 8),

            // Top Control Bar: LevelSelectorRibbon + Question Banner
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: LevelSelectorRibbon(
                    currentLevel: _currentLevel,
                    unlockedLevel: _unlockedLevel,
                    onSelectLevel: _switchLevel,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: _buildQuestionBanner(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Choices in comfortable vertical list for phone
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _current.choices
                        .map((key) => _buildChoiceCard(key, isHorizontal: true))
                        .toList(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // Bottom Hint
            Text(
              'Pencet salah satu jawaban di atas!',
              style: GoogleFonts.fredoka(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Top Control Bar: LevelSelectorRibbon + Mode Toggle Pill + Question Banner
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 3,
                child: LevelSelectorRibbon(
                  currentLevel: _currentLevel,
                  unlockedLevel: _unlockedLevel,
                  onSelectLevel: _switchLevel,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _buildModeTogglePill(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: _buildQuestionBanner(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // 3 Big Choice Cards for Landscape (Scales down gracefully without overflow)
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _current.choices.map((key) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _buildChoiceCard(key, isHorizontal: false),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Bottom Hint
          Text(
            'Pencet salah satu gambar di atas untuk menjawab!',
            style: GoogleFonts.fredoka(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
