import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_models.dart';

class StorageService {
  static const String _keyStars = 'taman_kata_stars';
  static const String _keyStickers = 'taman_kata_stickers';
  static const String _keyPlacedStickers = 'taman_kata_placed_stickers';
  static const String _keyScreenTimeLimit = 'taman_kata_screen_time_limit';
  static const String _keyPlayTimeSeconds = 'taman_kata_play_time_seconds';
  static const String _keyPlayTimeDate = 'taman_kata_play_time_date';
  static const String _keyTracingIndex = 'taman_kata_tracing_index';
  static const String _keyCompletedLetters = 'taman_kata_completed_letters';
  static const String _keyTrainIndex = 'taman_kata_train_index';
  static const String _keyBalloonIndex = 'taman_kata_balloon_index';
  static const String _keyQuizIndex = 'taman_kata_quiz_index';
  static const String _keyCompletedStories = 'taman_kata_completed_stories';

  static Future<int> getStars() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStars) ?? 20;
  }

  static Future<void> saveStars(int stars) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStars, stars);
  }

  static Future<List<String>> getUnlockedStickers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyStickers);
    if (jsonStr == null) return ['stk_apel'];
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return ['stk_apel'];
    }
  }

  static Future<void> saveUnlockedStickers(List<String> stickers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStickers, jsonEncode(stickers));
  }

  static Future<List<PlacedSticker>> getPlacedStickers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyPlacedStickers);
    if (jsonStr == null) {
      // Default initial sticker on the canvas
      return [
        PlacedSticker(
          uniqueId: 'init_1',
          stickerId: 'stk_apel',
          x: 0.35,
          y: 0.45,
          scale: 1.0,
        ),
      ];
    }
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => PlacedSticker.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> savePlacedStickers(List<PlacedSticker> stickers) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = stickers.map((e) => e.toJson()).toList();
    await prefs.setString(_keyPlacedStickers, jsonEncode(jsonList));
  }

  static Future<int> getScreenTimeLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyScreenTimeLimit) ?? 0; // 0 = off / unlimited
  }

  static Future<void> saveScreenTimeLimit(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyScreenTimeLimit, minutes);
  }

  static Future<int> getTodayPlayTimeSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString(_keyPlayTimeDate);
    if (savedDate != today) {
      await prefs.setString(_keyPlayTimeDate, today);
      await prefs.setInt(_keyPlayTimeSeconds, 0);
      return 0;
    }
    return prefs.getInt(_keyPlayTimeSeconds) ?? 0;
  }

  static Future<void> addPlayTimeSeconds(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString(_keyPlayTimeDate);
    int current = 0;
    if (savedDate == today) {
      current = prefs.getInt(_keyPlayTimeSeconds) ?? 0;
    }
    await prefs.setString(_keyPlayTimeDate, today);
    await prefs.setInt(_keyPlayTimeSeconds, current + seconds);
  }

  static Future<void> resetTodayPlayTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPlayTimeSeconds, 0);
  }

  // --- JEJAK HURUF (TRACING) ---
  static Future<int> getTracingIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTracingIndex) ?? 0;
  }

  static Future<void> saveTracingIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTracingIndex, index);
  }

  static Future<List<String>> getCompletedLetters() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyCompletedLetters);
    if (jsonStr == null) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCompletedLetters(List<String> letters) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCompletedLetters, jsonEncode(letters));
  }

  // --- KERETA SUKU KATA (TRAIN) ---
  static Future<int> getTrainIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTrainIndex) ?? 0;
  }

  static Future<void> saveTrainIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTrainIndex, index);
  }

  // --- BALON KATA AJAIB (BALLOON) ---
  static Future<int> getBalloonIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyBalloonIndex) ?? 0;
  }

  static Future<void> saveBalloonIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBalloonIndex, index);
  }

  // --- KUIS SENTUH PINTAR (QUIZ) ---
  static Future<int> getQuizIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyQuizIndex) ?? 0;
  }

  static Future<void> saveQuizIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyQuizIndex, index);
  }

  // --- BUKU CERITA AJAIB (STORYBOOK) ---
  static Future<List<String>> getCompletedStories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyCompletedStories);
    if (jsonStr == null) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCompletedStories(List<String> stories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCompletedStories, jsonEncode(stories));
  }

  // --- MULTI-LEVEL SYSTEM & TROPHIES ---
  static const String _keyTrophies = 'taman_kata_trophies';

  static Future<int> getGameLevel(String gameKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('taman_kata_${gameKey}_current_level') ?? 1;
  }

  static Future<void> saveGameLevel(String gameKey, int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('taman_kata_${gameKey}_current_level', level);
  }

  static Future<int> getUnlockedGameLevel(String gameKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('taman_kata_${gameKey}_unlocked_level') ?? 1;
  }

  static Future<void> saveUnlockedGameLevel(String gameKey, int level) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUnlocked = prefs.getInt('taman_kata_${gameKey}_unlocked_level') ?? 1;
    if (level > currentUnlocked) {
      await prefs.setInt('taman_kata_${gameKey}_unlocked_level', level);
    }
  }

  static Future<int> getGameLevelIndex(String gameKey, int level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('taman_kata_${gameKey}_l${level}_index') ?? 0;
  }

  static Future<void> saveGameLevelIndex(String gameKey, int level, int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('taman_kata_${gameKey}_l${level}_index', index);
  }

  static Future<List<String>> getTrophies() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyTrophies);
    if (jsonStr == null) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addTrophy(String trophyId) async {
    final trophies = await getTrophies();
    if (!trophies.contains(trophyId)) {
      trophies.add(trophyId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyTrophies, jsonEncode(trophies));
    }
  }

  // --- RESET SEMUA PROGRES BELAJAR ---
  static Future<void> resetAllLearningProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTracingIndex, 0);
    await prefs.setString(_keyCompletedLetters, jsonEncode([]));
    await prefs.setInt(_keyTrainIndex, 0);
    await prefs.setInt(_keyBalloonIndex, 0);
    await prefs.setInt(_keyQuizIndex, 0);
    await prefs.setString(_keyCompletedStories, jsonEncode([]));

    for (final game in ['train', 'balloon', 'quiz', 'tracing']) {
      await prefs.setInt('taman_kata_${game}_current_level', 1);
      await prefs.setInt('taman_kata_${game}_unlocked_level', 1);
      await prefs.setInt('taman_kata_${game}_l1_index', 0);
      await prefs.setInt('taman_kata_${game}_l2_index', 0);
      await prefs.setInt('taman_kata_${game}_l3_index', 0);
    }
  }
}

