// lib/smart_media_player/service/custom_waveform_generator_web.dart

@JS()
import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS('generateWaveformFromAudio')
external dynamic _generateWaveformFromAudio(String url);

Future<List<double>> generateWaveform(String url) async {
  final dynamic result = await promiseToFuture(_generateWaveformFromAudio(url));
  if (result is List) {
    return List<double>.from(result.map((e) => e.toDouble()));
  } else {
    throw Exception('Unexpected waveform format from JS');
  }
}
