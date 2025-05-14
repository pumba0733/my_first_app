// lib/smart_media_player/waveform/waveform_painter.dart
import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> waveform;
  final List<Duration> bpmMarks;
  final Duration currentPosition;
  final Duration totalDuration;
  final Duration? loopStart;
  final Duration? loopEnd;
  final Duration? dragStart;
  final Duration? dragEnd;

  WaveformPainter({
    required this.waveform,
    required this.bpmMarks,
    required this.currentPosition,
    required this.totalDuration,
    this.loopStart,
    this.loopEnd,
    this.dragStart,
    this.dragEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    final midY = size.height / 2;
    final samples = waveform.length;
    final widthPerSample = size.width / samples;

    // 🔁 A-B Loop 구간 배경
    if (loopStart != null && loopEnd != null) {
      final startX =
          (loopStart!.inMilliseconds / totalDuration.inMilliseconds) *
              size.width;
      final endX =
          (loopEnd!.inMilliseconds / totalDuration.inMilliseconds) * size.width;
      final loopPaint = Paint()..color = Colors.orange.withAlpha(77);
      canvas.drawRect(Rect.fromLTRB(startX, 0, endX, size.height), loopPaint);
    }

    // ✨ 드래그 중 영역 하이라이트 (반복 설정 영역 시각화)
    if (dragStart != null && dragEnd != null) {
      final startX =
          (dragStart!.inMilliseconds / totalDuration.inMilliseconds) *
              size.width;
      final endX =
          (dragEnd!.inMilliseconds / totalDuration.inMilliseconds) * size.width;
      final dragPaint = Paint()..color = Colors.yellow.withAlpha(80); // 연노란색
      canvas.drawRect(Rect.fromLTRB(startX, 0, endX, size.height), dragPaint);
    }

    // 🎵 파형 그리기
    for (int i = 0; i < samples; i++) {
      final x = i * widthPerSample;
      final y = waveform[i] * (size.height / 2);
      paint.color = Colors.blue;
      canvas.drawLine(Offset(x, midY - y), Offset(x, midY + y), paint);
    }

    // 🔴 현재 재생 위치 마커 (Playhead)
    final positionRatio =
        currentPosition.inMilliseconds / totalDuration.inMilliseconds;
    final playheadX = positionRatio * size.width;
    paint.color = Colors.red;
    canvas.drawLine(
      Offset(playheadX, 0),
      Offset(playheadX, size.height),
      paint..strokeWidth = 1.5,
    );

    // 🟢 BPM 마커
    for (final mark in bpmMarks) {
      final x =
          (mark.inMilliseconds / totalDuration.inMilliseconds) * size.width;
      paint.color = Colors.green;
      canvas.drawLine(
        Offset(x, 10),
        Offset(x, size.height - 10),
        paint..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.waveform != waveform ||
        oldDelegate.bpmMarks != bpmMarks ||
        oldDelegate.currentPosition != currentPosition ||
        oldDelegate.totalDuration != totalDuration ||
        oldDelegate.loopStart != loopStart ||
        oldDelegate.loopEnd != loopEnd ||
        oldDelegate.dragStart != dragStart ||
        oldDelegate.dragEnd != dragEnd;
  }
}
