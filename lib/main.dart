import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/storage_service.dart';
import 'services/audio_service.dart';
import 'widgets/ui_header.dart';
import 'widgets/sticker_album_dialog.dart';
import 'widgets/parental_gate_dialog.dart';
import 'widgets/rest_time_dialog.dart';
import 'widgets/daily_reward_dialog.dart';
import 'widgets/trophy_showcase_dialog.dart';
import 'widgets/settings_dialog.dart';
import 'screens/map_screen.dart';
import 'screens/tracing_screen.dart';
import 'screens/train_screen.dart';
import 'screens/balloon_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/sticker_playground_screen.dart';
import 'screens/storybook_screen.dart';
import 'screens/maze_screen.dart';
import 'screens/dictionary_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Support both Portrait and Landscape for Mobile Phones, Tablets, and Web
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set immersive full-screen UI overlay
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const TamanKataAjaibApp());
}

class TamanKataAjaibApp extends StatefulWidget {
  const TamanKataAjaibApp({super.key});

  @override
  State<TamanKataAjaibApp> createState() => _TamanKataAjaibAppState();
}

class _TamanKataAjaibAppState extends State<TamanKataAjaibApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taman Kata Ajaib',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.fredokaTextTheme(
          Theme.of(context).textTheme,
        ),
        scaffoldBackgroundColor: const Color(0xFF0369A1),
        primarySwatch: Colors.amber,
      ),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _showSplash
            ? SplashScreen(
                key: const ValueKey('splash_screen'),
                onFinish: () {
                  setState(() => _showSplash = false);
                },
              )
            : const MainTabletScreen(key: ValueKey('main_tablet_screen')),
      ),
    );
  }
}

class MainTabletScreen extends StatefulWidget {
  const MainTabletScreen({super.key});

  @override
  State<MainTabletScreen> createState() => _MainTabletScreenState();
}

class _MainTabletScreenState extends State<MainTabletScreen> {
  int _stars = 20;
  List<String> _unlockedStickers = ['stk_apel'];
  String _currentRoute = 'map';
  String _mascotText = 'Hai! Ayo bertualang dan belajar membaca bersama Miko!';

  // Screen Time Limiter variables
  int _limitMinutes = 0;
  int _todayPlayTimeSeconds = 0;
  Timer? _playTimer;
  bool _isRestDialogOpen = false;
  bool _hasDailyReward = false;

  @override
  void initState() {
    super.initState();
    _loadStoredData();
  }

  @override
  void dispose() {
    _playTimer?.cancel();
    AudioService().stopBgm();
    super.dispose();
  }

  void _loadStoredData() async {
    final stars = await StorageService.getStars();
    final stickers = await StorageService.getUnlockedStickers();
    final limit = await StorageService.getScreenTimeLimit();
    final todaySec = await StorageService.getTodayPlayTimeSeconds();
    final canDaily = await StorageService.canClaimDailyReward();
    if (mounted) {
      setState(() {
        _stars = stars;
        _unlockedStickers = stickers;
        _limitMinutes = limit;
        _todayPlayTimeSeconds = todaySec;
        _hasDailyReward = canDaily;
      });
      _startPlayTimer();
      AudioService().startBgm();

      if (canDaily) {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted && _hasDailyReward) {
            _openDailyRewardDialog();
          }
        });
      }
    }
  }

  void _startPlayTimer() {
    _playTimer?.cancel();
    _playTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _todayPlayTimeSeconds++;
      if (_todayPlayTimeSeconds % 60 == 0) {
        StorageService.addPlayTimeSeconds(60);
      }
      _checkScreenTimeLimit();
    });
  }

  void _checkScreenTimeLimit() {
    if (_limitMinutes > 0 &&
        _todayPlayTimeSeconds >= _limitMinutes * 60 &&
        !_isRestDialogOpen &&
        mounted) {
      _triggerRestDialog();
    }
  }

  void _triggerRestDialog() {
    _isRestDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RestTimeDialog(
        onAdd15Minutes: () {
          setState(() {
            _limitMinutes += 15;
          });
          StorageService.saveScreenTimeLimit(_limitMinutes);
          _isRestDialogOpen = false;
        },
        onDismissLimit: () {
          setState(() {
            _limitMinutes = 0;
          });
          StorageService.saveScreenTimeLimit(0);
          _isRestDialogOpen = false;
        },
      ),
    ).then((_) {
      _isRestDialogOpen = false;
    });
  }

  void _addStars(int count) {
    setState(() {
      _stars += count;
    });
    StorageService.saveStars(_stars);
  }

  void _navigateTo(String route) {
    setState(() {
      _currentRoute = route;
      if (route == 'map') {
        _mascotText = 'Pilih pulau yang ingin kamu jelajahi!';
      } else if (route == 'tracing') {
        _mascotText = 'Tarik garis mengikuti titik untuk membuat huruf!';
      } else if (route == 'train') {
        _mascotText = 'Susun gerbong suku kata agar kereta bisa melaju!';
      } else if (route == 'balloon') {
        _mascotText = 'Letuskan balon kata yang tepat ya!';
      } else if (route == 'quiz') {
        _mascotText = 'Dengarkan soalnya, lalu pencet gambar yang benar!';
      } else if (route == 'playground') {
        _mascotText = 'Tempel dan geser stikermu untuk menghias taman ajaib!';
      } else if (route == 'storybook') {
        _mascotText = 'Buka bukunya dan dengarkan dongeng ajaib bersama Miko!';
      } else if (route == 'maze') {
        _mascotText = 'Pandu Miko di labirin untuk menjemput huruf rahasia!';
      } else if (route == 'dictionary') {
        _mascotText = 'Buka kamus bergambar dan dengarkan bunyinya bersama Miko!';
      }
    });
  }

  void _openStickersAlbum() {
    showDialog(
      context: context,
      builder: (_) => StickerAlbumDialog(
        currentStars: _stars,
        unlockedStickers: _unlockedStickers,
        onUpdate: (newStars, newUnlocked) {
          setState(() {
            _stars = newStars;
            _unlockedStickers = newUnlocked;
          });
          StorageService.saveStars(_stars);
          StorageService.saveUnlockedStickers(_unlockedStickers);
        },
        onGoToPlayground: () => _navigateTo('playground'),
      ),
    );
  }

  void _openDailyRewardDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DailyRewardDialog(
        currentStars: _stars,
        unlockedStickers: _unlockedStickers,
        onRewardClaimed: (newStars, newUnlocked) {
          setState(() {
            _stars = newStars;
            _unlockedStickers = newUnlocked;
            _hasDailyReward = false;
          });
        },
      ),
    );
  }

  void _openTrophyShowcase() {
    showDialog(
      context: context,
      builder: (_) => TrophyShowcaseDialog(
        onBackToMap: () => _navigateTo('map'),
      ),
    );
  }

  void _openSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) => SettingsDialog(
        onOpenParentalGate: _openParentalGate,
      ),
    );
  }

  void _openParentalGate() {
    showDialog(
      context: context,
      builder: (_) => ParentalGateDialog(
        totalStars: _stars,
        onLimitChanged: (newLimit) {
          setState(() {
            _limitMinutes = newLimit;
          });
          _checkScreenTimeLimit();
        },
        onDataReset: _loadStoredData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE0F2FE),
                Color(0xFFFEF9C3),
                Color(0xFFDCFCE7),
              ],
            ),
          ),
          child: Column(
            children: [
              // Top Header Bar
              UiHeader(
                mascotText: _mascotText,
                stars: _stars,
                hasDailyReward: _hasDailyReward,
                onDailyRewardPressed: _openDailyRewardDialog,
                onTrophyPressed: _openTrophyShowcase,
                onDictionaryPressed: () => _navigateTo('dictionary'),
                onSettingsPressed: _openSettingsDialog,
                onHomePressed: () => _navigateTo('map'),
                onStickersPressed: _openStickersAlbum,
                onParentalPressed: _openParentalGate,
              ),

              // Game Body Viewport
              Expanded(
                child: _buildCurrentView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentRoute) {
      case 'tracing':
        return TracingScreen(
          onVictory: _addStars,
          onBack: () => _navigateTo('map'),
        );
      case 'train':
        return TrainScreen(
          onVictory: _addStars,
          onBack: () => _navigateTo('map'),
        );
      case 'balloon':
        return BalloonScreen(
          onVictory: _addStars,
          onBack: () => _navigateTo('map'),
        );
      case 'quiz':
        return QuizScreen(
          onVictory: _addStars,
          onBack: () => _navigateTo('map'),
        );
      case 'playground':
        return StickerPlaygroundScreen(
          unlockedStickers: _unlockedStickers,
          onBack: () => _navigateTo('map'),
          onOpenAlbum: _openStickersAlbum,
        );
      case 'storybook':
        return StorybookScreen(
          onVictory: _addStars,
          onBack: () => _navigateTo('map'),
        );
      case 'maze':
        return MazeScreen(
          onVictory: _addStars,
          onBack: () => _navigateTo('map'),
        );
      case 'dictionary':
        return DictionaryScreen(
          onVictory: _addStars,
          onBack: () => _navigateTo('map'),
        );
      case 'map':
      default:
        return MapScreen(
          onSelectGame: _navigateTo,
          onBonusStars: _addStars,
          onOpenTrophies: _openTrophyShowcase,
          onOpenSettings: _openSettingsDialog,
        );
    }
  }
}
