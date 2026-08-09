import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vocab_service.dart';

class OcrResultScreen extends StatelessWidget {
  final String extractedText;

  const OcrResultScreen({super.key, required this.extractedText});

  @override
  Widget build(BuildContext context) {
    final vocabService = context.read<VocabService>();
    
    // 2. List semua kata unik hasil tokenisasi
    final tokens = extractedText.toLowerCase().split(RegExp(r'[^a-z]+')).where((w) => w.isNotEmpty).toSet().toList();
    
    // 3. List kata yang match dengan KBBI (kata baru yang terdeteksi)
    // Untuk debug, kita anggap kataSudahDipelajari kosong
    final matchedWords = vocabService.ekstrakKataBaru(extractedText, <String>{});

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Vocab Tracker'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('1. RAW OCR TEXT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
            const SizedBox(height: 8),
            Text(
              extractedText.isEmpty ? 'Tidak ada teks terdeteksi.' : extractedText,
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(height: 32, thickness: 2),

            const Text('2. UNIK TOKENS (RegExp)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
            const SizedBox(height: 8),
            Text(
              tokens.isEmpty ? 'Tidak ada token.' : tokens.join(', '),
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(height: 32, thickness: 2),

            const Text('3. MATCHED KBBI (Kata Baru)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
            const SizedBox(height: 8),
            Text(
              matchedWords.isEmpty ? 'Tidak ada kata yang cocok di KBBI.' : matchedWords.join(', '),
              style: const TextStyle(fontSize: 16, color: Colors.deepOrange, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
