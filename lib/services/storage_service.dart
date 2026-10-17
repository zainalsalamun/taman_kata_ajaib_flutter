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
  static const String _keyPlaygroundTheme = 'taman_kata_playground_theme';
  static const String _keyLastVisitedIsland = 'taman_kata_last_visited_island';
  static const String _keyOpenedChests = 'taman_kata_opened_chests';
  static const String _keyChildName = 'taman_kata_child_name';
  static const String _keyLastDailySpinDate = 'taman_kata_last_daily_spin_date';
  static const String _keyDailyStreak = 'taman_kata_daily_streak';

  static Future<String> getChildName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyChildName) ?? 'Juara Cilik';
  }

  static Future<void> saveChildName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyChildName, name.trim().isEmpty ? 'Juara Cilik' : name.trim());
  }

  static Future<String> getLastVisitedIsland() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastVisitedIsland) ?? 'tracing';
  }

  static Future<void> saveLastVisitedIsland(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastVisitedIsland, route);
  }

  static Future<List<String>> getOpenedChests() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyOpenedChests);
    if (jsonStr == null) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> markChestOpened(String chestId) async {
    final opened = await getOpenedChests();
    if (!opened.contains(chestId)) {
      opened.add(chestId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyOpenedChests, jsonEncode(opened));
    }
  }

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

  // --- HADIAH HARIAN & RODA KEBERUNTUNGAN ---
  static String _getTodayDateString() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }

  static Future<bool> canClaimDailyReward() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_keyLastDailySpinDate);
    if (lastDate == null) return true;
    return lastDate != _getTodayDateString();
  }

  static Future<int> getDailyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDailyStreak) ?? 1;
  }

  static Future<String?> getLastDailySpinDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastDailySpinDate);
  }

  static Future<Map<String, dynamic>> claimDailyReward({
    required int rewardStars,
    String? rewardSticker,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _getTodayDateString();
    final lastDate = prefs.getString(_keyLastDailySpinDate);

    int currentStreak = prefs.getInt(_keyDailyStreak) ?? 1;
    if (lastDate != null) {
      try {
        final lastDt = DateTime.parse(lastDate);
        final todayDt = DateTime.parse(todayStr);
        final diffDays = todayDt.difference(lastDt).inDays;
        if (diffDays == 1) {
          // Consecutive streak (1 day difference)
          currentStreak = (currentStreak % 7) + 1;
        } else if (diffDays > 1) {
          // Streak broken (missed day)
          currentStreak = 1;
        }
      } catch (_) {
        currentStreak = 1;
      }
    }

    await prefs.setString(_keyLastDailySpinDate, todayStr);
    await prefs.setInt(_keyDailyStreak, currentStreak);

    // Add stars
    final currentStars = await getStars();
    final newStars = currentStars + rewardStars;
    await saveStars(newStars);

    // Unlock sticker if awarded and not yet owned
    final unlockedStickers = await getUnlockedStickers();
    if (rewardSticker != null && !unlockedStickers.contains(rewardSticker)) {
      unlockedStickers.add(rewardSticker);
      await saveUnlockedStickers(unlockedStickers);
    }

    return {
      'newStars': newStars,
      'streak': currentStreak,
      'unlockedStickers': unlockedStickers,
    };
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

  static Future<String> getPlaygroundTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPlaygroundTheme) ?? 'garden';
  }

  static Future<void> savePlaygroundTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPlaygroundTheme, theme);
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

  // --- RESET OPSI 1: ULANGI DARI TINGKAT 1 (TROFI & BINTANG AMAN) ---
  static Future<void> resetToLevelOneKeepTrophies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTracingIndex, 0);
    await prefs.setInt(_keyTrainIndex, 0);
    await prefs.setInt(_keyBalloonIndex, 0);
    await prefs.setInt(_keyQuizIndex, 0);

    for (final game in ['train', 'balloon', 'quiz', 'tracing']) {
      await prefs.setInt('taman_kata_${game}_current_level', 1);
      await prefs.setInt('taman_kata_${game}_l1_index', 0);
      await prefs.setInt('taman_kata_${game}_l2_index', 0);
      await prefs.setInt('taman_kata_${game}_l3_index', 0);
    }
  }

  // --- RESET OPSI 2: RESET TOTAL DATA BELAJAR ---
  static Future<void> resetAllDataFactory() async {
    final prefs = await SharedPreferences.getInstance();
    await resetAllLearningProgress();
    await prefs.setString(_keyTrophies, jsonEncode([]));
    await prefs.setInt(_keyStars, 20);
    await prefs.setString(_keyStickers, jsonEncode(['stk_apel']));
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
    await prefs.setString(_keyOpenedChests, jsonEncode([]));
    await prefs.setString(_keyLastVisitedIsland, 'tracing');

    for (final game in ['train', 'balloon', 'quiz', 'tracing']) {
      await prefs.setInt('taman_kata_${game}_current_level', 1);
      await prefs.setInt('taman_kata_${game}_unlocked_level', 1);
      await prefs.setInt('taman_kata_${game}_l1_index', 0);
      await prefs.setInt('taman_kata_${game}_l2_index', 0);
      await prefs.setInt('taman_kata_${game}_l3_index', 0);
    }
  }
}

