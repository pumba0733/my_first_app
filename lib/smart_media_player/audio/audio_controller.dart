// lib/smart_media_player/audio/audio_controller.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../service/youtube_loader.dart';

class AudioController extends StatefulWidget {
  final void Function(Duration) onPositionChanged;
  final void Function(Duration) onDurationChanged;
  final AudioPlayer player;
  final YouTubeLoader ytLoader;
  final TextEditingController ytController;
  final VoidCallback onSetLoopStart;
  final VoidCallback onSetLoopEnd;

  const AudioController({
    super.key,
    required this.player,
    required this.ytLoader,
    required this.ytController,
    required this.onPositionChanged,
    required this.onDurationChanged,
    required this.onSetLoopStart,
    required this.onSetLoopEnd,
  });

  @override
  State<AudioController> createState() => _AudioControllerState();
}

class _AudioControllerState extends State<AudioController> {
  bool _isPlaying = false;
  double _speed = 1.0;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    widget.player.playerStateStream.listen((state) {
      setState(() => _isPlaying = state.playing);
    });
    widget.player.durationStream.listen((d) {
      widget.onDurationChanged(d ?? Duration.zero);
    });
    widget.player.positionStream.listen((p) {
      widget.onPositionChanged(p);
    });
    widget.player.speedStream.listen((s) {
      setState(() => _speed = s);
    });
  }

  Future<void> _pickFile() async {
    String? filePath;

    if (Platform.isMacOS) {
      filePath = await _openMacOSFilePicker();
    } else {
      // TODO: 다른 플랫폼 처리 필요 시 추가
    }

    if (filePath != null) {
      print('🎧 선택된 파일 경로: $filePath');
      widget.ytLoader.pause();
      widget.ytLoader.dispose();

      await widget.player.setAudioSource(
        AudioSource.uri(Uri.file(filePath), tag: filePath),
      );
      await widget.player.setVolume(_volume);
      await widget.player.setSpeed(_speed);
    }
  }

  Future<String?> _openMacOSFilePicker() async {
    final script = '''
    set selectedFile to choose file of type {"public.audio"} with prompt "음원 파일을 선택하세요"
    set filePath to POSIX path of selectedFile
    return filePath
  ''';

    try {
      final result = await Process.run('osascript', ['-e', script]);

      if (result.exitCode == 0) {
        final output = result.stdout.toString().trim();
        return output.isNotEmpty ? output : null;
      } else {
        print('❌ stderr: ${result.stderr}');
        return null;
      }
    } catch (e) {
      print('❌ osascript 실행 오류: $e');
      return null;
    }
  }

  void _loadYouTube() {
    final url = widget.ytController.text.trim();
    final controller =
        widget.ytLoader.load(url, context, onReady: () => setState(() {}));
    if (controller == null) return;
    widget.player.stop();
  }

  void _startFastSeek() {
    widget.player.setSpeed(1.5);
    widget.player.play();
  }

  void _stopFastSeek() {
    widget.player.pause();
    widget.player.setSpeed(_speed);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.folder_open),
          label: const Text('음원 파일 선택'),
          onPressed: _pickFile,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: widget.ytController,
          decoration: InputDecoration(
            labelText: '🌐 유튜브 링크 붙여넣기',
            suffixIcon: IconButton(
              icon: const Icon(Icons.play_circle_fill),
              onPressed: _loadYouTube,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTapDown: (_) => _startFastSeek(),
              onTapUp: (_) => _stopFastSeek(),
              onTapCancel: _stopFastSeek,
              child: const Icon(Icons.fast_rewind, size: 36),
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              iconSize: 48,
              onPressed: () {
                setState(() {
                  _isPlaying = !_isPlaying;
                  _isPlaying ? widget.player.play() : widget.player.pause();
                });
              },
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTapDown: (_) => _startFastSeek(),
              onTapUp: (_) => _stopFastSeek(),
              onTapCancel: _stopFastSeek,
              child: const Icon(Icons.fast_forward, size: 36),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Slider(
          value: _speed,
          min: 0.5,
          max: 2.0,
          divisions: 15,
          label: '${_speed.toStringAsFixed(2)}x',
          onChanged: (value) {
            setState(() {
              _speed = value;
              widget.player.setSpeed(_speed);
            });
          },
        ),
        const Text('🔉 볼륨 조절'),
        Slider(
          value: _volume,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          label: '${(_volume * 100).toInt()}%',
          onChanged: (value) {
            setState(() {
              _volume = value;
              widget.player.setVolume(_volume);
            });
          },
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: widget.onSetLoopStart,
              child: const Text('A 지점'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: widget.onSetLoopEnd,
              child: const Text('B 지점'),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}
