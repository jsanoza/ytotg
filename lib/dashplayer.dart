import 'dart:async';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cool_nav/cool_nav.dart';
import 'package:draggable_bottom_sheet/draggable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'downloader.dart';
import 'dashplaylist.dart';
import 'model./singleAudio.dart';

class DashPlayer extends StatefulWidget {
  @override
  _DashPlayerState createState() => _DashPlayerState();
}

class _DashPlayerState extends State<DashPlayer> with TickerProviderStateMixin {
  final List<StreamSubscription> _subscriptions = [];
  final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer();
  PageController _pageController = PageController();
  int currentIndex;
  bool _isLoaded = false;
  List<String> url = [];
  List<String> pathfin2 = [];
  List<Audio> audios = [];

  _miniplayerWidget() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            height: Get.height,
            padding: EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
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
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 8),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      color: Colors.transparent,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
                    ),
                    child: Image.network(
                      'https://images.genius.com/7c1259227a882c3db656e53184128862.1000x1000x1.jpg', // _assetsAudioPlayer.
                      height: 30,
                      width: 30,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        width: Get.width / 1.3,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0.0, bottom: 0, top: 10),
                          child: Marquee(
                            text: 'Play some music G!',
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 15,
            left: 95,
            child: Row(
              children: [
                Container(
                  width: Get.width,
                  color: Colors.transparent,
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
              ],
            ),
          ),
        ],
      ),
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

  _openPlayer() async {
    await _assetsAudioPlayer.open(
      Playlist(audios: audios, startIndex: 1),
      showNotification: true,
      loopMode: LoopMode.playlist,
      autoStart: true,
    );

    setState(() {
      if (_assetsAudioPlayer.playerState != null) {
        // isPlaylist = true;
      }
      print(_assetsAudioPlayer.currentLoopMode);
    });
  }

  _getpath() async {
    setState(() {
      _openPlayer();
    });
  }

  refresh() async {
    setState(() {
      _isLoaded = true;
      print('narefreshakoa');
    });

    print(SingleAudio.singlePath);
    var singles = SingleAudio.singlePath.toString();
    _assetsAudioPlayer.open(
      Audio.file(
        SingleAudio.singlePath,
        metas: Metas(
          id: SingleAudio.singlePath,
          title: 'Hello There!',
          artist: 'John',
          album: 'Soft',
          image: MetasImage.network('https://i1.sndcdn.com/artworks-000419491731-f34a2h-t500x500.jpg'),
        ),
      ),
      showNotification: true,
      autoStart: true,
    );
  }

  _expandedPlayer() {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
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
                padding: const EdgeInsets.only(top: 0.0, left: 0, right: 0),
                child: Container(
                  width: Get.width,
                  height: Get.height,
                  child: Column(
                    children: [
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //   children: [
                      //     Padding(
                      //       padding: const EdgeInsets.only(left: 0.0, top: 40),
                      //       child: Text(
                      //         'Play G!',
                      //         style: GoogleFonts.poppins(
                      //           fontSize: 30,
                      //           color: Colors.white,
                      //           fontWeight: FontWeight.w500,
                      //         ),
                      //       ),
                      //     ),
                      //     Padding(
                      //       padding: const EdgeInsets.only(left: 0.0, top: 40),
                      //       child: IconButton(
                      //         icon: Icon(
                      //           Icons.notes,
                      //           size: 40,
                      //           color: Colors.white,
                      //         ),
                      //         onPressed: () async {
                      //           print('Pressed');
                      //           // if (_downplease == false) {
                      //           //   _pageController.animateToPage(_pageController.page.toInt() + 1, duration: Duration(milliseconds: 700), curve: Curves.fastOutSlowIn);
                      //           //   setState(() {
                      //           //     _downplease = true;
                      //           //     print(_downplease);
                      //           //   });
                      //           // }
                      //         },
                      //       ),
                      //     ),
                      //   ],
                      // ),
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
                                    color: Colors.blue,
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
                                  ),
                                  child: Image.network(
                                    'https://images.genius.com/7c1259227a882c3db656e53184128862.1000x1000x1.jpg', // _assetsAudioPlayer.
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
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
                                    _getpath();
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
                          child: Marquee(
                            text: 'PREP - Dont Wait For Me',
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
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Container(
                          width: Get.width,
                          child: _assetsAudioPlayer.builderRealtimePlayingInfos(
                            builder: (context, RealtimePlayingInfos infos) {
                              if (infos == null) {
                                return SizedBox();
                              }
                              return Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(width: 15),
                                        Container(
                                          width: 40,
                                          child: Text(
                                            durationToString(infos.currentPosition),
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Spacer(),
                                        Container(
                                          width: 40,
                                          child: Text(
                                            durationToString(infos.duration),
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Container(width: 10),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 18.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: Get.width,
                                            child: Slider(
                                              activeColor: Colors.white,
                                              inactiveColor: Colors.grey,
                                              min: 0,
                                              max: infos.duration.inMilliseconds.toDouble(),
                                              value: infos.currentPosition.inMilliseconds.toDouble(),
                                              onChanged: (double value) {
                                                _assetsAudioPlayer.seek(value.milliseconds);
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                      ),
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
                                            setState(() {});
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
    // _allfunctions();
    _isLoaded = false;
    super.initState();
  }

  @override
  void dispose() {
    // ignore: todo
    // TODO: implement dispose
    _assetsAudioPlayer.dispose();
    print('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DraggableBottomSheet(
        backgroundWidget: Stack(
          children: [
            Container(
              height: Get.height,
              child: PageView(
                controller: _pageController,
                pageSnapping: true,
                physics: AlwaysScrollableScrollPhysics(),
                children: <Widget>[
                  DashPlaylist(notifyParent: refresh),
                  Container(
                    color: Colors.green,
                  ),
                  // PickDL(),
                ],
                onPageChanged: (page) {
                  setState(() {
                    setState(() {
                      currentIndex = page;
                    });
                  });
                },
              ),
            ),
          ],
        ),
        // previewChild: _miniplayerWidget(),
        previewChild: _miniplayerWidget(),

        expandedChild: _expandedPlayer(),
        minExtent: 90,
        maxExtent: Get.height / 1.3,
      ),
      bottomNavigationBar: SpotlightBottomNavigationBar(
        items: [
          SpotlightBottomNavigationBarItem(icon: Icons.home),
          // SpotlightBottomNavigationBarItem(icon: Icons.music_note),
          SpotlightBottomNavigationBarItem(icon: Icons.web),
        ],
        currentIndex: currentIndex,
        onTap: _updateIndex,
        backgroundColor: Color(0xff355C7D),
        // backgroundColor: Colors.black87,
        selectedItemColor: Colors.white,
      ),
    );
  }
}

String durationToString(Duration duration) {
  String twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour));
  final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(Duration.secondsPerMinute));
  return '$twoDigitMinutes:$twoDigitSeconds';
}
