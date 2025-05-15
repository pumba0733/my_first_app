import 'package:flutter/material.dart';

class PlayheadMarker extends StatelessWidget {
  final double x;
  const PlayheadMarker({super.key, required this.x});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
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
  final double x;
  const PlaybackStartMarker({super.key, required this.x});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x - 6,
      top: 0,
      child: CustomPaint(
        painter: _TrianglePainter(),
        size: const Size(12, 12),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
