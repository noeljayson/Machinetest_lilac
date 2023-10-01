import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:machine_test_lilac/profile_display_page.dart';

import 'package:video_player/video_player.dart';

class AdvancedOverlayWidget extends StatefulWidget {
  VideoPlayerController controller;

  final VoidCallback onClickedFullScreen;
  var fullscreencontrol;
  static const allSpeeds = <double>[0.25, 0.5, 1, 1.5, 2, 3, 5, 10];

  AdvancedOverlayWidget({
    Key? key,
    required this.controller,
    required this.onClickedFullScreen,
    required this.fullscreencontrol,
  }) : super(key: key);

  @override
  State<AdvancedOverlayWidget> createState() => _AdvancedOverlayWidgetState();
}

class _AdvancedOverlayWidgetState extends State<AdvancedOverlayWidget> {
  String gettotalPosition() {
    Duration _duration = widget.controller.value.duration;
    final _totalHour = _duration.inHours == 0 ? '' : '${_duration.inHours}:';
    final _totalMinute = _duration.toString().split(':')[1];
    final _totalSeconds = (_duration - Duration(minutes: _duration.inMinutes))
        .inSeconds
        .toString()
        .padLeft(2, '0');
    final String videoLength = '$_totalHour$_totalMinute:$_totalSeconds';
    return videoLength;
  }

  String getPosition() {
    Duration _duration = widget.controller.value.position;
    final _totalHour = _duration.inHours == 0 ? '' : '${_duration.inHours}:';
    final _totalMinute = _duration.toString().split(':')[1];
    final _totalSeconds = (_duration - Duration(minutes: _duration.inMinutes))
        .inSeconds
        .toString()
        .padLeft(2, '0');
    final String videoposition = '$_totalHour$_totalMinute:$_totalSeconds';

    return videoposition;
  }



  bool istapped = false;

  double progress = 0.0;

  Orientation? target;
  var isPortrait;

  String name = "", email = "", dob = "",imageurl="";

  @override
  void initState() {
    super.initState();



    getfirebasedatas();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        if (widget.controller.value.isPlaying) {
          setState(() {
            istapped = true;
          });
          await Future.delayed(const Duration(seconds: 4));

          setState(() {
            istapped = false;
          });
        } else {}
      },
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Stack(
          children: <Widget>[
            widget.fullscreencontrol != true

                /// full screen case
                ? Positioned(
                    left: MediaQuery.of(context).size.width * 0.39,
                    bottom: 0,
                    top: 0,
                    child: buildPlay())
                : Positioned(
                    left: MediaQuery.of(context).size.width * 0.30,
                    bottom: 0,
                    top: 0,
                    child: buildPlay()),
            widget.controller.value.isPlaying && istapped == true
                ? Positioned(
                    top: 0,
                    child: widget.fullscreencontrol != true
                        ? Container(
                            margin: EdgeInsets.only(
                                left: 15,
                                top: MediaQuery.of(context).size.height *
                                    1 /
                                    100),
                            child: GestureDetector(
                                onTap: widget.onClickedFullScreen,
                                child: const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.blue,
                                )),
                          )
                        : Container(),
                  )
                : widget.controller.value.isPlaying == false &&
                        istapped == false
                    ? Positioned(
                        top: 0,
                        child: widget.fullscreencontrol != true
                            ? Container(
                                margin: EdgeInsets.only(
                                    left: 15,
                                    top: MediaQuery.of(context).size.height *
                                        1 /
                                        100),
                                child: GestureDetector(
                                    onTap: widget.onClickedFullScreen,
                                    child: const Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.blue,
                                    )),
                              )
                            : Container(),
                      )
                    : Container(),
            Positioned(
                left: MediaQuery.of(context).size.width * 0.83,
                right: 0,
                top: 0,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>  ProfileDisplayPage(name:name,email:email,dob:dob,imageurl:imageurl)),
                    );
                  },
                  child:  CircleAvatar(
                    radius: 20.0,
                    backgroundImage: NetworkImage(imageurl),
                    backgroundColor: Colors.green,
                  ),
                )),
            widget.controller.value.isPlaying && istapped == true
                ? Positioned(
                    left: 8,
                    bottom: 28,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${getPosition()}/${gettotalPosition()}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: widget.onClickedFullScreen,
                          child: const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  )
                : widget.controller.value.isPlaying == false &&
                        istapped == false
                    ? Positioned(
                        left: 8,
                        bottom: 28,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "",
                              style: TextStyle(color: Colors.white),
                            ),
                            GestureDetector(
                              onTap: widget.onClickedFullScreen,
                              child: const Icon(
                                Icons.fullscreen,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
            widget.controller.value.isPlaying && istapped == true
                ? Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Row(
                      children: [
                        Expanded(child: buildIndicator()),
                      ],
                    ))
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget buildIndicator() => Container(
        margin: const EdgeInsets.all(8).copyWith(right: 0),
        height: 10,
        child: VideoProgressIndicator(
          widget.controller,
          colors: const VideoProgressColors(
            playedColor: Colors.green,
          ),
          allowScrubbing: true,
        ),
      );

  Widget buildPlay() => widget.controller.value.isPlaying && istapped == true
      ? Row(
          children: [
            InkWell(
                onTap: () {
                  Duration currentPosition = widget.controller.value.position;
                  Duration targetPosition =
                      currentPosition + const Duration(seconds: -10);
                  widget.controller.seekTo(targetPosition);
                },
                child: const Icon(
                  Icons.skip_previous,
                  color: Colors.white,
                )),
            const SizedBox(
              width: 15,
            ),
            Center(
              child: widget.controller.value.isPlaying
                  ? InkWell(
                      onTap: () {
                        widget.controller.pause();

                        setState(() {
                          istapped = false;
                        });
                      },
                      child: const Icon(
                        Icons.pause,
                        color: Colors.white,
                        size: 46,
                      ),
                    )
                  : InkWell(
                      onTap: () {
                        widget.controller.play();

                        setState(() {
                          istapped = true;
                        });
                      },
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 46,
                      ),
                    ),
            ),
            const SizedBox(
              width: 15,
            ),
            InkWell(
                onTap: () {
                  Duration currentPosition = widget.controller.value.position;
                  Duration targetPosition =
                      currentPosition + const Duration(seconds: 10);
                  widget.controller.seekTo(targetPosition);
                },
                child: const Icon(
                  Icons.skip_next,
                  color: Colors.white,
                )),
          ],
        )
      : widget.controller.value.isPlaying == false && istapped == false
          ? Row(
              children: [
                InkWell(
                    onTap: () {
                      Duration currentPosition =
                          widget.controller.value.position;
                      Duration targetPosition =
                          currentPosition + const Duration(seconds: -10);
                      widget.controller.seekTo(targetPosition);
                    },
                    child: const Icon(
                      Icons.skip_previous,
                      color: Colors.white,
                    )),
                const SizedBox(
                  width: 15,
                ),
                Center(
                  child: widget.controller.value.isPlaying
                      ? InkWell(
                          onTap: () {

                            widget.controller.pause();

                            setState(() {
                              istapped = true;
                            });
                          },
                          child: const Icon(
                            Icons.pause,
                            color: Colors.white,
                            size: 46,
                          ),
                        )
                      : InkWell(
                          onTap: () async {
                            widget.controller.play();

                            setState(() {
                              istapped = true;
                            });

                            await Future.delayed(const Duration(seconds: 4));

                            setState(() {
                              istapped = false;
                            });
                          },
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 46,
                          ),
                        ),
                ),
                const SizedBox(
                  width: 15,
                ),
                InkWell(
                    onTap: () {
                      Duration currentPosition =
                          widget.controller.value.position;
                      Duration targetPosition =
                          currentPosition + const Duration(seconds: 10);
                      widget.controller.seekTo(targetPosition);
                    },
                    child: const Icon(
                      Icons.skip_next,
                      color: Colors.white,
                    )),
              ],
            )
          : Container();



  void getfirebasedatas() async {
    String userid = (FirebaseAuth.instance.currentUser!).uid;
    Reference  ref = FirebaseStorage.instance.ref().child('profileImage/$userid.jpg');


    imageurl = await ref.getDownloadURL();

    FirebaseFirestore.instance
        .collection('userdetail')
        .doc(userid)
        .get()
        .then((event) {
      setState(() {
        name = event['name'];
        email = event['email'];
        dob = event['dob'];
        imageurl;
      });
    });
  }
}
