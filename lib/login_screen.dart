import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'student.dart';
import 'home_screen.dart';
import 'admin_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameController = TextEditingController();
  List<Student> matchingStudents = [];
  bool showSelection = false;

  void _searchStudent() {
    final enteredName = nameController.text.trim();
    if (enteredName.isEmpty) return;

    final studentBox = Hive.box<Student>('students');
    final matches = studentBox.values
        .where((student) => student.name == enteredName)
        .toList();

    if (matches.length == 1) {
      _login(matches.first);
    } else if (matches.length > 1) {
      setState(() {
        matchingStudents = matches;
        showSelection = true;
      });
    } else {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('학생 없음'),
          content: const Text('해당 이름의 학생을 찾을 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  void _login(Student student) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(student: student)),
    );
  }

  void _showAdminDialog() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔐 관리자 로그인'),
        content: TextField(
          controller: passwordController,
          decoration: const InputDecoration(labelText: '관리자 비밀번호 입력'),
          obscureText: true,
          onSubmitted: (val) {
            _validateAdminPassword(val.trim());
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () {
              _validateAdminPassword(passwordController.text.trim());
            },
            child: const Text('입장'),
          ),
        ],
      ),
    );
  }

  void _validateAdminPassword(String password) {
    if (password == '0907') {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 관리자 모드로 입장합니다')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ 비밀번호가 틀렸습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👋 학생 로그인'),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: '관리자',
            onPressed: _showAdminDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '이름 입력',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _searchStudent(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _searchStudent,
              child: const Text('로그인'),
            ),
            if (showSelection)
              ...matchingStudents.map(
                (student) => ListTile(
                  title: Text('${student.name} (${student.phoneLast4})'),
                  onTap: () => _login(student),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
