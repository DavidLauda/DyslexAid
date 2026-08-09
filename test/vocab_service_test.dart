import 'package:flutter_test/flutter_test.dart';
import 'package:dyslexaid/services/vocab_service.dart';

void main() {
  group('VocabService', () {
    late VocabService service;

    setUp(() {
      service = VocabService();
      
      // Inject mock data for testing
      service.kbbi['halo'] = 'Kata sapaan';
      service.kbbi['teks'] = 'Wacana tertulis';
      service.kbbi['baru'] = 'Belum pernah ada';
      service.kbbi['baca'] = 'Melihat dan memahami isi tulisan';
      
      service.isLoaded = true;
    });

    test('cariArti mengembalikan arti yang benar', () {
      expect(service.cariArti('halo'), 'Kata sapaan');
      expect(service.cariArti('HALO'), 'Kata sapaan'); // Case-insensitive lookup
      expect(service.cariArti('tidakada'), isNull);
    });

    test('ekstrakKataBaru memisahkan tanda baca dan membuang duplikat', () {
      // Teks mengandung tanda baca, huruf besar/kecil, dan kata berulang
      String teks = "Halo, ini teks baru! Halo, teks ini sangat BARU...";
      Set<String> sudahDipelajari = {'ini', 'sangat'}; // 'ini' dan 'sangat' tidak ada di mock KBBI, tapi disimulasikan sebagai parameter saja
      
      List<String> kataBaru = service.ekstrakKataBaru(teks, sudahDipelajari);

      // Yang diharapkan:
      // Token unik (setelah tanda baca hilang & lowercase): 'halo', 'ini', 'teks', 'baru', 'sangat'
      // Yang ada di KBBI: 'halo', 'teks', 'baru'
      // Yang tidak ada di sudahDipelajari: 'halo', 'teks', 'baru'
      
      // Pastikan output tidak menduplikasi 'halo', 'teks', 'baru'
      expect(kataBaru.length, 3);
      expect(kataBaru.contains('halo'), isTrue);
      expect(kataBaru.contains('teks'), isTrue);
      expect(kataBaru.contains('baru'), isTrue);
    });

    test('ekstrakKataBaru mengabaikan kata yang sudah dipelajari', () {
      String teks = "Halo teks baru";
      
      // 'teks' sudah dipelajari
      Set<String> sudahDipelajari = {'teks'}; 
      
      List<String> kataBaru = service.ekstrakKataBaru(teks, sudahDipelajari);
      
      expect(kataBaru.length, 2);
      expect(kataBaru.contains('halo'), isTrue);
      expect(kataBaru.contains('baru'), isTrue);
      expect(kataBaru.contains('teks'), isFalse);
    });
  });
}
