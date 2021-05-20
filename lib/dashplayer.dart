import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cool_nav/cool_nav.dart';
import 'package:draggable_bottom_sheet/draggable_bottom_sheet.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:yt_otg/model/loop.dart';
import 'package:yt_otg/trialplayeragain.dart';
import 'downloader.dart';
import 'dashplaylist.dart';
import 'model/dbProvider.dart';
import 'model/downloadModel.dart';
import 'model/posseek.dart';
import 'model/showList.dart';
import 'model/singleAudio.dart';
import 'model/singleAudio.dart';
import 'dart:io' show Platform;

class DashPlayer extends StatefulWidget {
  @override
  _DashPlayerState createState() => _DashPlayerState();
}

class _DashPlayerState extends State<DashPlayer> with TickerProviderStateMixin {
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
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
  String app;

  Color face = Color(0xffC06C84);
  Color face2 = Color(0xff355C7D);
  Color face3 = Color(0xff6C5B7B);
  String colorFile;
  var myColors;
  List<Audio> _string = [];
  bool _showUpNext = false;
  bool _miniIsPlaying = false;

  // _getColors() async {
  //  myColors =  _updatePaletteGenerator(colorFile);
  //  myColors.
  // }

  // ignore: missing_return
  Future<PaletteGenerator> _updatePaletteGenerator(String image) async {
    var file = File(image);
    var paletteGenerator = await PaletteGenerator.fromImageProvider(Image.file(file).image);
    setState(() {
      face = paletteGenerator.dominantColor == null ? Color(0xffC06C84) : paletteGenerator.dominantColor.color;
      face2 = paletteGenerator.darkVibrantColor == null ? Color(0xff355C7D) : paletteGenerator.darkVibrantColor.color;
      // if (paletteGenerator.darkVibrantColor == null) {
      //   face2 = Colors.black;
      // } else {
      //   face2 = paletteGenerator.darkVibrantColor.color;
      // }
      face3 = paletteGenerator.dominantColor == null ? Color(0xff6C5B7B) : paletteGenerator.dominantColor.color;
      print(face.toString() + face2.toString() + face3.toString());
    });
    setState(() {});
    setState(() {});
    _counter.value += 1;
    _miniIsPlaying = true;
    // face = snapshot.data.dominantColor.color == null ? Colors.transparent : snapshot.data.dominantColor.color;
    // face2 = snapshot.data.lightVibrantColor.color == null ? Colors.transparent : snapshot.data.lightVibrantColor.color;
    // face3 = snapshot.data.darkMutedColor.color == null ? Colors.transparent : snapshot.data.darkMutedColor.color;
  }

  getColors() async {
    await _updatePaletteGenerator(app + _assetsAudioPlayer.getCurrentAudioAlbum.toString());
    _showUpNext = !_showUpNext;
  }

  set string(List<Audio> value) => setState(() => _string = value);

  _miniplayerWidget() {
    return Stack(
      children: [
        ValueListenableBuilder(
          valueListenable: _counter,
          builder: (BuildContext context, int value, Widget child) {
            return Container(
              height: Get.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                gradient: new LinearGradient(
                    colors: [
                      face,
                      face2,
                      face3,
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
                          if (playing == null) {
                            return SizedBox(
                              width: 50,
                            );
                          }
                          // return Container(
                          //   height: 50,
                          //   width: 50,
                          // );
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
                                  return SizedBox(
                                    width: 50,
                                  );
                                }
                                // var _list = _assetsAudioPlayer.getCurrentAudioextra.values.toList();
                                // return Image.file(File(_list[0].toString()), fit: BoxFit.cover);
                                _assetsAudioPlayer.playlistAudioFinished.listen((data) {
                                  print('playlistAudioFinished : $data');
                                  _counter.value += 1;
                                  getColors();
                                });
                                var _trial = _assetsAudioPlayer.getCurrentAudioAlbum.toString();
                                return Image.file(
                                  File(app + _trial),
                                  fit: BoxFit.cover,
                                );
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
                        padding: _miniIsPlaying ? const EdgeInsets.only(right: 70.0) : const EdgeInsets.only(right: 20.0),
                        child: Container(
                          child: PlayerBuilder.isPlaying(
                            player: _assetsAudioPlayer,
                            builder: (context, isPlaying) {
                              return Container(
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        // _assetsAudioPlayer.previous();
                                        _assetsAudioPlayer.previous().then((value) => getColors());
                                      },
                                      child: Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.all(Radius.circular(30)),
                                          gradient: new LinearGradient(
                                              colors: [
                                                face,
                                                face2,
                                                face3,
                                              ],
                                              begin: const FractionalOffset(0.0, 0.0),
                                              end: const FractionalOffset(1.0, 1.0),
                                              stops: [0.0, 1.0, 1.0],
                                              tileMode: TileMode.clamp),
                                          boxShadow: [BoxShadow(color: Colors.white.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
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
                                                face,
                                                face2,
                                                face3,
                                              ],
                                              begin: const FractionalOffset(0.0, 0.0),
                                              end: const FractionalOffset(1.0, 1.0),
                                              stops: [0.0, 1.0, 1.0],
                                              tileMode: TileMode.clamp),
                                          boxShadow: [BoxShadow(color: Colors.white.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
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
                                                    face,
                                                    face2,
                                                    face3,
                                                  ],
                                                  begin: const FractionalOffset(0.0, 0.0),
                                                  end: const FractionalOffset(1.0, 1.0),
                                                  stops: [0.0, 1.0, 1.0],
                                                  tileMode: TileMode.clamp),
                                              boxShadow: [BoxShadow(color: Colors.white.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
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
                                                face,
                                                face2,
                                                face3,
                                              ],
                                              begin: const FractionalOffset(0.0, 0.0),
                                              end: const FractionalOffset(1.0, 1.0),
                                              stops: [0.0, 1.0, 1.0],
                                              tileMode: TileMode.clamp),
                                          boxShadow: [BoxShadow(color: Colors.white.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
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
                                        // _assetsAudioPlayer.next();
                                        _assetsAudioPlayer.next().then((value) => getColors());
                                      },
                                      child: Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.all(Radius.circular(30)),
                                          gradient: new LinearGradient(
                                              colors: [
                                                face,
                                                face2,
                                                face3,
                                              ],
                                              begin: const FractionalOffset(0.0, 0.0),
                                              end: const FractionalOffset(1.0, 1.0),
                                              stops: [0.0, 1.0, 1.0],
                                              tileMode: TileMode.clamp),
                                          boxShadow: [BoxShadow(color: Colors.white.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
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
            );
          },
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

  playlist() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    int indexof;

//homepageplaylist
    if (SingleAudio.fromwhere == 'homepageplaylist') {
      await _assetsAudioPlayer.open(
        Playlist(audios: _string, startIndex: 0),
        showNotification: true,
        playInBackground: PlayInBackground.enabled,
        loopMode: LoopMode.playlist,
        audioFocusStrategy: AudioFocusStrategy.none(),
      );
    }

// //playlist
    if (SingleAudio.fromwhere == 'randomplay') {
      setState(() {
        print('imherer2');
        indexof = _string.indexWhere((element) => element.path == appDocDir.uri.toFilePath().toString() + SingleAudio.singlePath);
        print(indexof.toString() + "THIS IS THE INDEX");
      });
      await _assetsAudioPlayer.open(
        Playlist(audios: _string, startIndex: indexof),
        showNotification: true,
        playInBackground: PlayInBackground.enabled,
        loopMode: LoopMode.playlist,
        audioFocusStrategy: AudioFocusStrategy.none(),
      );
    }

//allsongs
    if (SingleAudio.fromwhere == 'playall') {
      setState(() {
        print('imherer');
      });
      await _assetsAudioPlayer.open(
        Playlist(audios: _string, startIndex: 0),
        showNotification: true,
        playInBackground: PlayInBackground.enabled,
        loopMode: LoopMode.playlist,
        audioFocusStrategy: AudioFocusStrategy.none(),
      );
      print(_assetsAudioPlayer.getCurrentAudioAlbum.toString());
    }

// //recently added
    if (SingleAudio.fromwhere == 'solo') {
      var resultpath = appDocDir.uri.toFilePath().toString() + SingleAudio.singlePath;
      await _assetsAudioPlayer.open(
        Audio.file(
          resultpath.toString(),
          metas: Metas(
            id: resultpath,
            title: SingleAudio.title,
            artist: SingleAudio.artist,
            album: SingleAudio.image,
            image: MetasImage.asset("assets/images/aa.jpeg"),
          ),
        ),
        showNotification: true,
        loopMode: LoopMode.none,
        playInBackground: PlayInBackground.enabled,
        audioFocusStrategy: AudioFocusStrategy.none(),
      );
    }

    //queue
    if (SingleAudio.fromwhere == 'queue') {
      var resultpath = appDocDir.uri.toFilePath().toString() + SingleAudio.singlePath;
      var aa = _assetsAudioPlayer.getCurrentAudioTitle;
      if (aa == '') {
        await _assetsAudioPlayer.open(
          Audio.file(
            resultpath.toString(),
            metas: Metas(
              id: resultpath,
              title: SingleAudio.title,
              artist: SingleAudio.artist,
              album: SingleAudio.image,
              image: MetasImage.asset("assets/images/aa.jpeg"),
            ),
          ),
          showNotification: true,
          loopMode: LoopMode.none,
          playInBackground: PlayInBackground.enabled,
          audioFocusStrategy: AudioFocusStrategy.none(),
        );
      } else {
        _assetsAudioPlayer.playlist.add(
          Audio.file(
            resultpath.toString(),
            metas: Metas(
              id: resultpath,
              title: SingleAudio.title,
              artist: SingleAudio.artist,
              album: SingleAudio.image,
              image: MetasImage.asset("assets/image/aa.jpeg"),
            ),
          ),
        );
      }
    }

    SingleAudio.singlePath = '';
    SingleAudio.title = '';
    SingleAudio.artist = '';
    SingleAudio.album = '';
    SingleAudio.image = '';
    PlaylistAudio.path = [];
    PlaylistAudio.artist = [];
    PlaylistAudio.image = [];
    PlaylistAudio.title = [];
    SingleAudio.fromwhere = '';
    setState(() {
      app = appDocDir.uri.toFilePath().toString();
      selected = true;
      _controller.forward();
      _isLoaded = true;
      getColors();
      print('narefreshakoa');
    });
  }

  _expandedPlayer() {
    return Dismissible(
      key: Key('some key here'),
      direction: DismissDirection.down,
      onDismissed: (_) => Get.back(),
      child: Scaffold(
        body: ValueListenableBuilder(
          builder: (BuildContext context, int value, Widget child) {
            return Container(
              decoration: BoxDecoration(
                gradient: new LinearGradient(
                    colors: [
                      face,
                      face2,
                      face3,
                    ],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(1.0, 1.0),
                    stops: [0.0, 1.0, 0.0],
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
                                    cardKey.currentState.toggleCard();
                                    setState(() {
                                      print(_showUpNext);

                                      // getColors();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                            child: FlipCard(
                              key: cardKey,
                              flipOnTouch: false,
                              front: Container(
                                  child: GestureDetector(
                                onHorizontalDragEnd: (DragEndDetails details) {
                                  setState(() {
                                    cardKey.currentState.toggleCard();
                                    getColors();
                                  });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 200,
                                      width: 200,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.all(Radius.circular(30)),
                                        color: Colors.transparent,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(.5),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          )
                                        ],
                                      ),
                                      child: _assetsAudioPlayer.builderCurrent(
                                        builder: (BuildContext context, Playing playing) {
                                          if (playing == null) {
                                            return SizedBox(
                                              width: 20,
                                            );
                                          }
                                          var _trial = _assetsAudioPlayer.getCurrentAudioAlbum.toString();
                                          _assetsAudioPlayer.playlistAudioFinished.listen((data) {
                                            print('playlistAudioFinished : $data');
                                            _counter.value += 1;
                                            getColors();
                                          });
                                          return Image.file(
                                            File(app + _trial),
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                              back: GestureDetector(
                                onHorizontalDragEnd: (DragEndDetails details) {
                                  setState(() {
                                    cardKey.currentState.toggleCard();
                                    getColors();
                                  });
                                },
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 18.0, right: 18, top: 0, bottom: 0),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                "Up Next",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 250,
                                            width: Get.width,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius.all(Radius.circular(0)),
                                              // color: Colors.red,
                                              // boxShadow: [
                                              //   BoxShadow(
                                              //     color: Colors.white.withOpacity(.5),
                                              //     blurRadius: 20,
                                              //     spreadRadius: 5,
                                              //   )
                                              // ],
                                            ),
                                            child: Container(
                                              height: Get.height,
                                              child: _assetsAudioPlayer.builderCurrent(
                                                builder: (BuildContext context, Playing playing) {
                                                  if (playing == null) {
                                                    return SizedBox(
                                                      width: 20,
                                                    );
                                                  }
                                                  print(playing.index.toString());
                                                  return ListView.builder(
                                                    itemCount: _assetsAudioPlayer.playlist.audios.length,
                                                    itemBuilder: (_, index) {
                                                      return Visibility(
                                                        visible: index > playing.index,
                                                        child: ListTile(
                                                          onTap: () {
                                                            _assetsAudioPlayer.playlistPlayAtIndex(index).then((value) {
                                                              getColors();
                                                              // mystate(() {});
                                                              cardKey.currentState.toggleCard();
                                                              return null;
                                                            });
                                                          },
                                                          leading: CircleAvatar(
                                                            backgroundColor: Colors.black,
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(75.0),
                                                              child: Image.file(
                                                                File(
                                                                  app + _assetsAudioPlayer.playlist.audios[index].metas.album.toString(),
                                                                ),
                                                                fit: BoxFit.fill,
                                                              ),
                                                            ),
                                                          ),
                                                          title: Padding(
                                                            padding: const EdgeInsets.only(top: 8.0, left: 8),
                                                            child: AutoSizeText(
                                                              _assetsAudioPlayer.playlist.audios[index].metas.title.toString(),
                                                              maxLines: 1,
                                                              maxFontSize: 18,
                                                              minFontSize: 18,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: GoogleFonts.poppins(
                                                                fontWeight: FontWeight.w500,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ),
                                                          subtitle: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Padding(
                                                                  padding: EdgeInsets.only(top: 0.0, left: 8),
                                                                  child: AutoSizeText(
                                                                    _assetsAudioPlayer.playlist.audios[index].metas.artist.toString(),
                                                                    maxLines: 1,
                                                                    maxFontSize: 12,
                                                                    minFontSize: 12,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: GoogleFonts.poppins(
                                                                      fontWeight: FontWeight.w500,
                                                                      color: Colors.white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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

                          _assetsAudioPlayer.builderCurrent(builder: (context, Playing playing) {
                            return Column(children: <Widget>[
                              _assetsAudioPlayer.builderLoopMode(
                                builder: (context, loopMode) {
                                  return PlayerBuilder.isPlaying(
                                      player: _assetsAudioPlayer,
                                      builder: (context, isPlaying) {
                                        return PlayingControls(
                                          loopMode: loopMode,
                                          isPlaying: isPlaying,
                                          isPlaylist: true,
                                          // onStop: () {
                                          //   _assetsAudioPlayer.stop();
                                          // },
                                          toggleLoop: () {
                                            _assetsAudioPlayer.toggleLoop();
                                          },
                                          onPlay: () {
                                            _assetsAudioPlayer.playOrPause();
                                          },
                                          onNext: () {
                                            //_assetsAudioPlayer.forward(Duration(seconds: 10));
                                            _assetsAudioPlayer.next(keepLoopMode: true
                                                /*keepLoopMode: false*/);
                                          },
                                          onPrevious: () {
                                            _assetsAudioPlayer.previous(
                                                /*keepLoopMode: false*/);
                                          },
                                        );
                                      });
                                },
                              ),
                            ]);
                          }),
                          // Padding(
                          //   padding: const EdgeInsets.only(top: 0.0),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //     children: [
                          //       PlayerBuilder.isPlaying(
                          //         player: _assetsAudioPlayer,
                          //         builder: (context, isPlaying) {
                          //           return Container(
                          //             width: Get.width,
                          //             child: Padding(
                          //               padding: const EdgeInsets.only(top: 20.0),
                          //               child: Row(
                          //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //                 children: [
                          //                   GestureDetector(
                          //                     onTap: () {
                          //                       setState(() {
                          //                         _assetsAudioPlayer.toggleShuffle();
                          //                         if (_assetsAudioPlayer.shuffle) {
                          //                           print('shuffling');
                          //                         } else {
                          //                           print('not shufflig');
                          //                         }
                          //                       });
                          //                     },
                          //                     child: Container(
                          //                       height: 30,
                          //                       width: 30,
                          //                       child: _assetsAudioPlayer.shuffle
                          //                           ? Icon(
                          //                               Icons.shuffle,
                          //                               size: 20,
                          //                               color: Colors.white,
                          //                             )
                          //                           : Icon(
                          //                               Icons.shuffle,
                          //                               size: 20,
                          //                               color: Colors.grey,
                          //                             ),
                          //                     ),
                          //                   ),
                          //                   Container(
                          //                     height: 50,
                          //                     width: 50,
                          //                     child: IconButton(
                          //                       icon: Icon(
                          //                         Icons.skip_previous,
                          //                         size: 30,
                          //                         color: Colors.white,
                          //                       ),
                          //                       onPressed: () async {
                          //                         // setState(() {
                          //                         //   getColors();

                          //                         //   // colorFile = colorFile;
                          //                         //   // _updatePaletteGenerator(app + _assetsAudioPlayer.getCurrentAudioAlbum.toString());
                          //                         //   // colorFile = (app + _assetsAudioPlayer.getCurrentAudioAlbum.toString());
                          //                         // });
                          //                         _assetsAudioPlayer.previous().then((value) => getColors());
                          //                       },
                          //                     ),
                          //                   ),
                          //                   StreamBuilder(
                          //                     stream: _assetsAudioPlayer.isPlaying,
                          //                     initialData: false,
                          //                     builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                          //                       return Container(
                          //                         height: 80,
                          //                         width: 80,
                          //                         child: ElevatedButton(
                          //                           style: ButtonStyle(
                          //                             backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                          //                             shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
                          //                             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          //                               RoundedRectangleBorder(
                          //                                 borderRadius: BorderRadius.circular(90.0),
                          //                                 side: BorderSide(color: Colors.white),
                          //                               ),
                          //                             ),
                          //                           ),
                          //                           onPressed: () async {
                          //                             _assetsAudioPlayer.playOrPause();
                          //                           },
                          //                           child: snapshot.data
                          //                               ? Icon(
                          //                                   Icons.pause,
                          //                                   size: 40,
                          //                                   color: Colors.white,
                          //                                 )
                          //                               : Icon(
                          //                                   Icons.play_arrow,
                          //                                   size: 40,
                          //                                   color: Colors.white,
                          //                                 ),
                          //                         ),
                          //                       );
                          //                     },
                          //                   ),
                          //                   Container(
                          //                     height: 50,
                          //                     width: 50,
                          //                     child: IconButton(
                          //                       icon: Icon(
                          //                         Icons.skip_next,
                          //                         size: 30,
                          //                         color: Colors.white,
                          //                       ),
                          //                       onPressed: () async {
                          //                         _assetsAudioPlayer.next().then((value) => getColors());
                          //                         // setState(() {
                          //                         //   getColors();
                          //                         //   // _counter.value += 1;
                          //                         //   // colorFile = colorFile;
                          //                         //   // _updatePaletteGenerator(app + _assetsAudioPlayer.getCurrentAudioAlbum.toString());
                          //                         //   // _updatePaletteGenerator(app + _assetsAudioPlayer.getCurrentAudioAlbum.toString());
                          //                         //   // colorFile = (app + _assetsAudioPlayer.getCurrentAudioAlbum.toString());
                          //                         // });
                          //                       },
                          //                     ),
                          //                   ),
                          //                   GestureDetector(
                          //                     onTap: () {
                          //                       print('pressed');
                          //                       print(_assetsAudioPlayer.currentLoopMode);
                          //                       _assetsAudioPlayer.toggleLoop();
                          //                       setState(() {});
                          //                     },
                          //                     child: loopwidget(),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //           );
                          //         },
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: FutureBuilder<PaletteGenerator>(
                          //     future: _updatePaletteGenerator(), // async work
                          //     builder: (BuildContext context, AsyncSnapshot<PaletteGenerator> snapshot) {
                          //       switch (snapshot.connectionState) {
                          //         case ConnectionState.waiting:
                          //           return Center(child: CircularProgressIndicator());
                          //         default:
                          //           if (snapshot.hasError)
                          //             return new Text('Error: ${snapshot.error}');
                          //           else {
                          //             // Color color=new Color(snapshot.data.dominantColor.color);
                          //             face = snapshot.data.dominantColor.color;
                          //             print(snapshot.data.paletteColors);
                          //             return new Text('color: ${face.toString()}');
                          //           }
                          //       }
                          //     },
                          //   ),
                          // ),

                          // Container(height: Get.height, color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          valueListenable: _counter,
        ),
      ),
    );
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    // _updatePaletteGenerator(colorFile);
    _subscriptions.add(_assetsAudioPlayer.playlistAudioFinished.listen((data) {
      print('playlistAudioFinished : $data');
      _counter.value += 1;
      getColors();
    }));
    _subscriptions.add(_assetsAudioPlayer.audioSessionId.listen((sessionId) {
      print('audioSessionId : $sessionId');
    }));
    _subscriptions.add(AssetsAudioPlayer.addNotificationOpenAction((notification) {
      return false;
    }));

    _showUpNext = false;
    currentIndex = 0;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 0),
    );
    // _allfunctions();
    _isLoaded = false;
    // _updatePaletteGenerator(app + _assetsAudioPlayer.getCurrentAudioAlbum.toString());
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
        child: Padding(
          padding: Platform.isAndroid ? const EdgeInsets.only(bottom: 16.0) : const EdgeInsets.only(bottom: 0.0),
          child: IconButton(
            icon: Icon(Icons.music_note_rounded, color: selected ? Colors.white : Colors.grey),
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
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            pageSnapping: true,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              DashPlaylist(playlist: playlist, callback: (val) => setState(() => _string = val)),
              ShowList(
                playlist: playlist,
              ),
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
                        barrierColor: Colors.black.withOpacity(0.0),
                        transitionDuration: Duration(milliseconds: 150),
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
                        barrierColor: Colors.black.withOpacity(0.0),
                        transitionDuration: Duration(milliseconds: 150),
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
