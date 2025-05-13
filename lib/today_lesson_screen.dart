// 오늘 수업 화면 개선본 (자동 저장 포함)

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'lesson.dart';
import 'student.dart';

class TodayLessonScreen extends StatefulWidget {
  final Student student;
  const TodayLessonScreen({super.key, required this.student});

  @override
  State<TodayLessonScreen> createState() => _TodayLessonScreenState();
}

class _TodayLessonScreenState extends State<TodayLessonScreen> {
  final lessonBox = Hive.box<Lesson>('lessons');

  DateTime selectedDate = DateTime.now();
  final List<String> selectedKeywords = [];
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController memoController = TextEditingController();
  final TextEditingController nextPlanController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  List<String> selectedAudioPaths = [];
  bool showTags = false;
  Map<String, List<Map<String, String>>> feedbackData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadFeedbackData();
      loadTodayLesson();
    });
    subjectController.addListener(saveLesson);
    memoController.addListener(saveLesson);
    nextPlanController.addListener(saveLesson);
  }

  Future<void> loadFeedbackData() async {
    final keywordBox = await Hive.openBox('keywords');
    final storedData = keywordBox.get('feedbackData');
    if (storedData != null) {
      final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(
        json.decode(storedData),
      );
      final Map<String, List<Map<String, String>>> parsed = {};
      jsonMap.forEach((key, value) {
        parsed[key] = (value as List<dynamic>)
            .map<Map<String, String>>(
              (item) => {
                'text': item['text'].toString(),
                'value': item['value'].toString(),
              },
            )
            .toList();
      });
      setState(() {
        feedbackData = parsed;
      });
    }
  }

  Future<void> loadPreviousLesson() async {
    final prevLessons = lessonBox.values
        .where((l) =>
            l.studentId == widget.student.id && l.date.isBefore(selectedDate))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (prevLessons.isNotEmpty) {
      final latest = prevLessons.first;
      setState(() {
        selectedKeywords.clear();
        selectedKeywords.addAll(latest.keywords);
        subjectController.text = latest.subject;
        memoController.text = latest.memo;
        nextPlanController.text = latest.nextPlan;
        selectedAudioPaths = List<String>.from(latest.audioPaths);
        urlController.text = '';
      });
    }
  }

  Future<void> loadTodayLesson() async {
    final todayLessons = lessonBox.values
        .where((l) =>
            l.studentId == widget.student.id &&
            DateFormat('yyyy-MM-dd').format(l.date) ==
                DateFormat('yyyy-MM-dd').format(selectedDate))
        .toList();

    if (todayLessons.isNotEmpty) {
      final lesson = todayLessons.last;
      setState(() {
        selectedKeywords.clear();
        selectedKeywords.addAll(lesson.keywords);
        subjectController.text = lesson.subject;
        memoController.text = lesson.memo;
        nextPlanController.text = lesson.nextPlan;
        selectedAudioPaths = List<String>.from(lesson.audioPaths);
        urlController.text = '';
      });
    }
  }

  Future<void> saveLesson() async {
    final todayLesson = lessonBox.values.firstWhere(
      (l) =>
          l.studentId == widget.student.id &&
          DateFormat('yyyy-MM-dd').format(l.date) ==
              DateFormat('yyyy-MM-dd').format(selectedDate),
      orElse: () => Lesson(
        date: selectedDate,
        subject: '',
        keywords: [],
        memo: '',
        audioPaths: [],
        nextPlan: '',
        studentId: widget.student.id,
      ),
    );

    todayLesson.date = selectedDate;
    todayLesson.subject = subjectController.text.trim();
    todayLesson.keywords = selectedKeywords;
    todayLesson.memo = memoController.text.trim();
    todayLesson.audioPaths = selectedAudioPaths;
    todayLesson.nextPlan = nextPlanController.text.trim();
    todayLesson.studentId = widget.student.id;

    if (todayLesson.isInBox) {
      await todayLesson.save();
    } else {
      await lessonBox.add(todayLesson);
    }
  }

  void toggleKeyword(String keyword) {
    setState(() {
      if (selectedKeywords.contains(keyword)) {
        selectedKeywords.remove(keyword);
      } else {
        selectedKeywords.add(keyword);
      }
    });
    saveLesson();
  }

  void removeKeyword(String keyword) {
    setState(() {
      selectedKeywords.remove(keyword);
    });
    saveLesson();
  }

  void removeFile(String path) {
    setState(() {
      selectedAudioPaths.remove(path);
    });
    saveLesson();
  }

  void openFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await Process.run('open', [path]);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ 파일이 존재하지 않습니다')),
      );
    }
  }

  void launchUrlIfValid(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ 유효하지 않은 링크입니다')),
      );
    }
  }

  ButtonStyle buttonStyle({double fontSize = 14}) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.red.shade300,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      textStyle: TextStyle(fontSize: fontSize),
    );
  }

  TextField buildTextField(TextEditingController controller, String label,
      {String? hint, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: (_) => saveLesson(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('yyyy-MM-dd (E)', 'ko_KR').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('📅 $formattedDate'),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2030),
                  locale: const Locale('ko'),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                  saveLesson();
                  loadTodayLesson();
                }
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await saveLesson();
              if (!mounted) return;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text('지난 수업 요약 불러오기'),
              style: buttonStyle(),
              onPressed: loadPreviousLesson,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('🏷️ 수업 주제 태그',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => setState(() => showTags = !showTags),
                  style: buttonStyle(fontSize: 12),
                  child: Text(showTags ? '숨기기' : '선택하기'),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: selectedKeywords
                  .map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () => removeKeyword(tag),
                        deleteIcon: const Icon(Icons.close),
                      ))
                  .toList(),
            ),
            if (showTags)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: feedbackData.entries.map((entry) {
                  final category = entry.key;
                  final items = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text('📂 $category',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8,
                        children: items.map((item) {
                          final label = item['text']!;
                          final isSelected = selectedKeywords.contains(label);
                          return FilterChip(
                            label: Text(label),
                            selected: isSelected,
                            selectedColor: Colors.red.shade200,
                            checkmarkColor: Colors.white,
                            onSelected: (_) => toggleKeyword(label),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),
            buildTextField(subjectController, '수업 주제 (텍스트 직접 입력)'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text('수업 자료 선택'),
              style: buttonStyle(),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('⚠️ 파일 선택 기능은 아직 구현되지 않았습니다')),
                );
              },
            ),
            Wrap(
              spacing: 8,
              children: selectedAudioPaths.map((path) {
                final name = path.split(Platform.pathSeparator).last;
                return GestureDetector(
                  onTap: () => openFile(path),
                  child: Chip(
                    label: Text(name),
                    onDeleted: () => removeFile(path),
                    deleteIcon: const Icon(Icons.close),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: '🌐 유튜브 링크',
                hintText: 'https://youtube.com/...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () {
                    final url = urlController.text.trim();
                    if (url.isNotEmpty) {
                      launchUrlIfValid(context, url);
                    }
                  },
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            buildTextField(
              memoController,
              '📝 수업 내용',
              hint: '오늘 배운 내용을 간단히 기록하세요',
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            buildTextField(
              nextPlanController,
              '📌 다음 수업 계획',
              hint: '예: 2절 암기 마무리 + 새로운 곡 도입',
            ),
          ],
        ),
      ),
    );
  }
}
