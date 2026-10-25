import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../services/voice_recording_service.dart';
import 'child_avatar_widget.dart';
import 'vector_illustrations.dart';

enum RecordState { idle, recording, recorded, playing }

class VoiceRecordDialog extends StatefulWidget {
  final String recordingKey;
  final String wordOrLetter;
  final String displayLabel;
  final String category;
  final String? illustrationKey;
  final String? phoneticTip;
  final VoidCallback? onRecordingSaved;
  final Function(int starsBonus)? onBonusStars;

  const VoiceRecordDialog({
    super.key,
    required this.recordingKey,
    required this.wordOrLetter,
    required this.displayLabel,
    required this.category,
    this.illustrationKey,
    this.phoneticTip,
    this.onRecordingSaved,
    this.onBonusStars,
  });

  @override
  State<VoiceRecordDialog> createState() => _VoiceRecordDialogState();
}

class _VoiceRecordDialogState extends State<VoiceRecordDialog> with TickerProviderStateMixin {
  final VoiceRecordingService _recorder = VoiceRecordingService();
  final AudioService _audio = AudioService();

  RecordState _state = RecordState.idle;
  int _secondsRecorded = 0;
  Timer? _recordTimer;
  bool _hasExistingRecording = false;
  String _childName = 'Juara Cilik';
  String _childAvatar = 'miko';

  late AnimationController _pulseController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadInitialData();
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    _recorder.stopPlayback();
    super.dispose();
  }

  void _loadInitialData() async {
    final avatar = await StorageService.getChildAvatar();
    final name = await StorageService.getChildName();
    final exists = await _recorder.hasRecording(widget.recordingKey);

    if (mounted) {
      setState(() {
        _childAvatar = avatar;
        _childName = name;
        _hasExistingRecording = exists;
        if (exists) {
          _state = RecordState.recorded;
        }
      });
    }
  }

  void _startRecording() async {
    HapticFeedback.heavyImpact();
    _audio.playSfx('pop');

    final success = await _recorder.startRecording(widget.recordingKey);
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat memulai mikrofon.')),
        );
      }
      return;
    }

    setState(() {
      _state = RecordState.recording;
      _secondsRecorded = 0;
    });

    _pulseController.repeat(reverse: true);
    _waveController.repeat(reverse: true);

    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _secondsRecorded++;
      });
      // Auto-stop after 8 seconds (plenty for kids' word/letter repetition)
      if (_secondsRecorded >= 8) {
        _stopRecording();
      }
    });
  }

  void _stopRecording() async {
    _recordTimer?.cancel();
    _pulseController.stop();
    _waveController.stop();

    HapticFeedback.mediumImpact();
    await _recorder.stopRecording();

    setState(() {
      _state = RecordState.recorded;
      _hasExistingRecording = true;
    });

    _audio.playSfx('star');
    _audio.speak('Hore! Suaramu berhasil direkam! Ayo dengarkan suaramu!');
  }

  void _playChildVoice() async {
    HapticFeedback.selectionClick();
    setState(() {
      _state = RecordState.playing;
    });
    _pulseController.repeat(reverse: true);

    final success = await _recorder.playRecording(widget.recordingKey);
    if (!success) {
      // Fallback: speak child's word if native recording is not available
      await _audio.speak(widget.wordOrLetter);
    }

    // Auto reset state after duration
    final playDuration = math.max(2, _secondsRecorded);
    Future.delayed(Duration(seconds: playDuration), () {
      if (mounted) {
        _pulseController.stop();
        setState(() {
          _state = RecordState.recorded;
        });
      }
    });
  }

  void _playTeacherVoice() {
    HapticFeedback.selectionClick();
    _audio.playSfx('ding');
    _audio.speak(widget.wordOrLetter);
  }

  void _saveToGallery() async {
    HapticFeedback.heavyImpact();
    _audio.playSfx('fanfare');

    final item = VoiceRecordingItem(
      key: widget.recordingKey,
      wordOrLetter: widget.wordOrLetter,
      displayLabel: widget.displayLabel,
      category: widget.category,
      avatarId: _childAvatar,
      childName: _childName,
      recordedAt: DateTime.now(),
      durationSeconds: math.max(1, _secondsRecorded),
    );

    await StorageService.saveVoiceRecordingMeta(item.toJson());
    await StorageService.updateDailyMissionProgress('voice', 1);

    // Check trophies
    final all = await StorageService.getVoiceRecordingMetas();
    final trophies = await StorageService.getTrophies();

    if (!trophies.contains('voice_first_star')) {
      await StorageService.addTrophy('voice_first_star');
      widget.onBonusStars?.call(2);
    } else {
      widget.onBonusStars?.call(1);
    }

    if (all.length >= 5 && !trophies.contains('voice_master')) {
      await StorageService.addTrophy('voice_master');
      widget.onBonusStars?.call(3);
    }

    widget.onRecordingSaved?.call();

    if (mounted) {
      Navigator.of(context).pop();
      _audio.speak('Hebat sekali $_childName! Rekamanmu tersimpan di Galeri Suara!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = math.min(480.0, screenSize.width * 0.94);
    final dialogHeight = math.min(620.0, screenSize.height * 0.92);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: dialogHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFAF5FF),
                Color(0xFFF3E8FF),
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFA855F7), width: 3),
            boxShadow: const [
              BoxShadow(color: Color(0x357E22CE), blurRadius: 24, offset: Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Header with Avatar & Title
              _buildHeader(),

              // 2. Scrollable Body
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Column(
                    children: [
                      // Target Word / Letter Card
                      _buildTargetCard(),
                      const SizedBox(height: 18),

                      // Animated Microphone Control
                      _buildMicrophoneSection(),
                      const SizedBox(height: 16),

                      // Action Buttons (Suara Pemandu vs Suaraku vs Simpan)
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9333EA), Color(0xFF7E22CE)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        children: [
          ChildAvatarWidget(avatarId: _childAvatar, size: 36, showGlow: true),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎙️ Suaraku Ajaib',
                  style: GoogleFonts.fredoka(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Rekam suaramu menirukan kata ini!',
                  style: GoogleFonts.nunito(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF3E8FF),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9D5FF), width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x10000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Illustration or Big Badge
          if (widget.illustrationKey != null && widget.illustrationKey!.isNotEmpty) ...[
            ObjectIllustrationWidget(
              illustrationKey: widget.illustrationKey!,
              size: 64,
            ),
            const SizedBox(height: 8),
          ],

          // Big Word / Letter
          Text(
            widget.wordOrLetter,
            style: GoogleFonts.fredoka(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF581C87),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 2),

          // Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              widget.displayLabel,
              style: GoogleFonts.fredoka(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF7E22CE),
              ),
            ),
          ),

          if (widget.phoneticTip != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.phoneticTip!,
              style: GoogleFonts.fredoka(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B21A8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMicrophoneSection() {
    final isRec = _state == RecordState.recording;
    final isPlay = _state == RecordState.playing;

    return Column(
      children: [
        // Pulsing Circle & Big Button
        Stack(
          alignment: Alignment.center,
          children: [
            // Animated Pulse Wave Rings
            if (isRec || isPlay)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = 1.0 + (_pulseController.value * 0.35);
                  return Container(
                    width: 95 * scale,
                    height: 95 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRec
                          ? const Color(0xFFEF4444).withOpacity(0.3 - (_pulseController.value * 0.2))
                          : const Color(0xFF8B5CF6).withOpacity(0.3 - (_pulseController.value * 0.2)),
                    ),
                  );
                },
              ),

            // Big Round Mic Button
            GestureDetector(
              onTap: () {
                if (isRec) {
                  _stopRecording();
                } else {
                  _startRecording();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isRec
                        ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                        : [const Color(0xFFA855F7), const Color(0xFF7E22CE)],
                  ),
                  border: Border.all(
                    color: isRec ? const Color(0xFFFCA5A5) : const Color(0xFFE9D5FF),
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isRec ? const Color(0x60EF4444) : const Color(0x507E22CE),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    isRec ? '⏹️' : '🎙️',
                    style: const TextStyle(fontSize: 38),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Status Label & Live Timer
        if (isRec) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔴', style: TextStyle(fontSize: 10)),
                const SizedBox(width: 6),
                Text(
                  'Sedang Merekam... 00:0$_secondsRecorded',
                  style: GoogleFonts.fredoka(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ucapkan "$widget.wordOrLetter" dengan jelas dan lantang!',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6B21A8),
            ),
          ),
        ] else if (_state == RecordState.recorded) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('✅', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 6),
                Text(
                  'Suara Ananda Tersimpan!',
                  style: GoogleFonts.fredoka(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Text(
            'Sentuh tombol mikrofon untuk mulai merekam',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Two Comparison Buttons: Suara Pemandu & Putar Suaraku
        Row(
          children: [
            // 1. Suara Pemandu
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _playTeacherVoice,
                icon: const Text('🗣️', style: TextStyle(fontSize: 15)),
                label: Text(
                  'Pemandu',
                  style: GoogleFonts.fredoka(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 2. Putar Suaraku
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _hasExistingRecording ? _playChildVoice : null,
                icon: Text(_state == RecordState.playing ? '⏸️' : '▶️', style: const TextStyle(fontSize: 15)),
                label: Text(
                  _state == RecordState.playing ? 'Memutar...' : 'Suaraku',
                  style: GoogleFonts.fredoka(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  disabledForegroundColor: const Color(0xFF94A3B8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
              ),
            ),

            if (_hasExistingRecording) ...[
              const SizedBox(width: 8),
              // 3. Rekam Ulang
              GestureDetector(
                onTap: _startRecording,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFDE047), width: 1.5),
                  ),
                  child: const Text('🔄', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 12),

        // Simpan ke Galeri Suaraku Button (Only when recorded)
        if (_hasExistingRecording)
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _saveToGallery,
              icon: const Text('⭐', style: TextStyle(fontSize: 18)),
              label: Text(
                'Simpan ke Galeri Suaraku (+1 Bintang)',
                style: GoogleFonts.fredoka(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7E22CE),
                elevation: 4,
                shadowColor: const Color(0xFF581C87),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
