import 'package:hive/hive.dart';

part 'teacher.g.dart'; // 자동 생성될 어댑터 코드 포함

/// 강사 정보를 담는 모델
@HiveType(typeId: 2)
class Teacher extends HiveObject {
  /// 강사 이름
  @HiveField(0)
  String name;

  /// 휴대폰 번호 뒷자리 (4자리)
  @HiveField(1)
  String phoneLast4;

  Teacher({
    required this.name,
    required this.phoneLast4,
  });
}
