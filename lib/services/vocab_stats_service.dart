import 'package:hive_flutter/hive_flutter.dart';

class VocabStatsService {
  static const String _boxName = 'vocab_stats_box';

  static Box<int> get _box => Hive.box<int>(_boxName);

  /// Menambah skor (semakin tinggi skor, semakin butuh dilatih)
  static void incrementScore(String word) {
    int currentScore = _box.get(word, defaultValue: 0) ?? 0;
    _box.put(word, currentScore + 1);
  }

  /// Mengurangi skor (jika sudah hafal)
  static void decrementScore(String word) {
    int currentScore = _box.get(word, defaultValue: 0) ?? 0;
    // Jangan biarkan skor terlalu negatif, batas bawah misalnya -5
    int newScore = currentScore - 2;
    if (newScore < -5) newScore = -5;
    _box.put(word, newScore);
  }

  /// Mendapatkan skor kata tertentu
  static int getScore(String word) {
    return _box.get(word, defaultValue: 0) ?? 0;
  }

  /// Mengambil daftar kata dan mengurutkannya berdasarkan skor tertinggi
  static List<String> getPrioritizedWords(List<String> allWords, {int limit = 20}) {
    List<String> wordsCopy = List.from(allWords);
    
    // Sort descending (highest score first)
    wordsCopy.sort((a, b) {
      int scoreA = getScore(a);
      int scoreB = getScore(b);
      return scoreB.compareTo(scoreA); // B banding A agar descending
    });

    if (wordsCopy.length > limit) {
      return wordsCopy.sublist(0, limit);
    }
    return wordsCopy;
  }
}
