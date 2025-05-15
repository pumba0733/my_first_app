import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';

class AudioController extends StatefulWidget {
  final AudioPlayer player;
  final TextEditingController ytController;
  final double speed;
  final double volume;
  final Function(double) onSpeedChanged;
  final Function(double) onVolumeChanged;
  final VoidCallback onYouTubeLoad;
  final VoidCallback onFilePicked;

  const AudioController({
    super.key,
    required this.player,
    required this.ytController,
    required this.speed,
    required this.volume,
    required this.onSpeedChanged,
    required this.onVolumeChanged,
    required this.onYouTubeLoad,
    required this.onFilePicked,
  });

  @override
  State<AudioController> createState() => _AudioControllerState();
}

class _AudioControllerState extends State<AudioController> {
  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      await widget.player.setFilePath(file.path);
      widget.onFilePicked();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.folder_open),
          label: const Text('📁 음원 파일 선택'),
          onPressed: _pickFile,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.ytController,
          decoration: InputDecoration(
            labelText: '🌐 유튜브 링크 붙여넣기',
            suffixIcon: IconButton(
              icon: const Icon(Icons.play_circle_fill),
              onPressed: widget.onYouTubeLoad,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text('⏱ 템포'),
                  Slider(
                    value: widget.speed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 150,
                    label: '${(widget.speed * 100).toInt()}%',
                    onChanged: widget.onSpeedChanged,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text('🔉 볼륨'),
                  Slider(
                    value: widget.volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    label: '${(widget.volume * 100).toInt()}%',
                    onChanged: widget.onVolumeChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
