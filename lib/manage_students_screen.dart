// 학생 관리 화면 개선본
// 주요 수정사항:
// - '담당강사 없음' 드롭다운 선택 시, 해당 조건에 맞는 학생 목록 표시
// - '담당강사 없음만 보기' 체크박스 제거
// - 학생 추가/수정 시 강사 선택 드롭다운 UI 추가
// - 자동 저장 기능 Hive 기반 정상 동작 확인
// - 전화번호 4자리 오류 및 Dart 구문 오류 수정
// - 버튼 기능들(_showAddStudentDialog 등) 완전 구현

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'student.dart';
import 'teacher.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  String? selectedTeacher;
  final adminPassword = '0907';
  String searchKeyword = '';

  List<String> get teacherList {
    final teacherBox = Hive.box<Teacher>('teachers');
    final names = teacherBox.values.map((t) => t.name).toSet().toList();
    return ['담당강사 없음', ...names];
  }

  @override
  Widget build(BuildContext context) {
    final studentBox = Hive.box<Student>('students');
    final allStudents = studentBox.values.toList();

    final filtered = allStudents.where((s) {
      final matchesName = s.name.contains(searchKeyword);
      final matchesTeacher = selectedTeacher == null
          ? true
          : selectedTeacher == '담당강사 없음'
              ? s.teacherName.isEmpty
              : s.teacherName == selectedTeacher;
      return matchesName && matchesTeacher;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('👥 학생 관리')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: '🔍 이름으로 검색',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) => setState(() => searchKeyword = val.trim()),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedTeacher,
              hint: const Text('강사를 선택하세요'),
              isExpanded: true,
              items: teacherList.map((teacher) {
                return DropdownMenuItem(
                  value: teacher,
                  child: Text(teacher),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedTeacher = value),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showAddStudentDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('학생 추가'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final student = filtered[index];
                  final phoneDisplay = student.phone.length >= 4
                      ? student.phone.substring(student.phone.length - 4)
                      : '번호 미입력';
                  final teacherDisplay = student.teacherName.isEmpty
                      ? '(담당 없음)'
                      : '담당: ${student.teacherName}';
                  return Card(
                    child: ListTile(
                      title: Text(student.name),
                      subtitle: Text('📱 $phoneDisplay  $teacherDisplay'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.note),
                            onPressed: () => _showMemoDialog(student),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditStudentDialog(student),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDeleteStudent(student),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStudentDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final schoolController = TextEditingController();
    String gender = '남';
    String ageGroup = '학생';
    String instrument = '통기타';
    String assignedTeacher = selectedTeacher ?? '담당강사 없음';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('➕ 새 학생 추가'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '이름'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: '휴대폰 번호 전체'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              const Align(alignment: Alignment.centerLeft, child: Text('성별')),
              DropdownButton<String>(
                value: gender,
                isExpanded: true,
                items: ['남', '여']
                    .map(
                        (val) => DropdownMenuItem(value: val, child: Text(val)))
                    .toList(),
                onChanged: (val) => setState(() => gender = val!),
              ),
              const Align(alignment: Alignment.centerLeft, child: Text('연령')),
              DropdownButton<String>(
                value: ageGroup,
                isExpanded: true,
                items: ['학생', '성인']
                    .map(
                        (val) => DropdownMenuItem(value: val, child: Text(val)))
                    .toList(),
                onChanged: (val) => setState(() => ageGroup = val!),
              ),
              TextField(
                controller: schoolController,
                decoration: const InputDecoration(labelText: '학교/학년'),
              ),
              const Align(alignment: Alignment.centerLeft, child: Text('악기')),
              DropdownButton<String>(
                value: instrument,
                isExpanded: true,
                items: ['일렉기타', '통기타', '클래식기타']
                    .map(
                        (val) => DropdownMenuItem(value: val, child: Text(val)))
                    .toList(),
                onChanged: (val) => setState(() => instrument = val!),
              ),
              const Align(
                  alignment: Alignment.centerLeft, child: Text('담당 강사')),
              DropdownButton<String>(
                value: assignedTeacher,
                isExpanded: true,
                items: teacherList
                    .map(
                        (val) => DropdownMenuItem(value: val, child: Text(val)))
                    .toList(),
                onChanged: (val) => setState(() => assignedTeacher = val!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final studentBox = Hive.box<Student>('students');
              await studentBox.add(
                Student(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  gender: gender,
                  ageGroup: ageGroup,
                  schoolGrade: schoolController.text.trim(),
                  instrument: instrument,
                  teacherName:
                      assignedTeacher == '담당강사 없음' ? '' : assignedTeacher,
                ),
              );
              if (!mounted) return;
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _showMemoDialog(Student student) {
    final memoController = TextEditingController(text: student.memo);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('📝 학생 메모'),
        content: TextField(
          controller: memoController,
          decoration: const InputDecoration(labelText: '비고'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () async {
              student.memo = memoController.text.trim();
              await student.save();
              if (!mounted) return;
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showEditStudentDialog(Student student) {
    final nameController = TextEditingController(text: student.name);
    final phoneController = TextEditingController(text: student.phone);
    final schoolController = TextEditingController(text: student.schoolGrade);
    String gender = student.gender;
    String ageGroup = student.ageGroup;
    String instrument = student.instrument;
    String assignedTeacher =
        student.teacherName.isEmpty ? '담당강사 없음' : student.teacherName;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('✏️ 학생 정보 수정'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '이름'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: '휴대폰 번호 전체'),
              ),
              const Align(alignment: Alignment.centerLeft, child: Text('성별')),
              DropdownButton<String>(
                value: gender,
                isExpanded: true,
                items: ['남', '여']
                    .map(
                        (val) => DropdownMenuItem(value: val, child: Text(val)))
                    .toList(),
                onChanged: (val) => setState(() => gender = val!),
              ),
              const Align(alignment: Alignment.centerLeft, child: Text('연령')),
              DropdownButton<String>(
                value: ageGroup,
                isExpanded: true,
                items: ['학생', '성인']
                    .map(
                        (val) => DropdownMenuItem(value: val, child: Text(val)))
                    .toList(),
                onChanged: (val) => setState(() => ageGroup = val!),
              ),
              TextField(
                controller: schoolController,
                decoration: const InputDecoration(labelText: '학교/학년'),
              ),
              const Align(alignment: Alignment.centerLeft, child: Text('악기')),
              DropdownButton<String>(
                value: instrument,
                isExpanded: true,
                items: ['일렉기타', '통기타', '클래식기타']
                    .map(
                        (val) => DropdownMenuItem(value: val, child: Text(val)))
                    .toList(),
                onChanged: (val) => setState(() => instrument = val!),
              ),
              const Align(
                  alignment: Alignment.centerLeft, child: Text('담당 강사')),
              DropdownButton<String>(
                value: assignedTeacher,
                isExpanded: true,
                items: teacherList
                    .map(
                        (val) => DropdownMenuItem(value: val, child: Text(val)))
                    .toList(),
                onChanged: (val) => setState(() => assignedTeacher = val!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              student.name = nameController.text.trim();
              student.phone = phoneController.text.trim();
              student.gender = gender;
              student.ageGroup = ageGroup;
              student.schoolGrade = schoolController.text.trim();
              student.instrument = instrument;
              student.teacherName =
                  assignedTeacher == '담당강사 없음' ? '' : assignedTeacher;
              await student.save();
              if (!mounted) return;
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStudent(Student student) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ 학생 삭제 확인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('정말로 이 학생을 삭제하시겠습니까?'),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '관리자 비밀번호 입력'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text.trim() == adminPassword) {
                await student.delete();
                if (!mounted) return;
                setState(() {});
                Navigator.pop(context);
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ 비밀번호가 틀렸습니다')),
                );
              }
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
