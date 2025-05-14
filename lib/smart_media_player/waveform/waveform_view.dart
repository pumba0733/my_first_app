// lib/smart_media_player/waveform/waveform_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../audio/bpm_tap_controller.dart';
import 'waveform_painter.dart';
import 'bpm_drag_marker.dart';
import '../ui/zoom_controls.dart';
import 'playhead_marker.dart';
import 'ab_loop_highlight.dart';
import 'waveform_timeline.dart'; // 추가

class WaveformView extends StatefulWidget {
  final List<double> waveform;
  final Duration position;
  final Duration duration;
  final Duration? playheadPosition;
  final Duration? loopStart;
  final Duration? loopEnd;
  final BpmTapController bpmController;
  final List<Map<String, dynamic>> comments;
  final void Function(Duration) onSeek;
  final void Function(Duration) onSetLoopStart;
  final void Function(Duration) onSetLoopEnd;

  const WaveformView({
    super.key,
    required this.waveform,
    required this.position,
    required this.duration,
    required this.playheadPosition,
    required this.loopStart,
    required this.loopEnd,
    required this.bpmController,
    required this.comments,
    required this.onSeek,
    required this.onSetLoopStart,
    required this.onSetLoopEnd,
  });

  @override
  State<WaveformView> createState() => _WaveformViewState();
}

class _WaveformViewState extends State<WaveformView> {
  final FocusNode _focusNode = FocusNode();
  double _zoom = 1.0;

  Duration? _clickStartPosition;
  Duration? _dragEndPosition;
  bool _isDraggingLoop = false;

  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
    Future.delayed(Duration.zero, () => _focusNode.requestFocus());

    _player = AudioPlayer();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    _player.dispose();
    super.dispose();
  }

  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final key = event.logicalKey.keyLabel.toLowerCase();

    if (key == 'b') {
      widget.bpmController.addMark(widget.position);
      return true;
    }

    if (key == 'e') {
      if (_clickStartPosition != null) {
        widget.onSetLoopStart(_clickStartPosition!);
      } else {
        widget.onSetLoopStart(widget.position);
      }
      return true;
    }

    if (key == 'd') {
      if (_dragEndPosition != null) {
        widget.onSetLoopEnd(_dragEndPosition!);
      } else {
        widget.onSetLoopEnd(widget.position);
      }
      return true;
    }

    return false;
  }

  void _handleWaveformTap(TapDownDetails details, double width) {
    final localX = details.localPosition.dx;
    final ratio = localX / width;
    final newDuration = Duration(
      milliseconds: (widget.duration.inMilliseconds * ratio).toInt(),
    );

    _player.pause();
    setState(() => _clickStartPosition = newDuration);
    widget.onSeek(newDuration);
  }

  void _handleDragStart(DragStartDetails details, double width) {
    _player.pause();
    setState(() {
      _isDraggingLoop = true;
      final localX = details.localPosition.dx;
      final ratio = localX / width;
      _clickStartPosition = Duration(
        milliseconds: (widget.duration.inMilliseconds * ratio).toInt(),
      );
      _dragEndPosition = null;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details, double width) {
    if (!_isDraggingLoop || _clickStartPosition == null) return;
    final localX = details.localPosition.dx;
    final ratio = localX / width;
    final end = Duration(
      milliseconds: (widget.duration.inMilliseconds * ratio)
          .clamp(0, widget.duration.inMilliseconds)
          .toInt(),
    );
    setState(() {
      _dragEndPosition = end;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() => _isDraggingLoop = false);
    if (_clickStartPosition != null && _dragEndPosition != null) {
      final start = _clickStartPosition!;
      final end = _dragEndPosition!;
      if (end > start) {
        widget.onSetLoopStart(start);
        widget.onSetLoopEnd(end);
      }
    }
  }

  List<Widget> _buildMarkers(double width) {
    final bpmWidgets = widget.bpmController.bpmMarks.map((mark) {
      final ratio = mark.inMilliseconds / widget.duration.inMilliseconds;
      final x = ratio * width;

      return BpmDragMarker(
        xPosition: x,
        height: 80,
        onDragStart: () {},
        onDragUpdate: (newX) {
          final newRatio = newX / width;
          final newPosition = Duration(
            milliseconds: (widget.duration.inMilliseconds * newRatio)
                .clamp(0, widget.duration.inMilliseconds)
                .toInt(),
          );
          widget.bpmController.updateMark(
            widget.bpmController.bpmMarks.indexOf(mark),
            newPosition,
          );
        },
        onDragEnd: () {},
        onDelete: () => widget.bpmController.removeMark(mark),
      );
    });

    return bpmWidgets.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      child: Column(
        children: [
          ZoomControls(
            zoomLevel: _zoom,
            onZoomIn: () {
              setState(() => _zoom = (_zoom + 0.2).clamp(1.0, 5.0));
            },
            onZoomOut: () {
              setState(() => _zoom = (_zoom - 0.2).clamp(1.0, 5.0));
            },
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth * _zoom;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) => _handleWaveformTap(details, width),
                    onHorizontalDragStart: (details) =>
                        _handleDragStart(details, width),
                    onHorizontalDragUpdate: (details) =>
                        _handleDragUpdate(details, width),
                    onHorizontalDragEnd: _handleDragEnd,
                    child: SizedBox(
                      height: 80,
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: Size(width, 80),
                            painter: WaveformPainter(
                              waveform: widget.waveform,
                              bpmMarks: widget.bpmController.bpmMarks,
                              currentPosition: widget.position,
                              totalDuration: widget.duration,
                              loopStart: widget.loopStart,
                              loopEnd: widget.loopEnd,
                              dragStart: _clickStartPosition,
                              dragEnd: _dragEndPosition,
                            ),
                          ),
                          ..._buildMarkers(width),
                          if (_clickStartPosition != null)
                            PlaybackStartMarker(
                              startPosition: _clickStartPosition,
                              duration: widget.duration,
                              width: width,
                            ),
                          PlayheadMarker(
                            position: widget.position,
                            duration: widget.duration,
                            width: width,
                          ),
                          AbLoopHighlight(
                            loopStart: widget.loopStart,
                            loopEnd: widget.loopEnd,
                            totalDuration: widget.duration,
                            waveformWidth: width,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  WaveformTimeline(
                    duration: widget.duration,
                    zoom: _zoom,
                    width: width,
                  ),
                  const SizedBox(height: 12),
                  if (widget.bpmController.calculatedBPM != null)
                    Text(
                      '🟡 실시간 BPM: ${widget.bpmController.calculatedBPM!.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
