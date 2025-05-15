// lib/smart_media_player/waveform/comment_marker.dart

import 'package:flutter/material.dart';

class CommentMarker extends StatefulWidget {
  final String label;
  final Duration position;
  final double xPosition;
  final void Function(Duration newPosition) onUpdatePosition;

  const CommentMarker({
    super.key,
    required this.label,
    required this.position,
    required this.xPosition,
    required this.onUpdatePosition,
  });

  @override
  State<CommentMarker> createState() => _CommentMarkerState();
}

class _CommentMarkerState extends State<CommentMarker> {
  late double _dragOffset;

  @override
  void initState() {
    super.initState();
    _dragOffset = widget.xPosition;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Positioned(
      left: _dragOffset - 1,
      top: 0,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            _dragOffset = (_dragOffset + details.delta.dx).clamp(0.0, width);
          });
        },
        onHorizontalDragEnd: (_) {
          final ratio = _dragOffset / width;
          final newPosition = Duration(
            milliseconds: (ratio * widget.position.inMilliseconds).round(),
          );
          widget.onUpdatePosition(newPosition);
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
