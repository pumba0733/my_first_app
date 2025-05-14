import 'package:flutter/material.dart';
import 'smart_media_player/smart_media_player.dart';

void main() {
  runApp(MaterialApp(
    home: SmartMediaPlayerScreen(), // ✅ const 제거됨
    debugShowCheckedModeBanner: false,
  ));
}
