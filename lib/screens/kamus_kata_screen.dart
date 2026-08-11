import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../services/vocab_service.dart';
import '../widgets/detail_kata_overlay.dart';
import '../widgets/text_settings_sheet.dart';
import 'scan_buku_screen.dart';
import '../widgets/glass_ui.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final vocabService = Provider.of<VocabService>(context, listen: false);
    final int totalWords = vocabService.kbbi.isNotEmpty ? vocabService.kbbi.length : 1;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Kamus Kata'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: _showSettingsSheet,
          ),
        ],
        backgroundColor: Colors.transparent,
      ),
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
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 30, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Icon(Icons.menu_book_rounded, size: 80, color: isDark ? Colors.grey.shade700 : Colors.grey.shade400),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Kamus Kata",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Pusat kosakata baru yang telah kamu pelajari",
                      style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.document_scanner_rounded),
                      label: const Text("Scan Buku Sekarang"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        backgroundColor: colorScheme.primary,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Progres Belajarmu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : colorScheme.primary)),
                          Text("$percentage%", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : colorScheme.primary.withOpacity(0.8))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          backgroundColor: isDark ? Colors.grey.shade800 : Colors.white.withOpacity(0.5),
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("$currentCount dari ${vocabService.kbbi.length} kata KBBI", style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                    ],
                  ),
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
                      icon: Icon(Icons.sort_rounded, color: colorScheme.primary),
                      style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
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
                          child: Ink(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade900.withOpacity(0.9) : Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.white, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                DetailKataOverlay.show(context, word);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: Text(word, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 15)),
                              ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.grey.shade900 : Colors.white).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            icon: const Icon(Icons.chevron_left_rounded),
                            color: _currentPage > 1 ? colorScheme.primary : Colors.grey,
                            onPressed: _currentPage > 1 ? () {
                              setState(() {
                                _currentPage--;
                              });
                            } : null,
                          ),
                          const SizedBox(width: 8),
                          Text("Hal $_currentPage / $totalPages", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colorScheme.primary)),
                          const SizedBox(width: 8),
                          IconButton(
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            icon: const Icon(Icons.chevron_right_rounded),
                            color: _currentPage < totalPages ? Theme.of(context).colorScheme.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.white30 : Colors.grey),
                            onPressed: _currentPage < totalPages ? () {
                              setState(() {
                                _currentPage++;
                              });
                            } : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
