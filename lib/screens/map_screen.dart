import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/vector_illustrations.dart';
import '../widgets/child_avatar_widget.dart';
import '../widgets/daily_missions_dialog.dart';
import '../models/daily_mission_models.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

class IslandData {
  final String route;
  final String title;
  final String shortName;
  final String ageRecommendation;
  final String description;
  final String illustrationKey;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Offset mapPosition; // (x, y) coordinates in the ocean map
  final String speechQuote;

  const IslandData({
    required this.route,
    required this.title,
    required this.shortName,
    required this.ageRecommendation,
    required this.description,
    required this.illustrationKey,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.mapPosition,
    required this.speechQuote,
  });
}

class MapScreen extends StatefulWidget {
  final Function(String route) onSelectGame;
  final Function(int bonusStars)? onBonusStars;
  final VoidCallback? onOpenTrophies;
  final VoidCallback? onOpenSettings;
  final String avatarId;
  final String childName;
  final VoidCallback? onOpenAvatarDialog;

  const MapScreen({
    super.key,
    required this.onSelectGame,
    this.onBonusStars,
    this.onOpenTrophies,
    this.onOpenSettings,
    this.avatarId = 'miko',
    this.childName = 'Petualang Hebat',
    this.onOpenAvatarDialog,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final AudioService _audio = AudioService();
  final ScrollController _scrollController = ScrollController();

  int _tracingLevel = 1;
  int _trainLevel = 1;
  int _balloonLevel = 1;
  int _quizLevel = 1;
  int _mazeLevel = 1;

  String _selectedIslandRoute = 'tracing';
  List<String> _openedChests = [];
  bool _isMapView = true; // Toggle between Adventure Map and Quick Cards
  bool _isLoading = true;
  int _dailyMissionsCompleted = 0;
  int _dailyStreakDays = 1;

  // Animation Controllers
  late AnimationController _shipRockController;
  late AnimationController _waveController;

  // Interactive Creature States
  bool _isDolphinJumping = false;
  bool _isWhaleSpouting = false;
  String? _bonusToastMessage;

  late final List<IslandData> _islands = [
    const IslandData(
      route: 'tracing',
      title: 'Dermaga Jejak Huruf',
      shortName: 'Jejak Huruf',
      ageRecommendation: 'Usia 3-5 Thn',
      description: 'Tarik garis ajaib dan kenali bunyi fonik huruf A–Z!',
      illustrationKey: 'apel',
      primaryColor: Color(0xFFFEF08A),
      secondaryColor: Color(0xFFFDE047),
      accentColor: Color(0xFFEAB308),
      mapPosition: Offset(110, 155),
      speechQuote: 'Dermaga Jejak Huruf! Belajar menulis huruf A sampai Z bersama Miko!',
    ),
    const IslandData(
      route: 'train',
      title: 'Pelabuhan Kereta Kata',
      shortName: 'Kereta Kata',
      ageRecommendation: 'Usia 5-7 Thn',
      description: 'Susun gerbong kata dan bunyikan peluit lokomotif!',
      illustrationKey: 'bola',
      primaryColor: Color(0xFFBAE6FD),
      secondaryColor: Color(0xFF7DD3FC),
      accentColor: Color(0xFF0284C7),
      mapPosition: Offset(350, 75),
      speechQuote: 'Pelabuhan Kereta Kata! Susun gerbong suku kata agar kereta melaju!',
    ),
    const IslandData(
      route: 'balloon',
      title: 'Puncak Balon Ajaib',
      shortName: 'Balon Ajaib',
      ageRecommendation: 'Usia 6-8 Thn',
      description: 'Letuskan balon kata yang tepat dan kumpulkan bintang!',
      illustrationKey: 'balon',
      primaryColor: Color(0xFFFBCFE8),
      secondaryColor: Color(0xFFF472B6),
      accentColor: Color(0xFFDB2777),
      mapPosition: Offset(590, 165),
      speechQuote: 'Puncak Balon Ajaib! Letuskan balon kata yang benar di langit!',
    ),
    const IslandData(
      route: 'quiz',
      title: 'Kuil Sentuh Pintar',
      shortName: 'Kuis Pintar',
      ageRecommendation: 'Semua Usia',
      description: 'Dengarkan suara fonik dan sentuh gambar yang benar!',
      illustrationKey: 'kucing',
      primaryColor: Color(0xFFDDD6FE),
      secondaryColor: Color(0xFFC4B5FD),
      accentColor: Color(0xFF7C3AED),
      mapPosition: Offset(830, 75),
      speechQuote: 'Kuil Sentuh Pintar! Jawab kuis seru dan uji ketelitianmu!',
    ),
    const IslandData(
      route: 'playground',
      title: 'Taman Kreasi Stiker',
      shortName: 'Taman Stiker',
      ageRecommendation: 'Kreativitas',
      description: 'Hias kebun, laut, dan galaksi dengan stiker lucu!',
      illustrationKey: 'rumah',
      primaryColor: Color(0xFFBBF7D0),
      secondaryColor: Color(0xFF86EFAC),
      accentColor: Color(0xFF16A34A),
      mapPosition: Offset(1070, 160),
      speechQuote: 'Taman Kreasi Stiker! Hias pulau ajaib dengan koleksi stikermu!',
    ),
    const IslandData(
      route: 'maze',
      title: 'Lembah Labirin Kata',
      shortName: 'Labirin Kata',
      ageRecommendation: 'Usia 4-7 Thn',
      description: 'Pandu Miko di labirin untuk menjemput huruf pembentuk kata!',
      illustrationKey: 'kucing',
      primaryColor: Color(0xFFFED7AA),
      secondaryColor: Color(0xFFFB923C),
      accentColor: Color(0xFFEA580C),
      mapPosition: Offset(1310, 80),
      speechQuote: 'Lembah Labirin Kata! Pandu Miko mengumpulkan huruf rahasia!',
    ),
    const IslandData(
      route: 'storybook',
      title: 'Kastil Dongeng Ajaib',
      shortName: 'Buku Dongeng',
      ageRecommendation: 'Membaca Cerita',
      description: 'Dengar dongeng bersuara & sentuh gambar ajaibnya!',
      illustrationKey: 'buku',
      primaryColor: Color(0xFFFDE68A),
      secondaryColor: Color(0xFFFBBF24),
      accentColor: Color(0xFFD97706),
      mapPosition: Offset(1550, 160),
      speechQuote: 'Kastil Dongeng Ajaib! Buka lembaran dongeng bersama sahabat Miko!',
    ),
    const IslandData(
      route: 'dictionary',
      title: 'Perpustakaan Kamus Ajaib',
      shortName: 'Kamus Ajaib',
      ageRecommendation: '50+ Kosakata',
      description: 'Eksplorasi kata bergambar, bunyikan suku kata & fonik suara!',
      illustrationKey: 'buku',
      primaryColor: Color(0xFFE0F2FE),
      secondaryColor: Color(0xFFBAE6FD),
      accentColor: Color(0xFF0284C7),
      mapPosition: Offset(1790, 80),
      speechQuote: 'Perpustakaan Kamus Ajaib! Sentuh kata bergambar dan pecah suku katanya bersama Miko!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _shipRockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _loadState();
  }

  @override
  void dispose() {
    _shipRockController.dispose();
    _waveController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadState() async {
    final tc = await StorageService.getUnlockedGameLevel('tracing');
    final tr = await StorageService.getUnlockedGameLevel('train');
    final bl = await StorageService.getUnlockedGameLevel('balloon');
    final qz = await StorageService.getUnlockedGameLevel('quiz');
    final mz = await StorageService.getUnlockedGameLevel('maze');
    final lastIsland = await StorageService.getLastVisitedIsland();
    final chests = await StorageService.getOpenedChests();
    final missionState = await StorageService.getDailyMissionsState();

    if (mounted) {
      setState(() {
        _tracingLevel = tc;
        _trainLevel = tr;
        _balloonLevel = bl;
        _quizLevel = qz;
        _mazeLevel = mz;
        _selectedIslandRoute = lastIsland;
        _openedChests = chests;
        _dailyMissionsCompleted = missionState.completedCount;
        _dailyStreakDays = missionState.streakDays;
        _isLoading = false;
      });

      // Automatically center scroll on the current island
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentIsland(immediate: true);
      });
    }
  }

  void _openDailyMissionsDialog() {
    HapticFeedback.mediumImpact();
    _audio.playSfx('pop');
    showDialog(
      context: context,
      builder: (ctx) => DailyMissionsDialog(
        childName: widget.childName,
        avatarId: widget.avatarId,
        onNavigateToIsland: (route) {
          widget.onSelectGame(route);
        },
        onBonusStars: (b) {
          widget.onBonusStars?.call(b);
          _loadState();
        },
      ),
    ).then((_) {
      _loadState();
    });
  }

  void _scrollToCurrentIsland({bool immediate = false}) {
    final targetIndex = _islands.indexWhere((i) => i.route == _selectedIslandRoute);
    final index = targetIndex >= 0 ? targetIndex : 0;
    final targetY = (80.0 + index * 225.0 - 150.0).clamp(0.0, double.infinity);

    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final targetScroll = targetY.clamp(0.0, maxScroll);

    if (immediate) {
      _scrollController.jumpTo(targetScroll);
    } else {
      _scrollController.animateTo(
        targetScroll,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _sailToIsland(IslandData island) {
    HapticFeedback.mediumImpact();
    final isAlreadySelected = _selectedIslandRoute == island.route;

    setState(() {
      _selectedIslandRoute = island.route;
    });
    StorageService.saveLastVisitedIsland(island.route);

    _audio.playSfx('tuut');
    _audio.speak(island.speechQuote);
    _scrollToCurrentIsland();

    if (isAlreadySelected) {
      // Second tap directly enters the game
      Future.delayed(const Duration(milliseconds: 400), () {
        widget.onSelectGame(island.route);
      });
    }
  }

  void _openTreasureChest(IslandData island) {
    if (_openedChests.contains(island.route)) {
      _audio.speak('Peti harta karun di ${island.shortName} sudah kamu buka hari ini! Bintangnya sudah tersimpan!');
      return;
    }

    HapticFeedback.heavyImpact();
    _audio.playSfx('star');

    setState(() {
      _openedChests.add(island.route);
      _bonusToastMessage = '🎁 +3 Bintang Ajaib di ${island.shortName}!';
    });

    StorageService.markChestOpened(island.route);
    widget.onBonusStars?.call(3);

    _audio.speak('Hore! Kamu menemukan peti harta karun di ${island.shortName}! Dapat tiga bintang ajaib!');

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _bonusToastMessage = null;
        });
      }
    });
  }

  bool _isIslandMastered(String route) {
    switch (route) {
      case 'tracing':
        return _tracingLevel >= 3;
      case 'train':
        return _trainLevel >= 3;
      case 'balloon':
        return _balloonLevel >= 3;
      case 'quiz':
        return _quizLevel >= 3;
      case 'maze':
        return _mazeLevel >= 3;
      default:
        return false;
    }
  }

  String _getIslandLevelBadge(String route) {
    switch (route) {
      case 'tracing':
        return _tracingLevel >= 3 ? '👑 Master ⭐' : 'Tingkat $_tracingLevel ${_tracingLevel > 1 ? "⭐" : ""}';
      case 'train':
        return _trainLevel >= 3 ? '👑 Master ⭐' : 'Tingkat $_trainLevel ${_trainLevel > 1 ? "⭐" : ""}';
      case 'balloon':
        return _balloonLevel >= 3 ? '👑 Master ⭐' : 'Tingkat $_balloonLevel ${_balloonLevel > 1 ? "⭐" : ""}';
      case 'quiz':
        return _quizLevel >= 3 ? '👑 Master ⭐' : 'Tingkat $_quizLevel ${_quizLevel > 1 ? "⭐" : ""}';
      case 'playground':
        return '🎨 3 Tema';
      case 'maze':
        return _mazeLevel >= 3 ? '👑 Master ⭐' : 'Tingkat $_mazeLevel ${_mazeLevel > 1 ? "⭐" : ""}';
      case 'storybook':
        return '📖 4 Cerita';
      case 'dictionary':
        return '📚 52 Kata';
      default:
        return 'Tingkat 1';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // 1. Main Background Content
        Positioned.fill(
          child: _isMapView ? _buildAdventureMapView() : _buildQuickCardsView(),
        ),

        // 2. Top Header Toolbar (Title Badge & View Switcher)
        Positioned(
          top: 8,
          left: 12,
          right: 12,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: math.max(MediaQuery.of(context).size.width - 24, 580),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Adventure Title Badge
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(245),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFFCD34D), width: 2.5),
                      boxShadow: const [
                        BoxShadow(color: Color(0x18000000), blurRadius: 8, offset: Offset(0, 3)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⛵', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(
                          'PETA KEPULAUAN KATA AJAIB',
                          style: GoogleFonts.fredoka(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFD97706),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // View Mode Switcher Pill (Map vs Quick Cards)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(240),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x10000000), blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildViewPill(
                      isMap: true,
                      icon: '🗺️',
                      label: 'Peta Laut',
                      isActive: _isMapView,
                    ),
                    const SizedBox(width: 4),
                    _buildViewPill(
                      isMap: false,
                      icon: '📋',
                      label: 'Daftar Cepat',
                      isActive: !_isMapView,
                    ),
                  ],
                ),
              ),

              // Daily Missions Shortcut Button
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _openDailyMissionsDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Color(0x20000000), blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📅', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        'Misi $_dailyMissionsCompleted/3',
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                      if (_dailyStreakDays > 1) ...[
                        const SizedBox(width: 4),
                        Text('🔥$_dailyStreakDays',
                            style: GoogleFonts.fredoka(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFEA580C))),
                      ],
                    ],
                  ),
                ),
              ),

              // Trophy Showcase Shortcut Button
              if (widget.onOpenTrophies != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    widget.onOpenTrophies!();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFEF08A), Color(0xFFFBBF24)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD97706), width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: Color(0x20000000), blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          'Trofi',
                          style: GoogleFonts.fredoka(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF854D0E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              // Kamus Shortcut Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  widget.onSelectGame('dictionary');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF0284C7), width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Color(0x20000000), blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📚', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        'Kamus',
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0369A1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Settings Shortcut Button
              if (widget.onOpenSettings != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    widget.onOpenSettings!();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF3E8FF), Color(0xFFDDD6FE)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF7C3AED), width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: Color(0x20000000), blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⚙️', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          'Pengaturan',
                          style: GoogleFonts.fredoka(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF6D28D9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              // Child Avatar Profile Pill
              if (widget.onOpenAvatarDialog != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onOpenAvatarDialog!();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFAF5FF), Color(0xFFF3E8FF)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFA855F7), width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: Color(0x20000000), blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ChildAvatarWidget(avatarId: widget.avatarId, size: 22, showGlow: false),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 80),
                          child: Text(
                            widget.childName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.fredoka(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6B21A8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),

        // 3. Floating Bonus Toast Notification
        if (_bonusToastMessage != null)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: _bonusToastMessage != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF08A),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFEAB308), width: 2),
                    boxShadow: const [
                      BoxShadow(color: Color(0x25000000), blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        _bonusToastMessage!,
                        style: GoogleFonts.fredoka(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF854D0E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // 4. Floating Daily Mission Badge on Ocean Map
        Positioned(
          bottom: 16,
          left: 16,
          child: GestureDetector(
            onTap: _openDailyMissionsDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFBEB), Color(0xFFFEF08A)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x25000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📅', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Misi Hari Ini',
                            style: GoogleFonts.fredoka(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('🔥$_dailyStreakDays',
                              style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                      Text(
                        '$_dailyMissionsCompleted/3 Selesai (+Bintang)',
                        style: GoogleFonts.nunito(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewPill({
    required bool isMap,
    required String icon,
    required String label,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _isMapView = isMap;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0284C7) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
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

  // ==========================================
  // 1. ADVENTURE MAP VIEW (LIVING ARCHIPELAGO)
  // ==========================================
  Widget _buildAdventureMapView() {
    const mapCanvasHeight = 1960.0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF38BDF8), // Light Sky Aqua
            Color(0xFF0284C7), // Turquoise Ocean
            Color(0xFF0369A1), // Deep Sea
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final canvasWidth = math.max(constraints.maxWidth, 360.0);
          final centerX = canvasWidth / 2;

          // Compute vertical positions for the 8 islands
          final List<Offset> islandPositions = [];
          for (int i = 0; i < _islands.length; i++) {
            final isLeft = i % 2 == 0;
            // Alternating left and right along vertical ocean path
            final islandX = isLeft ? (centerX - 150.0) : (centerX - 10.0);
            final islandY = 80.0 + i * 225.0;
            islandPositions.add(Offset(islandX, islandY));
          }

          final activeIndex = _islands.indexWhere((i) => i.route == _selectedIslandRoute);
          final safeIndex = activeIndex >= 0 ? activeIndex : 0;
          final currentPos = islandPositions[safeIndex];
          final isLeft = safeIndex % 2 == 0;
          final shipTargetX = isLeft ? currentPos.dx + 115 : currentPos.dx - 45;
          final shipTargetY = currentPos.dy + 65;

          return SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: canvasWidth,
              height: mapCanvasHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Maritime Path & Buoys
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MaritimePathPainter(
                        islandPositions: islandPositions,
                        wavePhase: _waveController.value,
                      ),
                    ),
                  ),

                  // Clouds Floating in the Sky
                  Positioned(left: centerX - 160, top: 25, child: _buildSkyCloud(size: 34)),
                  Positioned(left: centerX + 110, top: 250, child: _buildSkyCloud(size: 40)),
                  Positioned(left: centerX - 170, top: 700, child: _buildSkyCloud(size: 36)),
                  Positioned(left: centerX + 120, top: 1150, child: _buildSkyCloud(size: 38)),
                  Positioned(left: centerX - 150, top: 1600, child: _buildSkyCloud(size: 36)),

                  // Interactive Living Ocean Elements: Jumping Dolphin & Whale
                  Positioned(
                    left: centerX + 75,
                    top: 470,
                    child: _buildInteractiveDolphin(),
                  ),
                  Positioned(
                    left: centerX - 175,
                    top: 1070,
                    child: _buildInteractiveWhale(),
                  ),

                  // 8 Living Islands (Vertically placed)
                  for (int i = 0; i < _islands.length; i++) ...[
                    Positioned(
                      left: islandPositions[i].dx,
                      top: islandPositions[i].dy,
                      child: _buildIsland3DWidget(
                        island: _islands[i],
                        isSelected: _islands[i].route == _selectedIslandRoute,
                        levelBadge: _getIslandLevelBadge(_islands[i].route),
                        isChestOpened: _openedChests.contains(_islands[i].route),
                      ),
                    ),
                  ],

                  // Captain Miko's Animated Sailing Ship
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOutCubic,
                    left: shipTargetX,
                    top: shipTargetY,
                    child: _buildSailingShipWidget(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Island 3D Fantasy Knoll Widget
  Widget _buildIsland3DWidget({
    required IslandData island,
    required bool isSelected,
    required String levelBadge,
    required bool isChestOpened,
  }) {
    return GestureDetector(
      onTap: () => _sailToIsland(island),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Floating Level Badge & Age Pill
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  gradient: _isIslandMastered(island.route)
                      ? const LinearGradient(colors: [Color(0xFFFEF08A), Color(0xFFFBBF24)])
                      : null,
                  color: _isIslandMastered(island.route)
                      ? null
                      : (isSelected ? const Color(0xFFFEF08A) : Colors.white.withAlpha(230)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isIslandMastered(island.route)
                        ? const Color(0xFFD97706)
                        : (isSelected ? const Color(0xFFEAB308) : const Color(0xFFCBD5E1)),
                    width: _isIslandMastered(island.route) ? 2.0 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isIslandMastered(island.route)
                          ? const Color(0x40F59E0B)
                          : const Color(0x15000000),
                      blurRadius: _isIslandMastered(island.route) ? 6 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  levelBadge,
                  style: GoogleFonts.fredoka(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF854D0E),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: island.accentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  island.ageRecommendation,
                  style: GoogleFonts.fredoka(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Island Knoll Body
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isSelected ? 175 : 155,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [island.primaryColor, island.secondaryColor],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? const Color(0xFFF59E0B) : Colors.white.withAlpha(220),
                width: isSelected ? 3.5 : 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? const Color(0x50F59E0B) : const Color(0x25000000),
                  blurRadius: isSelected ? 16 : 8,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Illustration & Mini Mascot
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(210),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: ObjectIllustrationWidget(
                          illustrationKey: island.illustrationKey,
                          size: 42,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.star_rounded, color: Colors.white, size: 14),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),

                // Island Title
                Text(
                  island.shortName,
                  style: GoogleFonts.fredoka(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // Play / Explore Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    _audio.playSfx('whoosh');
                    _audio.speak('Ayo berpetualang di ${island.title}!');
                    widget.onSelectGame(island.route);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF15803D)])
                          : const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF0369A1)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Color(0x20000000), blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? Icons.play_arrow_rounded : Icons.explore_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isSelected ? 'Mulai Main' : 'Pilih',
                            style: GoogleFonts.fredoka(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
          const SizedBox(height: 4),

          // Dock Pier & Interactive Treasure Chest
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Wooden Dock Plank
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFB45309),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 1),
                ),
                child: Text(
                  '⚓ Dermaga',
                  style: GoogleFonts.fredoka(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Interactive Treasure Chest
              GestureDetector(
                onTap: () => _openTreasureChest(island),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: isChestOpened ? const Color(0xFFE2E8F0) : const Color(0xFFFEF08A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isChestOpened ? const Color(0xFF94A3B8) : const Color(0xFFF59E0B),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isChestOpened ? '🧰' : '🎁',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        isChestOpened ? 'Dibuka' : '+3 ⭐',
                        style: GoogleFonts.fredoka(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: isChestOpened ? const Color(0xFF64748B) : const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Captain Miko's Animated Sailing Ship Widget
  Widget _buildSailingShipWidget() {
    return RotationTransition(
      turns: Tween<double>(begin: -0.015, end: 0.015).animate(
        CurvedAnimation(parent: _shipRockController, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 82,
        height: 72,
        padding: const EdgeInsets.all(4),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Water Ripple Rings underneath the hull
            Positioned(
              bottom: 2,
              child: Container(
                width: 66,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(90),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Wooden Ship Hull with Port Holes
            Positioned(
              bottom: 6,
              child: Container(
                width: 62,
                height: 24,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD97706), Color(0xFF92400E)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x30000000), blurRadius: 6, offset: Offset(0, 3)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPortHole(),
                    _buildPortHole(),
                    _buildPortHole(),
                  ],
                ),
              ),
            ),

            // White Billowing Mast & Sail with Star
            Positioned(
              top: 4,
              child: Column(
                children: [
                  // Gold Flag atop mast
                  Container(
                    width: 14,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      borderRadius: BorderRadius.only(topRight: Radius.circular(4)),
                    ),
                  ),
                  // Billowing White Sail
                  Container(
                    width: 44,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                      boxShadow: const [
                        BoxShadow(color: Color(0x15000000), blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: const Center(
                      child: Text('⭐', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),

            // Captain Miko on the Deck
            Positioned(
              bottom: 18,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(200),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFBBF24), width: 1.2),
                ),
                child: const MascotWidget(size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortHole() {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Color(0xFFFEF08A),
        shape: BoxShape.circle,
      ),
    );
  }

  // Interactive Jumping Dolphin
  Widget _buildInteractiveDolphin() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _audio.playSfx('ding');
        _audio.speak('Ciut ciut! Lumba-lumba melompat riang di air laut!');
        setState(() {
          _isDolphinJumping = true;
        });
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) setState(() => _isDolphinJumping = false);
        });
      },
      child: AnimatedScale(
        scale: _isDolphinJumping ? 1.4 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.elasticOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(140),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(220), width: 1),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🐬', style: TextStyle(fontSize: 22)),
              SizedBox(width: 4),
              Text(
                'Ciut!',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Interactive Spouting Whale
  Widget _buildInteractiveWhale() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _audio.playSfx('pop');
        _audio.speak('Byuuuur! Paus biru menyemprotkan air segar!');
        setState(() {
          _isWhaleSpouting = true;
        });
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) setState(() => _isWhaleSpouting = false);
        });
      },
      child: AnimatedScale(
        scale: _isWhaleSpouting ? 1.4 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.elasticOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(140),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(220), width: 1),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🐳', style: TextStyle(fontSize: 22)),
              SizedBox(width: 4),
              Text(
                'Byuur!',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Soft Sky Clouds
  Widget _buildSkyCloud({required double size}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size * 0.4, vertical: size * 0.2),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(210),
        borderRadius: BorderRadius.circular(size),
        boxShadow: const [
          BoxShadow(color: Color(0x10000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Icon(Icons.cloud_rounded, color: Colors.white.withAlpha(240), size: size),
    );
  }

  // ==========================================
  // 2. QUICK CARDS VIEW (RESPONSIVE VERTICAL GRID)
  // ==========================================
  Widget _buildQuickCardsView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.bottomCenter,
          radius: 1.2,
          colors: [
            Color(0xFFBBF7D0),
            Color(0xFFBAE6FD),
            Color(0xFFE0F2FE),
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isPhone = constraints.maxWidth < 480;
          final cardWidth = isPhone
              ? math.max(150.0, (constraints.maxWidth - 44) / 2)
              : 215.0;
          final cardHeight = isPhone ? 250.0 : 275.0;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 68, left: 16, right: 16, bottom: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1060),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: _islands.map((island) {
                    final levelBadge = _getIslandLevelBadge(island.route);
                    return SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: _buildIslandQuickCard(
                        island,
                        levelBadge,
                        isCompact: isPhone,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIslandQuickCard(IslandData island, String levelBadge, {bool isCompact = false}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [island.primaryColor, Colors.white],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: island.accentColor, width: 3.5),
        boxShadow: const [
          BoxShadow(color: Color(0x18000000), blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Left Level Badge
          Positioned(
            top: -10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                gradient: _isIslandMastered(island.route)
                    ? const LinearGradient(colors: [Color(0xFFFEF08A), Color(0xFFFBBF24)])
                    : null,
                color: _isIslandMastered(island.route) ? null : const Color(0xFFFEF08A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isIslandMastered(island.route)
                      ? const Color(0xFFD97706)
                      : const Color(0xFFEAB308),
                  width: _isIslandMastered(island.route) ? 2.0 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isIslandMastered(island.route)
                        ? const Color(0x40F59E0B)
                        : const Color(0x20000000),
                    blurRadius: _isIslandMastered(island.route) ? 6 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                levelBadge,
                style: GoogleFonts.fredoka(
                  fontSize: isCompact ? 9 : 10,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF854D0E),
                ),
              ),
            ),
          ),

          // Right Age Badge
          Positioned(
            top: -10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: island.accentColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Text(
                island.ageRecommendation,
                style: GoogleFonts.nunito(
                  fontSize: isCompact ? 9.5 : 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(isCompact ? 10.0 : 14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: isCompact ? 4 : 6),
                ObjectIllustrationWidget(
                  illustrationKey: island.illustrationKey,
                  size: isCompact ? 46 : 58,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      island.title,
                      style: GoogleFonts.fredoka(
                        fontSize: isCompact ? 13 : 15,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      island.description,
                      style: GoogleFonts.fredoka(
                        fontSize: isCompact ? 10 : 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                        height: 1.25,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  height: isCompact ? 34 : 38,
                  child: ElevatedButton(
                    onPressed: () {
                      _audio.playSfx('whoosh');
                      _audio.speak('Ayo main ${island.title}!');
                      widget.onSelectGame(island.route);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      elevation: 4,
                      shadowColor: const Color(0xFF15803D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      'Mulai Main',
                      style: GoogleFonts.fredoka(
                        fontSize: isCompact ? 11.5 : 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

// Custom Painter for Maritime Dotted Paths, Waves, and Stepping Stones
class _MaritimePathPainter extends CustomPainter {
  final List<Offset> islandPositions;
  final double wavePhase;

  _MaritimePathPainter({required this.islandPositions, required this.wavePhase});

  @override
  void paint(Canvas canvas, Size size) {
    final pathPaint = Paint()
      ..color = Colors.white.withAlpha(160)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = const Color(0xFFFDE047).withAlpha(130)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0;

    // Draw maritime curved route between vertical islands
    for (int i = 0; i < islandPositions.length - 1; i++) {
      final p1 = islandPositions[i] + const Offset(80, 95);
      final p2 = islandPositions[i + 1] + const Offset(80, 95);

      final midX = (p1.dx + p2.dx) / 2 + (i % 2 == 0 ? 35 : -35);
      final midY = (p1.dy + p2.dy) / 2;

      final curvePath = Path()
        ..moveTo(p1.dx, p1.dy)
        ..quadraticBezierTo(midX, midY, p2.dx, p2.dy);

      canvas.drawPath(curvePath, glowPaint);
      canvas.drawPath(curvePath, pathPaint);

      // Draw floating nautical buoy / stepping stone at midpoint
      _drawBuoy(canvas, Offset(midX, midY), i + 1);
    }

    // Draw ambient ocean waves throughout vertical height
    final wavePaint = Paint()
      ..color = Colors.white.withAlpha(35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (double y = 60; y < size.height; y += 120) {
      final waveX = (size.width / 2) + math.sin((y / 70) + wavePhase * math.pi * 2) * 50 - 50;
      final wave = Path()
        ..moveTo(waveX - 40, y)
        ..quadraticBezierTo(waveX - 20, y - 6, waveX, y)
        ..quadraticBezierTo(waveX + 20, y + 6, waveX + 40, y);
      canvas.drawPath(wave, wavePaint);
    }
  }

  void _drawBuoy(Canvas canvas, Offset center, int stepNumber) {
    // Water ripple
    canvas.drawCircle(center, 14, Paint()..color = Colors.white.withAlpha(70));

    // Wooden / Golden Stepping Buoy
    final buoyPaint = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawCircle(center, 9, buoyPaint);
    canvas.drawCircle(center, 9, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Number text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$stepNumber',
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _MaritimePathPainter oldDelegate) => true;
}
