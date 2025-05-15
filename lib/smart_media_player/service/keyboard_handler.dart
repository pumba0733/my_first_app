import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

typedef VoidCallback = void Function();
typedef DurationCallback = void Function(Duration);
typedef DoubleCallback = void Function(double);

class KeyboardHandler {
  final AudioPlayer player;
  final VoidCallback? onTogglePlay;
  final DurationCallback? onSeekRelative;
  final DoubleCallback? onSpeedChange;
  final VoidCallback? onSetLoopStart;
  final VoidCallback? onSetLoopEnd;
  final VoidCallback? onAddComment;
  final VoidCallback? onAddBpm;

  bool _isArrowPressed = false;

  KeyboardHandler({
    required this.player,
    this.onTogglePlay,
    this.onSeekRelative,
    this.onSpeedChange,
    this.onSetLoopStart,
    this.onSetLoopEnd,
    this.onAddComment,
    this.onAddBpm,
  });

  KeyEventResult handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final logicalKey = event.logicalKey;

    // 🔁 ← 방향키: 되감기 1.5x
    if (logicalKey == LogicalKeyboardKey.arrowLeft && player.playing) {
      if (!_isArrowPressed) {
        _isArrowPressed = true;
        player.setSpeed(1.5);
        onSeekRelative?.call(const Duration(seconds: -2));
      }
      return KeyEventResult.handled;
    }

    // ⏩ → 방향키: 빨리감기 1.5x
    if (logicalKey == LogicalKeyboardKey.arrowRight && player.playing) {
      if (!_isArrowPressed) {
        _isArrowPressed = true;
        player.setSpeed(1.5);
        onSeekRelative?.call(const Duration(seconds: 2));
      }
      return KeyEventResult.handled;
    }

    // ↑ 템포 증가
    if (logicalKey == LogicalKeyboardKey.arrowUp) {
      onSpeedChange?.call(0.05);
      return KeyEventResult.handled;
    }

    // ↓ 템포 감소
    if (logicalKey == LogicalKeyboardKey.arrowDown) {
      onSpeedChange?.call(-0.05);
      return KeyEventResult.handled;
    }

    // 숫자키 5~0 → 속도 고정
    const speedMap = {
      LogicalKeyboardKey.digit5: 0.5,
      LogicalKeyboardKey.digit6: 0.6,
      LogicalKeyboardKey.digit7: 0.7,
      LogicalKeyboardKey.digit8: 0.8,
      LogicalKeyboardKey.digit9: 0.9,
      LogicalKeyboardKey.digit0: 1.0,
    };
    if (speedMap.containsKey(logicalKey)) {
      player.setSpeed(speedMap[logicalKey]!);
      return KeyEventResult.handled;
    }

    // ⏯ Space: 재생/정지
    if (logicalKey == LogicalKeyboardKey.space) {
      onTogglePlay?.call();
      return KeyEventResult.handled;
    }

    // 🔁 E → 반복 시작
    if (logicalKey == LogicalKeyboardKey.keyE) {
      onSetLoopStart?.call();
      return KeyEventResult.handled;
    }

    // 🔁 D → 반복 끝
    if (logicalKey == LogicalKeyboardKey.keyD) {
      onSetLoopEnd?.call();
      return KeyEventResult.handled;
    }

    // 💬 S → 코멘트 추가
    if (logicalKey == LogicalKeyboardKey.keyS) {
      onAddComment?.call();
      return KeyEventResult.handled;
    }

    // 🎯 B → BPM 추가
    if (logicalKey == LogicalKeyboardKey.keyB) {
      onAddBpm?.call();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void resetArrowState() {
    _isArrowPressed = false;
    player.setSpeed(1.0);
  }
}
