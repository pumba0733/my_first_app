// lib/smart_media_player/audio/bpm_tap_controller.dart
import 'package:flutter/material.dart';

class BpmTapController extends ChangeNotifier {
  final List<Duration> _bpmMarks = [];
  double? _calculatedBPM;

  List<Duration> get bpmMarks => List.unmodifiable(_bpmMarks);
  double? get calculatedBPM => _calculatedBPM;

  void addMark(Duration position) {
    _bpmMarks.add(position);
    _bpmMarks.sort((a, b) => a.inMilliseconds.compareTo(b.inMilliseconds));
    _calculateBPM();
    notifyListeners();
  }

  void removeMark(Duration position) {
    _bpmMarks.remove(position);
    _calculateBPM();
    notifyListeners();
  }

  void updateMark(int index, Duration newPosition) {
    if (index < 0 || index >= _bpmMarks.length) return;
    _bpmMarks[index] = newPosition;
    _bpmMarks.sort((a, b) => a.inMilliseconds.compareTo(b.inMilliseconds));
    _calculateBPM();
    notifyListeners();
  }

  void _calculateBPM() {
    if (_bpmMarks.length < 2) {
      _calculatedBPM = null;
      return;
    }

    final intervals = <int>[];
    for (int i = 1; i < _bpmMarks.length; i++) {
      intervals.add(
        _bpmMarks[i].inMilliseconds - _bpmMarks[i - 1].inMilliseconds,
      );
    }

    final avgIntervalMs = intervals.reduce((a, b) => a + b) / intervals.length;
    _calculatedBPM = avgIntervalMs == 0 ? null : 60000 / avgIntervalMs;
  }
}
