import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/vocab_stats_service.dart';
import 'flashcard_screen.dart';
import '../widgets/glass_ui.dart';

class LatihanScreen extends StatelessWidget {
  const LatihanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<List<String>>('global_box').listenable(keys: ['learned_words']),
      builder: (context, Box<List<String>> box, _) {
        final words = box.get('learned_words', defaultValue: <String>[]) ?? <String>[];
        if (words.isEmpty) {
          return GlassBackground(
            appBar: AppBar(title: const Text('Mode Latihan'), backgroundColor: Colors.transparent),
            child: const Center(
              child: Text('Kamus masih kosong. Mulai scan buku untuk menemukan kata baru!'),
            ),
          );
        }
        
        // We use a UniqueKey so that if words change drastically, it remounts,
        // but normally we just keep the same key. We can just pass the words.
        // Actually, we don't need a key here, FlashcardScreen manages its own state.
        final prioritized = VocabStatsService.getPrioritizedWords(words, limit: 20);
        return FlashcardScreen(prioritizedWords: prioritized);
      },
    );
  }
}
