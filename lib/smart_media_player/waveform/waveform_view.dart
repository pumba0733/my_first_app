import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../audio/bpm_tap_controller.dart';
import 'waveform_painter.dart';
import 'bpm_drag_marker.dart';
import '../ui/zoom_controls.dart';
import 'playhead_marker.dart';
import 'ab_loop_highlight.dart';

class WaveformView extends StatefulWidget {
  final List<double> waveform;
  final Duration position;
  final Duration duration;
  final Duration? playheadPosition;
  final BpmTapController bpmController;
  final List<Map<String, dynamic>> comments;
  final void Function(Duration) onSeek;

  const WaveformView({
    super.key,
    required this.waveform,
    required this.position,
    required this.duration,
    required this.playheadPosition,
    required this.bpmController,
    required this.comments,
    required this.onSeek,
  });

  @override
  State<WaveformView> createState() => _WaveformViewState();
}

class _WaveformViewState extends State<WaveformView> {
  final FocusNode _focusNode = FocusNode();
  double _zoom = 1.0;

  Duration? _loopStart;
  Duration? _loopEnd;
  bool _isDraggingLoop = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
    Future.delayed(Duration.zero, () => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    super.dispose();
  }

  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    final key = event.logicalKey.keyLabel.toLowerCase();
    switch (key) {
      case 'b':
        widget.bpmController.addMark(widget.position);
        return true;
      case 'e':
        setState(() => _loopStart = widget.position);
        return true;
      case 'd':
        setState(() => _loopEnd = widget.position);
        return true;
      default:
        return false;
    }
  }

  List<Widget> _buildMarkers(double width) {
    return List.generate(widget.bpmController.bpmMarks.length, (index) {
      final mark = widget.bpmController.bpmMarks[index];
      final ratio = mark.inMilliseconds / widget.duration.inMilliseconds;
      final x = ratio * width;

      return BpmDragMarker(
        xPosition: x,
        height: 80,
        onDragStart: () {}, // 필요 시 null로 대체 가능
        onDragUpdate: (newX) {
          final newRatio = newX / width;
          final newPosition = Duration(
            milliseconds: (widget.duration.inMilliseconds * newRatio)
                .clamp(0, widget.duration.inMilliseconds)
                .toInt(),
          );
          widget.bpmController.updateMark(index, newPosition);
        },
        onDragEnd: () {}, // 필요 시 null로 대체 가능
        onDelete: () => setState(() => widget.bpmController.removeMark(mark)),
      );
    });
  }

  void _handleWaveformTap(TapDownDetails details, double width) {
    final localX = details.localPosition.dx;
    final ratio = localX / width;
    final newDuration = Duration(
      milliseconds: (widget.duration.inMilliseconds * ratio).toInt(),
    );
    widget.onSeek(newDuration);
  }

  void _handleDragStart(DragStartDetails details, double width) {
    setState(() {
      _isDraggingLoop = true;
      final localX = details.localPosition.dx;
      final ratio = localX / width;
      _loopStart = Duration(
        milliseconds: (widget.duration.inMilliseconds * ratio).toInt(),
      );
      _loopEnd = null; // 일단 초기화
    });
  }

  void _handleDragUpdate(DragUpdateDetails details, double width) {
    if (!_isDraggingLoop || _loopStart == null) return;

    final localX = details.localPosition.dx;
    final ratio = localX / width;
    final newEnd = Duration(
      milliseconds: (widget.duration.inMilliseconds * ratio)
          .clamp(0, widget.duration.inMilliseconds)
          .toInt(),
    );

    setState(() {
      _loopEnd = newEnd;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() => _isDraggingLoop = false);
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
              setState(() {
                _zoom = (_zoom + 0.2).clamp(0.5, 5.0);
              });
            },
            onZoomOut: () {
              setState(() {
                _zoom = (_zoom - 0.2).clamp(0.5, 5.0);
              });
            },
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth * _zoom;
              return GestureDetector(
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
                          loopStart: _loopStart,
                          loopEnd: _loopEnd,
                        ),
                      ),
                      ..._buildMarkers(width),
                      PlayheadMarker(
                        position: widget.position,
                        duration: widget.duration,
                        width: width,
                      ),
                      AbLoopHighlight(
                        loopStart: _loopStart,
                        loopEnd: _loopEnd,
                        totalDuration: widget.duration,
                        waveformWidth: width,
                      ),
                    ],
                  ),
                ),
              );
            },
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
      ),
    );
  }
}
