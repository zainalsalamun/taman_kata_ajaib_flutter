import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_models.dart';
import '../widgets/vector_illustrations.dart';
import '../widgets/victory_dialog.dart';
import '../widgets/level_milestone_dialog.dart';
import '../widgets/island_mastery_dialog.dart';
import '../widgets/level_selector_ribbon.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/voice_record_dialog.dart';

enum BrushType { solid, rainbow, glitter }

enum TracingLetterSubMode { uppercase, lowercase, matchPairs }

class BrushItem {
  final String id;
  final String name;
  final BrushType type;
  final Color innerColor;
  final Color glowColor;
  final String emoji;
  final String voiceQuote;

  const BrushItem({
    required this.id,
    required this.name,
    this.type = BrushType.solid,
    required this.innerColor,
    required this.glowColor,
    required this.emoji,
    required this.voiceQuote,
  });
}

const List<BrushItem> _kBrushes = [
  BrushItem(
    id: 'brush_orange',
    name: 'Oranye Mentari',
    type: BrushType.solid,
    innerColor: Color(0xFFF97316),
    glowColor: Color(0xFFFDE047),
    emoji: '☀️',
    voiceQuote: 'Krayon Oranye Mentari ceria!',
  ),
  BrushItem(
    id: 'brush_blue',
    name: 'Biru Langit',
    type: BrushType.solid,
    innerColor: Color(0xFF0284C7),
    glowColor: Color(0xFFBAE6FD),
    emoji: '🌊',
    voiceQuote: 'Krayon Biru Langit yang sejuk!',
  ),
  BrushItem(
    id: 'brush_green',
    name: 'Hijau Daun',
    type: BrushType.solid,
    innerColor: Color(0xFF16A34A),
    glowColor: Color(0xFFBBF7D0),
    emoji: '🌱',
    voiceQuote: 'Krayon Hijau Daun segar!',
  ),
  BrushItem(
    id: 'brush_red',
    name: 'Merah Ceri',
    type: BrushType.solid,
    innerColor: Color(0xFFE11D48),
    glowColor: Color(0xFFFECDD3),
    emoji: '🍒',
    voiceQuote: 'Krayon Merah Ceri manis!',
  ),
  BrushItem(
    id: 'brush_purple',
    name: 'Ungu Ajaib',
    type: BrushType.solid,
    innerColor: Color(0xFF9333EA),
    glowColor: Color(0xFFE9D5FF),
    emoji: '💜',
    voiceQuote: 'Krayon Ungu Ajaib!',
  ),
  BrushItem(
    id: 'brush_rainbow',
    name: 'Pelangi Ajaib',
    type: BrushType.rainbow,
    innerColor: Color(0xFFF59E0B),
    glowColor: Color(0xFF38BDF8),
    emoji: '🌈',
    voiceQuote: 'Kuas Pelangi Ajaib! Goresanmu memancarkan warna-warni pelangi!',
  ),
  BrushItem(
    id: 'brush_glitter',
    name: 'Pena Bintang',
    type: BrushType.glitter,
    innerColor: Color(0xFFFACC15),
    glowColor: Color(0xFFFEF08A),
    emoji: '✨',
    voiceQuote: 'Pena Bintang Berkilau! Tulisanmu bertabur bintang emas bercahaya!',
  ),
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
  int _currentLevel = 1;
  int _unlockedLevel = 1;
  int _currentIndex = 0;
  TracingLetterSubMode _letterSubMode = TracingLetterSubMode.uppercase;
  List<LetterTracingData> _currentItems = GameRepository.getTracingItems(1);
  final List<Offset> _userStrokes = [];
  bool _isCompleted = false;
  bool _isFreehandMode = false; // Mode Panduan Titik vs Mode Menulis Mandiri
  final AudioService _audio = AudioService();
  final ScrollController _scrollController = ScrollController();
  int _selectedBrushIndex = 0;
  late AnimationController _guideAnimController;

  // Mini-game "Pasangan Aa" (Uppercase-Lowercase Matching) State
  int _matchBatchIndex = 0; // 0..6 (batches of 4 letters across 26 letters)
  List<LetterTracingData> _matchBatchItems = [];
  List<LetterTracingData> _shuffledLowercaseChoices = [];
  String? _selectedUpperLetter;
  String? _selectedLowerLetter;
  final Set<String> _matchedUppercaseLetters = {};
  String? _wrongUpperFlash;
  String? _wrongLowerFlash;

  BrushItem get _selectedBrush => _kBrushes[_selectedBrushIndex];
  LetterTracingData get _current => _currentIndex < _currentItems.length ? _currentItems[_currentIndex] : _currentItems[0];

  @override
  void initState() {
    super.initState();
    _guideAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _loadLevelData();
  }

  void _loadLevelData() async {
    final lvl = await StorageService.getGameLevel('tracing');
    final unl = await StorageService.getUnlockedGameLevel('tracing');
    final idx = await StorageService.getGameLevelIndex('tracing', lvl);
    final isLower = _letterSubMode == TracingLetterSubMode.lowercase;
    final items = GameRepository.getTracingItems(lvl, isLowercase: isLower);

    if (mounted) {
      setState(() {
        _currentLevel = lvl;
        _unlockedLevel = unl;
        _currentItems = items;
        _currentIndex = (idx < items.length) ? idx : 0;
      });
      _startLetter();
      _scrollToCurrentLetter();
    }
  }

  void _switchLetterSubMode(TracingLetterSubMode newMode) {
    if (_letterSubMode == newMode) return;
    HapticFeedback.mediumImpact();
    _audio.playSfx('pop');

    if (newMode == TracingLetterSubMode.matchPairs) {
      setState(() {
        _letterSubMode = newMode;
      });
      _startMatchPairsBatch(0);
      return;
    }

    final isLower = newMode == TracingLetterSubMode.lowercase;
    final items = GameRepository.getTracingItems(1, isLowercase: isLower);
    setState(() {
      _letterSubMode = newMode;
      _currentItems = items;
      if (_currentIndex >= items.length) {
        _currentIndex = 0;
      }
    });
    _startLetter();
    _scrollToCurrentLetter();
  }

  void _startMatchPairsBatch(int batchIdx) {
    final allUpper = GameRepository.letters;
    final totalBatches = (allUpper.length / 4).ceil();
    final safeBatch = batchIdx % totalBatches;
    final startIdx = safeBatch * 4;
    final endIdx = math.min(startIdx + 4, allUpper.length);
    final slice = allUpper.sublist(startIdx, endIdx);
    final shuffled = List<LetterTracingData>.from(slice)..shuffle();

    setState(() {
      _matchBatchIndex = safeBatch;
      _matchBatchItems = slice;
      _shuffledLowercaseChoices = shuffled;
      _selectedUpperLetter = null;
      _selectedLowerLetter = null;
      _matchedUppercaseLetters.clear();
      _wrongUpperFlash = null;
      _wrongLowerFlash = null;
    });

    final firstLetter = slice.first.letter;
    final lastLetter = slice.last.letter;
    _audio.speak(
      'Cocokkan induk huruf besar dengan anak huruf kecilnya! Kelompok huruf $firstLetter sampai $lastLetter!',
    );
  }

  void _onTapUpperMatchCard(LetterTracingData item) {
    if (_matchedUppercaseLetters.contains(item.letter)) {
      _audio.speak('Huruf ${item.letter} besar dan ${item.letter.toLowerCase()} kecil untuk ${item.word} sudah cocok!');
      return;
    }
    HapticFeedback.selectionClick();
    _audio.playSfx('pop');
    setState(() {
      _selectedUpperLetter = item.letter;
      _wrongUpperFlash = null;
    });
    _audio.speak('Huruf besar ${item.letter}!');
    _tryEvaluateMatchPair();
  }

  void _onTapLowerMatchCard(LetterTracingData item) {
    if (_matchedUppercaseLetters.contains(item.letter)) return;
    HapticFeedback.selectionClick();
    _audio.playSfx('pop');
    setState(() {
      _selectedLowerLetter = item.letter;
      _wrongLowerFlash = null;
    });
    _audio.speak('Huruf kecil ${item.letter.toLowerCase()}!');
    _tryEvaluateMatchPair();
  }

  void _tryEvaluateMatchPair() async {
    if (_selectedUpperLetter == null || _selectedLowerLetter == null) return;

    final upper = _selectedUpperLetter!;
    final lower = _selectedLowerLetter!;

    if (upper == lower) {
      // Correct match!
      final matchedItem = _matchBatchItems.firstWhere(
        (e) => e.letter == upper,
        orElse: () => _matchBatchItems.first,
      );
      HapticFeedback.heavyImpact();
      _audio.playSfx('star');
      setState(() {
        _matchedUppercaseLetters.add(upper);
        _selectedUpperLetter = null;
        _selectedLowerLetter = null;
      });

      _audio.speak('Pintar! Huruf besar $upper cocok dengan huruf kecil ${upper.toLowerCase()}! ${matchedItem.word}!');

      if (_matchedUppercaseLetters.length >= _matchBatchItems.length) {
        // Batch completed!
        StorageService.updateDailyMissionProgress('trace', 1);
        widget.onVictory(4);
        await StorageService.addTrophy('letter_match_master');

        final totalBatches = (GameRepository.letters.length / 4).ceil();
        final nextBatch = (_matchBatchIndex + 1) % totalBatches;

        if (!mounted) return;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => VictoryDialog(
              title: '🧩 Pasangan Huruf Cocok!',
              subtitle:
                  'Hebat sekali! Kamu berhasil mencocokkan semua induk huruf besar dan anak huruf kecil di kelompok ini!\nKamu dapat +4 Bintang Juara!',
              onNext: () {
                _startMatchPairsBatch(nextBatch);
              },
            ),
          );
        });
      }
    } else {
      // Mismatch
      HapticFeedback.lightImpact();
      _audio.playSfx('whoosh');
      setState(() {
        _wrongUpperFlash = upper;
        _wrongLowerFlash = lower;
      });
      _audio.speak('Belum cocok, ayo cari pasangan huruf $upper yang tepat ya!');
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          setState(() {
            _selectedLowerLetter = null;
            _wrongUpperFlash = null;
            _wrongLowerFlash = null;
          });
        }
      });
    }
  }

  void _switchLevel(int newLevel) async {
    if (newLevel < 1 || newLevel > 3) return;
    if (newLevel > _unlockedLevel) {
      HapticFeedback.lightImpact();
      _audio.speak('Tingkat $newLevel masih terkunci! Selesaikan tingkat sebelumnya ya!');
      return;
    }

    HapticFeedback.mediumImpact();
    final isLower = newLevel == 1 && _letterSubMode == TracingLetterSubMode.lowercase;
    final items = GameRepository.getTracingItems(newLevel, isLowercase: isLower);
    final idx = await StorageService.getGameLevelIndex('tracing', newLevel);

    setState(() {
      _currentLevel = newLevel;
      if (newLevel != 1 && _letterSubMode == TracingLetterSubMode.matchPairs) {
        _letterSubMode = TracingLetterSubMode.uppercase;
      }
      _currentItems = items;
      _currentIndex = (idx < items.length) ? idx : 0;
    });

    await StorageService.saveGameLevel('tracing', newLevel);
    _startLetter();
    _scrollToCurrentLetter();
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
    if (_currentLevel == 1) {
      if (_letterSubMode == TracingLetterSubMode.lowercase) {
        _audio.speak('Huruf kecil ${_current.letter}! ${_current.word}');
      } else {
        _audio.speak('Huruf besar ${_current.letter}! ${_current.word}');
      }
    } else if (_currentLevel == 2) {
      _audio.speak('Angka ${_current.letter}! ${_current.word}!');
    } else {
      _audio.speak('Bentuk ${_current.word}!');
    }
  }

  void _selectLetter(int index) {
    setState(() {
      _currentIndex = index;
    });
    StorageService.saveGameLevelIndex('tracing', _currentLevel, index);
    if (_currentLevel == 1) {
      StorageService.saveTracingIndex(index);
    }
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

  void _checkProgress() async {
    if (_userStrokes.length < 18) return;

    int hits = 0;
    const radius = 50.0;

    for (final gp in _current.guidePoints) {
      final isHit = _userStrokes.any((pt) => (pt - gp).distance < radius);
      if (isHit) hits++;
    }

    final rate = hits / _current.guidePoints.length;
    if (rate >= 0.75 && !_isCompleted) {
      _isCompleted = true;
      StorageService.updateDailyMissionProgress('trace', 1);

      // Determine Star Rating: 1 to 3 stars
      int awardedStars = 3;
      String starTitle = '⭐⭐⭐ Sempurna!';
      String itemType = _currentLevel == 1
          ? (_letterSubMode == TracingLetterSubMode.lowercase ? "Huruf Kecil" : "Huruf")
          : (_currentLevel == 2 ? "Angka" : "Bentuk");
      String praiseMessage = _currentLevel == 1
          ? (_letterSubMode == TracingLetterSubMode.lowercase
              ? 'Luar biasa! Tulisan huruf kecil ${_current.letter} sangat rapi!'
              : 'Luar biasa! Tulisan huruf ${_current.letter} sangat rapi!')
          : (_currentLevel == 2
              ? 'Pintar sekali! Angka ${_current.letter} berhasil kamu tulis!'
              : 'Wah indah! Bentuk ${_current.word} terlukis dengan sempurna!');

      if (rate >= 0.90 && _userStrokes.length >= 26) {
        awardedStars = 5;
        starTitle = '⭐⭐⭐ Sempurna!';
      } else if (rate >= 0.80) {
        awardedStars = 4;
        starTitle = '⭐⭐ Bagus Sekali!';
      } else {
        awardedStars = 3;
        starTitle = '⭐ Hebat!';
      }

      _audio.playSfx('star');
      _audio.speak(praiseMessage);

      final hasMore = _currentIndex + 1 < _currentItems.length;
      final nextIndex = _currentIndex + 1;

      if (hasMore) {
        widget.onVictory(awardedStars);
        StorageService.saveGameLevelIndex('tracing', _currentLevel, nextIndex);
        if (_currentLevel == 1) {
          StorageService.saveTracingIndex(nextIndex);
        }

        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => VictoryDialog(
            title: '$starTitle $itemType ${_current.letter}!',
            subtitle:
                '$praiseMessage\nKamu dapat +$awardedStars Bintang Juara!',
            onNext: () {
              _selectLetter(nextIndex);
            },
          ),
        );
      } else if (_currentLevel >= 3) {
        // Entire island completed (Level 3 Master)
        widget.onVictory(30);
        await StorageService.addTrophy('tracing_l3');
        await StorageService.addTrophy('tracing_master');
        await StorageService.saveGameLevelIndex('tracing', _currentLevel, 0);

        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => IslandMasteryDialog(
            islandTitle: 'Dermaga Jejak Huruf',
            islandRoute: 'tracing',
            bonusStars: 30,
            onReplay: () {
              _selectLetter(0);
            },
            onBackToMap: widget.onBack,
          ),
        );
      } else {
        // Level Graduation (Level 1 or 2 completed)
        widget.onVictory(15);
        final nextLvl = _currentLevel + 1;
        if (nextLvl <= 3) {
          await StorageService.saveUnlockedGameLevel('tracing', nextLvl);
          if (nextLvl > _unlockedLevel) {
            setState(() {
              _unlockedLevel = nextLvl;
            });
          }
        }
        await StorageService.addTrophy('tracing_l$_currentLevel');
        if (_currentLevel == 1) {
          if (_letterSubMode == TracingLetterSubMode.lowercase) {
            await StorageService.addTrophy('tracing_lowercase_master');
          } else {
            await StorageService.addTrophy('tracing_alphabet_master');
          }
        }
        await StorageService.saveGameLevelIndex('tracing', _currentLevel, 0);

        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => LevelMilestoneDialog(
            gameTitle: 'Dermaga Jejak Huruf',
            completedLevel: _currentLevel,
            onNextLevel: () {
              _switchLevel(_currentLevel + 1);
            },
            onReplay: () {
              _selectLetter(0);
            },
            onBackToMap: widget.onBack,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final isMatchPairsMode = _currentLevel == 1 && _letterSubMode == TracingLetterSubMode.matchPairs;

    if (isPortrait) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          children: [
            // 1. Top Control Bar: Level Selector Ribbon + Mode Switcher + Clear Button
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
                if (!isMatchPairsMode) ...[
                  const SizedBox(width: 6),
                  _buildModeSwitcher(),
                  const SizedBox(width: 6),
                  _buildClearButton(),
                ],
              ],
            ),
            const SizedBox(height: 6),

            // 1b. Level 1 Letter Case & Matching Sub-Mode Selector
            if (_currentLevel == 1) ...[
              _buildLetterSubModeRibbon(),
              const SizedBox(height: 6),
            ],

            if (isMatchPairsMode)
              Expanded(child: _buildMatchPairsGameView(isPortrait: true))
            else ...[
              // 2. Scrollable Item Ribbon (A-Z, a-z, 1-10, Shapes)
              _buildItemRibbon(),
              const SizedBox(height: 6),

              // 3. Compact Guide Card
              _buildCompactGuideCard(),
              const SizedBox(height: 8),

              // 4. Center Drawing Canvas (Expanded & Touch-Spacious)
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: _buildDrawingCanvas(),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 5. Bottom Horizontal Brush Rack
              _buildHorizontalBrushRack(),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // 1. Top Control Bar: Level Selector Ribbon + Sub-mode + Mode Switcher + Clear Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 4,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LevelSelectorRibbon(
                        currentLevel: _currentLevel,
                        unlockedLevel: _unlockedLevel,
                        onSelectLevel: _switchLevel,
                      ),
                      if (_currentLevel == 1) ...[
                        const SizedBox(width: 8),
                        _buildLetterSubModeRibbon(),
                      ],
                    ],
                  ),
                ),
              ),
              if (!isMatchPairsMode) ...[
                const SizedBox(width: 8),
                _buildModeSwitcher(),
                const SizedBox(width: 8),
                _buildClearButton(),
              ],
            ],
          ),
          const SizedBox(height: 6),

          if (isMatchPairsMode)
            Expanded(child: _buildMatchPairsGameView(isPortrait: false))
          else ...[
            // 2. Scrollable Item Ribbon (A-Z, a-z, 1-10, Shapes)
            _buildItemRibbon(),
            const SizedBox(height: 10),

            // Main Tracing Layout (Left Guide Card, Center Canvas, Right Brush Rack)
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
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
                          width: 205,
                          height: 320,
                          padding: const EdgeInsets.all(12),
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
                              // Speaker Audio & Voice Record Pills
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      _audio.speak('${_current.letter}! ${_current.word}!');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                            'Dengar',
                                            style: GoogleFonts.fredoka(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF0369A1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => VoiceRecordDialog(
                                          recordingKey: 'tracing_${_current.letter}',
                                          wordOrLetter: _current.letter,
                                          displayLabel: 'Huruf ${_current.letter}',
                                          category: 'Huruf',
                                          illustrationKey: _current.illustrationKey,
                                          phoneticTip: '${_current.letter}! ${_current.word}!',
                                          onBonusStars: (b) => widget.onVictory(b),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3E8FF),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: const Color(0xFFD8B4FE)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('🎙️', style: TextStyle(fontSize: 11)),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Rekam',
                                            style: GoogleFonts.fredoka(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF7E22CE),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              ObjectIllustrationWidget(
                                illustrationKey: _current.illustrationKey,
                                size: 56,
                              ),
                              Column(
                                children: [
                                  if (_currentLevel == 1)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 3),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF9C3),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFFDE047)),
                                      ),
                                      child: Text(
                                        'Pasangan: ${_current.letter.toUpperCase()}${_current.letter.toLowerCase()}',
                                        style: GoogleFonts.fredoka(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFFB45309),
                                        ),
                                      ),
                                    ),
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
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
                                      '${_currentIndex + 1} / ${_currentItems.length}',
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF0369A1),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                                      color: _currentIndex < _currentItems.length - 1 ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1),
                                      onPressed: _currentIndex < _currentItems.length - 1 ? () => _selectLetter(_currentIndex + 1) : null,
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

                      // Center Drawing Canvas
                      SizedBox(
                        width: 320,
                        height: 320,
                        child: _buildDrawingCanvas(),
                      ),
                      const SizedBox(width: 16),

                      // Right Brush Rack (Vertical)
                      _buildVerticalBrushRack(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawingCanvas() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _selectedBrush.type == BrushType.rainbow
              ? const Color(0xFF38BDF8)
              : _selectedBrush.glowColor,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: _selectedBrush.innerColor.withAlpha(40),
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
                      brush: _selectedBrush,
                      guideProgress: _guideAnimController.value,
                      showGuideHand: _userStrokes.isEmpty && !_isFreehandMode,
                      isFreehandMode: _isFreehandMode,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompactGuideCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _audio.speak('${_current.letter}! ${_current.word}!');
      },
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFBAE6FD), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ObjectIllustrationWidget(
              illustrationKey: _current.illustrationKey,
              size: 42,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_current.letter} - ${_current.word}',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0284C7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _current.hint,
                    style: GoogleFonts.fredoka(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF0284C7), size: 20),
              onPressed: () {
                _audio.speak('${_current.letter}! ${_current.word}!');
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Text('🎙️', style: TextStyle(fontSize: 18)),
              tooltip: 'Rekam Suaraku',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => VoiceRecordDialog(
                    recordingKey: 'tracing_${_current.letter}',
                    wordOrLetter: _current.letter,
                    displayLabel: 'Huruf ${_current.letter}',
                    category: 'Huruf',
                    illustrationKey: _current.illustrationKey,
                    phoneticTip: '${_current.letter}! ${_current.word}!',
                    onBonusStars: (b) => widget.onVictory(b),
                  ),
                );
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
              color: _currentIndex > 0 ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1),
              onPressed: _currentIndex > 0 ? () => _selectLetter(_currentIndex - 1) : null,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              color: _currentIndex < _currentItems.length - 1 ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1),
              onPressed: _currentIndex < _currentItems.length - 1 ? () => _selectLetter(_currentIndex + 1) : null,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalBrushRack() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
            'Kuas Ajaib',
            style: GoogleFonts.fredoka(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          ...List.generate(_kBrushes.length, (idx) {
            final brush = _kBrushes[idx];
            final isSel = idx == _selectedBrushIndex;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedBrushIndex = idx;
                });
                if (brush.type == BrushType.rainbow || brush.type == BrushType.glitter) {
                  _audio.playSfx('star');
                } else {
                  _audio.playSfx('ding');
                }
                _audio.speak(brush.voiceQuote);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(vertical: 3),
                width: isSel ? 38 : 32,
                height: isSel ? 38 : 32,
                decoration: BoxDecoration(
                  gradient: brush.type == BrushType.rainbow
                      ? const LinearGradient(
                          colors: [
                            Color(0xFFEF4444),
                            Color(0xFFF59E0B),
                            Color(0xFF10B981),
                            Color(0xFF06B6D4),
                            Color(0xFF8B5CF6),
                          ],
                        )
                      : null,
                  color: brush.type != BrushType.rainbow ? brush.innerColor : null,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSel ? Colors.white : brush.glowColor,
                    width: isSel ? 3.0 : 1.8,
                  ),
                  boxShadow: isSel
                      ? [
                          BoxShadow(
                            color: brush.innerColor.withAlpha(160),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    brush.emoji,
                    style: TextStyle(fontSize: isSel ? 16 : 13),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHorizontalBrushRack() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Kuas:',
            style: GoogleFonts.fredoka(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _kBrushes.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, idx) {
                final brush = _kBrushes[idx];
                final isSel = idx == _selectedBrushIndex;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedBrushIndex = idx;
                    });
                    if (brush.type == BrushType.rainbow || brush.type == BrushType.glitter) {
                      _audio.playSfx('star');
                    } else {
                      _audio.playSfx('ding');
                    }
                    _audio.speak(brush.voiceQuote);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSel ? 38 : 32,
                    height: isSel ? 38 : 32,
                    decoration: BoxDecoration(
                      gradient: brush.type == BrushType.rainbow
                          ? const LinearGradient(
                              colors: [
                                Color(0xFFEF4444),
                                Color(0xFFF59E0B),
                                Color(0xFF10B981),
                                Color(0xFF06B6D4),
                                Color(0xFF8B5CF6),
                              ],
                            )
                          : null,
                      color: brush.type != BrushType.rainbow ? brush.innerColor : null,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSel ? Colors.white : brush.glowColor,
                        width: isSel ? 3.0 : 1.8,
                      ),
                      boxShadow: isSel
                          ? [
                              BoxShadow(
                                color: brush.innerColor.withAlpha(160),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        brush.emoji,
                        style: TextStyle(fontSize: isSel ? 16 : 13),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Clear Canvas Button
  Widget _buildClearButton() {
    return ElevatedButton.icon(
      onPressed: () {
        HapticFeedback.lightImpact();
        setState(() {
          _userStrokes.clear();
          _isCompleted = false;
        });
        _audio.playSfx('whoosh');
      },
      icon: const VectorIconWidget(icon: 'reload', size: 16, color: Color(0xFFEA580C)),
      label: Text(
        'Hapus',
        style: GoogleFonts.fredoka(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFEA580C),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFF97316), width: 1.8),
        ),
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  // Horizontal Items Ribbon (A-Z, 1-10, Shapes)
  Widget _buildItemRibbon() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_currentItems.length, (idx) {
            final isSel = idx == _currentIndex;
            final item = _currentItems[idx];
            return GestureDetector(
              onTap: () => _selectLetter(idx),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                height: 32,
                constraints: const BoxConstraints(minWidth: 32),
                decoration: BoxDecoration(
                  color: isSel ? const Color(0xFFF97316) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSel ? const Color(0xFFEA580C) : const Color(0xFFCBD5E1),
                    width: 2,
                  ),
                  boxShadow: isSel
                      ? const [
                          BoxShadow(
                            color: Color(0x33F97316),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    item.letter,
                    style: GoogleFonts.fredoka(
                      fontSize: item.letter.length > 2 ? 11 : 14,
                      fontWeight: FontWeight.bold,
                      color: isSel ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // Top Mode Switcher Pill (Panduan vs Mandiri)
  Widget _buildModeSwitcher() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x10000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModePill(
            isFreehand: false,
            icon: '✍️',
            label: 'Panduan',
            isActive: !_isFreehandMode,
          ),
          const SizedBox(width: 4),
          _buildModePill(
            isFreehand: true,
            icon: '📝',
            label: 'Mandiri',
            isActive: _isFreehandMode,
          ),
        ],
      ),
    );
  }

  // Sub-mode Ribbon for Level 1: Huruf Besar (A-Z), Huruf Kecil (a-z), Pasangan (Aa)
  Widget _buildLetterSubModeRibbon() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(240),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBAE6FD), width: 1.8),
        boxShadow: const [
          BoxShadow(color: Color(0x10000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLetterSubModePill(
            mode: TracingLetterSubMode.uppercase,
            icon: '🔤',
            label: 'Besar A-Z',
          ),
          const SizedBox(width: 4),
          _buildLetterSubModePill(
            mode: TracingLetterSubMode.lowercase,
            icon: '🔡',
            label: 'Kecil a-z',
          ),
          const SizedBox(width: 4),
          _buildLetterSubModePill(
            mode: TracingLetterSubMode.matchPairs,
            icon: '🧩',
            label: 'Pasangan Aa',
          ),
        ],
      ),
    );
  }

  Widget _buildLetterSubModePill({
    required TracingLetterSubMode mode,
    required String icon,
    required String label,
  }) {
    final isActive = _letterSubMode == mode;
    return GestureDetector(
      onTap: () => _switchLetterSubMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF97316) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.fredoka(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mini-game View: Cocokkan Induk Huruf Besar (A-Z) & Anak Huruf Kecil (a-z)
  Widget _buildMatchPairsGameView({required bool isPortrait}) {
    final totalBatches = (GameRepository.letters.length / 4).ceil();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(235),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFBAE6FD), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Header Info & Batch Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🧩', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        isPortrait
                            ? 'Sentuh Huruf Besar lalu Huruf Kecilnya!'
                            : 'Sentuh Induk Huruf Besar (A-Z), lalu cari pasangan Anak Huruf Kecilnya (a-z)!',
                        style: GoogleFonts.fredoka(
                          fontSize: isPortrait ? 12.5 : 14,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0369A1),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Batch Navigation Pills
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        final prev = (_matchBatchIndex - 1 + totalBatches) % totalBatches;
                        _startMatchPairsBatch(prev);
                      },
                      child: const Icon(Icons.chevron_left_rounded, size: 20, color: Color(0xFFB45309)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Kelompok ${_matchBatchIndex + 1}/$totalBatches',
                      style: GoogleFonts.fredoka(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        final next = (_matchBatchIndex + 1) % totalBatches;
                        _startMatchPairsBatch(next);
                      },
                      child: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFB45309)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Uppercase Row (Induk Huruf Besar)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Row 1: Uppercase Cards with Object Illustration
                Expanded(
                  child: Row(
                    children: _matchBatchItems.map((item) {
                      final isMatched = _matchedUppercaseLetters.contains(item.letter);
                      final isSelected = _selectedUpperLetter == item.letter;
                      final isWrong = _wrongUpperFlash == item.letter;

                      Color bg = const Color(0xFFF0F9FF);
                      Color border = const Color(0xFF7DD3FC);
                      if (isMatched) {
                        bg = const Color(0xFFDCFCE7);
                        border = const Color(0xFF22C55E);
                      } else if (isWrong) {
                        bg = const Color(0xFFFEE2E2);
                        border = const Color(0xFFEF4444);
                      } else if (isSelected) {
                        bg = const Color(0xFFFEF08A);
                        border = const Color(0xFFEAB308);
                      }

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: GestureDetector(
                            onTap: () => _onTapUpperMatchCard(item),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: border,
                                  width: (isSelected || isMatched) ? 3.0 : 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: border.withAlpha(65),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ObjectIllustrationWidget(
                                          illustrationKey: item.illustrationKey,
                                          size: 36,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isMatched
                                              ? '${item.letter}${item.letter.toLowerCase()}'
                                              : item.letter,
                                          style: GoogleFonts.fredoka(
                                            fontSize: 38,
                                            fontWeight: FontWeight.w900,
                                            color: isMatched
                                                ? const Color(0xFF15803D)
                                                : const Color(0xFF0369A1),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isMatched ? '✅ ${item.word}' : item.word,
                                      style: GoogleFonts.fredoka(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isMatched
                                            ? const Color(0xFF166534)
                                            : const Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 10),

                // Divider Instruction Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '⬇️ Pasangkan dengan Anak Huruf Kecil di Bawah ⬇️',
                    style: GoogleFonts.fredoka(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Row 2: Shuffled Lowercase Cards
                Expanded(
                  child: Row(
                    children: _shuffledLowercaseChoices.map((item) {
                      final isMatched = _matchedUppercaseLetters.contains(item.letter);
                      final isSelected = _selectedLowerLetter == item.letter;
                      final isWrong = _wrongLowerFlash == item.letter;

                      Color bg = const Color(0xFFFFFBEB);
                      Color border = const Color(0xFFFCD34D);
                      if (isMatched) {
                        bg = const Color(0xFFDCFCE7);
                        border = const Color(0xFF22C55E);
                      } else if (isWrong) {
                        bg = const Color(0xFFFEE2E2);
                        border = const Color(0xFFEF4444);
                      } else if (isSelected) {
                        bg = const Color(0xFFFEF08A);
                        border = const Color(0xFFEAB308);
                      }

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: GestureDetector(
                            onTap: () => _onTapLowerMatchCard(item),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: border,
                                  width: (isSelected || isMatched) ? 3.0 : 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: border.withAlpha(65),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item.letter.toLowerCase(),
                                      style: GoogleFonts.fredoka(
                                        fontSize: 44,
                                        fontWeight: FontWeight.w900,
                                        color: isMatched
                                            ? const Color(0xFF15803D)
                                            : const Color(0xFFB45309),
                                      ),
                                    ),
                                    Text(
                                      isMatched ? 'Cocok! ⭐' : 'huruf ${item.letter.toLowerCase()}',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isMatched
                                            ? const Color(0xFF166534)
                                            : const Color(0xFF78350F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModePill({
    required bool isFreehand,
    required String icon,
    required String label,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (_isFreehandMode != isFreehand) {
          setState(() {
            _isFreehandMode = isFreehand;
            _userStrokes.clear();
            _isCompleted = false;
          });
          if (isFreehand) {
            _audio.speak('Mode Menulis Mandiri! Coba tulis huruf ${_current.letter} sendiri ya!');
          } else {
            _audio.speak('Mode Panduan Titik! Ikuti arah panduan tangan ya!');
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0284C7) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.fredoka(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CanvasTracingPainter extends CustomPainter {
  final String letter;
  final List<Offset> strokes;
  final Offset? startPoint;
  final List<Offset> guidePoints;
  final BrushItem brush;
  final double guideProgress;
  final bool showGuideHand;
  final bool isFreehandMode;

  _CanvasTracingPainter({
    required this.letter,
    required this.strokes,
    this.startPoint,
    required this.guidePoints,
    required this.brush,
    required this.guideProgress,
    required this.showGuideHand,
    required this.isFreehandMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 0. Kindergarten 3-Line Ruling in Freehand Mode
    if (isFreehandMode) {
      final topY = size.height * 0.22;
      final midY = size.height * 0.50;
      final botY = size.height * 0.78;

      // Top line (headline - soft red)
      final topPaint = Paint()
        ..color = const Color(0xFFF87171).withAlpha(120)
        ..strokeWidth = 2.0;
      canvas.drawLine(Offset(18, topY), Offset(size.width - 18, topY), topPaint);

      // Mid line (dashed midline - sky blue)
      final midPaint = Paint()
        ..color = const Color(0xFF38BDF8).withAlpha(150)
        ..strokeWidth = 1.8;
      for (double x = 18; x < size.width - 18; x += 12) {
        canvas.drawLine(Offset(x, midY), Offset(x + 6, midY), midPaint);
      }

      // Bottom line (baseline - slate blue)
      final botPaint = Paint()
        ..color = const Color(0xFF64748B).withAlpha(140)
        ..strokeWidth = 2.5;
      canvas.drawLine(Offset(18, botY), Offset(size.width - 18, botY), botPaint);
    }

    // 1. Base Stencil Letter (Solid in Guided Mode, Faint dashed watermark in Freehand Mode)
    final baseFontSize = letter.length > 1 ? 150.0 : 210.0;
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: baseFontSize,
          fontWeight: FontWeight.bold,
          foreground: Paint()
            ..color = isFreehandMode ? const Color(0xFFF1F5F9).withAlpha(140) : const Color(0xFFF1F5F9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = isFreehandMode ? 14 : 34
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textOffset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2 - (letter.length > 1 ? 4 : 10),
    );
    textPainter.paint(canvas, textOffset);

    // 2. Inner Dotted Guide Outline (Only in Guided Mode)
    if (!isFreehandMode) {
      final innerDotted = TextPainter(
        text: TextSpan(
          text: letter,
          style: TextStyle(
            fontSize: baseFontSize,
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
    }

    // 3. Start Point Marker ("1") in Guided Mode
    if (!isFreehandMode && startPoint != null) {
      if (showGuideHand) {
        final haloRadius = 13.0 + 7.0 * guideProgress;
        canvas.drawCircle(
          startPoint!,
          haloRadius,
          Paint()..color = brush.innerColor.withAlpha((100 * (1.0 - guideProgress)).toInt()),
        );
      }

      canvas.drawCircle(
        startPoint!,
        12,
        Paint()..color = brush.innerColor,
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

    // 4. Animated Guided Hand / Arrow Pointer (when child hasn't started drawing in Guided Mode)
    if (showGuideHand && !isFreehandMode && guidePoints.length >= 2) {
      final p1 = guidePoints[0];
      final p2 = guidePoints[1];
      final currentGuidePos = Offset.lerp(p1, p2, guideProgress)!;

      // Glow halo
      canvas.drawCircle(
        currentGuidePos,
        14,
        Paint()..color = brush.glowColor.withAlpha(180),
      );
      // Center finger/pointer dot
      canvas.drawCircle(
        currentGuidePos,
        8,
        Paint()..color = brush.innerColor,
      );

      // Pointing finger icon
      final pointerText = TextPainter(
        text: const TextSpan(
          text: '👆',
          style: TextStyle(fontSize: 20),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      pointerText.paint(canvas, Offset(currentGuidePos.dx + 4, currentGuidePos.dy + 4));
    }

    // 5. Drawn Strokes with Selected Brush Effect
    if (strokes.length > 1) {
      final path = Path()..moveTo(strokes[0].dx, strokes[0].dy);
      for (int i = 1; i < strokes.length; i++) {
        path.lineTo(strokes[i].dx, strokes[i].dy);
      }

      if (brush.type == BrushType.rainbow) {
        // Rainbow Gradient Effect
        final bounds = path.getBounds();
        final rainbowRect = (bounds.width > 0 && bounds.height > 0)
            ? bounds
            : Rect.fromLTWH(0, 0, size.width, size.height);

        final rainbowShader = const LinearGradient(
          colors: [
            Color(0xFFEF4444), // Red
            Color(0xFFF97316), // Orange
            Color(0xFFFACC15), // Yellow
            Color(0xFF22C55E), // Green
            Color(0xFF06B6D4), // Cyan
            Color(0xFF3B82F6), // Blue
            Color(0xFFA855F7), // Purple
          ],
        ).createShader(rainbowRect);

        // Rainbow Outer Glow
        final glowPaint = Paint()
          ..shader = rainbowShader
          ..strokeWidth = 26
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawPath(path, glowPaint);

        // Rainbow Core Stroke
        final corePaint = Paint()
          ..shader = rainbowShader
          ..strokeWidth = 15
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;
        canvas.drawPath(path, corePaint);
      } else if (brush.type == BrushType.glitter) {
        // Glitter Star Pen with Golden Halo & Twinkles
        final goldHalo = Paint()
          ..color = const Color(0xFFFDE047).withAlpha(150)
          ..strokeWidth = 26
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawPath(path, goldHalo);

        // Core Golden Stroke
        final corePaint = Paint()
          ..color = const Color(0xFFFEF08A)
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;
        canvas.drawPath(path, corePaint);

        // Draw twinkling stars along stroke samples
        for (int i = 0; i < strokes.length; i += 8) {
          _drawMiniStar(canvas, strokes[i], 5.0, Colors.white);
        }
      } else {
        // Standard Solid Crayon
        final outerGlow = Paint()
          ..color = brush.glowColor
          ..strokeWidth = 26
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;

        final innerStroke = Paint()
          ..color = brush.innerColor
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;

        canvas.drawPath(path, outerGlow);
        canvas.drawPath(path, innerStroke);
      }
    }
  }

  void _drawMiniStar(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CanvasTracingPainter oldDelegate) => true;
}
