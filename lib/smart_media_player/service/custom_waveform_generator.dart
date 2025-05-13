// lib/smart_media_player/service/custom_waveform_generator.dart

export 'custom_waveform_generator_io.dart'
    if (dart.library.html) 'custom_waveform_generator_web.dart';

import 'custom_waveform_generator_io.dart'
    if (dart.library.html) 'custom_waveform_generator_web.dart';

/// 공통 인터페이스
abstract class CustomWaveformGenerator {
  /// [filePath]와 [fileName]을 입력받아 [List<double>]로 파형 생성
  Future<List<double>> generateWaveform(String filePath, String fileName);
}

/// 각 플랫폼에 맞는 구현체 생성 함수
CustomWaveformGenerator createWaveformGenerator() =>
    CustomWaveformGeneratorImpl();
