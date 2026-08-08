import 'package:flutter/material.dart';

class KamusKataScreen extends StatelessWidget {
  const KamusKataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kamus Kata'),
      ),
      body: const Center(
        child: Text('Halaman Kamus Kata', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
