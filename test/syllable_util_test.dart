import 'package:flutter_test/flutter_test.dart';
import 'package:dyslexaid/utils/syllable_util.dart';

void main() {
  group('SyllableUtil.pemenggalSukuKata', () {
    test('1. Kata 2 suku kata sederhana (V-KV, KV-KV)', () {
      expect(SyllableUtil.pemenggalSukuKata('buku'), ['bu', 'ku']);
      expect(SyllableUtil.pemenggalSukuKata('itu'), ['i', 'tu']);
      expect(SyllableUtil.pemenggalSukuKata('makan'), ['ma', 'kan']); // bukan mak-an
    });

    test('2. Kata dengan diftong (ai, au, oi)', () {
      expect(SyllableUtil.pemenggalSukuKata('pantai'), ['pan', 'tai']);
      expect(SyllableUtil.pemenggalSukuKata('harimau'), ['ha', 'ri', 'mau']);
      expect(SyllableUtil.pemenggalSukuKata('amboi'), ['am', 'boi']);
      expect(SyllableUtil.pemenggalSukuKata('sungai'), ['su', 'ngai']); // ng + ai
    });

    test('3. Kata dengan gugus konsonan / 3+ konsonan', () {
      // Gugus konsonan di awal suku kata atau di tengah
      expect(SyllableUtil.pemenggalSukuKata('kompleks'), ['kom', 'pleks']);
      expect(SyllableUtil.pemenggalSukuKata('instruksi'), ['in', 'struk', 'si']);
      expect(SyllableUtil.pemenggalSukuKata('abstrak'), ['ab', 'strak']);
      expect(SyllableUtil.pemenggalSukuKata('bentrok'), ['ben', 'trok']);
    });

    test('4. Kata dengan digraf konsonan (ng, ny, sy, kh)', () {
      expect(SyllableUtil.pemenggalSukuKata('banyak'), ['ba', 'nyak']);
      expect(SyllableUtil.pemenggalSukuKata('syarat'), ['sya', 'rat']);
      expect(SyllableUtil.pemenggalSukuKata('akhir'), ['a', 'khir']);
      expect(SyllableUtil.pemenggalSukuKata('bangkrut'), ['bang', 'krut']);
    });

    test('5. Kata panjang (5+ suku kata)', () {
      expect(SyllableUtil.pemenggalSukuKata('perpustakaan'), ['per', 'pus', 'ta', 'ka', 'an']);
    });

    test('6. Kata dengan awalan/akhiran yang aman dipenggal', () {
      expect(SyllableUtil.pemenggalSukuKata('mengambil'), ['meng', 'am', 'bil']);
      expect(SyllableUtil.pemenggalSukuKata('berubah'), ['ber', 'u', 'bah']);
      expect(SyllableUtil.pemenggalSukuKata('melakukan'), ['me', 'la', 'ku', 'kan']); // me bukan prefix di list kita, tapi V-KV bekerja!
      expect(SyllableUtil.pemenggalSukuKata('berikan'), ['be', 'ri', 'kan']); 
    });

    test('7. Kata dengan awalan/akhiran yang HANYA 1 vokal pada stem (Jangan dipotong paksa)', () {
      // 'beras' -> stem 'as' (1 vokal) -> tidak potong prefix 'ber' -> be-ras
      expect(SyllableUtil.pemenggalSukuKata('beras'), ['be', 'ras']);
      // 'makan' -> stem 'ma' (1 vokal) -> tidak potong suffix 'kan' -> ma-kan
      expect(SyllableUtil.pemenggalSukuKata('makan'), ['ma', 'kan']);
      // 'peran' -> stem 'an' (1 vokal) -> tidak potong prefix 'per' -> pe-ran
      expect(SyllableUtil.pemenggalSukuKata('peran'), ['pe', 'ran']);
    });

    test('8. Pertemuan dua vokal (V-V)', () {
      expect(SyllableUtil.pemenggalSukuKata('kue'), ['ku', 'e']);
      expect(SyllableUtil.pemenggalSukuKata('saat'), ['sa', 'at']);
      expect(SyllableUtil.pemenggalSukuKata('biologi'), ['bi', 'o', 'lo', 'gi']);
    });
  });
}
