import 'package:hive/hive.dart';

part 'student.g.dart';

@HiveType(typeId: 1)
class Student extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone; // 전체 전화번호

  @HiveField(3)
  String gender; // '남' 또는 '여'

  @HiveField(4)
  String ageGroup; // '성인' 또는 '학생'

  @HiveField(5)
  String schoolGrade;

  @HiveField(6)
  String instrument; // '일렉기타', '통기타', '클래식기타'

  @HiveField(7)
  String teacherName; // 담당 강사 이름

  @HiveField(8)
  String memo; // 비고사항 (메모)

  Student({
    required this.id,
    required this.name,
    required this.phone,
    required this.gender,
    required this.ageGroup,
    required this.schoolGrade,
    required this.instrument,
    required this.teacherName,
    this.memo = '',
  });

  String get phoneLast4 => phone.substring(phone.length - 4);
}
