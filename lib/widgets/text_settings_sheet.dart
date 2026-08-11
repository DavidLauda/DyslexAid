import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_provider.dart';

class TextSettingsSheet extends StatelessWidget {
  const TextSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Personalisasi Teks',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Font Family
            const Text('Jenis Huruf', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['OpenDyslexic', 'Lexend', 'Comic Sans MS', 'Arial'].map((font) {
                final isSelected = settings.fontFamily == font;
                return ChoiceChip(
                  label: Text(font, style: TextStyle(fontFamily: font)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) settings.updateFontFamily(font);
                  },
                  selectedColor: Colors.teal.shade100,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Font Size
            _buildSlider(
              label: 'Ukuran Teks',
              value: settings.fontSize,
              min: 14.0,
              max: 36.0,
              onChanged: settings.updateFontSize,
            ),

            // Line Spacing
            _buildSlider(
              label: 'Jarak Baris',
              value: settings.lineSpacing,
              min: 1.2,
              max: 3.5,
              onChanged: settings.updateLineSpacing,
            ),

            // Word Spacing
            _buildSlider(
              label: 'Jarak Antar Kata',
              value: settings.wordSpacing,
              min: 4.0,
              max: 20.0,
              onChanged: settings.updateWordSpacing,
            ),

            // Letter Spacing
            _buildSlider(
              label: 'Jarak Antar Huruf',
              value: settings.letterSpacing,
              min: 0.5,
              max: 5.0,
              onChanged: settings.updateLetterSpacing,
            ),

            const SizedBox(height: 16),
            const Text('Warna Tema', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildColorCircle(0, const Color(0xFFFDFBF7), settings), // Krim
                _buildColorCircle(1, const Color(0xFFE8F0FE), settings), // Biru
                _buildColorCircle(2, const Color(0xFFE6F4EA), settings), // Hijau
                _buildColorCircle(3, Colors.white, settings),            // Putih
                _buildColorCircle(4, const Color(0xFF2C2C2C), settings), // Gelap
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(value.toStringAsFixed(1), style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: Colors.teal,
            inactiveColor: Colors.teal.shade100,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildColorCircle(int index, Color color, SettingsProvider settings) {
    final isSelected = settings.themeColorIndex == index;
    return GestureDetector(
      onTap: () => settings.updateThemeColorIndex(index),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.teal.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              )
          ],
        ),
      ),
    );
  }
}
