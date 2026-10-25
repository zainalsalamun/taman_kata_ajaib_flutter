import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'storage_service.dart';

class VoiceRecordingItem {
  final String key;
  final String wordOrLetter;
  final String displayLabel;
  final String category; // 'huruf', 'suku_kata', 'kata'
  final String avatarId;
  final String childName;
  final DateTime recordedAt;
  final int durationSeconds;

  const VoiceRecordingItem({
    required this.key,
    required this.wordOrLetter,
    required this.displayLabel,
    required this.category,
    required this.avatarId,
    required this.childName,
    required this.recordedAt,
    required this.durationSeconds,
  });

  Map<String, dynamic> toJson() => {
        'key': key,
        'wordOrLetter': wordOrLetter,
        'displayLabel': displayLabel,
        'category': category,
        'avatarId': avatarId,
        'childName': childName,
        'recordedAt': recordedAt.toIso8601String(),
        'durationSeconds': durationSeconds,
      };

  factory VoiceRecordingItem.fromJson(Map<String, dynamic> map) => VoiceRecordingItem(
        key: map['key'] as String? ?? 'temp',
        wordOrLetter: map['wordOrLetter'] as String? ?? '',
        displayLabel: map['displayLabel'] as String? ?? '',
        category: map['category'] as String? ?? 'kata',
        avatarId: map['avatarId'] as String? ?? 'miko',
        childName: map['childName'] as String? ?? 'Juara Cilik',
        recordedAt: DateTime.tryParse(map['recordedAt'] as String? ?? '') ?? DateTime.now(),
        durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 3,
      );
}

class VoiceRecordingService {
  static final VoiceRecordingService _instance = VoiceRecordingService._internal();
  factory VoiceRecordingService() => _instance;
  VoiceRecordingService._internal();

  static const MethodChannel _channel = MethodChannel('com.tamankata.app/audio');

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _currentKey;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  String? get currentKey => _currentKey;

  Future<bool> startRecording(String key) async {
    _currentKey = key;
    _isRecording = true;
    if (kIsWeb) {
      return true;
    }
    try {
      final res = await _channel.invokeMethod<bool>('startRecording', {'key': key});
      return res ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<bool> stopRecording() async {
    _isRecording = false;
    if (kIsWeb) {
      return true;
    }
    try {
      final res = await _channel.invokeMethod<bool>('stopRecording');
      return res ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<bool> playRecording(String key) async {
    _currentKey = key;
    _isPlaying = true;
    if (kIsWeb) {
      return true;
    }
    try {
      final res = await _channel.invokeMethod<bool>('playRecording', {'key': key});
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> stopPlayback() async {
    _isPlaying = false;
    if (!kIsWeb) {
      try {
        await _channel.invokeMethod('stopPlayback');
      } catch (_) {}
    }
  }

  Future<bool> hasRecording(String key) async {
    if (kIsWeb) {
      final all = await StorageService.getVoiceRecordingMetas();
      return all.any((m) => m['key'] == key);
    }
    try {
      final res = await _channel.invokeMethod<bool>('hasRecording', {'key': key});
      if (res == true) return true;
      final all = await StorageService.getVoiceRecordingMetas();
      return all.any((m) => m['key'] == key);
    } catch (_) {
      final all = await StorageService.getVoiceRecordingMetas();
      return all.any((m) => m['key'] == key);
    }
  }

  Future<bool> deleteRecording(String key) async {
    await StorageService.deleteVoiceRecordingMeta(key);
    if (!kIsWeb) {
      try {
        await _channel.invokeMethod('deleteRecording', {'key': key});
      } catch (_) {}
    }
    return true;
  }
}
