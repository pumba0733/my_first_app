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
    player.setPitch(rate); // ⚠️ setPitch 지원되지 않으면 대체 방식 필요
  }

  /// 단순 시뮬레이션용 변환 함수 (실제 FFmpeg pitch shift 미사용 시 활용)
  double _semitoneToRate(int pitch) {
    return (pitch == 0)
        ? 1.0
        : pow(1.05946309436, pitch).toDouble(); // 12-TET 기준
  }
}
