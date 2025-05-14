// lib/smart_media_player/smart_media_player.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import 'audio/audio_controller.dart';
import 'waveform/waveform_view.dart';
import 'audio/bpm_tap_controller.dart';
import 'service/youtube_loader.dart';
import 'service/keyboard_handler.dart';
import 'service/custom_waveform_generator.dart';
import 'audio/pitch_controller.dart';
import 'ui/pitch_slider.dart';
import 'waveform/comment_marker.dart';

class SmartMediaPlayerScreen extends StatefulWidget {
  const SmartMediaPlayerScreen({super.key});

  @override
  State<SmartMediaPlayerScreen> createState() => _SmartMediaPlayerScreenState();
}

class _SmartMediaPlayerScreenState extends State<SmartMediaPlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  final YouTubeLoader _ytLoader = YouTubeLoader();
  final TextEditingController _ytController = TextEditingController();
  final BpmTapController _bpmController = BpmTapController();
  final PitchController _pitchController = PitchController();
  late KeyboardHandler _keyboardHandler;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  List<double> _waveform = [];
  final List<Map<String, dynamic>> _comments = [];
  Duration? _playheadPosition;
  Duration? _loopStart;
  Duration? _loopEnd;
  final TextEditingController _bottomCommentController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    _keyboardHandler = KeyboardHandler(
      player: _player,
      onSpeedChange: (speed) {
        setState(() => _player.setSpeed(speed));
      },
      onTogglePlay: () {
        setState(() {
          if (_player.playing) {
            _player.pause();
          } else {
            if (_playheadPosition != null) {
              _player.seek(_playheadPosition!);
            }
            _player.play();
          }
        });
      },
      onSeekRelative: (offset) {
        final newPosition = _player.position + offset;
        final clampedPosition = newPosition < Duration.zero
            ? Duration.zero
            : (newPosition > _duration ? _duration : newPosition);

        _player.seek(clampedPosition);
        setState(() {
          _playheadPosition = clampedPosition;
        });
      },
      onAddComment: () {
        final label = _nextCommentLabel();
        _comments.add({
          'label': label,
          'memo': '',
          'position': _position,
        });
        setState(() {});
      },
      onSetLoopStart: () {
        setState(() => _loopStart = _position);
      },
      onSetLoopEnd: () {
        setState(() => _loopEnd = _position);
      },
    );

    HardwareKeyboard.instance.addHandler(_keyboardHandler.handleKeyEvent);

    _player.positionStream.listen((pos) {
      setState(() => _position = pos);
      if (_loopStart != null && _loopEnd != null && pos >= _loopEnd!) {
        _player.seek(_loopStart!);
      }
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyboardHandler.handleKeyEvent);
    super.dispose();
  }

  String _nextCommentLabel() {
    final existingLabels = _comments.map((c) => c['label'] as String).toSet();
    for (var codeUnit = 'a'.codeUnitAt(0);
        codeUnit <= 'z'.codeUnitAt(0);
        codeUnit++) {
      final label = String.fromCharCode(codeUnit);
      if (!existingLabels.contains(label)) return label;
    }
    return '?';
  }

  void _reassignCommentLabels() {
    _comments.sort((a, b) =>
        (a['position'] as Duration).compareTo(b['position'] as Duration));
    for (int i = 0; i < _comments.length; i++) {
      _comments[i]['label'] = String.fromCharCode('a'.codeUnitAt(0) + i);
    }
  }

  void _editOrDeleteComment(Map<String, dynamic> comment) {
    final memoController = TextEditingController(text: comment['memo'] ?? '');
    final labelController = TextEditingController(text: comment['label'] ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💬 코멘트 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: '코멘트 이름'),
            ),
            TextField(
              controller: memoController,
              decoration: const InputDecoration(labelText: '메모 입력'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _comments.remove(comment);
                _reassignCommentLabels();
              });
              Navigator.pop(context);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                comment['label'] = labelController.text;
                comment['memo'] = memoController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showGuideDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🧠 Smart Media Player 단축키 안내'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('[▶ 재생/정지] 스페이스바'),
            Text('[← / →] 1.5배속 이동'),
            Text('[↑ / ↓] 속도 5% 느리게/빠르게'),
            Text('[5~0] 속도 50~100% 설정'),
            Text('[S] 현재 위치에 코멘트 추가'),
            Text('[E / D] 반복 구간 시작/종료'),
            Text('[B] BPM 마커 추가'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎧 Smart Media Player')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showGuideDialog,
        child: const Icon(Icons.help_outline),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            ListView(
              children: [
                AudioController(
                  player: _player,
                  ytLoader: _ytLoader,
                  ytController: _ytController,
                  onPositionChanged: (p) => setState(() {
                    _position = p;
                    _playheadPosition ??= p;
                  }),
                  onDurationChanged: (d) async {
                    setState(() => _duration = d);
                    if (_ytLoader.isInitialized) return;
                    final path =
                        _player.audioSource?.sequence.first.tag as String?;
                    if (path != null) {
                      final generator = createWaveformGenerator();
                      final wave = await generator.generateWaveform(
                          path, path.split('/').last);
                      setState(() => _waveform = wave);
                    }
                  },
                  onSetLoopStart: () => setState(() => _loopStart = _position),
                  onSetLoopEnd: () => setState(() => _loopEnd = _position),
                ),
                const SizedBox(height: 16),
                if (_waveform.isNotEmpty)
                  WaveformView(
                    waveform: _waveform,
                    position: _position,
                    duration: _duration,
                    playheadPosition: _playheadPosition,
                    loopStart: _loopStart,
                    loopEnd: _loopEnd,
                    bpmController: _bpmController,
                    comments: _comments,
                    onSeek: (newPosition) {
                      _player.seek(newPosition);
                      setState(() => _playheadPosition = newPosition);
                    },
                    onSetLoopStart: (value) =>
                        setState(() => _loopStart = value),
                    onSetLoopEnd: (value) => setState(() => _loopEnd = value),
                  ),
                const SizedBox(height: 16),
                PitchSlider(
                  pitch: _pitchController.pitch,
                  onChanged: (value) {
                    setState(() {
                      _pitchController.setPitch(value);
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bottomCommentController,
                  decoration: const InputDecoration(
                    labelText: '📝 수업 코멘트 입력',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 40),
              ],
            ),
            if (_waveform.isNotEmpty)
              ..._comments.map((comment) {
                final ratio = comment['position'].inMilliseconds /
                    _duration.inMilliseconds;
                final x = ratio * MediaQuery.of(context).size.width;
                return CommentMarker(
                  xPosition: x,
                  label: comment['label'],
                  onTap: () => _editOrDeleteComment(comment),
                );
              }),
          ],
        ),
      ),
    );
  }
}
