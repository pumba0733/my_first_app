import 'package:flutter/material.dart';

class FeedbackPanel extends StatelessWidget {
  final List<String> feedbackTags;
  final Function(String) onRemove;

  const FeedbackPanel({
    super.key,
    required this.feedbackTags,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (feedbackTags.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📌 선택된 수업 주제',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: feedbackTags
              .map((tag) => Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () => onRemove(tag),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
