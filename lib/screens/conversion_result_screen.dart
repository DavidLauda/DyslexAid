import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import '../models/reading_history.dart';
import '../services/vocab_service.dart';
import '../widgets/dyslexia_friendly_text.dart';
import '../widgets/detail_kata_overlay.dart';

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
  final bool isFromHistory;
  final int initialRotation;

  const ConversionResultScreen({
    super.key,
    this.imagePath,
    required this.recognizedText,
    this.isFromHistory = false,
    this.initialRotation = 0,
  });

  @override
  State<ConversionResultScreen> createState() => _ConversionResultScreenState();
}

class _ConversionResultScreenState extends State<ConversionResultScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  
  List<WordBoundary> _boundaries = [];
  int? _highlightedWordIndex;
  final ValueNotifier<int?> _highlightNotifier = ValueNotifier<int?>(null);
  bool _isPlaying = false;
  
  double _speechRate = 0.5; // 0.5 di flutter_tts biasanya sama dengan 1.0x normal
  int _currentBoundaryIndex = 0;
  int _offsetShift = 0;
  
  List<String> _newWords = [];

  @override
  void initState() {
    super.initState();
    _parseWordBoundaries();
    _initTts();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vocabService = Provider.of<VocabService>(context, listen: false);
      final globalBox = Hive.box<List<String>>('global_box');
      
      // Ambil kata yang sudah pernah dipelajari sebelumnya
      List<String> existingWordsList = globalBox.get('learned_words', defaultValue: <String>[]) ?? [];
      Set<String> existingWordsSet = existingWordsList.toSet();

      setState(() {
        _newWords = vocabService.ekstrakKataBaru(widget.recognizedText, existingWordsSet);
      });
      
      // Simpan ke riwayat otomatis jika ini pemindaian baru
      if (!widget.isFromHistory) {
        // Tampilkan prompt judul buku terlebih dahulu sebelum menyimpan
        _promptForTitleAndSave(existingWordsSet);
      }
    });
  }

  void _promptForTitleAndSave(Set<String> existingWordsSet) {
    String defaultTitle = "Pemindaian ${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}";
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Wajib diisi agar tersimpan
      builder: (context) {
        return AlertDialog(
          title: const Text('Beri Judul Bacaan', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: defaultTitle,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Jika dilewati, gunakan default title
                _saveToHistory(defaultTitle, existingWordsSet);
                Navigator.pop(context);
              },
              child: const Text('Lewati', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              onPressed: () {
                String title = controller.text.trim();
                if (title.isEmpty) title = defaultTitle;
                _saveToHistory(title, existingWordsSet);
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _saveToHistory(String title, Set<String> existingWordsSet) {
    final globalBox = Hive.box<List<String>>('global_box');
    
    // Update global box (akumulasi kata lama + kata baru)
    if (_newWords.isNotEmpty) {
      existingWordsSet.addAll(_newWords);
      globalBox.put('learned_words', existingWordsSet.toList());
    }

    final box = Hive.box<ReadingHistory>('reading_history_box');
    final history = ReadingHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      thumbnailPath: widget.imagePath,
      extractedText: widget.recognizedText,
      tanggalScan: DateTime.now(),
      kataBaruDitemukan: _newWords,
      rotation: widget.initialRotation,
    );
    box.put(history.id, history);
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
            _highlightNotifier.value = i;
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
      _highlightNotifier.value = null;
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _highlightNotifier.dispose();
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
      _highlightNotifier.value = _currentBoundaryIndex;
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
        _highlightNotifier.value = _currentBoundaryIndex;
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
        _highlightNotifier.value = _currentBoundaryIndex;
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

  void _showNewWordsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Total ${_newWords.length} Kata yang bisa kamu pelajari dari gambar ini",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _newWords.map((word) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // Tutup bottom sheet daftar kata
                            Navigator.pop(context);
                            // Tampilkan overlay Detail Kata
                            DetailKataOverlay.show(context, word);
                          },
                          child: Ink(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                )
                              ],
                              border: Border.all(color: Colors.blue.shade200, width: 1.5),
                            ),
                            child: Text(
                              word,
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFullscreenPhoto() {
    if (widget.imagePath == null) return;
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Tutup Foto",
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        int quarterTurns = widget.initialRotation;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Stack(
                children: [
                  // Fullscreen Image, takes up all space
                  Positioned.fill(
                    child: InteractiveViewer(
                      child: Center(
                        child: RotatedBox(
                          quarterTurns: quarterTurns,
                          child: Image.file(
                            File(widget.imagePath!),
                            fit: BoxFit.contain, 
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Top buttons
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.rotate_right, color: Colors.white, size: 30),
                      onPressed: () {
                        setDialogState(() {
                          quarterTurns++;
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
        },
      );
    },
  );
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
      bottomNavigationBar: _newWords.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(top: BorderSide(color: Colors.blue.shade200, width: 1)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Ada ${_newWords.length} kata yang bisa dipelajari dari gambar ini",
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
                      ),
                    ),
                    TextButton(
                      onPressed: _showNewWordsBottomSheet,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Lihat kata ->", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    )
                  ],
                ),
              ),
            )
          : null,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 180.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.imagePath != null) ...[
                  GestureDetector(
                    onTap: _showFullscreenPhoto,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxHeight: 250),
                            color: Colors.grey.shade300,
                            child: RotatedBox(
                              quarterTurns: widget.initialRotation,
                              child: Image.file(
                                File(widget.imagePath!),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 250),
                            width: double.infinity,
                            color: Colors.black.withOpacity(0.2),
                          ),
                          const Icon(
                            Icons.zoom_out_map,
                            color: Colors.white,
                            size: 48,
                          ),
                        ],
                      ),
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
