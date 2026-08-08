import 'package:flutter/material.dart';

class OcrResultScreen extends StatelessWidget {
  final String extractedText;

  const OcrResultScreen({super.key, required this.extractedText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Ekstraksi'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Text(
          extractedText.isEmpty ? 'Tidak ada teks terdeteksi.' : extractedText,
          style: const TextStyle(fontSize: 18, height: 1.5),
        ),
      ),
    );
  }
}
