// lib/smart_media_player/ui/pitch_slider.dart

import 'package:flutter/material.dart';

class PitchSlider extends StatelessWidget {
  final int pitchSemitone;
  final ValueChanged<int> onChanged;

  const PitchSlider({
    super.key,
    required this.pitchSemitone,
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
              '🎼 피치 조절',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.grey.shade300,
                child: Text(
                  '${pitchSemitone >= 0 ? '+' : ''}$pitchSemitone key',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
        Slider(
          min: -12,
          max: 12,
          divisions: 24,
          value: pitchSemitone.toDouble(),
          onChanged: (double value) => onChanged(value.round()),
          label: '${pitchSemitone >= 0 ? '+' : ''}$pitchSemitone key',
        ),
      ],
    );
  }
}
