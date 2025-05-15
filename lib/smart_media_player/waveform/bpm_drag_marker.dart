// lib/smart_media_player/waveform/bpm_drag_marker.dart

import 'package:flutter/material.dart';

class BpmDragMarker extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final VoidCallback onRemove;

  const BpmDragMarker({
    super.key,
    required this.position,
    required this.duration,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double ratio = position.inMilliseconds / duration.inMilliseconds;
    final double xPos = width * ratio;

    return Positioned(
      left: xPos - 1,
      bottom: 0,
      child: GestureDetector(
        onTap: onRemove,
        child: Container(
          width: 2,
          height: 10,
          color: Colors.orange,
        ),
      ),
    );
  }
}
