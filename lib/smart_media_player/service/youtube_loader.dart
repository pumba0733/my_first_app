import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubeLoader {
  YoutubePlayerController? _controller;

  void loadFromUrl(String url, BuildContext context) {
    final videoId = YoutubePlayer.convertUrlToId(url);

    if (videoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ 유효하지 않은 유튜브 링크입니다.')),
      );
      return;
    }

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🎬 유튜브 영상 재생"),
        content: AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubePlayer(controller: _controller!),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _controller?.pause();
              _controller?.dispose();
              Navigator.of(context).pop();
            },
            child: const Text('닫기'),
          )
        ],
      ),
    );
  }

  void pause() {
    _controller?.pause();
  }

  void dispose() {
    _controller?.dispose();
  }
}
