import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsProvider extends ChangeNotifier {
  late Box _box;

  String _fontFamily = 'OpenDyslexic';
  double _fontSize = 20.0;
  double _lineSpacing = 1.8;
  double _wordSpacing = 8.0;
  double _letterSpacing = 1.5;
  int _themeColorIndex = 0;

  SettingsProvider() {
    _init();
  }

  void _init() {
    _box = Hive.box('settings_box');
    _fontFamily = _box.get('fontFamily', defaultValue: 'OpenDyslexic');
    _fontSize = _box.get('fontSize', defaultValue: 20.0);
    _lineSpacing = _box.get('lineSpacing', defaultValue: 1.8);
    _wordSpacing = _box.get('wordSpacing', defaultValue: 8.0);
    _letterSpacing = _box.get('letterSpacing', defaultValue: 1.5);
    _themeColorIndex = _box.get('themeColorIndex', defaultValue: 0);
    notifyListeners();
  }

  String get fontFamily => _fontFamily;
  double get fontSize => _fontSize;
  double get lineSpacing => _lineSpacing;
  double get wordSpacing => _wordSpacing;
  double get letterSpacing => _letterSpacing;
  int get themeColorIndex => _themeColorIndex;

  Color getThemeColor() {
    switch (_themeColorIndex) {
      case 0: return const Color(0xFFFDFBF7); // Krim
      case 1: return const Color(0xFFE8F0FE); // Biru
      case 2: return const Color(0xFFE6F4EA); // Hijau
      case 3: return Colors.white;            // Putih
      case 4: return const Color(0xFF2C2C2C); // Gelap
      default: return const Color(0xFFFDFBF7);
    }
  }

  Color getTextColor() {
     // Jika tema gelap, gunakan teks terang
     if (_themeColorIndex == 4) return Colors.grey.shade100;
     return Colors.black87;
  }
  
  Color getHighlightColor() {
    if (_themeColorIndex == 4) return Colors.teal.shade800; // Highlight untuk tema gelap
    return Colors.yellow.withOpacity(0.5);
  }

  void updateFontFamily(String value) {
    _fontFamily = value;
    _box.put('fontFamily', value);
    notifyListeners();
  }

  void updateFontSize(double value) {
    _fontSize = value;
    _box.put('fontSize', value);
    notifyListeners();
  }

  void updateLineSpacing(double value) {
    _lineSpacing = value;
    _box.put('lineSpacing', value);
    notifyListeners();
  }

  void updateWordSpacing(double value) {
    _wordSpacing = value;
    _box.put('wordSpacing', value);
    notifyListeners();
  }

  void updateLetterSpacing(double value) {
    _letterSpacing = value;
    _box.put('letterSpacing', value);
    notifyListeners();
  }

  void updateThemeColorIndex(int value) {
    _themeColorIndex = value;
    _box.put('themeColorIndex', value);
    notifyListeners();
  }
}
