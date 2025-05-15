import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'custom_waveform_generator.dart';

class CustomWaveformGeneratorImpl implements CustomWaveformGenerator {
  @override
  Future<List<double>> generateWaveform(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return [];

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return [];

    return compute(_extractWaveform, bytes);
  }
}

List<double> _extractWaveform(Uint8List bytes) {
  const samples = 512;
  final step = (bytes.length / samples).floor();
  final waveform = <double>[];

  for (int i = 0; i < samples; i++) {
    int sum = 0;
    for (int j = 0; j < step && (i * step + j) < bytes.length; j++) {
      sum += bytes[i * step + j].abs();
    }
    waveform.add(sum / step / 255);
  }

  return waveform;
}
