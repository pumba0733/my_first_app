// lib/smart_media_player/audio/pitch_controller.dart
import 'package:flutter/material.dart';

class PitchController extends ChangeNotifier {
  double _pitch = 0.0;

  double get pitch => _pitch;

  void setPitch(double value) {
    _pitch = value.clamp(-6.0, 6.0);
    notifyListeners();
  }
}
