// lib/smart_media_player/waveform/comment_marker.dart
import 'package:flutter/material.dart';

class CommentMarker extends StatefulWidget {
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
  State<CommentMarker> createState() => _CommentMarkerState();
}

class _CommentMarkerState extends State<CommentMarker> {
  double? _dragOffset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _dragOffset ?? widget.xPosition,
      top: 0,
      child: GestureDetector(
        onTap: widget.onTap,
        onHorizontalDragUpdate: (details) {
          setState(() {
            _dragOffset = (widget.xPosition + details.delta.dx)
                .clamp(0.0, MediaQuery.of(context).size.width);
          });
        },
        onHorizontalDragEnd: (_) {
          // TODO: 드래그 완료 후 위치 저장 처리 필요 (현재 위치 저장 방식은 smart_media_player.dart에서 추후 반영)
        },
        child: Column(
          children: [
            const Icon(Icons.comment, size: 16, color: Colors.blueAccent),
            Text(
              widget.label,
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
