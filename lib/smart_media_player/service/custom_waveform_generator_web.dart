// lib/smart_media_player/service/custom_waveform_generator_web.dart

import 'dart:js' as js;
import 'dart:js_util';
import 'custom_waveform_generator.dart';

class CustomWaveformGeneratorImpl implements CustomWaveformGenerator {
  @override
  Future<List<double>> generateWaveform(
      String filePath, String fileName) async {
    try {
      final jsResult = await promiseToFuture(
        js.context.callMethod('generateWaveformFromUrl', [filePath]),
      );

      final List<dynamic> raw = List.from(jsResult);
      return raw.map((e) => (e as num).toDouble()).toList();
    } catch (e) {
      return [];
    }
  }
}
