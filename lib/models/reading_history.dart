import 'package:hive/hive.dart';

part 'reading_history.g.dart';

@HiveType(typeId: 0)
class ReadingHistory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? thumbnailPath;

  @HiveField(2)
  final String extractedText;

  @HiveField(3)
  final DateTime tanggalScan;

  @HiveField(4)
  final List<String> kataBaruDitemukan;

  @HiveField(5)
  String? title;

  @HiveField(6, defaultValue: 0)
  int rotation;

  ReadingHistory({
    required this.id,
    this.thumbnailPath,
    required this.extractedText,
    required this.tanggalScan,
    required this.kataBaruDitemukan,
    this.title,
    this.rotation = 0,
  });
}
