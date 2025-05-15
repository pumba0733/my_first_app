import 'dart:io' show Platform;
import 'custom_waveform_generator_io.dart'
    if (dart.library.html) 'custom_waveform_generator_web.dart';

abstract class CustomWaveformGenerator {
  Future<List<double>> generateWaveform(String filePath);
}

CustomWaveformGenerator createWaveformGenerator() {
  return CustomWaveformGeneratorImpl();
}
