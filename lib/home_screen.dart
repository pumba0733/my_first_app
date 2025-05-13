import 'package:flutter/material.dart';
import 'lesson_history_screen.dart';
import 'today_lesson_screen.dart';
import 'student.dart';

class HomeScreen extends StatelessWidget {
  final Student student;
  const HomeScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('기타 레슨 앱 - ${student.name}님'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('🎸 오늘 수업 보기'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TodayLessonScreen(student: student),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('📚 지난 수업 복습'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LessonHistoryScreen(student: student),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
