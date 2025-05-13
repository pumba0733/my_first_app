// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LessonAdapter extends TypeAdapter<Lesson> {
  @override
  final int typeId = 0;

  @override
  Lesson read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lesson(
      date: fields[0] as DateTime,
      subject: fields[1] as String,
      keywords: (fields[2] as List).cast<String>(),
      memo: fields[3] as String,
      audioPaths: (fields[4] as List).cast<String>(),
      nextPlan: fields[5] as String,
      studentId: fields[6] as String,
      playbackSpeed: fields[7] as double,
      pitch: fields[8] as int,
      loopStart: fields[9] as Duration?,
      loopEnd: fields[10] as Duration?,
      bpmMarks: (fields[11] as List?)?.cast<Duration>(),
      comments: (fields[12] as List?)?.cast<SmartComment>(),
    );
  }

  @override
  void write(BinaryWriter writer, Lesson obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.subject)
      ..writeByte(2)
      ..write(obj.keywords)
      ..writeByte(3)
      ..write(obj.memo)
      ..writeByte(4)
      ..write(obj.audioPaths)
      ..writeByte(5)
      ..write(obj.nextPlan)
      ..writeByte(6)
      ..write(obj.studentId)
      ..writeByte(7)
      ..write(obj.playbackSpeed)
      ..writeByte(8)
      ..write(obj.pitch)
      ..writeByte(9)
      ..write(obj.loopStart)
      ..writeByte(10)
      ..write(obj.loopEnd)
      ..writeByte(11)
      ..write(obj.bpmMarks)
      ..writeByte(12)
      ..write(obj.comments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SmartCommentAdapter extends TypeAdapter<SmartComment> {
  @override
  final int typeId = 1;

  @override
  SmartComment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SmartComment(
      label: fields[0] as String,
      memo: fields[1] as String,
      position: fields[2] as Duration,
    );
  }

  @override
  void write(BinaryWriter writer, SmartComment obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.memo)
      ..writeByte(2)
      ..write(obj.position);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmartCommentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
