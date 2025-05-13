// lib/smart_media_player/waveform/bpm_drag_marker.dart
import 'package:flutter/material.dart';

class BpmDragMarker extends StatefulWidget {
  final double xPosition;
  final double height;
  final VoidCallback onDragStart;
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;
  final VoidCallback onDelete;

  const BpmDragMarker({
    super.key,
    required this.xPosition,
    required this.height,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDelete,
  });

  @override
  State<BpmDragMarker> createState() => _BpmDragMarkerState();
}

class _BpmDragMarkerState extends State<BpmDragMarker> {
  bool _hovering = false;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.xPosition - 2,
      top: 0,
      child: GestureDetector(
        onTap: widget.onDelete,
        onHorizontalDragStart: (_) {
          setState(() => _dragging = true);
          widget.onDragStart();
        },
        onHorizontalDragUpdate: (details) {
          final newX = widget.xPosition + details.delta.dx;
          widget.onDragUpdate(newX);
        },
        onHorizontalDragEnd: (_) {
          setState(() => _dragging = false);
          widget.onDragEnd();
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          cursor: SystemMouseCursors.click,
          child: Container(
            width: 4,
            height: widget.height,
            color: _dragging
                ? Colors.red
                : (_hovering ? Colors.orange : Colors.blue),
          ),
        ),
      ),
    );
  }
}
