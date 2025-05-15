import 'package:flutter/material.dart';

class CommentWidget extends StatefulWidget {
  final String label;
  final String initialText;
  final void Function(String newText) onUpdate;
  final VoidCallback onDelete;
  final void Function(String newLabel)? onUpdateLabel;

  const CommentWidget({
    super.key,
    required this.label,
    required this.initialText,
    required this.onUpdate,
    required this.onDelete,
    this.onUpdateLabel,
  });

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  late TextEditingController _textController;
  late TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _labelController = TextEditingController(text: widget.label);
  }

  @override
  void dispose() {
    _textController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('💬 코멘트 수정'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.onUpdateLabel != null)
            TextField(
              controller: _labelController,
              decoration:
                  const InputDecoration(labelText: '라벨 (예: a, b, c...)'),
            ),
          TextField(
            controller: _textController,
            decoration: const InputDecoration(labelText: '코멘트 내용'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onDelete();
            Navigator.of(context).pop();
          },
          child: const Text('삭제'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onUpdate(_textController.text);
            if (widget.onUpdateLabel != null) {
              widget.onUpdateLabel!(_labelController.text);
            }
            Navigator.of(context).pop();
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}
