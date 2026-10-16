import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_models.dart';
import '../widgets/vector_illustrations.dart';
import '../widgets/victory_dialog.dart';
import '../widgets/level_milestone_dialog.dart';
import '../widgets/level_selector_ribbon.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

class MazeScreen extends StatefulWidget {
  final Function(int starsAdded) onVictory;
  final VoidCallback onBack;

  const MazeScreen({
    super.key,
    required this.onVictory,
    required this.onBack,
  });

  @override
  State<MazeScreen> createState() => _MazeScreenState();
}

class _MazeScreenState extends State<MazeScreen> with TickerProviderStateMixin {
  int _currentLevel = 1;
  int _unlockedLevel = 1;
  int _currentIndex = 0;
  List<MazeWordData> _mazeWords = GameRepository.getMazeWords(1);
  final AudioService _audio = AudioService();

  // Maze gameplay state
  Point<int> _currentPos = const Point<int>(1, 1);
  bool _facingLeft = false;
  final Set<int> _collectedIndices = <int>{};
  final Set<Point<int>> _collectedStars = <Point<int>>{};
  List<Point<int>> _hintPath = <Point<int>>[];
  Timer? _hintTimer;
  bool _isGoalUnlocked = false;
  final FocusNode _focusNode = FocusNode();

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _bounceController;

  MazeWordData get _current =>
      _currentIndex < _mazeWords.length ? _mazeWords[_currentIndex] : _mazeWords[0];

  @override
  void initState() {
    super.initState();
    _currentPos = _current.startPos;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _loadLevelData();
  }

  void _loadLevelData() async {
    final lvl = await StorageService.getGameLevel('maze');
    final unl = await StorageService.getUnlockedGameLevel('maze');
    final idx = await StorageService.getGameLevelIndex('maze', lvl);
    final words = GameRepository.getMazeWords(lvl);

    if (mounted) {
      setState(() {
        _currentLevel = lvl;
        _unlockedLevel = unl;
        _mazeWords = words;
        _currentIndex = (idx < words.length) ? idx : 0;
      });
      _startMaze();
    }
  }

  void _switchLevel(int newLevel) async {
    final words = GameRepository.getMazeWords(newLevel);
    final idx = await StorageService.getGameLevelIndex('maze', newLevel);
    await StorageService.saveGameLevel('maze', newLevel);

    setState(() {
      _currentLevel = newLevel;
      _mazeWords = words;
      _currentIndex = (idx < words.length) ? idx : 0;
    });

    _startMaze();
    final titles = {1: 'Tunas Huruf', 2: 'Petualang Suku Kata', 3: 'Master Labirin'};
    _audio.speak('Tingkat $_currentLevel: ${titles[_currentLevel]}! Bantu Miko mencari kata ${_current.word}!');
  }

  void _startMaze() {
    setState(() {
      _currentPos = _current.startPos;
      _collectedIndices.clear();
      _collectedStars.clear();
      _hintPath.clear();
      _isGoalUnlocked = false;
      _facingLeft = false;
    });

    final firstToken = _current.sequence.isNotEmpty ? _current.sequence[0] : '';
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _audio.speak(
          'Ayo pandu Miko menyusun kata ${_current.word}! Cari ${_currentLevel == 1 ? "huruf" : "suku kata"} pertama: $firstToken!',
        );
      }
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _pulseController.dispose();
    _bounceController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // --- PATHFINDING & HINT HELPER ---
  List<Point<int>> _findShortestPath(Point<int> start, Point<int> target) {
    final grid = _current.grid;
    final queue = <List<Point<int>>>[
      [start]
    ];
    final visited = <Point<int>>{start};

    while (queue.isNotEmpty) {
      final path = queue.removeAt(0);
      final current = path.last;

      if (current == target) {
        return path;
      }

      final directions = const [
        Point(0, -1), // Up
        Point(0, 1),  // Down
        Point(-1, 0), // Left
        Point(1, 0),  // Right
      ];

      for (final dir in directions) {
        final next = Point(current.x + dir.x, current.y + dir.y);
        if (next.y >= 0 &&
            next.y < _current.rows &&
            next.x >= 0 &&
            next.x < _current.cols &&
            grid[next.y][next.x] == 0 &&
            !visited.contains(next)) {
          visited.add(next);
          queue.add([...path, next]);
        }
      }
    }
    return [];
  }

  void _triggerHint() {
    HapticFeedback.mediumImpact();
    Point<int> target;

    if (_collectedIndices.length < _current.sequence.length) {
      target = _current.itemPositions[_collectedIndices.length];
      final targetToken = _current.sequence[_collectedIndices.length];
      _audio.speak('Ikuti jejak kaki menuju $targetToken!');
    } else {
      target = _current.goalPos;
      _audio.speak('Ayo bawa kata ${_current.word} ke Peti Emas!');
    }

    final path = _findShortestPath(_currentPos, target);
    setState(() {
      _hintPath = path;
    });

    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _hintPath = [];
        });
      }
    });
  }

  // --- MOVEMENT & INTERACTION LOGIC ---
  void _tryMove(int dx, int dy) {
    final nextX = _currentPos.x + dx;
    final nextY = _currentPos.y + dy;

    // Check bounds
    if (nextX < 0 || nextX >= _current.cols || nextY < 0 || nextY >= _current.rows) {
      HapticFeedback.lightImpact();
      return;
    }

    // Check wall
    if (_current.grid[nextY][nextX] == 1) {
      HapticFeedback.mediumImpact();
      _bounceController.forward(from: 0.0);
      _audio.playSfx('pop');
      return;
    }

    final newPoint = Point(nextX, nextY);
    HapticFeedback.selectionClick();

    setState(() {
      _currentPos = newPoint;
      if (dx < 0) _facingLeft = true;
      if (dx > 0) _facingLeft = false;

      // Clear visited hint point
      _hintPath.remove(newPoint);
    });

    // Check bonus stars
    if (_current.bonusStars.contains(newPoint) && !_collectedStars.contains(newPoint)) {
      _collectedStars.add(newPoint);
      _audio.playSfx('star');
      widget.onVictory(1);
      _audio.speak('Bintang bonus!');
    }

    // Check sequence item collection
    for (int i = 0; i < _current.itemPositions.length; i++) {
      if (_current.itemPositions[i] == newPoint) {
        final expectedIdx = _collectedIndices.length;

        if (i == expectedIdx) {
          // Correct sequence collection!
          setState(() {
            _collectedIndices.add(i);
          });
          HapticFeedback.heavyImpact();
          _audio.playSfx('star');

          final collectedToken = _current.sequence[i];

          if (_collectedIndices.length == _current.sequence.length) {
            // All items collected!
            setState(() {
              _isGoalUnlocked = true;
            });
            Future.delayed(const Duration(milliseconds: 300), () {
              _audio.speak(
                '$collectedToken! Luar biasa, semua huruf lengkap! Ayo pandu Miko ke Peti Emas!',
              );
            });
          } else {
            final nextToken = _current.sequence[_collectedIndices.length];
            Future.delayed(const Duration(milliseconds: 250), () {
              _audio.speak(
                '$collectedToken! Hebat! Sekarang cari $nextToken!',
              );
            });
          }
        } else if (!_collectedIndices.contains(i)) {
          // Out of order attempt
          final neededToken = _current.sequence[expectedIdx];
          _audio.speak('Kumpulkan $neededToken dulu ya!');
        }
        break;
      }
    }

    // Check Goal Arrival
    if (newPoint == _current.goalPos) {
      if (_isGoalUnlocked) {
        _handleVictory();
      } else {
        _audio.speak(
          'Kumpulkan semua ${_currentLevel == 1 ? "huruf" : "suku kata"} dulu untuk membuka peti!',
        );
      }
    }
  }

  void _handleTileTap(int r, int c) {
    final dist = (r - _currentPos.y).abs() + (c - _currentPos.x).abs();
    if (dist == 1) {
      _tryMove(c - _currentPos.x, r - _currentPos.y);
    }
  }

  void _handleVictory() async {
    HapticFeedback.heavyImpact();
    _audio.playSfx('star');
    _audio.speak('Hore! Kata ${_current.word} berhasil ditemukan!');

    final hasMoreInLevel = _currentIndex + 1 < _mazeWords.length;

    if (hasMoreInLevel) {
      widget.onVictory(3);
      final solvedWord = _current.word;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => VictoryDialog(
          title: 'Hebat! Kata "$solvedWord"!',
          subtitle: 'Miko berhasil keluar dari labirin membawa kata $solvedWord!',
          onNext: () {
            setState(() {
              _currentIndex++;
            });
            StorageService.saveGameLevelIndex('maze', _currentLevel, _currentIndex);
            _startMaze();
          },
        ),
      );
    } else {
      // LEVEL GRADUATION / MILESTONE
      widget.onVictory(15);
      final nextLvl = _currentLevel + 1;
      if (nextLvl <= 3) {
        await StorageService.saveUnlockedGameLevel('maze', nextLvl);
        if (nextLvl > _unlockedLevel) {
          setState(() {
            _unlockedLevel = nextLvl;
          });
        }
      }
      await StorageService.addTrophy('maze_l$_currentLevel');
      await StorageService.saveGameLevelIndex('maze', _currentLevel, 0);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => LevelMilestoneDialog(
          gameTitle: 'Labirin Kata Si Miko',
          completedLevel: _currentLevel,
          onNextLevel: () {
            _switchLevel(_currentLevel + 1);
          },
          onReplay: () {
            setState(() {
              _currentIndex = 0;
            });
            _startMaze();
          },
          onBackToMap: widget.onBack,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
              event.logicalKey == LogicalKeyboardKey.keyW) {
            _tryMove(0, -1);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
              event.logicalKey == LogicalKeyboardKey.keyS) {
            _tryMove(0, 1);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
              event.logicalKey == LogicalKeyboardKey.keyA) {
            _tryMove(-1, 0);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
              event.logicalKey == LogicalKeyboardKey.keyD) {
            _tryMove(1, 0);
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // TOP BAR: Level Selector Ribbon + Word Banner + Hint Button
            _buildTopBar(),
            const SizedBox(height: 8),

            // MAIN GAME AREA: Maze Board (Left/Center) + D-Pad Controls (Right)
            Expanded(
              child: Row(
                children: [
                  // Left / Center: Interactive Maze Board
                  Expanded(
                    flex: 7,
                    child: _buildMazeBoard(),
                  ),
                  const SizedBox(width: 14),

                  // Right: Tactile Directional D-Pad & Control Card
                  Expanded(
                    flex: 3,
                    child: _buildControlPanel(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Level Ribbon
        Flexible(
          flex: 4,
          child: LevelSelectorRibbon(
            currentLevel: _currentLevel,
            unlockedLevel: _unlockedLevel,
            onSelectLevel: _switchLevel,
          ),
        ),

        // Target Word Tray Banner
        Expanded(
          flex: 6,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF59E0B), width: 2.5),
              boxShadow: const [
                BoxShadow(color: Color(0x18000000), blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Illustration
                  ObjectIllustrationWidget(
                    illustrationKey: _current.illustrationKey,
                    size: 38,
                  ),
                  const SizedBox(width: 8),

                  // Sequence Token Chips
                  ...List.generate(_current.sequence.length, (idx) {
                    final token = _current.sequence[idx];
                    final isCollected = _collectedIndices.contains(idx);
                    final isNext = idx == _collectedIndices.length;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCollected
                            ? const Color(0xFF22C55E)
                            : (isNext ? const Color(0xFFFDE047) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCollected
                              ? const Color(0xFF15803D)
                              : (isNext ? const Color(0xFFD97706) : const Color(0xFFCBD5E1)),
                          width: isNext ? 2.5 : 1.5,
                        ),
                        boxShadow: isNext
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withAlpha(120),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCollected) ...[
                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 3),
                          ],
                          Text(
                            token,
                            style: GoogleFonts.fredoka(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isCollected
                                  ? Colors.white
                                  : (isNext ? const Color(0xFF92400E) : const Color(0xFF94A3B8)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(width: 8),

                  // Audio Word Speaker
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _audio.speak('Kata ${_current.word}!');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E7FF),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF818CF8)),
                      ),
                      child: const Icon(Icons.volume_up_rounded, size: 18, color: Color(0xFF4338CA)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Hint Button
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEF08A),
              foregroundColor: const Color(0xFF854D0E),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFEAB308), width: 2),
              ),
            ),
            onPressed: _triggerHint,
            icon: const Icon(Icons.lightbulb_rounded, size: 18, color: Color(0xFFCA8A04)),
            label: Text(
              'Petunjuk',
              style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMazeBoard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF86EFAC), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x18000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxH = constraints.maxHeight - 16;
          final maxW = constraints.maxWidth - 16;
          final cellH = maxH / _current.rows;
          final cellW = maxW / _current.cols;
          final cellSize = min(cellH, cellW);

          final gridWidth = cellSize * _current.cols;
          final gridHeight = cellSize * _current.rows;

          return Center(
            child: SizedBox(
              width: gridWidth,
              height: gridHeight,
              child: Stack(
                children: [
                  // 1. Grid of Path and Wall Tiles
                  Column(
                    children: List.generate(_current.rows, (r) {
                      return Row(
                        children: List.generate(_current.cols, (c) {
                          final isWall = _current.grid[r][c] == 1;
                          final isGoal = _current.goalPos == Point(c, r);
                          final hasStar = _current.bonusStars.contains(Point(c, r)) &&
                              !_collectedStars.contains(Point(c, r));
                          final isHint = _hintPath.contains(Point(c, r));

                          // Check if cell has a sequence item
                          int itemIdx = -1;
                          for (int i = 0; i < _current.itemPositions.length; i++) {
                            if (_current.itemPositions[i] == Point(c, r)) {
                              itemIdx = i;
                              break;
                            }
                          }
                          final isCollected = itemIdx != -1 && _collectedIndices.contains(itemIdx);
                          final isNextItem = itemIdx == _collectedIndices.length;

                          return GestureDetector(
                            onTap: () => _handleTileTap(r, c),
                            child: Container(
                              width: cellSize - 3.0,
                              height: cellSize - 3.0,
                              margin: const EdgeInsets.all(1.5),
                              decoration: BoxDecoration(
                                color: isWall
                                    ? const Color(0xFF15803D) // Leafy Hedge Green
                                    : (isHint
                                        ? const Color(0xFFFEF08A)
                                        : const Color(0xFFFFFBEB)), // Sunny Cobblestone
                                borderRadius: BorderRadius.circular(cellSize * 0.22),
                                border: Border.all(
                                  color: isWall
                                      ? const Color(0xFF166534)
                                      : (isHint
                                          ? const Color(0xFFEAB308)
                                          : const Color(0xFFFDE68A)),
                                  width: isHint ? 2.5 : 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isWall
                                        ? const Color(0x30000000)
                                        : const Color(0x10000000),
                                    offset: const Offset(0, 1.5),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Wall leaf decoration
                                  if (isWall)
                                    Text(
                                      (r + c) % 3 == 0 ? '🌸' : '🌿',
                                      style: TextStyle(fontSize: cellSize * 0.38),
                                    ),

                                  // Hint Footprints
                                  if (isHint && !isWall)
                                    Text('🐾', style: TextStyle(fontSize: cellSize * 0.34)),

                                  // Bonus Star
                                  if (hasStar && !isWall)
                                    RotationTransition(
                                      turns: _pulseController,
                                      child: Text(
                                        '⭐',
                                        style: TextStyle(fontSize: cellSize * 0.46),
                                      ),
                                    ),

                                  // Sequence Item Token (Letter / Syllable)
                                  if (itemIdx != -1 && !isWall)
                                    _buildTokenTile(
                                      cellSize: cellSize,
                                      token: _current.sequence[itemIdx],
                                      isCollected: isCollected,
                                      isNext: isNextItem,
                                    ),

                                  // Goal Chest / Finish Gate
                                  if (isGoal)
                                    _buildGoalTile(cellSize),
                                ],
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ),

                  // 2. Miko Walking Mascot Avatar
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    left: _currentPos.x * cellSize + 1.5,
                    top: _currentPos.y * cellSize + 1.5,
                    width: cellSize - 3.0,
                    height: cellSize - 3.0,
                    child: Center(
                      child: Transform.flip(
                        flipX: _facingLeft,
                        child: MascotWidget(size: cellSize * 0.88),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTokenTile({
    required double cellSize,
    required String token,
    required bool isCollected,
    required bool isNext,
  }) {
    if (isCollected) {
      return Container(
        width: cellSize * 0.65,
        height: cellSize * 0.65,
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: const Center(
          child: Icon(Icons.check_rounded, color: Color(0xFF16A34A), size: 14),
        ),
      );
    }

    return ScaleTransition(
      scale: isNext
          ? Tween<double>(begin: 0.95, end: 1.15).animate(_pulseController)
          : const AlwaysStoppedAnimation(1.0),
      child: Container(
        width: cellSize * 0.76,
        height: cellSize * 0.76,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isNext
                ? const [Color(0xFFFEF08A), Color(0xFFF59E0B)]
                : const [Color(0xFFBAE6FD), Color(0xFF38BDF8)],
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: isNext ? const Color(0xFFD97706) : const Color(0xFF0284C7),
            width: 2.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isNext ? const Color(0xFFF59E0B) : const Color(0xFF38BDF8))
                  .withAlpha(140),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            token,
            style: GoogleFonts.fredoka(
              fontSize: cellSize * (token.length > 2 ? 0.28 : 0.36),
              fontWeight: FontWeight.w900,
              color: isNext ? const Color(0xFF78350F) : const Color(0xFF0369A1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalTile(double cellSize) {
    return Container(
      width: cellSize * 0.85,
      height: cellSize * 0.85,
      decoration: BoxDecoration(
        color: _isGoalUnlocked ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
        shape: BoxShape.circle,
        border: Border.all(
          color: _isGoalUnlocked ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
          width: 2,
        ),
        boxShadow: _isGoalUnlocked
            ? [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withAlpha(160),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          _isGoalUnlocked ? '🏆' : '🔒',
          style: TextStyle(fontSize: cellSize * 0.48),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 2.5),
        boxShadow: const [
          BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: 170,
                height: 250,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Current Mission Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🧭', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            _isGoalUnlocked
                                ? 'Ke Peti Harta!'
                                : 'Cari ${_current.sequence.isNotEmpty && _collectedIndices.length < _current.sequence.length ? _current.sequence[_collectedIndices.length] : ""}',
                            style: GoogleFonts.fredoka(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1D4ED8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // TACTILE D-PAD (DIAMOND LAYOUT)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Up Button
                        _buildDpadButton(
                          icon: Icons.keyboard_arrow_up_rounded,
                          color: const Color(0xFFF59E0B),
                          borderColor: const Color(0xFFD97706),
                          onTap: () => _tryMove(0, -1),
                        ),
                        const SizedBox(height: 6),

                        // Middle Row: Left & Right Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDpadButton(
                              icon: Icons.keyboard_arrow_left_rounded,
                              color: const Color(0xFF0284C7),
                              borderColor: const Color(0xFF0369A1),
                              onTap: () => _tryMove(-1, 0),
                            ),
                            const SizedBox(width: 28),
                            _buildDpadButton(
                              icon: Icons.keyboard_arrow_right_rounded,
                              color: const Color(0xFF0284C7),
                              borderColor: const Color(0xFF0369A1),
                              onTap: () => _tryMove(1, 0),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Down Button
                        _buildDpadButton(
                          icon: Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFF7E22CE),
                          borderColor: const Color(0xFF6B21A8),
                          onTap: () => _tryMove(0, 1),
                        ),
                      ],
                    ),

                    // Reset maze position button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _startMaze();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.refresh_rounded, size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              'Ulangi Labirin',
                              style: GoogleFonts.fredoka(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDpadButton({
    required IconData icon,
    required Color color,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: borderColor.withAlpha(180),
              offset: const Offset(0, 3.5),
              blurRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: Colors.white, size: 34),
        ),
      ),
    );
  }
}
