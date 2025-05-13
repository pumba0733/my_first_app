import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive_flutter/hive_flutter.dart';

class ManageKeywordsScreen extends StatefulWidget {
  const ManageKeywordsScreen({super.key});

  @override
  State<ManageKeywordsScreen> createState() => _ManageKeywordsScreenState();
}

class _ManageKeywordsScreenState extends State<ManageKeywordsScreen> {
  Map<String, List<Map<String, String>>> feedbackData = {};
  late Box keywordBox;

  @override
  void initState() {
    super.initState();
    loadFeedbackData();
  }

  Future<void> loadFeedbackData() async {
    keywordBox = await Hive.openBox('keywords');

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
    } else {
      final jsonString =
          await rootBundle.loadString('assets/json/feedback_data.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
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
      await keywordBox.put('feedbackData', json.encode(parsed));
    }
  }

  Future<void> saveData() async {
    await keywordBox.put('feedbackData', json.encode(feedbackData));
  }

  void addCategory() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('새 카테고리 추가'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '카테고리 이름 입력'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty && !feedbackData.containsKey(name)) {
                setState(() {
                  feedbackData[name] = [];
                });
                saveData();
              }
              Navigator.pop(ctx);
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void renameCategory(String oldName) {
    final controller = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('카테고리 이름 수정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '새 이름 입력'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && !feedbackData.containsKey(newName)) {
                setState(() {
                  feedbackData[newName] = feedbackData.remove(oldName)!;
                });
                saveData();
              }
              Navigator.pop(ctx);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void renameItem(String category, int index, String currentText) {
    final controller = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('항목 텍스트 수정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '새 텍스트 입력'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                feedbackData[category]![index]['text'] = controller.text.trim();
              });
              saveData();
              Navigator.pop(ctx);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧩 키워드 관리'),
        actions: [
          IconButton(onPressed: addCategory, icon: const Icon(Icons.add)),
        ],
      ),
      body: feedbackData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: feedbackData.entries.map((entry) {
                final category = entry.key;
                final items = entry.value;

                return ExpansionTile(
                  title: Row(
                    children: [
                      Expanded(child: Text(category)),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => renameCategory(category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            feedbackData.remove(category);
                          });
                          saveData();
                        },
                      ),
                    ],
                  ),
                  children: [
                    ...items.asMap().entries.map((e) {
                      final index = e.key;
                      final item = e.value;
                      return ListTile(
                        title: Row(
                          children: [
                            Expanded(child: Text(item['text'] ?? '')),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => renameItem(
                                  category, index, item['text'] ?? ''),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  feedbackData[category]!.removeAt(index);
                                });
                                saveData();
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          feedbackData[category]!.add({
                            'text': '새 항목',
                            'value': 'new_item',
                          });
                        });
                        saveData();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('항목 추가'),
                    ),
                  ],
                );
              }).toList(),
            ),
    );
  }
}
