import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
// import 'package:downloads_path_provider/downloads_path_provider.dart';
// import 'package:draggable_floating_button/draggable_floating_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path/path.dart' as path;

import 'model/dbProvider.dart';
import 'model/downloadModel.dart';

class PickDL extends StatefulWidget {
  final Function() notifyList;

  const PickDL({Key key, this.notifyList}) : super(key: key);

  @override
  _PickDLState createState() => _PickDLState();
}

class _PickDLState extends State<PickDL> {
  Completer<WebViewController> _controller = Completer<WebViewController>();

  bool _isDownloading = false;
  List<String> titleList = [];
  List<String> authorList = [];
  List<String> thumbList = [];
  List<String> urlList = [];

  List<String> _titleList = [];
  List<String> _authorList = [];
  List<String> _thumbList = [];
  List<String> _urlList = [];
  final yt = YoutubeExplode();

  StateSetter _setState;
  int indexNow;

  MemoDbProvider musicDB = MemoDbProvider();
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  _anotherBookmark() {
    return FutureBuilder<WebViewController>(
      future: _controller.future,
      builder: (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        if (controller.hasData) {
          return FloatingActionButton(
            splashColor: Colors.white,
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: () async {
              var url = await controller.data.currentUrl();
              print(url);

              if (url.length == 22) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text('Empty.'),
                      );
                    });
              }

              if (url == 'https://m.youtube.com/channel/UC-9-kyTW8ZkZNDHQJ6FgpwQ') {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text('Invalid Video'),
                      );
                    });
              }

              if (url.length == 41) {
                var yt = YoutubeExplode();
                var playlist = await yt.videos.get(url);
                var check = await musicDB.getcount(url.toString());

                if (check.toString() == '1') {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text('Video is already downloaded on this phone.'),
                        );
                      });
                } else {
                  urlList.add(playlist.url);
                  titleList.add(playlist.title);
                  authorList.add(playlist.author);
                  thumbList.add(playlist.thumbnails.highResUrl);

                  _urlList.add(playlist.url);
                  _titleList.add(playlist.title);
                  _authorList.add(playlist.author);
                  _thumbList.add(playlist.thumbnails.highResUrl);

                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text('Video added to download list.'),
                        );
                      });
                }
              }

              if (url.length >= 70) {
                var yt = YoutubeExplode();
                var playlist = await yt.playlists.get(url);

                await for (var video in yt.playlists.getVideos(playlist.id)) {
                  var videoTitle = video.title;
                  var videoAuthor = video.author;
                  var videoUrl = video.url;
                  var videoThumbnail = video.thumbnails.highResUrl;
                  var check = await musicDB.getcount(videoUrl.toString());

                  if (check.toString() == '1') {
                    print(videoUrl.toString());

                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text('$videoTitle is already downloaded on this phone. Therefore deleting it on the download list.'),
                          );
                        });
                  } else {
                    if (urlList.contains(videoUrl)) {
                    } else {
                      urlList.add(videoUrl);
                      titleList.add(videoTitle);
                      authorList.add(videoAuthor);
                      thumbList.add(videoThumbnail);

                      _urlList.add(videoUrl);
                      _titleList.add(videoTitle);
                      _authorList.add(videoAuthor);
                      _thumbList.add(videoThumbnail);
                    }
                  }
                }

                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text('Vidoes added to download list.'),
                      );
                    });
              }
            },
            child: Icon(Icons.favorite, color: Colors.white),
          );
        }
        return Container();
      },
    );
  }

  Future<void> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        setState(() {});
      }
    } catch (e) {
      // Error in getting access to the file.
    }
  }

  _downloadFunc() async {
    _setState(() {
      _isDownloading = true;
    });

    for (var i = 0; i < urlList.length; i++) {
      _setState(() {
        indexNow = i;
      });
      var yt = YoutubeExplode();
      var id = VideoId(urlList[i]);
      _isDownloading = true;
      await Permission.storage.request();
      var manifest = await yt.videos.streamsClient.getManifest(id);
      var audio = manifest.audioOnly.last;
      Directory appDocDir = await getApplicationDocumentsDirectory();
      var tempTitle = '${titleList[i]}'.replaceAll(r'\', '').replaceAll('/', '').replaceAll('*', '').replaceAll('?', '').replaceAll('"', '').replaceAll('<', '').replaceAll('>', '').replaceAll('|', '').replaceAll('{', '').replaceAll('}', '').replaceAll('\'', '');
      var tempPath = '${titleList[i]}.${audio.container.name}'.replaceAll(r'\', '').replaceAll('/', '').replaceAll('*', '').replaceAll('?', '').replaceAll('"', '').replaceAll('<', '').replaceAll('>', '').replaceAll('|', '').replaceAll('{', '').replaceAll('}', '').replaceAll('\'', '');
      var filePath = path.join(appDocDir.uri.toFilePath(), tempPath);

      print(filePath.toString());
      var file = File(filePath);
      var fileStream = file.openWrite();
      await yt.videos.streamsClient.get(audio).pipe(fileStream);

      await fileStream.flush();
      await fileStream.close();
      // yt.close();

      var fileq = path.join(appDocDir.uri.toFilePath(), tempPath);
      var filePath2 = path.join(appDocDir.uri.toFilePath(), '${tempTitle}1.mp4');
      var filey = File(fileq);
      var filex = File(filePath2);
      if (await filex.exists()) {
        await filex.delete();
      }

      String okay2 = '\"${filex.path}\"';
      String okay = '\"${filey.path}\"';

      await _flutterFFmpeg.execute("-i $okay -q:a 0 -map a $okay2").then((rt) async {
        print('[TRIMMED VIDEO RESULT] : $rt');

        final response = await http.get(Uri.parse(thumbList[i]));
        var split = urlList[i].toString().substring(30);
        File file2 = new File(path.join(appDocDir.uri.toFilePath(), '$split.jpg'));
        file2.writeAsBytesSync(response.bodyBytes);

        var fileCon = path.join(appDocDir.uri.toFilePath(), tempPath);
        deleteFile(File(fileCon));

        final memo = DlModel(
          urlList[i],
          titleList[i].replaceAll(r'\', '').replaceAll('/', '').replaceAll('*', '').replaceAll('?', '').replaceAll('"', '').replaceAll('<', '').replaceAll('>', '').replaceAll('|', '').replaceAll('{', '').replaceAll('}', '').replaceAll('\'', ''),
          authorList[i].replaceAll(r'\', '').replaceAll('/', '').replaceAll('*', '').replaceAll('?', '').replaceAll('"', '').replaceAll('<', '').replaceAll('>', '').replaceAll('|', '').replaceAll('{', '').replaceAll('}', '').replaceAll('\'', ''),
          '$split.jpg',
          '${tempTitle}1.mp4'.replaceAll(r'\', '').replaceAll('/', '').replaceAll('*', '').replaceAll('?', '').replaceAll('"', '').replaceAll('<', '').replaceAll('>', '').replaceAll('|', '').replaceAll('{', '').replaceAll('}', '').replaceAll('\'', ''),
        );
        await musicDB.addItem(memo);

        _setState(() {});
      });

      // await _flutterFFmpeg.execute("-i 00:00:00 -q:a 0 -map a $okay2").then((rt) async {
      //   print('[TRIMMED VIDEO RESULT] : $rt');

      //   setState(() {
      //     titleList.remove(titleList[i]);
      //     authornameList.remove(authornameList[i]);
      //     thumbnailList.remove(thumbnailList[i]);
      //     urlList.remove(urlList[i]);
      //   });
      //   await showDialog(
      //     context: context,
      //     builder: (context) {
      //       return AlertDialog(
      //         content: Text('Download completed!'),
      //       );
      //     },
      //   );
      // });

    }
    _setState(() {
      indexNow = indexNow + 1;

      urlList = [];
      titleList = [];
      authorList = [];
      thumbList = [];

      _urlList = [];
      _titleList = [];
      _authorList = [];
      _thumbList = [];

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Download completed!'),
          );
        },
      ).then((value) => {
            Get.back(),
          });
      _isDownloading = false;
    });
  }

  _downloadList() {
    return StatefulBuilder(builder: (context, setState) {
      _setState = setState;
      return Dismissible(
        key: Key('some key here'),
        direction: DismissDirection.down,
        onDismissed: (_) {
          Get.back();
        },
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: new LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context).colorScheme.primaryVariant,
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 25, top: 80),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Download List',
                          style: GoogleFonts.poppins(
                            fontSize: 23,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        Spacer(),
                        _isDownloading
                            ? Container(
                                height: 40,
                                width: 40,
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        border: Border.all(color: Colors.white),
                                        borderRadius: BorderRadius.all(Radius.circular(90)),
                                        color: Colors.transparent,
                                      ),
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xffC06C84)),
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                    Center(child: Icon(Icons.download_sharp, color: Colors.white)),
                                  ],
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  if (titleList.length != 0) {
                                    _downloadFunc();
                                    indexNow = 0;
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: Text('Download list is empty.'),
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.all(Radius.circular(90)),
                                    color: Colors.transparent,
                                  ),
                                  child: Icon(Icons.download_sharp, color: Colors.white),
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 100.0,
                  bottom: 60,
                ),
                child: _isDownloading
                    ? ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 50.0),
                            child: Container(
                              height: Get.height,
                              width: Get.width,
                              decoration: BoxDecoration(
                                gradient: new LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.secondary,
                                      Theme.of(context).colorScheme.primaryVariant,
                                    ],
                                    begin: const FractionalOffset(0.0, 0.0),
                                    end: const FractionalOffset(1.0, 1.0),
                                    stops: [0.0, 1.0, 1.0],
                                    tileMode: TileMode.clamp),
                              ),
                              child: Container(
                                child: ListView.builder(
                                  itemCount: _titleList.length,
                                  itemBuilder: (_, index) {
                                    return Column(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 5.0, left: 8.0, right: 8.0),
                                          child: Container(
                                            height: 70,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                            ),
                                            child: ListTile(
                                              leading: Container(
                                                padding: EdgeInsets.only(left: 8.0, top: 10),
                                                child: CircleAvatar(
                                                  backgroundImage: NetworkImage(_thumbList[index].toString()),
                                                ),
                                              ),
                                              title: Padding(
                                                padding: const EdgeInsets.only(top: 8.0, left: 8),
                                                child: AutoSizeText(
                                                  _titleList[index].toString(),
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
                                                        _authorList[index].toString(),
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
                                                  index == indexNow
                                                      ? Expanded(
                                                          child: Container(
                                                            width: Get.width,
                                                            child: LinearProgressIndicator(
                                                              backgroundColor: Color(0xffC06C84),
                                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                            ),
                                                          ),
                                                        )
                                                      : Expanded(child: Container(width: Get.width, child: Text(''))),
                                                  index != indexNow && index < indexNow
                                                      ? Expanded(
                                                          child: Container(
                                                            width: Get.width,
                                                            child: Text(
                                                              'Downloaded',
                                                              style: TextStyle(color: Colors.white),
                                                            ),
                                                          ),
                                                        )
                                                      : Expanded(
                                                          child: Container(
                                                            width: Get.width,
                                                            child: Text(
                                                              '  Waiting...',
                                                              style: TextStyle(color: Colors.white),
                                                            ),
                                                          ),
                                                        ),
                                                ],
                                              ),
                                              onTap: () {},
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0),
                            child: Container(
                              height: Get.height,
                              width: Get.width,
                              decoration: BoxDecoration(
                                gradient: new LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.secondary,
                                      Theme.of(context).colorScheme.primaryVariant,
                                    ],
                                    begin: const FractionalOffset(0.0, 0.0),
                                    end: const FractionalOffset(1.0, 1.0),
                                    stops: [0.0, 1.0, 1.0],
                                    tileMode: TileMode.clamp),
                              ),
                              child: Container(
                                child: ListView.builder(
                                  itemCount: titleList.length,
                                  itemBuilder: (_, index) {
                                    return Dismissible(
                                      key: Key('item ${titleList[index]}'),
                                      background: Container(
                                        color: Colors.red,
                                        child: Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, color: Colors.white),
                                              Text('Remove from list', style: TextStyle(color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      onDismissed: (DismissDirection direction) {
                                        if (direction == DismissDirection.startToEnd) {
                                          titleList.remove(titleList[index]);
                                          authorList.remove(authorList[index]);
                                          thumbList.remove(thumbList[index]);
                                          urlList.remove(urlList[index]);

                                          _urlList.remove(_urlList[index]);
                                          _titleList.remove(_titleList[index]);
                                          _authorList.remove(_authorList[index]);
                                          _thumbList.remove(_thumbList[index]);
                                        } else {
                                          titleList.remove(titleList[index]);
                                          authorList.remove(authorList[index]);
                                          thumbList.remove(thumbList[index]);
                                          urlList.remove(urlList[index]);

                                          _urlList.remove(_urlList[index]);
                                          _titleList.remove(_titleList[index]);
                                          _authorList.remove(_authorList[index]);
                                          _thumbList.remove(_thumbList[index]);
                                        }
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 5.0, left: 8.0, right: 8.0),
                                            child: Container(
                                              height: 70,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                              ),
                                              child: ListTile(
                                                leading: Container(
                                                  padding: EdgeInsets.only(left: 8.0, top: 10),
                                                  child: CircleAvatar(
                                                    backgroundImage: NetworkImage(thumbList[index].toString()),
                                                  ),
                                                ),
                                                title: Padding(
                                                  padding: const EdgeInsets.only(top: 8.0, left: 8),
                                                  child: AutoSizeText(
                                                    titleList[index].toString(),
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
                                                          authorList[index].toString(),
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
                                                onTap: () {},
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
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        print('Backbutton pressed (device or appbar button), do whatever you want.');
        widget.notifyList();
        Get.back();
        return Future.value(false);
      },
      child: Scaffold(
        body: Container(
          height: Get.height,
          decoration: BoxDecoration(
            gradient: new LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.primaryVariant,
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 1.0),
                stops: [0.0, 1.0, 1.0],
                tileMode: TileMode.clamp),
          ),
          child: Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 0, right: 0),
                  child: Container(
                    width: Get.width,
                    child: Column(
                      children: [
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 0.0, right: 0, bottom: 0, top: 3),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.arrow_back_ios,
                                      size: 25,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      widget.notifyList();
                                      Get.back();
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 0.0, right: 15, bottom: 10, top: 12),
                                  child: Text(
                                    'Browse & Save',
                                    style: GoogleFonts.poppins(
                                      fontSize: 23,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    print("CLICKED DOWNLOAD");
                                    showGeneralDialog(
                                      barrierLabel: "Label",
                                      barrierDismissible: false,
                                      barrierColor: Colors.black.withOpacity(0.2),
                                      transitionDuration: Duration(milliseconds: 200),
                                      context: context,
                                      pageBuilder: (context, anim1, anim2) {
                                        return _downloadList();
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
                                    height: 40,
                                    width: 40,
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            border: Border.all(color: Colors.white),
                                            borderRadius: BorderRadius.all(Radius.circular(90)),
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        Center(child: Icon(Icons.archive, color: Colors.white)),
                                      ],
                                    ),
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
              ),
              Padding(
                padding: const EdgeInsets.only(left: 0.0, right: 0, top: 150),
                child: Stack(
                  children: [
                    Container(
                      height: Get.height,
                      width: Get.width,
                      child: WebView(
                        initialUrl: 'https://www.youtube.com/channel/UC-9-kyTW8ZkZNDHQJ6FgpwQ',
                        javascriptMode: JavascriptMode.unrestricted,
                        onWebViewCreated: (WebViewController webViewController) {
                          _controller.complete(webViewController);
                        },
                        allowsInlineMediaPlayback: true,
                        initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.require_user_action_for_all_media_types,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(left: 28.0, bottom: 40),
          child: _anotherBookmark(),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(top: 0.0, bottom: 0),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: new LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.primaryVariant,
                  ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.0, 1.0),
                  stops: [0.0, 1.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NavigationControls(_controller.future),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture) : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder: (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady = snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        return Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              GestureDetector(
                onTap: !webViewReady ? null : () => navigate(context, controller, goBack: true),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chevron_left_outlined,
                        size: 40,
                        color: Colors.white,
                      ),
                      Text(
                        'Back   ',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  controller.reload();
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Icon(
                    Icons.refresh,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
              ),
              GestureDetector(
                onTap: !webViewReady ? null : () => navigate(context, controller, goBack: false),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, right: 0),
                  child: Row(
                    children: [
                      Text(
                        'Forward',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_outlined,
                        size: 40,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  navigate(BuildContext context, WebViewController controller, {bool goBack: false}) async {
    bool canNavigate = goBack ? await controller.canGoBack() : await controller.canGoForward();
    if (canNavigate) {
      goBack ? controller.goBack() : controller.goForward();
    } else {
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text("No ${goBack ? 'back' : 'forward'} history item")),
      );
    }
  }
}
