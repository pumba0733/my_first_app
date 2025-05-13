// lib/smart_media_player/service/custom_waveform_generator_io.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'custom_waveform_generator.dart';

class CustomWaveformGeneratorImpl implements CustomWaveformGenerator {
  @override
  Future<List<double>> generateWaveform(
      String filePath, String fileName) async {
    final file = File(filePath);
    if (!await file.exists()) return [];

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return [];

    return compute(_extractWaveform, bytes);
  }
}

List<double> _extractWaveform(Uint8List bytes) {
  const samples = 512;
  final chunkSize = (bytes.length / samples).floor();
  final List<double> waveform = [];

  for (int i = 0; i < samples; i++) {
    final start = i * chunkSize;
    final end = (start + chunkSize).clamp(0, bytes.length);
    final chunk = bytes.sublist(start, end);
    final avg = chunk.fold<double>(0, (sum, b) => sum + b) / chunk.length;
    waveform.add(avg / 255.0);
  }

  return waveform;
}
