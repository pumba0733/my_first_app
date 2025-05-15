import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> waveform;
  final Duration position;
  final Duration duration;
  final Duration? loopStart;
  final Duration? loopEnd;
  final List<Duration> bpmMarks;

  WaveformPainter({
    required this.waveform,
    required this.position,
    required this.duration,
    required this.loopStart,
    required this.loopEnd,
    required this.bpmMarks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey
      ..strokeWidth = 1.0;

    final waveformLength = waveform.length;
    if (waveformLength == 0 || duration.inMilliseconds == 0) return;

    final width = size.width;
    final height = size.height;
    final barWidth = width / waveformLength;

    for (int i = 0; i < waveformLength; i++) {
      final x = i * barWidth;
      final y = waveform[i] * height;
      canvas.drawLine(
          Offset(x, height / 2 - y / 2), Offset(x, height / 2 + y / 2), paint);
    }

    // 🔴 현재 위치 (재생 위치)
    final playheadPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0;
    final playheadX =
        (position.inMilliseconds / duration.inMilliseconds) * width;
    canvas.drawLine(
        Offset(playheadX, 0), Offset(playheadX, height), playheadPaint);

    // 🟩 반복 구간 하이라이트 (겹침 방지용 - Deprecated로 남겨둠)
    if (loopStart != null && loopEnd != null) {
      final loopPaint = Paint()
        ..color = Colors.green.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      final startX =
          (loopStart!.inMilliseconds / duration.inMilliseconds) * width;
      final endX = (loopEnd!.inMilliseconds / duration.inMilliseconds) * width;
      canvas.drawRect(Rect.fromLTRB(startX, 0, endX, height), loopPaint);
    }

    // 🟢 BPM 마커
    final bpmPaint = Paint()
      ..color = Colors.lightGreen
      ..strokeWidth = 1.0;
    for (final mark in bpmMarks) {
      final bpmX = (mark.inMilliseconds / duration.inMilliseconds) * width;
      canvas.drawLine(
          Offset(bpmX, height - 15), Offset(bpmX, height), bpmPaint);
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.waveform != waveform ||
        oldDelegate.position != position ||
        oldDelegate.duration != duration ||
        oldDelegate.loopStart != loopStart ||
        oldDelegate.loopEnd != loopEnd ||
        oldDelegate.bpmMarks != bpmMarks;
  }
}
