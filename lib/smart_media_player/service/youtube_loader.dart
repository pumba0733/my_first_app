// lib/smart_media_player/service/youtube_loader.dart

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubeLoader {
  YoutubePlayerController? controller;

  bool get isInitialized => controller != null;

  /// 유튜브 URL에서 videoId를 추출하고 컨트롤러를 초기화함
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

  /// 컨트롤러 해제
  void dispose() {
    controller?.dispose();
    controller = null;
  }

  /// 재생 중지
  void pause() {
    controller?.pause();
  }
}
