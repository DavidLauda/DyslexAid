import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../services/vocab_service.dart';
import '../utils/syllable_util.dart';

class DetailKataOverlay extends StatefulWidget {
  final String kata;

  const DetailKataOverlay({super.key, required this.kata});

  /// Fungsi helper untuk memanggil overlay ini dari mana saja
  static void show(BuildContext context, String kata) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DetailKataOverlay(kata: kata),
      ),
    );
  }

  @override
  State<DetailKataOverlay> createState() => _DetailKataOverlayState();
}

class _DetailKataOverlayState extends State<DetailKataOverlay> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  late List<String> _syllables;
  double _speechRate = 0.5; // Normal speed

  @override
  void initState() {
    super.initState();
    _syllables = SyllableUtil.pemenggalSukuKata(widget.kata);
    _initTts();
  }

  void _initTts() {
    _flutterTts.setLanguage("id-ID");
    _flutterTts.setSpeechRate(_speechRate);
    
    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _speakWord() async {
    setState(() {
      _isPlaying = true;
    });
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.speak(widget.kata);
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  void _onSpeedChanged(double value) {
    setState(() {
      _speechRate = value;
    });
    if (_isPlaying) {
      _stopSpeaking().then((_) => _speakWord());
    }
  }

  @override
  Widget build(BuildContext context) {
    final vocabService = Provider.of<VocabService>(context, listen: false);
    final String? arti = vocabService.cariArti(widget.kata);

    // Warna selang-seling untuk suku kata
    final colors = [Colors.blue.shade800, Colors.green.shade800, Colors.orange.shade800, Colors.purple.shade800];
    String speedLabel = "${(_speechRate * 2).toStringAsFixed(1)}x";

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFDFBF7), // Warna krem lembut ramah disleksia
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle untuk gesture swipe down
          Container(
            width: 48,
            height: 6,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Kata dalam ukuran besar
                  Text(
                    widget.kata,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'OpenDyslexic', // Menggunakan OpenDyslexic untuk kejelasan
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Suku kata dengan warna berbeda
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    children: List.generate(_syllables.length, (index) {
                      return Text(
                        _syllables[index] + (index < _syllables.length - 1 ? " -" : ""),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lexend',
                          color: colors[index % colors.length],
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Arti Kata
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade100, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Arti Kata:",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          arti ?? "Arti kata tidak ditemukan di kamus.",
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Speed Slider
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.teal.shade100, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.speed, color: Colors.teal, size: 20),
                        const SizedBox(width: 8),
                        Text(speedLabel, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                        Expanded(
                          child: Slider(
                            value: _speechRate,
                            min: 0.25, // 0.5x
                            max: 0.75, // 1.5x
                            divisions: 4,
                            activeColor: Colors.teal,
                            inactiveColor: Colors.teal.shade100,
                            onChanged: _onSpeedChanged,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // Kontrol TTS untuk kata
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 32,
                        color: Colors.grey,
                        icon: const Icon(Icons.fast_rewind_rounded),
                        onPressed: () {
                          // Rewind: restart pengucapan kata dari awal
                          _stopSpeaking().then((_) => _speakWord());
                        },
                      ),
                      const SizedBox(width: 16),
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.teal,
                        child: IconButton(
                          iconSize: 40,
                          color: Colors.white,
                          icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                          onPressed: () {
                            if (_isPlaying) {
                              _stopSpeaking();
                            } else {
                              _speakWord();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        iconSize: 32,
                        color: Colors.grey,
                        icon: const Icon(Icons.fast_forward_rounded),
                        onPressed: () {
                          // Forward: skip (hentikan) pengucapan kata tunggal
                          _stopSpeaking();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Dengarkan pengucapan kata ini",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Instruksi Keluar
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Geser ke bawah atau sentuh di sini untuk menutup",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
