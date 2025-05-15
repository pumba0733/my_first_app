import 'package:flutter/material.dart';

class WaveformTimeline extends StatelessWidget {
  final Duration duration;
  final double width;

  const WaveformTimeline({
    super.key,
    required this.duration,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final totalSeconds = duration.inSeconds;
    final step = (totalSeconds / 10).ceil().clamp(1, totalSeconds);

    return SizedBox(
      height: 20,
      width: width,
      child: CustomPaint(
        painter: _TimelinePainter(duration: duration, step: step.toInt()),
      ),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  final Duration duration;
  final int step;

  _TimelinePainter({required this.duration, required this.step});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    final totalSeconds = duration.inSeconds;
    final pixelsPerSecond = size.width / totalSeconds;

    for (int i = 0; i <= totalSeconds; i += step) {
      final x = i * pixelsPerSecond;
      canvas.drawLine(Offset(x, 0), Offset(x, 10), paint);
      final textSpan = TextSpan(
        text: _formatTime(i),
        style: const TextStyle(fontSize: 10, color: Colors.black),
      );
      final textPainter =
          TextPainter(text: textSpan, textDirection: TextDirection.ltr)
            ..layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(canvas, Offset(x - 10, 10));
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
