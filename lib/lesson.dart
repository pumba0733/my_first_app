import 'package:hive/hive.dart';
part 'lesson.g.dart'; // 이건 lesson.dart 안에 있어야 함

@HiveType(typeId: 0)
class Lesson extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  String subject;

  @HiveField(2)
  List<String> keywords;

  @HiveField(3)
  String memo;

  @HiveField(4)
  List<String> audioPaths;

  @HiveField(5)
  String nextPlan;

  @HiveField(6)
  String studentId;

  // 🎯 SmartMediaPlayer 연동 필드
  @HiveField(7)
  double? playbackSpeed; // 🔧 null 허용으로 변경

  @HiveField(8)
  int pitch;

  @HiveField(9)
  Duration? loopStart;

  @HiveField(10)
  Duration? loopEnd;

  @HiveField(11)
  List<Duration> bpmMarks;

  @HiveField(12)
  List<SmartComment> comments;

  Lesson({
    required this.date,
    required this.subject,
    required this.keywords,
    required this.memo,
    required this.audioPaths,
    required this.nextPlan,
    required this.studentId,
    this.playbackSpeed = 1.0,
    this.pitch = 0,
    this.loopStart,
    this.loopEnd,
    List<Duration>? bpmMarks,
    List<SmartComment>? comments,
  })  : bpmMarks = bpmMarks ?? [],
        comments = comments ?? [];
}

@HiveType(typeId: 1)
class SmartComment {
  @HiveField(0)
  String label;

  @HiveField(1)
  String memo;

  @HiveField(2)
  Duration position;

  SmartComment({
    required this.label,
    required this.memo,
    required this.position,
  });
}
