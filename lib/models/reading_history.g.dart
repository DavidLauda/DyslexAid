// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReadingHistoryAdapter extends TypeAdapter<ReadingHistory> {
  @override
  final int typeId = 0;

  @override
  ReadingHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingHistory(
      id: fields[0] as String,
      thumbnailPath: fields[1] as String?,
      extractedText: fields[2] as String,
      tanggalScan: fields[3] as DateTime,
      kataBaruDitemukan: (fields[4] as List).cast<String>(),
      title: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingHistory obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.thumbnailPath)
      ..writeByte(2)
      ..write(obj.extractedText)
      ..writeByte(3)
      ..write(obj.tanggalScan)
      ..writeByte(4)
      ..write(obj.kataBaruDitemukan)
      ..writeByte(5)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
