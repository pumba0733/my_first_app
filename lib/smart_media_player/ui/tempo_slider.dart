// lib/smart_media_player/ui/tempo_slider.dart

import 'package:flutter/material.dart';

class TempoSlider extends StatelessWidget {
  final double tempo;
  final ValueChanged<double> onChanged;

  const TempoSlider({
    super.key,
    required this.tempo,
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
              '⚡ 속도 조절',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.grey.shade300,
                child: Text(
                  '${(tempo * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
        Slider(
          min: 0.1,
          max: 2.0,
          divisions: 190,
          value: tempo,
          onChanged: onChanged,
          label: '${(tempo * 100).toStringAsFixed(0)}%',
        ),
      ],
    );
  }
}
