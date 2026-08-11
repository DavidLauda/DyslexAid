import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_provider.dart';

class TextSettingsSheet extends StatelessWidget {
  const TextSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Personalisasi Teks',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
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
                  selectedColor: Theme.of(context).colorScheme.primary.withOpacity(isDark ? 0.3 : 0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Font Size
            _buildSlider(
              context: context,
              label: 'Ukuran Teks',
              value: settings.fontSize,
              min: 14.0,
              max: 36.0,
              onChanged: settings.updateFontSize,
            ),

            // Line Spacing
            _buildSlider(
              context: context,
              label: 'Jarak Baris',
              value: settings.lineSpacing,
              min: 1.2,
              max: 3.5,
              onChanged: settings.updateLineSpacing,
            ),

            // Word Spacing
            _buildSlider(
              context: context,
              label: 'Jarak Antar Kata',
              value: settings.wordSpacing,
              min: 4.0,
              max: 20.0,
              onChanged: settings.updateWordSpacing,
            ),

            // Letter Spacing
            _buildSlider(
              context: context,
              label: 'Jarak Antar Huruf',
              value: settings.letterSpacing,
              min: 0.5,
              max: 5.0,
              onChanged: settings.updateLetterSpacing,
            ),

            const SizedBox(height: 16),
            const Text('Warna Latar Bacaan', style: TextStyle(fontWeight: FontWeight.w600)),
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
            
            const Divider(height: 48),
            const Text('Tema Aplikasi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mode Gelap', style: TextStyle(fontWeight: FontWeight.w600)),
                Switch(
                  value: settings.isAppDarkMode,
                  onChanged: (value) => settings.toggleAppDarkMode(value),
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Warna Utama', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAppThemeCircle(0, Colors.teal, settings),
                _buildAppThemeCircle(1, const Color(0xFF0277BD), settings), // Ocean Breeze
                _buildAppThemeCircle(2, const Color(0xFFFF7043), settings), // Sunset Coral
                _buildAppThemeCircle(3, const Color(0xFF7E57C2), settings), // Lavender Dream
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required BuildContext context,
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
            activeColor: Theme.of(context).colorScheme.primary,
            inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
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

  Widget _buildAppThemeCircle(int index, Color color, SettingsProvider settings) {
    final isSelected = settings.appThemeIndex == index;
    return GestureDetector(
      onTap: () => settings.updateAppThemeIndex(index),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)
          ],
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}
