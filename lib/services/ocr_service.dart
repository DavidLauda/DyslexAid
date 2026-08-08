import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> extractText(
    String imagePath, {
    double? shortEdgePercent,
    double? longEdgePercent,
    int deviceOrientation = 0, // 0: Portrait, 1: Landscape Left, -1: Landscape Right
  }) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    
    if (shortEdgePercent == null || longEdgePercent == null) {
      return recognizedText.text;
    }

    final bytes = await File(imagePath).readAsBytes();
    final image = await decodeImageFromList(bytes);
    final double imgW = image.width.toDouble();
    final double imgH = image.height.toDouble();
    
    double cropW, cropH;
    if (imgW < imgH) {
      cropW = imgW * shortEdgePercent;
      cropH = imgH * longEdgePercent;
    } else {
      cropW = imgW * longEdgePercent;
      cropH = imgH * shortEdgePercent;
    }
    
    final absoluteScanArea = Rect.fromCenter(
      center: Offset(imgW / 2, imgH / 2),
      width: cropW,
      height: cropH,
    );

    List<TextLine> allLines = [];
    int sidewaysLines = 0;
    int uprightLines = 0;

    for (TextBlock block in recognizedText.blocks) {
      final intersect = absoluteScanArea.intersect(block.boundingBox);
      
      if (intersect.width > 0 && intersect.height > 0) {
        final intersectArea = intersect.width * intersect.height;
        final blockArea = block.boundingBox.width * block.boundingBox.height;
        
        if (intersectArea > blockArea * 0.5) {
          allLines.addAll(block.lines);
          
          for (TextLine line in block.lines) {
            if (line.boundingBox.height > line.boundingBox.width * 1.2) {
              sidewaysLines++;
            } else if (line.boundingBox.width > line.boundingBox.height * 1.2) {
              uprightLines++;
            }
          }
        }
      }
    }

    bool isSideways = sidewaysLines > uprightLines;
    double tolerance = 25.0;

    if (isSideways) {
      if (deviceOrientation == 1) { // Landscape Kiri (Teks dari Kanan ke Kiri gambar)
        allLines.sort((a, b) {
          if ((a.boundingBox.center.dx - b.boundingBox.center.dx).abs() < tolerance) {
            return a.boundingBox.center.dy.compareTo(b.boundingBox.center.dy);
          }
          return b.boundingBox.center.dx.compareTo(a.boundingBox.center.dx);
        });
      } else if (deviceOrientation == -1) { // Landscape Kanan (Teks dari Kiri ke Kanan gambar)
        allLines.sort((a, b) {
          if ((a.boundingBox.center.dx - b.boundingBox.center.dx).abs() < tolerance) {
            return b.boundingBox.center.dy.compareTo(a.boundingBox.center.dy);
          }
          return a.boundingBox.center.dx.compareTo(b.boundingBox.center.dx);
        });
      } else { // Fallback
        allLines.sort((a, b) {
          if ((a.boundingBox.center.dx - b.boundingBox.center.dx).abs() < tolerance) {
            return a.boundingBox.center.dy.compareTo(b.boundingBox.center.dy);
          }
          return b.boundingBox.center.dx.compareTo(a.boundingBox.center.dx);
        });
      }
    } else { // Portrait / Gambar Tegak
      allLines.sort((a, b) {
        if ((a.boundingBox.center.dy - b.boundingBox.center.dy).abs() < tolerance) {
          return a.boundingBox.center.dx.compareTo(b.boundingBox.center.dx);
        }
        return a.boundingBox.center.dy.compareTo(b.boundingBox.center.dy);
      });
    }

    List<String> filteredText = allLines.map((l) => l.text).toList();
    return filteredText.join('\n');
  }
  
  void dispose() {
    _textRecognizer.close();
  }
}
