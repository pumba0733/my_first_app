// lib/smart_media_player/waveform/playhead_marker.dart

import 'package:flutter/material.dart';

class PlayheadMarker extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final double width;

  const PlayheadMarker({
    super.key,
    required this.position,
    required this.duration,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = position.inMilliseconds / duration.inMilliseconds;
    final x = ratio * width;

    return Positioned(
      left: x - 1,
      top: 0,
      bottom: 0,
      child: Container(
        width: 2,
        color: Colors.red,
      ),
    );
  }
}

class PlaybackStartMarker extends StatelessWidget {
  final Duration? startPosition;
  final Duration duration;
  final double width;

  const PlaybackStartMarker({
    super.key,
    required this.startPosition,
    required this.duration,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (startPosition == null) return const SizedBox.shrink();

    final ratio = startPosition!.inMilliseconds / duration.inMilliseconds;
    final x = ratio * width;

    return Positioned(
      left: x - 4,
      top: 0,
      child: Icon(
        Icons.play_arrow,
        size: 12,
        color: Colors.green,
      ),
    );
  }
}
