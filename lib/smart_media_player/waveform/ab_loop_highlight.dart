// lib/smart_media_player/waveform/ab_loop_highlight.dart

import 'package:flutter/material.dart';

class AbLoopHighlight extends StatelessWidget {
  final Duration? loopStart;
  final Duration? loopEnd;
  final Duration totalDuration;
  final double waveformWidth;
  final double height;

  const AbLoopHighlight({
    super.key,
    required this.loopStart,
    required this.loopEnd,
    required this.totalDuration,
    required this.waveformWidth,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    if (loopStart == null || loopEnd == null) return const SizedBox.shrink();

    final startRatio = loopStart!.inMilliseconds / totalDuration.inMilliseconds;
    final endRatio = loopEnd!.inMilliseconds / totalDuration.inMilliseconds;

    final left = (startRatio * waveformWidth).clamp(0.0, waveformWidth);
    final right = (endRatio * waveformWidth).clamp(0.0, waveformWidth);
    final width = (right - left).clamp(0.0, waveformWidth - left);

    return Positioned(
      left: left,
      top: 0,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.orange.withAlpha(77),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
