import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../services/vocab_service.dart';
import '../services/vocab_stats_service.dart';
import '../widgets/glass_ui.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (_currentIndex) / widget.prioritizedWords.length;

    if (_currentIndex >= widget.prioritizedWords.length) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F4F9),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 40, spreadRadius: 10),
                  ],
                ),
                child: Icon(Icons.emoji_events_rounded, size: 100, color: colorScheme.primary),
              ),
              const SizedBox(height: 32),
              Text(
                "Luar Biasa!",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Kamu telah menyelesaikan sesi latihan kosakata hari ini. Teruslah berlatih untuk memperbanyak perbendaharaan katamu!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black54, height: 1.5),
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: colorScheme.primary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                ),
                child: const Text("Ulangi Latihan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      );
    }

    String word = widget.prioritizedWords[_currentIndex];

    return GlassBackground(
      appBar: AppBar(
        title: Text('Kartu ${_currentIndex + 1} dari ${widget.prioritizedWords.length}'),
        backgroundColor: Colors.transparent,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                borderRadius: BorderRadius.circular(6),
                backgroundColor: isDark ? Colors.grey.shade800 : Colors.white.withOpacity(0.5),
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Dismissible(
                    key: ValueKey('${word}_$_currentIndex'),
                    direction: _isFlipped ? DismissDirection.horizontal : DismissDirection.none,
                    onDismissed: (direction) {
                      if (direction == DismissDirection.startToEnd) {
                        _nextCard(true);
                      } else {
                        _nextCard(false);
                      }
                    },
                    background: Container(
                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(24)),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 24),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
                    ),
                    secondaryBackground: Container(
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(24)),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 48),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 400),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 40,
                            offset: const Offset(0, 15),
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
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                                fontFamily: 'OpenDyslexic',
                                fontFamilyFallback: ['Lexend'],
                              ),
                            ),
                            const SizedBox(height: 24),
                            IconButton(
                              iconSize: 56,
                              color: colorScheme.primary,
                              icon: const Icon(Icons.volume_up_rounded),
                              onPressed: () => _speak(word),
                            ),
                            const SizedBox(height: 32),
                            if (_isFlipped) ...[
                              const Divider(),
                              const SizedBox(height: 16),
                              Text(
                                _currentMeaning ?? "Arti tidak ditemukan",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                            ] else ...[
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                                  foregroundColor: colorScheme.primary,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.visibility_rounded),
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
                        icon: const Icon(Icons.close_rounded),
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
                        icon: const Icon(Icons.check_rounded),
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
