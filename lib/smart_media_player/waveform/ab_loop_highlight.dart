// lib/smart_media_player/waveform/ab_loop_highlight.dart

import 'package:flutter/material.dart';

class AbLoopHighlight extends StatelessWidget {
  final Duration? loopStart;
  final Duration? loopEnd;
  final Duration totalDuration;
  final double? waveformWidth;
  final double height;

  const AbLoopHighlight({
    super.key,
    required this.loopStart,
    required this.loopEnd,
    required this.totalDuration,
    this.waveformWidth,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    if (loopStart == null || loopEnd == null) return const SizedBox.shrink();

    final width = waveformWidth ?? MediaQuery.of(context).size.width;

    final startRatio = loopStart!.inMilliseconds / totalDuration.inMilliseconds;
    final endRatio = loopEnd!.inMilliseconds / totalDuration.inMilliseconds;

    final left = (startRatio * width).clamp(0.0, width);
    final right = (endRatio * width).clamp(0.0, width);
    final barWidth = (right - left).clamp(0.0, width - left);

    return Positioned(
      left: left,
      top: 0,
      child: Container(
        width: barWidth,
        height: height,
        color: const Color.fromARGB(77, 33, 150, 243), // 🔵 30% 투명 파란색
      ),
    );
  }
}
