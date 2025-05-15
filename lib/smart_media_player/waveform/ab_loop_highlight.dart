import 'package:flutter/material.dart';

class AbLoopHighlight extends StatelessWidget {
  final double startRatio;
  final double endRatio;
  final double waveformWidth;
  final double waveformHeight;

  const AbLoopHighlight({
    super.key,
    required this.startRatio,
    required this.endRatio,
    required this.waveformWidth,
    required this.waveformHeight,
  });

  @override
  Widget build(BuildContext context) {
    final start = (startRatio * waveformWidth).clamp(0.0, waveformWidth);
    final end = (endRatio * waveformWidth).clamp(0.0, waveformWidth);
    final width = (end - start).clamp(0.0, waveformWidth);

    return Positioned(
      left: start,
      top: 0,
      width: width,
      height: waveformHeight,
      child: Container(
        color: Colors.lightGreen.withOpacity(0.2), // 연한 연두색 하이라이트
      ),
    );
  }
}
