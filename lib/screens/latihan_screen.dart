import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/vocab_stats_service.dart';
import 'flashcard_screen.dart';

class LatihanScreen extends StatelessWidget {
  const LatihanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode Latihan', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Lexend')),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF4F4F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sports_esports, size: 100, color: Colors.teal),
              const SizedBox(height: 24),
              const Text(
                'Latih Ingatan Kosakata',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Lexend'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Aplikasi akan secara cerdas memilih kata-kata yang paling sering kamu lihat untuk dilatih kembali menggunakan kartu flash.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    final words = Hive.box<List<String>>('global_box').get('learned_words', defaultValue: <String>[]) ?? <String>[];
                    if (words.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kamus masih kosong. Mulai scan buku untuk menemukan kata baru!'))
                      );
                      return;
                    }
                    final prioritized = VocabStatsService.getPrioritizedWords(words, limit: 20);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FlashcardScreen(prioritizedWords: prioritized)),
                    );
                  },
                  icon: const Icon(Icons.play_arrow, size: 28),
                  label: const Text('Mulai Latihan Sekarang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
