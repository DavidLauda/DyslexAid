import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ocr_service.dart';
import 'scan_buku_screen.dart';
import 'conversion_result_screen.dart';
import '../widgets/text_settings_sheet.dart';
import '../widgets/glass_ui.dart';

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
              builder: (context) => ConversionResultScreen(
                imagePath: pickedFile.path,
                recognizedText: text,
              ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Beranda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: const TextSettingsSheet(),
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 40, offset: const Offset(0, 10)),
                ],
              ),
              child: Icon(Icons.import_contacts_rounded, size: 80, color: colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Ayo Mulai Membaca!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih sumber buku atau teks untuk dibaca hari ini',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(height: 48),
            GlassCard(
              isPrimary: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanBukuScreen()),
                );
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.document_scanner_rounded, size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Text(
                      'Scan Buku',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white70),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GlassCard(
              onTap: () => _pickImageAndExtractText(context),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.photo_library_rounded, size: 32, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      'Upload Dokumen',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: isDark ? Colors.white54 : Colors.black26),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
