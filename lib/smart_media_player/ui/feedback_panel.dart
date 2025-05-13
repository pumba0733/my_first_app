import 'package:flutter/material.dart';

class ZoomControls extends StatelessWidget {
  final double zoomLevel;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const ZoomControls({
    super.key,
    required this.zoomLevel,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.zoom_out),
          onPressed: onZoomOut,
        ),
        Text('Zoom: ${zoomLevel.toStringAsFixed(1)}x'),
        IconButton(
          icon: const Icon(Icons.zoom_in),
          onPressed: onZoomIn,
        ),
      ],
    );
  }
}
