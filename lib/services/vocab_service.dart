import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class VocabService {
  @visibleForTesting
  final Map<String, String> kbbi = {};
  
  bool _isLoaded = false;
  
  @visibleForTesting
  set isLoaded(bool value) => _isLoaded = value;

  /// Load dataset JSON. Disarankan dipanggil sekali saat app start.
  Future<void> loadDataset() async {
    if (_isLoaded) return;
    
    try {
      final String jsonString = await rootBundle.loadString('assets/kbbi_clean.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      for (var item in jsonList) {
        if (item is Map<String, dynamic>) {
          String kata = (item['kata'] as String).toLowerCase();
          String arti = item['arti'] as String;
          kbbi[kata] = arti;
        }
      }
      _isLoaded = true;
    } catch (e) {
      print('Gagal memuat dataset KBBI: $e');
    }
  }

  /// Cek apakah dataset sudah selesai diload
  bool get isLoaded => _isLoaded;

  /// Mencari arti dari sebuah kata
  String? cariArti(String kata) {
    return kbbi[kata.toLowerCase()];
  }

  /// Mengekstrak kata-kata baru dari teks hasil OCR
  /// - teks: Teks sumber
  /// - kataSudahDipelajari: Set kata yang sudah pernah dipelajari sebelumnya
  List<String> ekstrakKataBaru(String teks, Set<String> kataSudahDipelajari) {
    if (!_isLoaded) {
      print('Warning: VocabService belum diload!');
      return [];
    }

    // Ubah ke huruf kecil
    String lowerTeks = teks.toLowerCase();

    // Pecah berdasarkan semua karakter yang bukan huruf (tanda baca, angka, spasi, enter, dll)
    List<String> tokens = lowerTeks.split(RegExp(r'[^a-z]+'));

    // Hilangkan string kosong & hilangkan duplikat menggunakan Set
    Set<String> uniqueWords = tokens.where((w) => w.isNotEmpty).toSet();

    List<String> kataBaru = [];
    for (String word in uniqueWords) {
      // Kata harus ada di kamus KBBI DAN belum pernah dipelajari
      if (kbbi.containsKey(word) && !kataSudahDipelajari.contains(word)) {
        kataBaru.add(word);
      }
    }

    return kataBaru;
  }
}
