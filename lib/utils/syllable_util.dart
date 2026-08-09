class SyllableUtil {
  static List<String> pemenggalSukuKata(String kata) {
    kata = kata.toLowerCase().trim();
    if (kata.isEmpty) return [];
    
    // Helper untuk menghitung jumlah vokal (untuk menebak jumlah suku kata dasar)
    int countVowels(String s) {
      int c = 0;
      String temp = s.replaceAll('ai', 'V').replaceAll('au', 'V').replaceAll('oi', 'V');
      for (int i = 0; i < temp.length; i++) {
        if ('aeiouV'.contains(temp[i])) c++;
      }
      return c;
    }

    List<String> result = [];
    String prefix = '';
    String suffix = '';

    // Tangani Akhiran (Suffix) dengan batasan stem minimal 2 suku kata
    List<String> suffixes = ['kan', 'lah', 'kah', 'pun', 'nya'];
    for (String s in suffixes) {
      if (kata.endsWith(s)) {
        String stem = kata.substring(0, kata.length - s.length);
        if (countVowels(stem) >= 2) {
          suffix = s;
          kata = stem;
          break; // hanya tangani 1 suffix
        }
      }
    }

    // Tangani Awalan (Prefix) dengan batasan stem minimal 2 suku kata (vokal)
    List<String> prefixes = ['meng', 'peng', 'meny', 'peny', 'mem', 'pem', 'men', 'pen', 'ber', 'ter', 'per'];
    for (String p in prefixes) {
      if (kata.startsWith(p)) {
        String stem = kata.substring(p.length);
        if (countVowels(stem) >= 2) {
          prefix = p;
          kata = stem;
          break; // hanya tangani 1 prefix
        }
      }
    }

    // Proses kata/stem utama dengan algoritma V/K
    List<String> tokens = [];
    int i = 0;
    while (i < kata.length) {
      if (i + 1 < kata.length) {
        String two = kata.substring(i, i + 2);
        // Tangani diftong dan digraf konsonan
        if (['ai', 'au', 'oi', 'ng', 'ny', 'sy', 'kh'].contains(two)) {
          tokens.add(two);
          i += 2;
          continue;
        }
      }
      tokens.add(kata[i]);
      i += 1;
    }

    bool isV(String t) => ['a', 'e', 'i', 'o', 'u', 'ai', 'au', 'oi'].contains(t);

    List<int> vIndices = [];
    for (int j = 0; j < tokens.length; j++) {
      if (isV(tokens[j])) vIndices.add(j);
    }

    List<String> vkSyllables = [];
    if (vIndices.isEmpty) {
      vkSyllables.add(tokens.join(''));
    } else {
      int start = 0;
      for (int v = 0; v < vIndices.length; v++) {
        int currentV = vIndices[v];
        int end;
        
        if (v == vIndices.length - 1) {
          // Suku kata terakhir mengambil semua sisa konsonan di akhir
          end = tokens.length;
        } else {
          int nextV = vIndices[v + 1];
          int kCount = nextV - currentV - 1;
          
          if (kCount == 0) {
            end = currentV + 1; // V - V (contoh: ma-in)
          } else if (kCount == 1) {
            end = currentV + 1; // V - K V (contoh: ma-kan)
          } else {
            // Jika ada 2 atau lebih konsonan di tengah:
            // 1 konsonan pertama ikut ke suku kata sebelumnya, sisanya ke suku kata berikutnya.
            // Contoh: V K - K V (man-di), V K - K K V (in-struk-si)
            end = currentV + 2; 
          }
        }
        
        vkSyllables.add(tokens.sublist(start, end).join(''));
        start = end;
      }
    }

    if (prefix.isNotEmpty) result.add(prefix);
    result.addAll(vkSyllables);
    if (suffix.isNotEmpty) result.add(suffix);

    return result;
  }
}
