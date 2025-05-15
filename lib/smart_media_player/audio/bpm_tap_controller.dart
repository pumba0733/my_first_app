import 'package:flutter/material.dart';

class BpmTapController extends ChangeNotifier {
  final List<Duration> _bpmMarks = [];
  double? _calculatedBPM;

  List<Duration> get bpmMarks => _bpmMarks;
  double? get calculatedBPM => _calculatedBPM;

  void addMark(Duration position) {
    _bpmMarks.add(position);
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
    _calculateBPM();
    notifyListeners();
  }

  void clear() {
    _bpmMarks.clear();
    _calculatedBPM = null;
    notifyListeners();
  }

  void _calculateBPM() {
    if (_bpmMarks.length < 2) {
      _calculatedBPM = null;
      return;
    }
    _bpmMarks.sort((a, b) => a.compareTo(b));
    final intervals = <Duration>[];
    for (var i = 1; i < _bpmMarks.length; i++) {
      intervals.add(_bpmMarks[i] - _bpmMarks[i - 1]);
    }
    final avgInterval =
        intervals.map((d) => d.inMilliseconds).reduce((a, b) => a + b) /
            intervals.length;
    if (avgInterval == 0) {
      _calculatedBPM = null;
    } else {
      _calculatedBPM = 60000 / avgInterval;
    }
  }
}
