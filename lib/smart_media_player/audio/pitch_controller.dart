// lib/smart_media_player/audio/pitch_controller.dart
import 'package:flutter/material.dart';

class PitchController extends ChangeNotifier {
  int _pitchSemitone = 0;

  int get pitchSemitone => _pitchSemitone;

  void setPitchSemitone(int value) {
    _pitchSemitone = value.clamp(-12, 12);
    notifyListeners();
  }
}
