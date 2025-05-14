// lib/smart_media_player/ui/comment_widget.dart

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class CommentWidget extends StatelessWidget {
  final AudioPlayer player;
  final Duration currentPosition;
  final List<Map<String, dynamic>> comments;
  final void Function(Map<String, dynamic>) onAddComment;

  const CommentWidget({
    super.key,
    required this.player,
    required this.currentPosition,
    required this.comments,
    required this.onAddComment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💬 코멘트',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.comment),
          label: const Text('현재 위치에 코멘트 추가 (단축키: S)'),
          onPressed: () {
            final label = _nextCommentLabel();
            final comment = {
              'label': label,
              'memo': '',
              'position': currentPosition,
            };
            onAddComment(comment);
          },
        ),
        const SizedBox(height: 8),
        if (comments.isNotEmpty)
          Wrap(
            spacing: 8,
            children: comments.map((comment) {
              return Chip(
                label: Text('${comment['label']}'),
              );
            }).toList(),
          ),
      ],
    );
  }

  String _nextCommentLabel() {
    final existingLabels = comments.map((c) => c['label'] as String).toSet();
    for (var codeUnit = 'a'.codeUnitAt(0);
        codeUnit <= 'z'.codeUnitAt(0);
        codeUnit++) {
      final label = String.fromCharCode(codeUnit);
      if (!existingLabels.contains(label)) return label;
    }
    return '?';
  }
}
