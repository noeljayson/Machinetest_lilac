import 'package:flutter/material.dart';
import 'package:machine_test_lilac/Offline_downloads/offline_downloads.dart';
import 'package:video_player/video_player.dart';

import 'video_controls/video_player_both_widget.dart';

class HomeScreen extends StatefulWidget {
   String vidlist;
   HomeScreen({Key? key, required this. vidlist}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VideoPlayerController controller;

  List<Map> downloadsListMaps = [];

  String url = "";

  String videoposition = "";

  Orientation? target;
  String currentposition = "";
  int currentvideoposition = 0;
  List vidurls = [
    "https://drive.google.com/uc?export=download&id=1IjWLqTDkjZ8tqWdbcln4T23si40sTnJG",
    "https://drive.google.com/uc?export=download&id=1AmfqoCslu85uM0Y6ZGb5ch_br_B-YSd9"
  ];

  @override
  void initState() {
    loadVideoPlayer();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton:  FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () {  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const OfflineDownloads()));
          },
          child: const Icon(Icons.download_for_offline),
        ),

        body: VideoPlayerBothWidget(
          controller: controller,
          vidlist:vidurls,

        ),
      ),
    );
  }

  void loadVideoPlayer() {

    controller = VideoPlayerController.networkUrl(Uri.parse(widget.vidlist.isEmpty?vidurls.first:widget.vidlist.toString()));

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
