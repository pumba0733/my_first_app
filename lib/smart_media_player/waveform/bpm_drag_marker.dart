import 'package:flutter/material.dart';

class BpmDragMarker extends StatelessWidget {
  final double xPosition;
  final VoidCallback onRemove;
  final VoidCallback onDragStart;
  final void Function(double) onDragUpdate;
  final VoidCallback onDragEnd;

  const BpmDragMarker({
    super.key,
    required this.xPosition,
    required this.onRemove,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: xPosition - 1,
      bottom: 0,
      child: GestureDetector(
        onTap: onRemove,
        onHorizontalDragStart: (_) => onDragStart(),
        onHorizontalDragUpdate: (details) => onDragUpdate(details.delta.dx),
        onHorizontalDragEnd: (_) => onDragEnd(),
        child: Container(
          width: 2,
          height: 60,
          color: Colors.greenAccent,
        ),
      ),
    );
  }
}
