// lib/smart_media_player/waveform/waveform_timeline.dart

import 'package:flutter/material.dart';
import '../service/time_formatter.dart';

class WaveformTimeline extends StatelessWidget {
  final Duration duration;
  final double zoom;
  final double width;
  final double height;

  const WaveformTimeline({
    super.key,
    required this.duration,
    required this.zoom,
    required this.width,
    this.height = 20,
  });

  @override
  Widget build(BuildContext context) {
    final seconds = duration.inSeconds;
    final pixelsPerSecond = width / duration.inSeconds;
    final interval = _getOptimalInterval(pixelsPerSecond);

    final marks = <Widget>[];
    for (int i = 0; i <= seconds; i += interval) {
      final x = i * pixelsPerSecond;
      if (x > width) break;

      marks.add(Positioned(
        left: x - 10,
        top: 0,
        child: Text(
          formatDuration(Duration(seconds: i)),
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ));

      marks.add(Positioned(
        left: x,
        top: 15,
        child: Container(
          width: 1,
          height: 5,
          color: Colors.grey,
        ),
      ));
    }

    return SizedBox(
      height: height,
      width: width,
      child: Stack(children: marks),
    );
  }

  int _getOptimalInterval(double pixelsPerSecond) {
    if (pixelsPerSecond > 150) return 1; // 1초 간격
    if (pixelsPerSecond > 80) return 2;
    if (pixelsPerSecond > 40) return 5;
    if (pixelsPerSecond > 20) return 10;
    return 15;
  }
}
