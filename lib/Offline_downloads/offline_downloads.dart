import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OfflineDownloads extends StatefulWidget with WidgetsBindingObserver {
  const OfflineDownloads({
    super.key,
  });

  @override
  _OfflineDownloadsState createState() => _OfflineDownloadsState();
}

class _OfflineDownloadsState extends State<OfflineDownloads> {
  final ReceivePort _port = ReceivePort();
  List<Map> downloadsListMaps = [];

  late DownloadTaskStatus _status;

  var pos;

  @override
  void initState() {
    super.initState();

    task();
    _bindBackgroundIsolate();

    getcallback();
  }

  @pragma('vm:entry-point')
  void _bindBackgroundIsolate() async {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }

    _port.listen((dynamic data) {
      String id = data[0];

      DownloadTaskStatus status = data[1];
      int progress = data[2];

      var task = downloadsListMaps.where((element) => element['id'] == id);

      task.forEach((element) {
        element['progress'] = progress;
        element['status'] = status;
        setState(() {
          print("newcompleted");
          print(element['status'] == const DownloadTaskStatus(3));
          Fluttertoast.showToast(msg: "File download completed");
        });
      });
    });
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @pragma('vm:entry-point')
  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @pragma('vm:entry-point')
  Future task() async {
    List<DownloadTask>? getTasks = await FlutterDownloader.loadTasks();

    getTasks!.forEach((_task) {
      Map _map = Map();
      _map['status'] = _task.status;

      _map['progress'] = _task.progress;

      _map['id'] = _task.taskId;
      _map['filename'] = _task.filename;
      _map['savedDirectory'] = _task.savedDir;
      downloadsListMaps.add(_map);

      print(_map['status']);
    });
    setState(() {});
  }

  var scaffoldKey = GlobalKey<ScaffoldState>();

  var searchitem;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.green, title: const Text("Downloads")),
        extendBody: true,
        key: scaffoldKey,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: ListView.builder(
                    itemCount: downloadsListMaps.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int i) {
                      Map _map = downloadsListMaps[i];
                      String _filename = _map['filename'];
                      int _progress = _map['progress'];
                      _status = _map['status'];
                      String _id = _map['id'];
                      if (Platform.isAndroid) {
                        String _savedDirectory = _map['savedDirectory'];
                        List<FileSystemEntity> _directories =
                            Directory(_savedDirectory)
                                .listSync(followLinks: true);

                        FileSystemEntity? _file =
                            _directories.isNotEmpty ? _directories.first : null;
                      }

                      return GestureDetector(
                        onTap: () {},
                        child: Card(
                          color: Colors.white,
                          elevation: 10,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ListTile(
                                isThreeLine: false,
                                title: Text(
                                  _filename,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      fontFamily: 'Manrope-Bold'),
                                ),
                                subtitle: downloadStatus(
                                  _status,
                                ),
                                trailing: SizedBox(
                                  width: 60,
                                  child:
                                      buttons(_status, _id, i, _filename, pos),
                                ),
                              ),
                              _status == DownloadTaskStatus.complete
                                  ? Container()
                                  : const SizedBox(height: 5),
                              _status == DownloadTaskStatus.complete
                                  ? Container()
                                  : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Text('$_progress%',
                                              style: const TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Manrope-Bold')),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: LinearProgressIndicator(
                                                  color: Colors.green,
                                                  backgroundColor: Colors.white,
                                                  value: _progress / 100,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                              const SizedBox(height: 10)
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget downloadStatus(DownloadTaskStatus _status) {
    return _status == DownloadTaskStatus.canceled
        ? const Text(
            'Canceled',
            style: TextStyle(
                color: Colors.green,
                fontSize: 13,
                fontWeight: FontWeight.w300,
                fontFamily: 'Manrope-Bold'),
          )
        : _status == DownloadTaskStatus.complete
            ? const Text('Completed',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Manrope-Bold'))
            : _status == DownloadTaskStatus.failed
                ? const Text('Failed',
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'Manrope-Bold'))
                : _status == DownloadTaskStatus.paused
                    ? const Text('Paused',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'Manrope-Bold'))
                    : _status == DownloadTaskStatus.running
                        ? const Text('Downloading..',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                fontFamily: 'Manrope-Bold'))
                        : const Text('Waiting',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                fontFamily: 'Manrope-Bold'));
  }

  Widget buttons(DownloadTaskStatus _status, String taskid, int index,
      String filename, pos) {
    void changeTaskID(String taskid, String newTaskID) {
      Map? task = downloadsListMaps.firstWhere(
        (element) => element['taskId'] == taskid,
      );
      task['taskId'] = newTaskID;

      // setState(() {});
    }

    return _status == DownloadTaskStatus.canceled
        ? GestureDetector(
            child: const Icon(Icons.cached, size: 20, color: Colors.green),
            onTap: () {
              FlutterDownloader.retry(taskId: taskid).then((newTaskID) {
                changeTaskID(taskid, newTaskID!);
              });
            },
          )
        : _status == DownloadTaskStatus.failed
            ? GestureDetector(
                child: const Icon(Icons.cached, size: 20, color: Colors.green),
                onTap: () {
                  FlutterDownloader.retry(taskId: taskid).then((newTaskID) {
                    changeTaskID(taskid, newTaskID!);
                  });
                },
              )
            : _status == DownloadTaskStatus.paused
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Visibility(
                        visible: false,
                        child: GestureDetector(
                          child: const Icon(Icons.play_arrow,
                              size: 20, color: Colors.green),
                          onTap: () async {
                            Navigator.pop(context);

                            FlutterDownloader.resume(taskId: taskid).then(
                              (newTaskID) => changeTaskID(taskid, newTaskID!),
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OfflineDownloads(),
                              ),
                            );

                            //task();
                            _bindBackgroundIsolate();

                            FlutterDownloader.registerCallback(
                                downloadCallback);
                          },
                        ),
                      ),
                      GestureDetector(
                        child: const Icon(Icons.play_arrow,
                            size: 20, color: Colors.green),
                        onTap: () async {
                          Navigator.pop(context);

                          FlutterDownloader.resume(taskId: taskid).then(
                            (newTaskID) => changeTaskID(taskid, newTaskID!),
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OfflineDownloads(),
                            ),
                          );

                          //task();
                          _bindBackgroundIsolate();
                          FlutterDownloader.registerCallback(downloadCallback);
                        },
                      ),
                    ],
                  )
                : _status == DownloadTaskStatus.running
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Visibility(
                            visible: false,
                            child: GestureDetector(
                              child: const Icon(Icons.pause,
                                  size: 20, color: Colors.green),
                              onTap: () {
                                Navigator.pop(context);
                                FlutterDownloader.pause(taskId: taskid);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const OfflineDownloads(),
                                  ),
                                );
                              },
                            ),
                          ),
                          GestureDetector(
                            child: const Icon(Icons.pause,
                                size: 20, color: Colors.green),
                            onTap: () {
                              Navigator.pop(context);
                              FlutterDownloader.pause(taskId: taskid);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const OfflineDownloads(),
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    : Container();
  }

  @pragma('vm:entry-point')
  void getcallback() {
    FlutterDownloader.registerCallback(downloadCallback);
  }
}
