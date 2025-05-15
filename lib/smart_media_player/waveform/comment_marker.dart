import 'package:flutter/material.dart';

class CommentMarker extends StatefulWidget {
  final String label;
  final Duration position;
  final double xPosition;
  final void Function(Duration newPosition) onUpdatePosition;
  final VoidCallback onEdit;

  const CommentMarker({
    super.key,
    required this.label,
    required this.position,
    required this.xPosition,
    required this.onUpdatePosition,
    required this.onEdit,
  });

  @override
  State<CommentMarker> createState() => _CommentMarkerState();
}

class _CommentMarkerState extends State<CommentMarker> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.xPosition - 6,
      top: 0,
      child: GestureDetector(
        onTap: widget.onEdit,
        onPanStart: (_) => setState(() => _isDragging = true),
        onPanUpdate: (details) {
          setState(() {
            final newX = widget.xPosition + details.delta.dx;
            widget
                .onUpdatePosition(Duration(milliseconds: (newX * 10).toInt()));
          });
        },
        onPanEnd: (_) => setState(() => _isDragging = false),
        child: Column(
          children: [
            Text(widget.label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const Icon(Icons.comment, size: 18, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
