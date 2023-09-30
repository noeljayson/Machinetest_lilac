import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';


import 'package:fluttertoast/fluttertoast.dart';
import 'package:machine_test_lilac/home_screen.dart';
import 'package:machine_test_lilac/register_page.dart';
import 'package:machine_test_lilac/video_controls/advanced_overlay_widget.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class VideoPlayerBothWidget extends StatefulWidget {
  VideoPlayerController controller;
  List<dynamic> vidlist;
  bool initclicked;

  VideoPlayerBothWidget({
    Key? key,
    required this.controller,required this.vidlist, required this.initclicked,
  }) : super(key: key);

  @override
  _VideoPlayerBothWidgetState createState() => _VideoPlayerBothWidgetState();
}

class _VideoPlayerBothWidgetState extends State<VideoPlayerBothWidget> {
  Orientation? target;

  bool isfavourites = false;

  final ReceivePort _port = ReceivePort();
  List<Map> downloadsListMaps = [];

  bool istapped = false;

  List<int> ids = [];

  double progress = 0.0;
  Map<int, int> speed = {};

  String isexist = "";
  String iswatchlistexist = "";
  String currentposition = "";
  bool ispaused = false;
  int currentvideoposition = 0;
  bool isclicked=false;

  @override
  void initState() {
    super.initState();

    NativeDeviceOrientationCommunicator()
        .onOrientationChanged(useSensor: false)
        .listen((event) {
      final isPortrait = event == NativeDeviceOrientation.portraitUp;
      final isLandscape = event == NativeDeviceOrientation.landscapeLeft ||
          event == NativeDeviceOrientation.landscapeRight;
      final isTargetPortrait = target == Orientation.portrait;
      final isTargetLandscape = target == Orientation.landscape;

      if (isPortrait && isTargetPortrait || isLandscape && isTargetLandscape) {
        target;

        if (target == Orientation.portrait) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
        } else {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
          ]);
        }
      }
    });

    _bindBackgroundIsolate();

    getcallback();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    widget.controller.dispose();
    //calldisposeapi();
    super.dispose();
  }

  void setOrientation(bool isPortrait) {
    if (isPortrait) {
      Wakelock.disable();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
      //SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    } else {
      Wakelock.enable();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      //SystemChrome.setEnabledSystemUIOverlays([]);
    }
  }

  @override
  Widget build(BuildContext context) => buildVideoImage();

  Widget buildVideoPlayer() {
    final video = AspectRatio(
      aspectRatio: widget.controller.value.aspectRatio,
      child: Stack(
        children: [

          VideoPlayer(widget.controller),
          target == Orientation.portrait?   const Positioned(
            top: 30,
            left: 30,
              child: Icon(Icons.menu,color: Colors.white,size: 100)):Container()

        ],
      ),
    );

    return buildFullScreen(child: video);
  }

  Widget buildFullScreen({
    required Widget child,
  }) {
    final size = widget.controller.value.size;
    final width = size.width;
    final height = size.height;

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(width: width, height: height, child: child),
    );
  }

  Widget buildVideoImage() {
    return OrientationBuilder(builder: (context, orientation) {
      final isPortrait = orientation == Orientation.portrait;

      setOrientation(isPortrait);

      return isPortrait == true
          ? SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.controller.value.isInitialized
                      ? Stack(
                          fit: isPortrait ? StackFit.loose : StackFit.expand,
                          children: <Widget>[
                            buildVideoPlayer(),
                            Positioned.fill(
                              child: AdvancedOverlayWidget(
                                fullscreencontrol: isPortrait,
                                controller: widget.controller,
                                onClickedFullScreen: () async {
                                  target = isPortrait
                                      ? Orientation.landscape
                                      : Orientation.portrait;

                                  if (isPortrait) {
                                    if (Platform.isAndroid) {
                                      AutoOrientation.landscapeRightMode();
                                    } else {
                                      await SystemChrome
                                          .setPreferredOrientations([
                                        DeviceOrientation.landscapeLeft,
                                      ]);
                                    }
                                  } else {
                                    AutoOrientation.portraitUpMode();
                                  }
                                },
                              ),
                            ),
                          ],
                        )
                      : Container(),

                  const SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap:(){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => HomeScreen(vidlist:widget.vidlist.first.toString())));
setState(() {
  isclicked=false;
});
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 22,

                            decoration: BoxDecoration(

                                border: Border.all(
                                  color: Colors.grey,
                                ),
                                borderRadius: const BorderRadius.all(Radius.circular(15))
                            ),
                            child: const Icon(
                                Icons.arrow_left_outlined,
                                color: Colors.green,
                                size: 22
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            if(widget.initclicked==false){
                              requestDownload(widget.vidlist.first, "video1",);

                            }
                            else if(isclicked==false){
                              requestDownload(widget.vidlist.first, "video1",);
                            }
                            else{
                              requestDownload(widget.vidlist.last, "video1",);
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 40,

                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                                borderRadius: const BorderRadius.all(Radius.circular(15))
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: const [
                                  Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.green,
                                      size: 22
                                  ),
                                  Text("Download",),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => HomeScreen(vidlist:widget.vidlist.last.toString())));
                            setState(() {
                              isclicked=true;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 22,

                            decoration: BoxDecoration(

                                border: Border.all(
                                  color: Colors.grey,
                                ),
                                borderRadius: const BorderRadius.all(Radius.circular(15))
                            ),
                            child: const Icon(
                                Icons.arrow_right,
                                color: Colors.green,
                                size: 22
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          : Stack(
              fit: isPortrait ? StackFit.loose : StackFit.expand,
              children: <Widget>[
                buildVideoPlayer(),
                Positioned.fill(
                  child: AdvancedOverlayWidget(
                    fullscreencontrol: isPortrait,
                    controller: widget.controller,
                    onClickedFullScreen: () async {
                      target = isPortrait
                          ? Orientation.landscape
                          : Orientation.portrait;

                      if (isPortrait) {
                        AutoOrientation.landscapeRightMode();
                      } else {
                        await SystemChrome.setPreferredOrientations([
                          DeviceOrientation.portraitUp,
                        ]);
                      }
                    },
                  ),
                ),
              ],
            );
    });
  }

  Future<void> requestDownload(
      String _url, String _name,) async {
    final dir =
        await getExternalStorageDirectory(); //From path_provider package
    var _localPath = dir!.absolute.path + _name;

    final savedDir = Directory(_localPath);

    await savedDir.create(recursive: true).then((value) async {
      String? _taskid = await FlutterDownloader.enqueue(
        url: _url,
        fileName: "$_name.mp4",
        savedDir: _localPath,
        showNotification: true,
        openFileFromNotification: false,
      );
      print(_taskid);
    });


  }

  @pragma('vm:entry-point')
  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      print('UI Isolate Callback: $data');

      if (data[1] == const DownloadTaskStatus(3) && data[2] == 100) {
        Fluttertoast.showToast(msg: "File download completed");
      }

      /*
       Update UI with the latest progress
       */
    });
  }

  @pragma('vm:entry-point')
  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, int status, int progress) {
    print(
        'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');

    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  @pragma('vm:entry-point')
  void getcallback() {
    FlutterDownloader.registerCallback(downloadCallback);
  }
}
