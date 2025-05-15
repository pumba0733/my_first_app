import 'dart:math';

class PitchController {
  int _semitone = 0;

  int get pitchSemitone => _semitone;

  void setPitchSemitone(int value) {
    _semitone = value.clamp(-12, 12);
  }

  /// 피치에 따른 재생 속도 조절값 계산 (반음 단위 → 배속 변환)
  double getRateFromPitch() {
    return pow(1.05946309436, _semitone.toDouble()).toDouble();
  }
}
