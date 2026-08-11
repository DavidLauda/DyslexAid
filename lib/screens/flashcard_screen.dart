import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../services/vocab_service.dart';
import '../services/vocab_stats_service.dart';

class FlashcardScreen extends StatefulWidget {
  final List<String> prioritizedWords;

  const FlashcardScreen({super.key, required this.prioritizedWords});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  late FlutterTts _flutterTts;
  String? _currentMeaning;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("id-ID");
    _loadMeaning();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  void _loadMeaning() {
    if (_currentIndex < widget.prioritizedWords.length) {
      final word = widget.prioritizedWords[_currentIndex];
      final vocabService = Provider.of<VocabService>(context, listen: false);
      setState(() {
        _currentMeaning = vocabService.cariArti(word);
        _isFlipped = false;
      });
      // Otomatis bacakan kata saat kartu muncul
      _speak(word);
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  void _nextCard(bool isEasy) {
    if (_currentIndex >= widget.prioritizedWords.length) return;
    
    String word = widget.prioritizedWords[_currentIndex];
    if (isEasy) {
      VocabStatsService.decrementScore(word);
    } else {
      VocabStatsService.incrementScore(word);
    }

    setState(() {
      _currentIndex++;
    });
    _loadMeaning();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.prioritizedWords.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Latihan Selesai')),
        backgroundColor: const Color(0xFFF4F4F9),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration, size: 100, color: Colors.orange),
              const SizedBox(height: 24),
              const Text('Hebat! Kamu sudah menyelesaikan sesi ini.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                ),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali ke Kamus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        ),
      );
    }

    String word = widget.prioritizedWords[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F9),
      appBar: AppBar(
        title: Text('Kartu ${_currentIndex + 1} dari ${widget.prioritizedWords.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Dismissible(
                    key: ValueKey('${word}_$_currentIndex'),
                    direction: _isFlipped ? DismissDirection.horizontal : DismissDirection.none,
                    onDismissed: (direction) {
                      if (direction == DismissDirection.startToEnd) {
                        // Swipe Right = Hafal
                        _nextCard(true);
                      } else {
                        // Swipe Left = Sulit
                        _nextCard(false);
                      }
                    },
                    background: Container(
                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(24)),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 24),
                      child: const Icon(Icons.check, color: Colors.white, size: 48),
                    ),
                    secondaryBackground: Container(
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(24)),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: const Icon(Icons.close, color: Colors.white, size: 48),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 400),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            Text(
                              word,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'OpenDyslexic',
                                fontFamilyFallback: ['Lexend'],
                              ),
                            ),
                            const SizedBox(height: 24),
                            IconButton(
                              iconSize: 56,
                              color: Colors.blue,
                              icon: const Icon(Icons.volume_up),
                              onPressed: () => _speak(word),
                            ),
                            const SizedBox(height: 32),
                            if (_isFlipped) ...[
                              const Divider(),
                              const SizedBox(height: 16),
                              Text(
                                _currentMeaning ?? "Arti tidak ditemukan",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                            ] else ...[
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal.shade50,
                                  foregroundColor: Colors.teal,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.visibility),
                                label: const Text('Tampilkan Arti', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                onPressed: () => setState(() => _isFlipped = true),
                              ),
                            ]
                          ],
                        ),
                       ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Bottom Action Buttons
            if (_isFlipped)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.close),
                        label: const Text('Masih Sulit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        onPressed: () => _nextCard(false),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.check),
                        label: const Text('Sudah Hafal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        onPressed: () => _nextCard(true),
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 100), // Spacing for unflipped state
          ],
        ),
      ),
    );
  }
}
