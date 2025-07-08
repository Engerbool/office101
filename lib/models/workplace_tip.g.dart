// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workplace_tip.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkplaceTipAdapter extends TypeAdapter<WorkplaceTip> {
  @override
  final int typeId = 4;

  @override
  WorkplaceTip read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkplaceTip(
      tipId: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      keyPoints: (fields[3] as List).cast<String>(),
      category: fields[4] as TipCategory,
      priority: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WorkplaceTip obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.tipId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.keyPoints)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.priority);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkplaceTipAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TipCategoryAdapter extends TypeAdapter<TipCategory> {
  @override
  final int typeId = 5;

  @override
  TipCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TipCategory.schedule;
      case 1:
        return TipCategory.report;
      case 2:
        return TipCategory.meeting;
      case 3:
        return TipCategory.communication;
      case 4:
        return TipCategory.general;
      default:
        return TipCategory.schedule;
    }
  }

  @override
  void write(BinaryWriter writer, TipCategory obj) {
    switch (obj) {
      case TipCategory.schedule:
        writer.writeByte(0);
        break;
      case TipCategory.report:
        writer.writeByte(1);
        break;
      case TipCategory.meeting:
        writer.writeByte(2);
        break;
      case TipCategory.communication:
        writer.writeByte(3);
        break;
      case TipCategory.general:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
