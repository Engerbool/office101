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
    );
  }

  @override
  void write(BinaryWriter writer, WorkplaceTip obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.tipId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.keyPoints)
      ..writeByte(4)
      ..write(obj.category);
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
        return TipCategory.basic_attitude;
      case 1:
        return TipCategory.reporting;
      case 2:
        return TipCategory.todo_management;
      case 3:
        return TipCategory.communication;
      case 4:
        return TipCategory.self_growth;
      case 5:
        return TipCategory.general;
      default:
        return TipCategory.basic_attitude;
    }
  }

  @override
  void write(BinaryWriter writer, TipCategory obj) {
    switch (obj) {
      case TipCategory.basic_attitude:
        writer.writeByte(0);
        break;
      case TipCategory.reporting:
        writer.writeByte(1);
        break;
      case TipCategory.todo_management:
        writer.writeByte(2);
        break;
      case TipCategory.communication:
        writer.writeByte(3);
        break;
      case TipCategory.self_growth:
        writer.writeByte(4);
        break;
      case TipCategory.general:
        writer.writeByte(5);
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
