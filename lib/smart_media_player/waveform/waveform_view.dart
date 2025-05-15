// lib/smart_media_player/waveform/waveform_view.dart
import 'package:flutter/material.dart';
import '../audio/bpm_tap_controller.dart';
import 'waveform_painter.dart';
import 'bpm_drag_marker.dart';
import 'playhead_marker.dart';
import 'ab_loop_highlight.dart';
import 'comment_marker.dart';

class WaveformView extends StatefulWidget {
  final List<double> waveform;
  final List<Duration> bpmMarks;
  final Duration currentPosition;
  final Duration totalDuration;
  final Duration? playheadPosition;
  final Duration? loopStart;
  final Duration? loopEnd;
  final BpmTapController bpmController;
  final List<Map<String, dynamic>> comments;
  final void Function(Duration) onSeek;
  final void Function(Duration) onSetLoopStart;
  final void Function(Duration) onSetLoopEnd;
  final void Function(String label, Duration newPosition)?
      onUpdateCommentPosition;

  final Duration position;
  final Duration duration;
  const WaveformView({
    super.key,
    required this.waveform,
    required this.bpmMarks,
    required this.currentPosition,
    required this.totalDuration,
    this.playheadPosition,
    this.loopStart,
    this.loopEnd,
    required this.bpmController,
    required this.comments,
    required this.onSeek,
    required this.onSetLoopStart,
    required this.onSetLoopEnd,
    this.onUpdateCommentPosition,
    required this.position,
    required this.duration,
  });

  @override
  State<WaveformView> createState() => _WaveformViewState();
}

class _WaveformViewState extends State<WaveformView> {
  double? dragStartX;
  double? dragEndX;

  Duration? get _startDuration {
    if (dragStartX == null || dragEndX == null) return null;
    final startRatio = (dragStartX! < dragEndX!) ? dragStartX! : dragEndX!;
    return widget.totalDuration * (startRatio / context.size!.width);
  }

  Duration? get _endDuration {
    if (dragStartX == null || dragEndX == null) return null;
    final endRatio = (dragStartX! > dragEndX!) ? dragStartX! : dragEndX!;
    return widget.totalDuration * (endRatio / context.size!.width);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          dragStartX = details.localPosition.dx;
          dragEndX = null;
        });
      },
      onPanUpdate: (details) {
        setState(() {
          dragEndX = details.localPosition.dx;
        });
      },
      onPanEnd: (_) {
        if (_startDuration != null && _endDuration != null) {
          widget.onSetLoopStart(_startDuration!);
          widget.onSetLoopEnd(_endDuration!);
        }
        setState(() {
          dragStartX = null;
          dragEndX = null;
        });
      },
      child: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: WaveformPainter(
              waveform: widget.waveform,
              bpmMarks: widget.bpmMarks,
              currentPosition: widget.currentPosition,
              totalDuration: widget.totalDuration,
              loopStart: widget.loopStart,
              loopEnd: widget.loopEnd,
              dragStart: _startDuration,
              dragEnd: _endDuration,
            ),
          ),
          if (widget.loopStart != null && widget.loopEnd != null)
            AbLoopHighlight(
              loopStart: widget.loopStart!,
              loopEnd: widget.loopEnd!,
              totalDuration: widget.totalDuration,
            ),
          if (dragStartX != null && dragEndX != null)
            Positioned.fill(
              child: Container(
                color: const Color.fromARGB(64, 100, 149, 237),
              ),
            ),
          if (widget.playheadPosition != null)
            PlayheadMarker(
              position: widget.playheadPosition!,
              duration: widget.totalDuration,
              width: MediaQuery.of(context).size.width,
            ),
          ...widget.bpmMarks.map((mark) {
            return BpmDragMarker(
              position: mark,
              duration: widget.totalDuration,
              onRemove: () => widget.bpmController.removeBPMMark(mark),
            );
          }),
          ...widget.comments.map((comment) {
            final positionRatio = comment['position'].inMilliseconds /
                widget.totalDuration.inMilliseconds;
            final x = MediaQuery.of(context).size.width * positionRatio;

            return CommentMarker(
              label: comment['label'],
              position: comment['position'],
              xPosition: x,
              onUpdatePosition: (newPos) {
                widget.onUpdateCommentPosition?.call(comment['label'], newPos);
              },
            );
          }),
        ],
      ),
    );
  }
}
