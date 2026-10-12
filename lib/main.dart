import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/storage_service.dart';
import 'widgets/ui_header.dart';
import 'widgets/sticker_album_dialog.dart';
import 'widgets/parental_gate_dialog.dart';
import 'widgets/rest_time_dialog.dart';
import 'screens/map_screen.dart';
import 'screens/tracing_screen.dart';
import 'screens/train_screen.dart';
import 'screens/balloon_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/sticker_playground_screen.dart';
import 'screens/storybook_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to Landscape for Tablet / iPad experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set immersive full-screen UI overlay
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const TamanKataAjaibApp());
}

class TamanKataAjaibApp extends StatelessWidget {
  const TamanKataAjaibApp({super.key});

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
      home: const MainTabletScreen(),
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

  @override
  void initState() {
    super.initState();
    _loadStoredData();
  }

  @override
  void dispose() {
    _playTimer?.cancel();
    super.dispose();
  }

  void _loadStoredData() async {
    final stars = await StorageService.getStars();
    final stickers = await StorageService.getUnlockedStickers();
    final limit = await StorageService.getScreenTimeLimit();
    final todaySec = await StorageService.getTodayPlayTimeSeconds();
    if (mounted) {
      setState(() {
        _stars = stars;
        _unlockedStickers = stickers;
        _limitMinutes = limit;
        _todayPlayTimeSeconds = todaySec;
      });
      _startPlayTimer();
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
      case 'map':
      default:
        return MapScreen(
          onSelectGame: _navigateTo,
        );
    }
  }
}
