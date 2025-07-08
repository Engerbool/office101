// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_template.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmailTemplateAdapter extends TypeAdapter<EmailTemplate> {
  @override
  final int typeId = 2;

  @override
  EmailTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmailTemplate(
      templateId: fields[0] as String,
      title: fields[1] as String,
      situation: fields[2] as String,
      subject: fields[3] as String,
      body: fields[4] as String,
      tips: (fields[5] as List).cast<String>(),
      category: fields[6] as EmailCategory,
    );
  }

  @override
  void write(BinaryWriter writer, EmailTemplate obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.templateId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.situation)
      ..writeByte(3)
      ..write(obj.subject)
      ..writeByte(4)
      ..write(obj.body)
      ..writeByte(5)
      ..write(obj.tips)
      ..writeByte(6)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmailTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmailCategoryAdapter extends TypeAdapter<EmailCategory> {
  @override
  final int typeId = 3;

  @override
  EmailCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EmailCategory.request;
      case 1:
        return EmailCategory.report;
      case 2:
        return EmailCategory.meeting;
      case 3:
        return EmailCategory.apology;
      case 4:
        return EmailCategory.general;
      default:
        return EmailCategory.request;
    }
  }

  @override
  void write(BinaryWriter writer, EmailCategory obj) {
    switch (obj) {
      case EmailCategory.request:
        writer.writeByte(0);
        break;
      case EmailCategory.report:
        writer.writeByte(1);
        break;
      case EmailCategory.meeting:
        writer.writeByte(2);
        break;
      case EmailCategory.apology:
        writer.writeByte(3);
        break;
      case EmailCategory.general:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmailCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
