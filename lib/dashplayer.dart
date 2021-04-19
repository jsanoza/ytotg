import 'dart:async';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cool_nav/cool_nav.dart';
import 'package:draggable_bottom_sheet/draggable_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:yt_otg/trialplayeragain.dart';
import 'downloader.dart';
import 'dashplaylist.dart';
import 'model/posseek.dart';
import 'model/showList.dart';
import 'model/singleAudio.dart';

class DashPlayer extends StatefulWidget {
  @override
  _DashPlayerState createState() => _DashPlayerState();
}

class _DashPlayerState extends State<DashPlayer> with TickerProviderStateMixin {
  final FlutterFFprobe _flutterFFprobe = new FlutterFFprobe();
  final List<StreamSubscription> _subscriptions = [];
  final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer();
  PageController _pageController = PageController();
  AnimationController _controller;
  int currentIndex;
  bool _isLoaded = false;
  File _image;
  List<String> url = [];
  List<String> pathfin2 = [];
  List<Audio> audios = [];
  bool selected = false;
  String imageplaying;
  Duration nowplaying;

  _miniplayerWidget() {
    return Stack(
      children: [
        Container(
          height: Get.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            gradient: new LinearGradient(
                colors: [
                  Color(0xffC06C84),
                  Color(0xff355C7D),
                  Color(0xff6C5B7B),
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 1.0),
                stops: [0.0, 1.0, 1.0],
                tileMode: TileMode.clamp),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  // Get.to(_expandedPlayer(), transition: Transition.topLevel);
                  // showCupertinoModalBottomSheet(
                  //   context: context,
                  //   builder: (context) => _expandedPlayer(),
                  // );
                  showGeneralDialog(
                    barrierLabel: "Label",
                    barrierDismissible: false,
                    barrierColor: Colors.black.withOpacity(0.2),
                    transitionDuration: Duration(milliseconds: 200),
                    context: context,
                    pageBuilder: (context, anim1, anim2) {
                      return _expandedPlayer();
                    },
                    transitionBuilder: (context, anim1, anim2, child) {
                      return SlideTransition(
                        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
                        child: child,
                      );
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _assetsAudioPlayer.builderCurrent(
                    builder: (BuildContext context, Playing playing) {
                      // final myAudio = find(audios, playing.audio.assetAudioPath);
                      if (playing == null) {}
                      return Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: Colors.transparent,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
                        ),
                        // child: Image.file(File(_assetsAudioPlayer.getCurrentAudioImage.path.toString())),
                        child: _assetsAudioPlayer.builderCurrent(
                          builder: (BuildContext context, Playing playing) {
                            // final myAudio = find(audios, playing.audio.assetAudioPath);
                            if (playing == null) {
                              return SizedBox();
                            }
                            var _list = _assetsAudioPlayer.getCurrentAudioextra.values.toList();
                            return Image.file(File(_list[0].toString()), fit: BoxFit.cover);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              Column(
                children: [
                  Container(
                    height: 40,
                    width: Get.width / 1.3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _assetsAudioPlayer.builderCurrent(
                        builder: (BuildContext context, Playing playing) {
                          // final myAudio = find(audios, playing.audio.assetAudioPath);
                          if (playing == null) {
                            return SizedBox();
                          }
                          return Marquee(
                            text: _assetsAudioPlayer.getCurrentAudioTitle,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            blankSpace: 20.0,
                            velocity: 20.0,
                            pauseAfterRound: Duration(seconds: 1),
                            startPadding: 10.0,
                            accelerationDuration: Duration(seconds: 1),
                            accelerationCurve: Curves.linear,
                            decelerationDuration: Duration(milliseconds: 500),
                            decelerationCurve: Curves.easeOut,
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 45.0),
                    child: Container(
                      child: PlayerBuilder.isPlaying(
                        player: _assetsAudioPlayer,
                        builder: (context, isPlaying) {
                          return Container(
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _assetsAudioPlayer.previous();
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.all(Radius.circular(30)),
                                      gradient: new LinearGradient(
                                          colors: [
                                            Color(0xff355C7D),
                                            Color(0xffC06C84),
                                            Color(0xff6C5B7B),
                                          ],
                                          begin: const FractionalOffset(0.0, 0.0),
                                          end: const FractionalOffset(1.0, 1.0),
                                          stops: [0.0, 1.0, 1.0],
                                          tileMode: TileMode.clamp),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
                                    ),
                                    child: Icon(
                                      Icons.skip_previous,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _assetsAudioPlayer.seekBy(Duration(seconds: -10));
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.all(Radius.circular(30)),
                                      gradient: new LinearGradient(
                                          colors: [
                                            Color(0xff355C7D),
                                            Color(0xffC06C84),
                                            Color(0xff6C5B7B),
                                          ],
                                          begin: const FractionalOffset(0.0, 0.0),
                                          end: const FractionalOffset(1.0, 1.0),
                                          stops: [0.0, 1.0, 1.0],
                                          tileMode: TileMode.clamp),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 0.0),
                                      child: Icon(
                                        Icons.fast_rewind,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 10,
                                ),
                                StreamBuilder(
                                    stream: _assetsAudioPlayer.isPlaying,
                                    initialData: false,
                                    builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                                      return Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.all(Radius.circular(60)),
                                          gradient: new LinearGradient(
                                              colors: [
                                                Color(0xff355C7D),
                                                Color(0xffC06C84),
                                                Color(0xff6C5B7B),
                                              ],
                                              begin: const FractionalOffset(0.0, 0.0),
                                              end: const FractionalOffset(1.0, 1.0),
                                              stops: [0.0, 1.0, 1.0],
                                              tileMode: TileMode.clamp),
                                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
                                        ),
                                        child: IconButton(
                                          icon: snapshot.data
                                              ? Icon(
                                                  Icons.pause,
                                                  size: 20,
                                                  color: Colors.white,
                                                )
                                              : Icon(
                                                  Icons.play_arrow,
                                                  size: 20,
                                                  color: Colors.white,
                                                ),
                                          onPressed: () async {
                                            _assetsAudioPlayer.playOrPause();
                                          },
                                        ),
                                      );
                                    }),
                                Container(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _assetsAudioPlayer.seekBy(Duration(seconds: 10));
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.all(Radius.circular(30)),
                                      gradient: new LinearGradient(
                                          colors: [
                                            Color(0xff355C7D),
                                            Color(0xffC06C84),
                                            Color(0xff6C5B7B),
                                          ],
                                          begin: const FractionalOffset(0.0, 0.0),
                                          end: const FractionalOffset(1.0, 1.0),
                                          stops: [0.0, 1.0, 1.0],
                                          tileMode: TileMode.clamp),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 2.0),
                                      child: Icon(
                                        Icons.fast_forward,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _assetsAudioPlayer.next();
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.all(Radius.circular(30)),
                                      gradient: new LinearGradient(
                                          colors: [
                                            Color(0xff355C7D),
                                            Color(0xffC06C84),
                                            Color(0xff6C5B7B),
                                          ],
                                          begin: const FractionalOffset(0.0, 0.0),
                                          end: const FractionalOffset(1.0, 1.0),
                                          stops: [0.0, 1.0, 1.0],
                                          tileMode: TileMode.clamp),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
                                    ),
                                    child: Icon(
                                      Icons.skip_next,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  _updateIndex(index) {
    setState(() {
      currentIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  loopwidget() {
    print(_assetsAudioPlayer.currentLoopMode);
    var state = _assetsAudioPlayer.currentLoopMode;
    if (state.toString() == 'LoopMode.playlist') {
      return Container(
        height: 30,
        width: 30,
        child: Icon(
          Icons.playlist_play,
          size: 20,
          color: Colors.white,
        ),
      );
    } else if (state.toString() == 'LoopMode.none') {
      return Container(
        height: 30,
        width: 30,
        child: Icon(
          Icons.loop,
          size: 20,
          color: Colors.grey,
        ),
      );
    } else if (state.toString() == 'LoopMode.single') {
      return Container(
        height: 30,
        width: 30,
        child: Icon(
          Icons.loop,
          size: 20,
          color: Colors.white,
        ),
      );
    }
  }

  refresh() async {
    selected = true;
    _controller.forward();
    setState(() {
      _isLoaded = true;
      print('narefreshakoa');
    });
    Directory appDocDir = await getApplicationDocumentsDirectory();
    var resultpath = appDocDir.uri.toFilePath().toString() + SingleAudio.singlePath;
    var imagepath = appDocDir.uri.toFilePath().toString() + SingleAudio.image;

    _isLoaded = true;
    var usrMap = {"name": imagepath.toString(), "dummy": 'dummy'};
    await _assetsAudioPlayer.open(
      Audio.file(
        resultpath.toString(),
        metas: Metas(
          id: resultpath,
          extra: usrMap,
          title: SingleAudio.title,
          artist: SingleAudio.artist,
          album: SingleAudio.album,
          image: MetasImage.asset("assets/images/aa.jpeg"),
        ),
      ),
      showNotification: true,
      loopMode: LoopMode.single,
      playInBackground: PlayInBackground.enabled,
    );
    SingleAudio.singlePath = '';
    SingleAudio.title = '';
    SingleAudio.artist = '';
    SingleAudio.album = '';
    SingleAudio.image = '';
  }

  _expandedPlayer() {
    return Dismissible(
      key: Key('some key here'),
      direction: DismissDirection.down,
      onDismissed: (_) => Get.back(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: new LinearGradient(
                colors: [
                  Color(0xffC06C84),
                  Color(0xff355C7D),
                  Color(0xff6C5B7B),
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 1.0),
                stops: [0.0, 1.0, 1.0],
                tileMode: TileMode.clamp),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50.0, left: 0, right: 0),
                child: Container(
                  width: Get.width,
                  height: Get.height,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 0.0, top: 40),
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_downward,
                                size: 30,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                print('Pressed');
                                Get.back();
                              },
                            ),
                          ),
                          Container(width: 50),
                          Padding(
                            padding: const EdgeInsets.only(left: 0.0, top: 40),
                            child: Text(
                              'Play G!',
                              style: GoogleFonts.poppins(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(width: 50),
                          Padding(
                            padding: const EdgeInsets.only(left: 0.0, top: 40),
                            child: IconButton(
                              icon: Icon(
                                Icons.playlist_play,
                                size: 35,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                print('Pressed');
                                // Get.back();
                              },
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                Container(
                                  height: 200,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.all(Radius.circular(30)),
                                    color: Colors.transparent,
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
                                  ),
                                  child: _assetsAudioPlayer.builderCurrent(
                                    builder: (BuildContext context, Playing playing) {
                                      // final myAudio = find(audios, playing.audio.assetAudioPath);
                                      if (playing == null) {
                                        return SizedBox();
                                      }
                                      var _list = _assetsAudioPlayer.getCurrentAudioextra.values.toList();
                                      return Image.file(
                                        File(_list[0].toString()),
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              right: 5,
                              top: 5,
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.all(Radius.circular(30)),
                                  color: Colors.blue,
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
                                  gradient: new LinearGradient(
                                      colors: [
                                        Color(0xff355C7D),
                                        Color(0xffC06C84),
                                        Color(0xff6C5B7B),
                                      ],
                                      begin: const FractionalOffset(0.0, 0.0),
                                      end: const FractionalOffset(1.0, 1.0),
                                      stops: [0.0, 1.0, 1.0],
                                      tileMode: TileMode.clamp),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.add,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    // _getpath();

                                    // Get.to(_expandedPlayer());
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 210,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _assetsAudioPlayer.builderCurrent(
                            builder: (BuildContext context, Playing playing) {
                              // final myAudio = find(audios, playing.audio.assetAudioPath);

                              return Marquee(
                                text: _assetsAudioPlayer.getCurrentAudioTitle,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                blankSpace: 20.0,
                                velocity: 20.0,
                                pauseAfterRound: Duration(seconds: 1),
                                startPadding: 10.0,
                                accelerationDuration: Duration(seconds: 1),
                                accelerationCurve: Curves.linear,
                                decelerationDuration: Duration(milliseconds: 500),
                                decelerationCurve: Curves.easeOut,
                              );
                            },
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 15.0),
                      //   child: Container(
                      //     width: Get.width,
                      //     child: _assetsAudioPlayer.builderRealtimePlayingInfos(
                      //       builder: (context, RealtimePlayingInfos infos) {
                      //         if (infos == null) {
                      //           return SizedBox();
                      //         }
                      //         // double hi = infos.duration.inSeconds.toDouble();
                      //         // var letssee = hi / 2;
                      //         // Duration okayx = Duration(seconds: letssee.toInt());

                      //         //  double hix = infos.currentPosition.inSeconds.toDouble();
                      //         //  var letsseee = hix / 2;
                      //         //   Duration okayxx = Duration(seconds: letsseee.toInt());

                      //         return PositionSeekWidget(
                      //           currentPosition: infos.currentPosition,
                      //           duration: infos.duration,
                      //           seekTo: (to) {
                      //             _assetsAudioPlayer.seek(to);
                      //           },
                      //         );
                      //       },
                      //     ),
                      //   ),
                      // ),
                      _assetsAudioPlayer.builderRealtimePlayingInfos(builder: (context, RealtimePlayingInfos infos) {
                        if (infos == null) {
                          return SizedBox();
                        }
                        //print('infos: $infos');
                        return Column(
                          children: [
                            PositionSeekWidget(
                              currentPosition: infos.currentPosition,
                              duration: infos.duration,
                              seekTo: (to) {
                                _assetsAudioPlayer.seek(to);
                              },
                            ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: [
                            //     NeumorphicButton(
                            //       onPressed: () {
                            //         _assetsAudioPlayer.seekBy(Duration(seconds: -10));
                            //       },
                            //       child: Text('-10'),
                            //     ),
                            //     SizedBox(
                            //       width: 12,
                            //     ),
                            //     NeumorphicButton(
                            //       onPressed: () {
                            //         _assetsAudioPlayer.seekBy(Duration(seconds: 10));
                            //       },
                            //       child: Text('+10'),
                            //     ),
                            //   ],
                            // )
                          ],
                        );
                      }),
                      // _assetsAudioPlayer.builderCurrent(builder: (context, Playing playing) {
                      //   return Container(
                      //     width: Get.width,
                      //     // height: 200,
                      //     child: Column(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: <Widget>[
                      //         _assetsAudioPlayer.builderLoopMode(
                      //           builder: (context, loopMode) {
                      //             return PlayerBuilder.isPlaying(
                      //                 player: _assetsAudioPlayer,
                      //                 builder: (context, isPlaying) {
                      //                   return PlayingControls(
                      //                     loopMode: loopMode,
                      //                     isPlaying: isPlaying,
                      //                     isPlaylist: true,
                      //                     // onStop: () {
                      //                     //   _assetsAudioPlayer.stop();
                      //                     // },
                      //                     toggleLoop: () {
                      //                       _assetsAudioPlayer.toggleLoop();
                      //                     },
                      //                     onPlay: () {
                      //                       _assetsAudioPlayer.playOrPause();
                      //                     },
                      //                     onNext: () {
                      //                       //_assetsAudioPlayer.forward(Duration(seconds: 10));
                      //                       _assetsAudioPlayer.next(keepLoopMode: true
                      //                           /*keepLoopMode: false*/);
                      //                     },
                      //                     onPrevious: () {
                      //                       _assetsAudioPlayer.previous(
                      //                           /*keepLoopMode: false*/);
                      //                     },
                      //                   );
                      //                 });
                      //           },
                      //         ),
                      //       ],
                      //     ),
                      //   );
                      // }),
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            PlayerBuilder.isPlaying(
                              player: _assetsAudioPlayer,
                              builder: (context, isPlaying) {
                                return Container(
                                  width: Get.width,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _assetsAudioPlayer.toggleShuffle();
                                              if (_assetsAudioPlayer.shuffle) {
                                                print('shuffling');
                                              } else {
                                                print('not shufflig');
                                              }
                                            });
                                          },
                                          child: Container(
                                            height: 30,
                                            width: 30,
                                            child: _assetsAudioPlayer.shuffle
                                                ? Icon(
                                                    Icons.shuffle,
                                                    size: 20,
                                                    color: Colors.white,
                                                  )
                                                : Icon(
                                                    Icons.shuffle,
                                                    size: 20,
                                                    color: Colors.grey,
                                                  ),
                                          ),
                                        ),
                                        Container(
                                          height: 50,
                                          width: 50,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.skip_previous,
                                              size: 30,
                                              color: Colors.white,
                                            ),
                                            onPressed: () async {
                                              _assetsAudioPlayer.previous();
                                            },
                                          ),
                                        ),
                                        StreamBuilder(
                                          stream: _assetsAudioPlayer.isPlaying,
                                          initialData: false,
                                          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                                            return Container(
                                              height: 80,
                                              width: 80,
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                                                  shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
                                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(90.0),
                                                      side: BorderSide(color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  _assetsAudioPlayer.playOrPause();
                                                },
                                                child: snapshot.data
                                                    ? Icon(
                                                        Icons.pause,
                                                        size: 40,
                                                        color: Colors.white,
                                                      )
                                                    : Icon(
                                                        Icons.play_arrow,
                                                        size: 40,
                                                        color: Colors.white,
                                                      ),
                                              ),
                                            );
                                          },
                                        ),
                                        Container(
                                          height: 50,
                                          width: 50,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.skip_next,
                                              size: 30,
                                              color: Colors.white,
                                            ),
                                            onPressed: () async {
                                              _assetsAudioPlayer.next();
                                            },
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            print('pressed');
                                            print(_assetsAudioPlayer.currentLoopMode);
                                            _assetsAudioPlayer.toggleLoop();
                                          },
                                          child: loopwidget(),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    _subscriptions.add(_assetsAudioPlayer.playlistAudioFinished.listen((data) {
      print('playlistAudioFinished : $data');
    }));
    _subscriptions.add(_assetsAudioPlayer.audioSessionId.listen((sessionId) {
      print('audioSessionId : $sessionId');
    }));
    _subscriptions.add(AssetsAudioPlayer.addNotificationOpenAction((notification) {
      return false;
    }));
    currentIndex = 0;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    // _allfunctions();
    _isLoaded = false;
    super.initState();
  }

  @override
  void dispose() {
    // ignore: todo
    // TODO: implement dispose
    _controller.dispose();
    _assetsAudioPlayer.dispose();
    print('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: GestureDetector(
        child: IconButton(
          icon: Icon(Icons.music_note_rounded, color: selected ? Color(0xffC06C84) : Colors.white),
          onPressed: () {
            selected = !selected;
            if (selected) {
              setState(() {});
              _controller.forward();
            } else {
              setState(() {});
              _controller.reverse();
            }
            print('ress');
          },
        ),
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            pageSnapping: true,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              DashPlaylist(notifyParent: refresh),
              ShowList(notifyParent: refresh),
            ],
            onPageChanged: (page) {
              setState(() {
                setState(() {
                  currentIndex = page;
                });
              });
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizeTransition(
                  sizeFactor: _controller,
                  child: GestureDetector(
                    onVerticalDragUpdate: (DragUpdateDetails details) {
                      // Get.to(TrialAgain(), transition: Transition.downToUp);
                      showGeneralDialog(
                        barrierLabel: "Label",
                        barrierDismissible: false,
                        barrierColor: Colors.black.withOpacity(0.2),
                        transitionDuration: Duration(milliseconds: 200),
                        context: context,
                        pageBuilder: (context, anim1, anim2) {
                          return _expandedPlayer();
                        },
                        transitionBuilder: (context, anim1, anim2, child) {
                          return SlideTransition(
                            position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
                            child: child,
                          );
                        },
                      );
                    },
                    onTap: () {
                      showGeneralDialog(
                        barrierLabel: "Label",
                        barrierDismissible: false,
                        barrierColor: Colors.black.withOpacity(0.2),
                        transitionDuration: Duration(milliseconds: 200),
                        context: context,
                        pageBuilder: (context, anim1, anim2) {
                          return _expandedPlayer();
                        },
                        transitionBuilder: (context, anim1, anim2, child) {
                          return SlideTransition(
                            position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
                            child: child,
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 100,
                      child: _miniplayerWidget(),
                    ),
                  ),
                ),
                SpotlightBottomNavigationBar(
                  items: [
                    SpotlightBottomNavigationBarItem(icon: Icons.home),
                    SpotlightBottomNavigationBarItem(icon: Icons.web),
                  ],
                  currentIndex: currentIndex,
                  onTap: _updateIndex,
                  backgroundColor: Color(0xff6C5B7B),
                  unselectedItemColor: Colors.grey[400],
                  selectedItemColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
