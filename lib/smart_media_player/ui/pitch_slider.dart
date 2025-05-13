import 'package:flutter/material.dart';

class PitchSlider extends StatelessWidget {
  final double pitch;
  final ValueChanged<double> onChanged;

  const PitchSlider({
    super.key,
    required this.pitch,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎼 피치 조절 (±6 반음)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Slider(
          min: -6.0,
          max: 6.0,
          divisions: 12,
          label: '${pitch.toStringAsFixed(1)} semitones',
          value: pitch,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
