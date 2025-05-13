import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'lesson.dart';
import 'student.dart';
import 'teacher.dart'; // ✅ 강사 어댑터용 import
import 'login_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeDateFormatting('ko_KR', null);
    await Hive.initFlutter();

    Hive.registerAdapter(LessonAdapter());
    Hive.registerAdapter(StudentAdapter());
    Hive.registerAdapter(TeacherAdapter()); // ✅ 강사 어댑터 등록

    if (!Hive.isBoxOpen('students')) {
      await Hive.openBox<Student>('students');
    }
    if (!Hive.isBoxOpen('lessons')) {
      await Hive.openBox<Lesson>('lessons');
    }
    if (!Hive.isBoxOpen('teachers')) {
      await Hive.openBox<Teacher>('teachers');
    }

    final students = Hive.box<Student>('students');
    if (students.isEmpty) {
      students.addAll([
        Student(
          id: 'stu001',
          name: '개똥이',
          phone: '010-1111-1234',
          gender: '남',
          ageGroup: '학생',
          schoolGrade: '진안중 1',
          instrument: '통기타',
          teacherName: '이재형 선생님',
        ),
        Student(
          id: 'stu002',
          name: '개똥이',
          phone: '010-2222-5678',
          gender: '여',
          ageGroup: '성인',
          schoolGrade: '해성고 2',
          instrument: '일렉기타',
          teacherName: '김태용 선생님',
        ),
        Student(
          id: 'stu003',
          name: '소똥이',
          phone: '010-3333-8888',
          gender: '남',
          ageGroup: '학생',
          schoolGrade: '푸른초 3',
          instrument: '클래식기타',
          teacherName: '이재형 선생님',
        ),
      ]);
    }

    runApp(const MyApp());
  } catch (e, stack) {
    debugPrint('❌ 앱 초기화 중 오류 발생: $e');
    debugPrint('🪵 StackTrace:\n$stack');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '기타 레슨 앱',
      theme: ThemeData(primarySwatch: Colors.red),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      locale: const Locale('ko', 'KR'),
      supportedLocales: [const Locale('ko', 'KR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
