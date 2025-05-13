// 지난 수업 화면 개선본
// 주요 수정사항:
// - Transcribe 실행 버튼 제거 완료
// - 저장된 데이터가 정상적으로 정렬되고 불러오도록 유지

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'lesson.dart';
import 'student.dart';

class LessonHistoryScreen extends StatefulWidget {
  final Student student;
  const LessonHistoryScreen({super.key, required this.student});

  @override
  State<LessonHistoryScreen> createState() => _LessonHistoryScreenState();
}

class _LessonHistoryScreenState extends State<LessonHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final lessonBox = Hive.box<Lesson>('lessons');
    final lessons = lessonBox.values
        .where((l) => l.studentId == widget.student.id)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: Text('📚 지난 수업 - ${widget.student.name}'),
      ),
      body: lessons.isEmpty
          ? const Center(child: Text('저장된 수업이 없습니다.'))
          : ListView.builder(
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                final formattedDate =
                    DateFormat('yyyy-MM-dd (E)', 'ko_KR').format(lesson.date);

                return ExpansionTile(
                  title: Text('$formattedDate - ${lesson.subject}'),
                  subtitle: Text(lesson.keywords.join(', ')),
                  children: [
                    if (lesson.audioPaths.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('🎵 수업 자료'),
                          ),
                          ...lesson.audioPaths.map((path) {
                            final name =
                                path.split(Platform.pathSeparator).last;
                            return ListTile(
                              title: Text(name),
                              onTap: () async {
                                final file = File(path);
                                if (await file.exists()) {
                                  await Process.run('open', [path]);
                                } else {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('파일을 찾을 수 없습니다.')),
                                  );
                                }
                              },
                            );
                          }),
                        ],
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📝 수업 내용:\n${lesson.memo}'),
                          const SizedBox(height: 8),
                          Text('📌 다음 수업 계획:\n${lesson.nextPlan}'),
                          const SizedBox(height: 12),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await lesson.delete();
                                if (!mounted) return;
                                setState(() {});
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('삭제 완료')),
                                    );
                                  }
                                });
                              },
                              icon: const Icon(Icons.delete_forever),
                              label: const Text('이 수업 삭제'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
