import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class OfflineVideoDisplay extends StatefulWidget {
  const OfflineVideoDisplay({Key? key}) : super(key: key);

  @override
  State<OfflineVideoDisplay> createState() => _OfflineVideoDisplayState();
}

class _OfflineVideoDisplayState extends State<OfflineVideoDisplay> {
  late VideoPlayerController controller;

  @override
  @override
  void initState() {
    loadVideoPlayer();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(
          children: [
            VideoPlayer(controller),
          ],
        ),
      ),
    );
  }

  void loadVideoPlayer() {
    controller = VideoPlayerController.file(File(
        "/storage/emulated/0/Android/data/com.example.machine_test_lilac/filesvideo1/video1.mp4"));
    controller.play();
    controller.addListener(() {
      if (mounted) {
        setState(() {
          // Your state change code goes here
        });
      }
    });

    controller.initialize().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
  }
}
