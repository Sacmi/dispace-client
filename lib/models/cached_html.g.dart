// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_html.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedHtmlAdapter extends TypeAdapter<CachedHtml> {
  @override
  final int typeId = 3;

  @override
  CachedHtml read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedHtml(
      fields[0] as String,
      fields[1] as DateTime,
      fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CachedHtml obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.expires)
      ..writeByte(2)
      ..write(obj.document);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedHtmlAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
