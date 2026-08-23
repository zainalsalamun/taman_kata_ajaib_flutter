import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyStars = 'taman_kata_stars';
  static const String _keyStickers = 'taman_kata_stickers';

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
}
