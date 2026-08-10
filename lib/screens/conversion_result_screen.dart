import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../widgets/dyslexia_friendly_text.dart';

class WordBoundary {
  final int index;
  final String word;
  final int startOffset;
  final int endOffset;

  WordBoundary(this.index, this.word, this.startOffset, this.endOffset);
}

class ConversionResultScreen extends StatefulWidget {
  final String? imagePath;
  final String recognizedText;

  const ConversionResultScreen({
    super.key,
    this.imagePath,
    required this.recognizedText,
  });

  @override
  State<ConversionResultScreen> createState() => _ConversionResultScreenState();
}

class _ConversionResultScreenState extends State<ConversionResultScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  
  List<WordBoundary> _boundaries = [];
  int? _highlightedWordIndex;
  bool _isPlaying = false;
  
  double _speechRate = 0.5; // 0.5 di flutter_tts biasanya sama dengan 1.0x normal
  int _currentBoundaryIndex = 0;
  int _offsetShift = 0;

  @override
  void initState() {
    super.initState();
    _parseWordBoundaries();
    _initTts();
  }

  void _parseWordBoundaries() {
    final RegExp wordSplitter = RegExp(r'\S+');
    final matches = wordSplitter.allMatches(widget.recognizedText);
    int idx = 0;
    _boundaries = matches.map((m) {
      return WordBoundary(idx++, m.group(0)!, m.start, m.end);
    }).toList();
  }

  void _initTts() {
    _flutterTts.setLanguage("id-ID");
    _flutterTts.setSpeechRate(_speechRate);
    
    _flutterTts.setProgressHandler((String text, int startOffset, int endOffset, String word) {
      if (!mounted) return;
      int absoluteStart = _offsetShift + startOffset;
      
      // Cari boundary yang cocok dengan absoluteStart
      for (int i = _currentBoundaryIndex; i < _boundaries.length; i++) {
        if (absoluteStart >= _boundaries[i].startOffset && absoluteStart <= _boundaries[i].endOffset) {
          if (_highlightedWordIndex != i) {
            setState(() {
              _highlightedWordIndex = i;
              _currentBoundaryIndex = i;
            });
          }
          break;
        }
      }
    });

    _flutterTts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _highlightedWordIndex = null;
        _currentBoundaryIndex = 0;
        _offsetShift = 0;
      });
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _playFromCurrent() async {
    if (_boundaries.isEmpty) return;
    if (_currentBoundaryIndex >= _boundaries.length) {
      _currentBoundaryIndex = 0;
    }
    
    _offsetShift = _boundaries[_currentBoundaryIndex].startOffset;
    String textToSpeak = widget.recognizedText.substring(_offsetShift);
    
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.speak(textToSpeak);
    
    if (mounted) {
      setState(() {
        _isPlaying = true;
        _highlightedWordIndex = _currentBoundaryIndex;
      });
    }
  }

  Future<void> _pause() async {
    await _flutterTts.stop();
    if (mounted) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _pause();
    } else {
      _playFromCurrent();
    }
  }

  Future<void> _nextWord() async {
    await _pause();
    if (_currentBoundaryIndex < _boundaries.length - 1) {
      _currentBoundaryIndex++;
      if (mounted) {
        setState(() {
          _highlightedWordIndex = _currentBoundaryIndex;
        });
      }
    }
  }

  Future<void> _prevWord() async {
    await _pause();
    if (_currentBoundaryIndex > 0) {
      _currentBoundaryIndex--;
      if (mounted) {
        setState(() {
          _highlightedWordIndex = _currentBoundaryIndex;
        });
      }
    }
  }

  void _onSpeedChanged(double value) {
    setState(() {
      _speechRate = value;
    });
    if (_isPlaying) {
      // Jika sedang bermain, hentikan dan mainkan ulang dari kata saat ini dengan speed baru
      _pause().then((_) {
        _playFromCurrent();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 0.5 == 1.0x. Jadi displayMultiplier = value * 2
    String speedLabel = "${(_speechRate * 2).toStringAsFixed(1)}x";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hasil Konversi',
          style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF4F4F9),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 180.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.imagePath != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(widget.imagePath!),
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                const Text(
                  'Teks Ramah Disleksia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lexend',
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                DyslexiaFriendlyText(
                  text: widget.recognizedText,
                  highlightedWordIndex: _highlightedWordIndex,
                ),
              ],
            ),
          ),
          
          // Floating TTS Control Panel
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
                border: Border.all(color: Colors.teal.shade100, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Speed Slider
                  Row(
                    children: [
                      const Icon(Icons.speed, color: Colors.teal, size: 20),
                      const SizedBox(width: 8),
                      Text(speedLabel, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                      Expanded(
                        child: Slider(
                          value: _speechRate,
                          min: 0.25, // 0.5x
                          max: 0.75, // 1.5x
                          divisions: 4, // 0.25, 0.375, 0.5, 0.625, 0.75
                          activeColor: Colors.teal,
                          inactiveColor: Colors.teal.shade100,
                          onChanged: _onSpeedChanged,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 1),
                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        iconSize: 32,
                        color: Colors.teal,
                        icon: const Icon(Icons.skip_previous_rounded),
                        onPressed: _prevWord,
                      ),
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.teal,
                        child: IconButton(
                          iconSize: 32,
                          color: Colors.white,
                          icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                          onPressed: _togglePlayPause,
                        ),
                      ),
                      IconButton(
                        iconSize: 32,
                        color: Colors.teal,
                        icon: const Icon(Icons.skip_next_rounded),
                        onPressed: _nextWord,
                      ),
                    ],
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
