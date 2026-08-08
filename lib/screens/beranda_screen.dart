import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ocr_service.dart';
import 'scan_buku_screen.dart';
import 'ocr_result_screen.dart';

class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  Future<void> _pickImageAndExtractText(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (!context.mounted) return;
      
      // Tampilkan indikator loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final ocrService = OcrService();
      try {
        final text = await ocrService.extractText(pickedFile.path);
        
        if (context.mounted) {
          // Tutup dialog loading
          Navigator.pop(context);
          
          // Pindah ke layar hasil
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OcrResultScreen(extractedText: text),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Tutup dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan: ')),
          );
        }
      } finally {
        ocrService.dispose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.auto_stories, size: 100, color: Colors.teal),
            const SizedBox(height: 32),
            const Text(
              'Ayo Mulai Membaca!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt, size: 32),
              label: const Text('Scan Buku', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanBukuScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.image, size: 28),
              label: const Text('Upload Dokumen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: Colors.teal,
                side: const BorderSide(color: Colors.teal, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => _pickImageAndExtractText(context),
            ),
          ],
        ),
      ),
    );
  }
}
