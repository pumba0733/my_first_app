import 'package:flutter/material.dart';
import 'package:smart_media_player/waveform/ab_loop_highlight.dart';
import 'package:smart_media_player/waveform/bpm_drag_marker.dart';
import 'package:smart_media_player/waveform/comment_marker.dart';
import 'package:smart_media_player/waveform/playhead_marker.dart';
import 'package:smart_media_player/waveform/waveform_painter.dart';

import '../audio/bpm_tap_controller.dart';

class WaveformView extends StatefulWidget {
  final List<double> waveform;
  final Duration position;
  final Duration duration;
  final List<Map<String, dynamic>> comments;
  final List<Duration> bpmMarks;
  final Duration currentPosition;
  final Duration totalDuration;
  final BpmTapController bpmController;
  final Duration? loopStart;
  final Duration? loopEnd;
  final Duration playheadPosition;
  final Function(Duration) onSeek;
  final Function(Duration) onSetLoopStart;
  final Function(Duration) onSetLoopEnd;
  final Function(String, Duration) onUpdateCommentPosition;

  const WaveformView({
    super.key,
    required this.waveform,
    required this.position,
    required this.duration,
    required this.comments,
    required this.bpmMarks,
    required this.currentPosition,
    required this.totalDuration,
    required this.bpmController,
    required this.loopStart,
    required this.loopEnd,
    required this.playheadPosition,
    required this.onSeek,
    required this.onSetLoopStart,
    required this.onSetLoopEnd,
    required this.onUpdateCommentPosition,
  });

  @override
  State<WaveformView> createState() => _WaveformViewState();
}

class _WaveformViewState extends State<WaveformView> {
  Duration? _clickStartPosition;
  bool _isDraggingLoop = false;
  double _zoom = 1.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * _zoom;
    final height = 120.0;

    final loopStartRatio = widget.loopStart != null
        ? widget.loopStart!.inMilliseconds / widget.duration.inMilliseconds
        : null;
    final loopEndRatio = widget.loopEnd != null
        ? widget.loopEnd!.inMilliseconds / widget.duration.inMilliseconds
        : null;

    return GestureDetector(
      onTapDown: (details) {
        final localX = details.localPosition.dx;
        final ratio = localX / width;
        final newPos = Duration(
            milliseconds: (widget.duration.inMilliseconds * ratio).round());
        widget.onSeek(newPos);
      },
      onHorizontalDragStart: (details) {
        setState(() {
          _isDraggingLoop = true;
          final dx = details.localPosition.dx;
          final ratio = dx / width;
          _clickStartPosition = Duration(
              milliseconds: (widget.duration.inMilliseconds * ratio).round());
        });
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          final dx = details.localPosition.dx;
          final ratio = dx / width;
          final newPos = Duration(
              milliseconds: (widget.duration.inMilliseconds * ratio).round());
          if (_clickStartPosition != null) {
            if (newPos > _clickStartPosition!) {
              widget.onSetLoopStart(_clickStartPosition!);
              widget.onSetLoopEnd(newPos);
            } else {
              widget.onSetLoopStart(newPos);
              widget.onSetLoopEnd(_clickStartPosition!);
            }
          }
        });
      },
      onHorizontalDragEnd: (_) {
        setState(() {
          _isDraggingLoop = false;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
        ),
        width: width,
        height: height,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(width, height),
              painter: WaveformPainter(
                waveform: widget.waveform,
                position: widget.position,
                duration: widget.duration,
                loopStart: widget.loopStart,
                loopEnd: widget.loopEnd,
                bpmMarks: widget.bpmMarks,
              ),
            ),
            if (widget.loopStart != null &&
                widget.loopEnd != null &&
                !_isDraggingLoop)
              AbLoopHighlight(
                startRatio: loopStartRatio ?? 0.0,
                endRatio: loopEndRatio ?? 0.0,
                waveformWidth: width,
                waveformHeight: height,
              ),
            PlayheadMarker(
              position: widget.playheadPosition,
              duration: widget.duration,
              waveformWidth: width,
              waveformHeight: height,
              isPlaybackStart: false,
            ),
            for (var comment in widget.comments)
              CommentMarker(
                label: comment['label'],
                position: comment['position'],
                xPosition: (comment['position'].inMilliseconds /
                        widget.duration.inMilliseconds) *
                    width,
                onUpdatePosition: (newPos) =>
                    widget.onUpdateCommentPosition(comment['label'], newPos),
              ),
            for (var mark in widget.bpmMarks)
              BpmDragMarker(
                bpmController: widget.bpmController,
                position: mark,
                duration: widget.duration,
                waveformWidth: width,
                waveformHeight: height,
                onUpdate: () {
                  setState(() {});
                },
              ),
          ],
        ),
      ),
    );
  }
}
