class SyllableUtil {
  static List<String> pemenggalSukuKata(String kata) {
    kata = kata.toLowerCase().trim();
    if (kata.isEmpty) return [];
    
    List<String> result = [];

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

    result.addAll(vkSyllables);
    return result;
  }
}
