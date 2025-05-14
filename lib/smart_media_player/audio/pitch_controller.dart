// lib/smart_media_player/audio/pitch_controller.dart
import 'package:just_audio/just_audio.dart';
import 'dart:math';

class PitchController {
  final AudioPlayer player;

  /// -6 ~ +6 범위 (반음 단위)
  int _pitch = 0;

  PitchController({required this.player});

  int get pitch => _pitch;

  void setPitch(int semitone) {
    if (semitone < -6 || semitone > 6) return;

    _pitch = semitone;

    // pitch == 0일 땐 원래 템포로 (정확히 1.0)
    final rate = _semitoneToRate(_pitch);
    player.setSpeed(rate); // just_audio에서는 pitch 조절을 속도 변화로 시뮬레이션
  }

  /// 반음 -> 속도 변환 (12-TET 기준)
  double _semitoneToRate(int pitch) {
    return (pitch == 0) ? 1.0 : pow(1.05946309436, pitch).toDouble();
  }
}
