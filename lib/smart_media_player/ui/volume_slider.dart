// lib/smart_media_player/ui/volume_slider.dart

import 'package:flutter/material.dart';

class VolumeSlider extends StatelessWidget {
  final double volume;
  final ValueChanged<double> onChanged;

  const VolumeSlider({
    super.key,
    required this.volume,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '🔊 볼륨 조절',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.grey.shade300,
                child: Text(
                  '${(volume * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
        Slider(
          min: 0.0,
          max: 1.0,
          divisions: 100,
          value: volume,
          onChanged: onChanged,
          label: '${(volume * 100).toStringAsFixed(0)}%',
        ),
      ],
    );
  }
}
