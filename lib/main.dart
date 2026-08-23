import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/storage_service.dart';
import 'widgets/ui_header.dart';
import 'widgets/sticker_album_dialog.dart';
import 'widgets/parental_gate_dialog.dart';
import 'screens/map_screen.dart';
import 'screens/tracing_screen.dart';
import 'screens/train_screen.dart';
import 'screens/balloon_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadStoredData();
  }

  void _loadStoredData() async {
    final stars = await StorageService.getStars();
    final stickers = await StorageService.getUnlockedStickers();
    if (mounted) {
      setState(() {
        _stars = stars;
        _unlockedStickers = stickers;
      });
    }
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
      ),
    );
  }

  void _openParentalGate() {
    showDialog(
      context: context,
      builder: (_) => ParentalGateDialog(totalStars: _stars),
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
      case 'map':
      default:
        return MapScreen(
          onSelectGame: _navigateTo,
        );
    }
  }
}
