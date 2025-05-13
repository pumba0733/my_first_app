import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'teacher.dart';
import 'student.dart';

class ManageTeachersScreen extends StatefulWidget {
  const ManageTeachersScreen({super.key});

  @override
  State<ManageTeachersScreen> createState() => _ManageTeachersScreenState();
}

class _ManageTeachersScreenState extends State<ManageTeachersScreen> {
  Box<Teacher>? teacherBox;
  final String adminPassword = '0907';

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    teacherBox = Hive.box<Teacher>('teachers');
    setState(() {});
  }

  void _showAddOrEditDialog({Teacher? teacher}) {
    final nameController = TextEditingController(text: teacher?.name ?? '');
    final phoneController =
        TextEditingController(text: teacher?.phoneLast4 ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(teacher == null ? '➕ 강사 추가' : '✏️ 강사 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: phoneController,
              maxLength: 4,
              decoration: const InputDecoration(labelText: '휴대폰 뒷자리'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              if (name.isEmpty || phone.length != 4) return;

              if (teacher == null) {
                await teacherBox?.add(Teacher(name: name, phoneLast4: phone));
              } else {
                teacher.name = name;
                teacher.phoneLast4 = phone;
                await teacher.save();
              }

              if (!mounted) return;
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTeacher(Teacher teacher) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ 강사 삭제 확인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('정말로 이 강사를 삭제하시겠습니까?\n학생 정보는 유지됩니다.'),
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
                await teacher.delete();
                await _reassignStudents(teacher.name);
                if (!mounted) return;
                Navigator.pop(context);
                setState(() {});
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

  Future<void> _reassignStudents(String teacherName) async {
    final studentBox = Hive.box<Student>('students');
    for (var student in studentBox.values) {
      if (student.teacherName == teacherName) {
        student.teacherName = '';
        await student.save();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teachers = teacherBox?.values.toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('👩‍🏫 강사 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddOrEditDialog(),
            tooltip: '강사 추가',
          )
        ],
      ),
      body: teachers.isEmpty
          ? const Center(child: Text('등록된 강사가 없습니다.'))
          : ListView.builder(
              itemCount: teachers.length,
              itemBuilder: (context, index) {
                final teacher = teachers[index];
                return ListTile(
                  title: Text(teacher.name),
                  subtitle: Text('📱 ${teacher.phoneLast4}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showAddOrEditDialog(teacher: teacher),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteTeacher(teacher),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
