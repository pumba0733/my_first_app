// lib/smart_media_player/service/youtube_loader.dart

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubeLoader {
  YoutubePlayerController? controller;

  bool get isInitialized => controller != null;

  YoutubePlayerController? load(String url, BuildContext context,
      {VoidCallback? onReady}) {
    final videoId = YoutubePlayer.convertUrlToId(url);
    if (videoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ 유효하지 않은 유튜브 링크입니다')),
      );
      return null;
    }

    controller?.dispose();
    controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: true),
    );

    if (onReady != null) {
      onReady();
    }

    return controller;
  }

  // ✅ 오류 해결용 래퍼 함수
  YoutubePlayerController? loadFromUrl(String url, BuildContext context) {
    return load(url, context);
  }
}
