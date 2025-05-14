// lib/smart_media_player/service/time_formatter.dart

String formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  final milliseconds = (duration.inMilliseconds.remainder(1000) / 100).floor();
  return '$minutes:$seconds.$milliseconds';
}
