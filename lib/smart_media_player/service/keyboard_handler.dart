// lib/smart_media_player/service/keyboard_handler.dart

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class KeyboardHandler {
  final AudioPlayer player;
  final void Function(double) onSpeedChange;
  final void Function() onTogglePlay;
  final void Function(Duration) onSeekRelative;
  final void Function()? onAddComment;
  final void Function()? onSetLoopStart;
  final void Function()? onSetLoopEnd;

  bool _isArrowPressed = false;

  KeyboardHandler({
    required this.player,
    required this.onSpeedChange,
    required this.onTogglePlay,
    required this.onSeekRelative,
    this.onAddComment,
    this.onSetLoopStart,
    this.onSetLoopEnd,
  });

  bool handleKeyEvent(KeyEvent event) {
    final key = event.logicalKey.keyLabel.toLowerCase();

    // 방향키 ←/→ 누르고 있는 동안만 1.5배속 재생
    if ((key == 'arrow left' || key == 'arrow right') && player.playing) {
      if (event is KeyDownEvent && !_isArrowPressed) {
        _isArrowPressed = true;

        if (key == 'arrow left') {
          onSeekRelative(Duration(milliseconds: -500));
        } else {
          onSeekRelative(Duration(milliseconds: 500));
        }

        player.setSpeed(1.5);
        player.play();
        return true;
      }

      if (event is KeyUpEvent) {
        _isArrowPressed = false;
        player.setSpeed(1.0);
        player.play();
        return true;
      }
    }

    // 일반 단축키는 KeyDown만 처리
    if (event is! KeyDownEvent) return false;

    switch (key) {
      case ' ':
        onTogglePlay();
        return true;

      case 'arrow up':
        onSpeedChange((player.speed + 0.05).clamp(0.5, 2.0));
        return true;

      case 'arrow down':
        onSpeedChange((player.speed - 0.05).clamp(0.5, 2.0));
        return true;

      case '5':
        onSpeedChange(0.5);
        return true;
      case '6':
        onSpeedChange(0.6);
        return true;
      case '7':
        onSpeedChange(0.7);
        return true;
      case '8':
        onSpeedChange(0.8);
        return true;
      case '9':
        onSpeedChange(0.9);
        return true;
      case '0':
        onSpeedChange(1.0);
        return true;

      case 's':
        onAddComment?.call();
        return true;

      case 'e':
        onSetLoopStart?.call();
        return true;

      case 'd':
        onSetLoopEnd?.call();
        return true;
    }

    return false;
  }
}
