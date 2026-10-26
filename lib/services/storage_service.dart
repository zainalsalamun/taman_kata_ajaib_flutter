import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_models.dart';
import '../models/daily_mission_models.dart';

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
  static const String _keyChildAvatar = 'taman_kata_child_avatar';
  static const String _keyVoiceGender = 'taman_kata_voice_gender';
  static const String _keySpeechSpeed = 'taman_kata_speech_speed';
  static const String _keyMapTimeMode = 'taman_kata_map_time_mode';
  static const String _keyLastDailySpinDate = 'taman_kata_last_daily_spin_date';
  static const String _keyDailyStreak = 'taman_kata_daily_streak';
  static const String _keyLearnedWords = 'taman_kata_learned_words';
  static const String _keyVoiceRecordings = 'taman_kata_voice_recordings';
  static const String _keyDailyMissions = 'taman_kata_daily_missions';
  static const String _keyDailyMissionsDate = 'taman_kata_daily_missions_date';
  static const String _keyAllMissionsBonusClaimed = 'taman_kata_daily_all_claimed';
  static const String _keySpeedRushHighScore = 'taman_kata_speed_rush_high_score';
  static const String _keySpeedRushBestCombo = 'taman_kata_speed_rush_best_combo';

  static Future<String> getChildAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyChildAvatar) ?? 'miko';
  }

  static Future<void> saveChildAvatar(String avatarId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyChildAvatar, avatarId);
  }

  static Future<String> getVoiceGender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyVoiceGender) ?? 'female';
  }

  static Future<void> saveVoiceGender(String gender) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyVoiceGender, gender == 'male' ? 'male' : 'female');
  }

  static Future<String> getSpeechSpeed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySpeechSpeed) ?? 'normal';
  }

  static Future<void> saveSpeechSpeed(String speed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySpeechSpeed, speed == 'slow' ? 'slow' : 'normal');
  }

  static Future<String> getMapTimeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyMapTimeMode) ?? 'auto';
  }

  static Future<void> saveMapTimeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMapTimeMode, mode);
  }

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

  // --- SUARAKU AJAIB / VOICE RECORDING METHODS ---
  static Future<List<Map<String, dynamic>>> getVoiceRecordingMetas() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyVoiceRecordings);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveVoiceRecordingMeta(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getVoiceRecordingMetas();
    final key = item['key'] as String;
    list.removeWhere((m) => m['key'] == key);
    list.insert(0, item);
    await prefs.setString(_keyVoiceRecordings, jsonEncode(list));
  }

  static Future<void> deleteVoiceRecordingMeta(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getVoiceRecordingMetas();
    list.removeWhere((m) => m['key'] == key);
    await prefs.setString(_keyVoiceRecordings, jsonEncode(list));
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

  static Future<void> unlockTrophy(String trophyId) => addTrophy(trophyId);

  // --- TANTANGAN KILAT KATA 60 DETIK (SPEED RUSH) ---
  static Future<int> getSpeedRushHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySpeedRushHighScore) ?? 0;
  }

  static Future<bool> saveSpeedRushHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keySpeedRushHighScore) ?? 0;
    if (score > current) {
      await prefs.setInt(_keySpeedRushHighScore, score);
      return true; // new high score
    }
    return false;
  }

  static Future<int> getSpeedRushBestCombo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySpeedRushBestCombo) ?? 0;
  }

  static Future<void> saveSpeedRushBestCombo(int combo) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keySpeedRushBestCombo) ?? 0;
    if (combo > current) {
      await prefs.setInt(_keySpeedRushBestCombo, combo);
    }
  }

  // --- KAMUS BERGAMBAR & SUARA MIKO ---
  static Future<List<String>> getLearnedWords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyLearnedWords);
    if (jsonStr == null) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => e.toString().toLowerCase()).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> markWordLearned(String word) async {
    final words = await getLearnedWords();
    final normalized = word.trim().toLowerCase();
    if (!words.contains(normalized)) {
      words.add(normalized);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLearnedWords, jsonEncode(words));
      return true; // newly learned
    }
    return false; // already learned
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
    await prefs.setString(_keyLearnedWords, jsonEncode([]));
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
    await prefs.setString(_keyLearnedWords, jsonEncode([]));

    for (final game in ['train', 'balloon', 'quiz', 'tracing']) {
      await prefs.setInt('taman_kata_${game}_current_level', 1);
      await prefs.setInt('taman_kata_${game}_unlocked_level', 1);
      await prefs.setInt('taman_kata_${game}_l1_index', 0);
      await prefs.setInt('taman_kata_${game}_l2_index', 0);
      await prefs.setInt('taman_kata_${game}_l3_index', 0);
    }
  }

  // --- MISI HARIAN & RUNTUTAN BELAJAR (DAILY MISSIONS & 7-DAY STREAK) ---
  static DateTime _parseDateOnly(String str) {
    final parts = str.split('-');
    if (parts.length >= 3) {
      return DateTime(
        int.tryParse(parts[0]) ?? 2026,
        int.tryParse(parts[1]) ?? 1,
        int.tryParse(parts[2]) ?? 1,
      );
    }
    return DateTime.now();
  }

  static Future<DailyMissionsState> getDailyMissionsState() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _getTodayDateString();
    final storedDate = prefs.getString(_keyDailyMissionsDate);
    final rawJson = prefs.getString(_keyDailyMissions);
    final allClaimedDate = prefs.getString(_keyAllMissionsBonusClaimed);
    int currentStreak = prefs.getInt(_keyDailyStreak) ?? 1;

    if (storedDate == todayStr && rawJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(rawJson);
        final missions = decoded
            .map((m) => DailyMissionItem.fromJson(m as Map<String, dynamic>))
            .toList();
        return DailyMissionsState(
          date: todayStr,
          missions: missions,
          allClaimed: allClaimedDate == todayStr,
          streakDays: currentStreak.clamp(1, 7),
        );
      } catch (_) {}
    }

    // New day or first time initialization:
    if (storedDate != null) {
      try {
        final lastDt = _parseDateOnly(storedDate);
        final todayDt = _parseDateOnly(todayStr);
        final diffDays = todayDt.difference(lastDt).inDays;
        if (diffDays == 1) {
          currentStreak = (currentStreak % 7) + 1;
        } else if (diffDays > 1) {
          currentStreak = 1;
        }
      } catch (_) {
        currentStreak = 1;
      }
    }

    await prefs.setInt(_keyDailyStreak, currentStreak);
    final newMissions = DailyMissionPool.generateMissionsForDate(DateTime.now());
    final encoded = jsonEncode(newMissions.map((m) => m.toJson()).toList());
    await prefs.setString(_keyDailyMissions, encoded);
    await prefs.setString(_keyDailyMissionsDate, todayStr);

    return DailyMissionsState(
      date: todayStr,
      missions: newMissions,
      allClaimed: false,
      streakDays: currentStreak.clamp(1, 7),
    );
  }

  static Future<bool> updateDailyMissionProgress(String actionType, [int amount = 1]) async {
    final prefs = await SharedPreferences.getInstance();
    final state = await getDailyMissionsState();
    bool anyChanged = false;
    bool justCompleted = false;

    for (final mission in state.missions) {
      if (mission.actionType == actionType && !mission.isCompleted) {
        mission.currentCount = (mission.currentCount + amount).clamp(0, mission.targetCount);
        anyChanged = true;
        if (mission.isCompleted) {
          justCompleted = true;
        }
      }
    }

    if (anyChanged) {
      final encoded = jsonEncode(state.missions.map((m) => m.toJson()).toList());
      await prefs.setString(_keyDailyMissions, encoded);
    }

    return justCompleted;
  }

  static Future<int> claimDailyMission(String missionId) async {
    final prefs = await SharedPreferences.getInstance();
    final state = await getDailyMissionsState();

    for (final mission in state.missions) {
      if (mission.id == missionId && mission.isCompleted && !mission.isClaimed) {
        mission.isClaimed = true;
        final encoded = jsonEncode(state.missions.map((m) => m.toJson()).toList());
        await prefs.setString(_keyDailyMissions, encoded);

        // Award stars
        final currentStars = await getStars();
        await saveStars(currentStars + mission.starReward);
        return mission.starReward;
      }
    }
    return 0;
  }

  static Future<int> claimAllDailyMissionsBonus() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _getTodayDateString();
    final allClaimedDate = prefs.getString(_keyAllMissionsBonusClaimed);
    if (allClaimedDate == todayStr) return 0;

    final state = await getDailyMissionsState();
    if (!state.allCompleted) return 0;

    await prefs.setString(_keyAllMissionsBonusClaimed, todayStr);

    int bonusStars = 5;
    final trophies = await getTrophies();

    if (!trophies.contains('daily_mission_master')) {
      await addTrophy('daily_mission_master');
    }

    if (state.streakDays >= 3 && !trophies.contains('streak_3_star')) {
      await addTrophy('streak_3_star');
    }

    if (state.streakDays >= 7) {
      bonusStars += 15; // +15 extra stars for golden chest day 7!
      if (!trophies.contains('streak_7_champion')) {
        await addTrophy('streak_7_champion');
      }
    }

    final currentStars = await getStars();
    await saveStars(currentStars + bonusStars);
    return bonusStars;
  }
}

