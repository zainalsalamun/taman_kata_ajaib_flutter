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
}

