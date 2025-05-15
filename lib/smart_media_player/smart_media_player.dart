import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import 'waveform/waveform_view.dart';
import 'audio/bpm_tap_controller.dart';
import 'service/youtube_loader.dart';
import 'service/keyboard_handler.dart';
import 'audio/pitch_controller.dart';
import 'ui/pitch_slider.dart';
import 'ui/tempo_slider.dart';
import 'ui/volume_slider.dart';

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

  double _tempo = 1.0;
  double _volume = 1.0;
  bool _isPlaying = false;

  final List<double> _waveformData = [];
  final List<Map<String, dynamic>> _comments = [];
  Duration? _loopStart;
  Duration? _loopEnd;
  String _newComment = "";

  late KeyboardHandler _keyboardHandler;

  void _pickFile() {
    // TODO: 로컬 파일 선택 구현
    debugPrint("파일 선택 기능 실행됨 (미구현)");
  }

  void _loadYouTube() {
    _ytLoader.loadFromUrl(_ytController.text.trim(), context);
  }

  @override
  void initState() {
    super.initState();
    _keyboardHandler = KeyboardHandler(
      player: _player,
      onTogglePlay: _togglePlay,
      onSeekRelative: _seekRelative,
      onSpeedChange: _adjustSpeedBy,
    );
    HardwareKeyboard.instance.addHandler(_keyboardHandler.handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyboardHandler.handleKeyEvent);
    _player.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    setState(() {
      _isPlaying = _player.playing;
    });
  }

  void _seekRelative(Duration offset) {
    final newPos = _player.position + offset;
    _player.seek(newPos);
  }

  void _adjustSpeedBy(double delta) {
    setState(() {
      _tempo = (_tempo + delta).clamp(0.1, 2.0);
      _player.setSpeed(_tempo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SmartMediaPlayer v3.3")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.folder_open),
              label: const Text('음원 파일 선택'),
              onPressed: _pickFile,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ytController,
              decoration: InputDecoration(
                labelText: '🌐 유튜브 링크 붙여넣기',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.play_circle_fill),
                  onPressed: _loadYouTube,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTapDown: (_) => _player.setSpeed(1.5),
                  onTapUp: (_) => _player.setSpeed(_tempo),
                  child: const Icon(Icons.fast_rewind, size: 32),
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 48,
                  onPressed: _togglePlay,
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  onTapDown: (_) => _player.setSpeed(1.5),
                  onTapUp: (_) => _player.setSpeed(_tempo),
                  child: const Icon(Icons.fast_forward, size: 32),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration =
                      _player.duration ?? const Duration(seconds: 1);

                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        height: 120,
                        child: WaveformView(
                          waveform: _waveformData,
                          bpmMarks: _bpmController.bpmMarks,
                          currentPosition: position,
                          totalDuration: duration,
                          playheadPosition: position,
                          loopStart: _loopStart,
                          loopEnd: _loopEnd,
                          bpmController: _bpmController,
                          comments: _comments,
                          position: _player.position,
                          duration: _player.duration ?? Duration.zero,
                          onSeek: (pos) => _player.seek(pos),
                          onSetLoopStart: (pos) =>
                              setState(() => _loopStart = pos),
                          onSetLoopEnd: (pos) => setState(() => _loopEnd = pos),
                          onUpdateCommentPosition: (label, newPos) {
                            setState(() {
                              final index = _comments
                                  .indexWhere((c) => c['label'] == label);
                              if (index != -1) {
                                _comments[index]['position'] = newPos;
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Text('⏱ 템포'),
                                TempoSlider(
                                  tempo: _tempo,
                                  onChanged: (value) {
                                    setState(() {
                                      _tempo = value;
                                      _player.setSpeed(_tempo);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                const Text('🔉 볼륨'),
                                VolumeSlider(
                                  volume: _volume,
                                  onChanged: (value) {
                                    setState(() {
                                      _volume = value;
                                      _player.setVolume(_volume);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: PitchSlider(
                              pitchSemitone: _pitchController.pitchSemitone,
                              onChanged: (value) {
                                setState(() {
                                  _pitchController.setPitchSemitone(value);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Wrap(
                            spacing: 6,
                            children: [50, 60, 70, 80, 90, 100].map((percent) {
                              return ElevatedButton(
                                onPressed: () {
                                  final newTempo = percent / 100.0;
                                  setState(() {
                                    _tempo = newTempo;
                                    _player.setSpeed(_tempo);
                                  });
                                },
                                child: Text('$percent%'),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: '💬 코멘트 입력',
                          border: OutlineInputBorder(), // 깨짐 방지
                        ),
                        onSubmitted: (text) {
                          setState(() {
                            final label =
                                String.fromCharCode(97 + _comments.length);
                            _comments.add({
                              "label": label,
                              "position": _player.position,
                              "text": text
                            });
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
