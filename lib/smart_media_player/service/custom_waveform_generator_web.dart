import 'dart:js' as js;
import 'custom_waveform_generator.dart';

class CustomWaveformGeneratorImpl implements CustomWaveformGenerator {
  @override
  Future<List<double>> generateWaveform(String filePath) async {
    try {
      final result =
          js.context.callMethod('generateWaveformFromUrl', [filePath]);
      if (result is List) {
        return result.map((e) => (e as num).toDouble()).toList();
      }
    } catch (e) {
      // JS interop 실패 시 빈 파형 반환
      return [];
    }
    return [];
  }
}
