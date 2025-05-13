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
    if (duration.inMilliseconds == 0) return const SizedBox.shrink();

    final ratio = position.inMilliseconds / duration.inMilliseconds;
    final x = ratio * width;

    return Positioned(
      left: x.clamp(0.0, width - 1),
      child: Container(
        width: 2,
        height: 80,
        color: Colors.orange.withAlpha(77),
      ),
    );
  }
}
