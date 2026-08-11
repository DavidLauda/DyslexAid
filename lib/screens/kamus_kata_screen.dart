import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../services/vocab_service.dart';
import '../widgets/detail_kata_overlay.dart';
import '../widgets/text_settings_sheet.dart';
import 'scan_buku_screen.dart';

class KamusKataScreen extends StatefulWidget {
  const KamusKataScreen({super.key});

  @override
  State<KamusKataScreen> createState() => _KamusKataScreenState();
}

class _KamusKataScreenState extends State<KamusKataScreen> {
  String _sortOrder = 'Terbaru'; // Options: Terbaru, Terlama, A-Z, Z-A
  int _currentPage = 1;
  final int _itemsPerPage = 50;

  List<String> _getSortedAndPaginatedWords(List<String> rawWords) {
    List<String> words = List.from(rawWords);
    
    // Sort
    switch (_sortOrder) {
      case 'A-Z':
        words.sort((a, b) => a.compareTo(b));
        break;
      case 'Z-A':
        words.sort((a, b) => b.compareTo(a));
        break;
      case 'Terlama':
        // Natural order is terlama to terbaru
        break;
      case 'Terbaru':
        words = words.reversed.toList();
        break;
    }
    
    // Paginate
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    if (startIndex >= words.length) {
      startIndex = 0; 
    }
    
    return words.skip(startIndex).take(_itemsPerPage).toList();
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const TextSettingsSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vocabService = Provider.of<VocabService>(context, listen: false);
    final int totalWords = vocabService.kbbi.isNotEmpty ? vocabService.kbbi.length : 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kamus Kata', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Lexend')),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsSheet,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF4F4F9),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<List<String>>('global_box').listenable(keys: ['learned_words']),
        builder: (context, Box<List<String>> box, _) {
          List<String> learnedWords = List<String>.from(box.get('learned_words') ?? []);
          int currentCount = learnedWords.length;
          
          if (learnedWords.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book_rounded, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 24),
                    const Text(
                      "Kamu belum pernah mempelajari satu kata pun di aplikasi ini",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Scan Buku Sekarang"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanBukuScreen()));
                      },
                    )
                  ],
                ),
              ),
            );
          }

          double progress = currentCount / totalWords;
          if (progress > 1.0) progress = 1.0;
          String percentage = (progress * 100).toStringAsFixed(3);
          
          int totalPages = (currentCount / _itemsPerPage).ceil();
          if (_currentPage > totalPages) _currentPage = totalPages > 0 ? totalPages : 1;

          List<String> displayedWords = _getSortedAndPaginatedWords(learnedWords);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Panel Progress
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Progres Belajarmu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal.shade900)),
                        Text("$percentage%", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal.shade700)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("$currentCount dari ${vocabService.kbbi.length} kata KBBI", style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              
              // Filter dan Sorting
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Daftar Kata:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    DropdownButton<String>(
                      value: _sortOrder,
                      isDense: true,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.sort),
                      style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                      items: <String>['Terbaru', 'Terlama', 'A-Z', 'Z-A'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _sortOrder = newValue;
                            _currentPage = 1; // Reset to page 1 on sort change
                          });
                        }
                      },
                    )
                  ],
                ),
              ),
              
              // Grid Kosakata
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: displayedWords.map((word) {
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              DetailKataOverlay.show(context, word);
                            },
                            child: Ink(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: Colors.blue.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 3))
                                ],
                                border: Border.all(color: Colors.blue.shade200, width: 1.5),
                              ),
                              child: Text(word, style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              
              // Pagination Controls
              if (totalPages > 1)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        iconSize: 24,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.chevron_left),
                        color: _currentPage > 1 ? Colors.teal : Colors.grey,
                        onPressed: _currentPage > 1 ? () {
                          setState(() {
                            _currentPage--;
                          });
                        } : null,
                      ),
                      Text("Hal $_currentPage / $totalPages", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      IconButton(
                        iconSize: 24,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.chevron_right),
                        color: _currentPage < totalPages ? Colors.teal : Colors.grey,
                        onPressed: _currentPage < totalPages ? () {
                          setState(() {
                            _currentPage++;
                          });
                        } : null,
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
