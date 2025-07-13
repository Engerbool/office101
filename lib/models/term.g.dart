// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'term.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TermAdapter extends TypeAdapter<Term> {
  @override
  final int typeId = 0;

  @override
  Term read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Term(
      termId: fields[0] as String,
      category: fields[1] as TermCategory,
      term: fields[2] as String,
      definition: fields[3] as String,
      example: fields[4] as String,
      tags: (fields[5] as List).cast<String>(),
      userAdded: fields[6] as bool,
      isBookmarked: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Term obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.termId)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.term)
      ..writeByte(3)
      ..write(obj.definition)
      ..writeByte(4)
      ..write(obj.example)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.userAdded)
      ..writeByte(7)
      ..write(obj.isBookmarked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TermAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TermCategoryAdapter extends TypeAdapter<TermCategory> {
  @override
  final int typeId = 1;

  @override
  TermCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TermCategory.approval;
      case 1:
        return TermCategory.business;
      case 2:
        return TermCategory.marketing;
      case 3:
        return TermCategory.it;
      case 4:
        return TermCategory.hr;
      case 5:
        return TermCategory.communication;
      case 6:
        return TermCategory.time;
      case 7:
        return TermCategory.other;
      case 8:
        return TermCategory.bookmarked;
      default:
        return TermCategory.approval;
    }
  }

  @override
  void write(BinaryWriter writer, TermCategory obj) {
    switch (obj) {
      case TermCategory.approval:
        writer.writeByte(0);
        break;
      case TermCategory.business:
        writer.writeByte(1);
        break;
      case TermCategory.marketing:
        writer.writeByte(2);
        break;
      case TermCategory.it:
        writer.writeByte(3);
        break;
      case TermCategory.hr:
        writer.writeByte(4);
        break;
      case TermCategory.communication:
        writer.writeByte(5);
        break;
      case TermCategory.time:
        writer.writeByte(6);
        break;
      case TermCategory.other:
        writer.writeByte(7);
        break;
      case TermCategory.bookmarked:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TermCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
