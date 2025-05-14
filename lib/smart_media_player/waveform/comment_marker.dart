// lib/smart_media_player/waveform/comment_marker.dart

import 'package:flutter/material.dart';

class CommentMarker extends StatelessWidget {
  final double xPosition;
  final String label;
  final VoidCallback? onTap;

  const CommentMarker({
    super.key,
    required this.xPosition,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: xPosition,
      top: 0,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            const Icon(
              Icons.comment,
              size: 16,
              color: Colors.blueAccent,
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
