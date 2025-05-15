import 'package:flutter/material.dart';
import 'smart_media_player/smart_media_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    home: SmartMediaPlayerScreen(),
    debugShowCheckedModeBanner: false,
  ));
}
