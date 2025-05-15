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

    // ←/→ 방향키 누르고 있는 동안 1.5배속 재생
    if ((key == 'arrow left' || key == 'arrow right') && player.playing) {
      if (event is KeyDownEvent && !_isArrowPressed) {
        _isArrowPressed = true;

        if (key == 'arrow left') {
          onSeekRelative(Duration(milliseconds: -500));
        } else {
          onSeekRelative(Duration(milliseconds: 500));
        }

        player.setSpeed(1.5);
      } else if (event is KeyUpEvent) {
        player.setSpeed(1.0);
        _isArrowPressed = false;
      }

      return true;
    }

    // 템포 ↑↓ 조절
    if (event is KeyDownEvent) {
      if (key == 'arrow up') {
        onSpeedChange(0.05);
        return true;
      } else if (key == 'arrow down') {
        onSpeedChange(-0.05);
        return true;
      }
    }

    if (event is KeyDownEvent && key == ' ') {
      onTogglePlay();
      return true;
    }

    if (event is KeyDownEvent && key == 's' && onAddComment != null) {
      onAddComment!();
      return true;
    }

    if (event is KeyDownEvent && key == 'e' && onSetLoopStart != null) {
      onSetLoopStart!();
      return true;
    }

    if (event is KeyDownEvent && key == 'd' && onSetLoopEnd != null) {
      onSetLoopEnd!();
      return true;
    }

    return false;
  }
}
