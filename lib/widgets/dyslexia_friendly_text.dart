import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/syllable_util.dart';
import '../services/settings_provider.dart';

class DyslexiaFriendlyText extends StatelessWidget {
  final String text;
  final int? highlightedWordIndex;
  final ValueChanged<int>? onWordTapped;

  const DyslexiaFriendlyText({
    super.key,
    required this.text,
    this.highlightedWordIndex,
    this.onWordTapped,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    // Split by whitespace to get words
    final RegExp wordSplitter = RegExp(r'\s+');
    final List<String> words =
        text.split(wordSplitter).where((w) => w.isNotEmpty).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: settings.getThemeColor(), 
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: settings.wordSpacing,
        runSpacing: settings.fontSize * settings.lineSpacing * 0.5, 
        children: List.generate(words.length, (index) {
          final word = words[index];
          final syllables = SyllableUtil.pemenggalSukuKata(word);

          List<TextSpan> spans = [];
          int currentIndex = 0;

          // Colors for alternating syllables
          final colors = [
            Colors.blue[800]!,
            Colors.green[800]!,
          ];

          for (int i = 0; i < syllables.length; i++) {
            final syl = syllables[i];
            final sylLength = syl.length;

            // Substring from original word to preserve case and punctuation
            String originalSyl = word;
            if (currentIndex + sylLength <= word.length) {
              originalSyl =
                  word.substring(currentIndex, currentIndex + sylLength);
            } else if (currentIndex < word.length) {
              originalSyl = word.substring(currentIndex);
            } else {
              originalSyl = ""; // Shouldn't happen if lengths match
            }

            spans.add(TextSpan(
              text: originalSyl,
              style: TextStyle(
                color: colors[i % colors.length],
              ),
            ));

            currentIndex += sylLength;
          }

          // If there's any remaining part of the word (fallback)
          if (currentIndex < word.length) {
            spans.add(TextSpan(
              text: word.substring(currentIndex),
              style: TextStyle(color: colors[syllables.length % colors.length]),
            ));
          }

          final isHighlighted = highlightedWordIndex == index;

          return GestureDetector(
            onTap: () {
              if (onWordTapped != null) {
                onWordTapped!(index);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              decoration: isHighlighted
                  ? BoxDecoration(
                      color: settings.getHighlightColor(),
                      borderRadius: BorderRadius.circular(4),
                    )
                  : null,
              child: Text.rich(
                TextSpan(children: spans),
                style: TextStyle(
                  fontFamily: settings.fontFamily,
                  fontFamilyFallback: const ['Lexend'],
                  fontSize: settings.fontSize, 
                  height: settings.lineSpacing, 
                  letterSpacing: settings.letterSpacing, 
                  color: settings.getTextColor(),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
