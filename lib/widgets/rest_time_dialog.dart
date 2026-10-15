import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';
import 'vector_illustrations.dart';

class RestTimeDialog extends StatefulWidget {
  final VoidCallback onAdd15Minutes;
  final VoidCallback onDismissLimit;

  const RestTimeDialog({
    super.key,
    required this.onAdd15Minutes,
    required this.onDismissLimit,
  });

  @override
  State<RestTimeDialog> createState() => _RestTimeDialogState();
}

class _RestTimeDialogState extends State<RestTimeDialog> {
  bool _showParentUnlock = false;
  late int _a;
  late int _b;
  late int _answer;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateMath();
    HapticFeedback.mediumImpact();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioService().speak('Mata kita istirahat dulu yuk! Kita sudah belajar dengan sangat hebat hari ini!');
    });
  }

  void _generateMath() {
    _a = Random().nextInt(7) + 5;
    _b = Random().nextInt(6) + 4;
    _answer = _a + _b;
  }

  void _verifyMath(VoidCallback onSuccess) {
    final val = int.tryParse(_controller.text.trim());
    if (val == _answer) {
      onSuccess();
    } else {
      _controller.clear();
      _generateMath();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jawaban belum tepat. Silakan hitung kembali.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = min(500.0, screenSize.width * 0.92);
    final dialogMaxHeight = screenSize.height * 0.92;

    return PopScope(
      canPop: false, // Prevents child from dismissing accidentally
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: dialogWidth, maxHeight: dialogMaxHeight),
          child: Container(
            width: dialogWidth,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF0FDF4),
                  Color(0xFFDCFCE7),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFF86EFAC), width: 5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3516A34A),
                  blurRadius: 32,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              // Mascot & Calm Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('🌿', style: TextStyle(fontSize: 32)),
                  SizedBox(width: 8),
                  MascotWidget(size: 64),
                  SizedBox(width: 8),
                  Text('👀', style: TextStyle(fontSize: 32)),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                'Waktunya Istirahat Mata! 🌱',
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF15803D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Friendly explanation
              Text(
                'Kamu sudah belajar dan bermain dengan sangat hebat! Yuk lepaskan layar sejenak, lihat pemandangan luar jendela atau minum air agar mata tetap segar dan sehat.',
                style: GoogleFonts.fredoka(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),

              if (!_showParentUnlock) ...[
                // Parent Unlock Button
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showParentUnlock = true;
                    });
                  },
                  icon: const Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFF0F766E)),
                  label: Text(
                    'Zona Orang Tua (Buka Kunci)',
                    style: GoogleFonts.fredoka(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F766E),
                    ),
                  ),
                ),
              ] else ...[
                // Parent Math Challenge Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF6EE7B7), width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Konfirmasi Orang Tua: Berapa $_a + $_b = ?',
                        style: GoogleFonts.fredoka(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F766E),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            hintText: '?',
                            contentPadding: const EdgeInsets.symmetric(vertical: 6),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF6EE7B7)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _verifyMath(() {
                                  Navigator.of(context).pop();
                                  widget.onAdd15Minutes();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D9488),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text(
                                '+15 Menit',
                                style: GoogleFonts.fredoka(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _verifyMath(() {
                                  Navigator.of(context).pop();
                                  widget.onDismissLimit();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text(
                                'Matikan Batas',
                                style: GoogleFonts.fredoka(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _showParentUnlock = false;
                              });
                            },
                            icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  ),
);
}
}
