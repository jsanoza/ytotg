import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
// import 'package:downloads_path_provider/downloads_path_provider.dart';
// import 'package:draggable_floating_button/draggable_floating_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path/path.dart' as path;

class PickDL extends StatefulWidget {
  @override
  _PickDLState createState() => _PickDLState();
}

class _PickDLState extends State<PickDL> {
  Completer<WebViewController> _controller = Completer<WebViewController>();
  List<String> titleList = [];
  List<String> authornameList = [];
  List<String> thumbnailList = [];
  List<String> urlList = [];
  bool _isDownloading = false;
  GlobalKey _toolTipKey = GlobalKey();
  final yt = YoutubeExplode();

  Future<dynamic> getDetail(String userUrl) async {
    // Uri.parse('https://swapi.co/api/people')
    String embedUrl = "https://www.youtube.com/oembed?url=$userUrl&format=json";
    var res = await http.get(Uri.parse(embedUrl));
    print("get youtube detail status code: " + res.statusCode.toString());

    try {
      if (res.statusCode == 200) {
        return json.decode(res.body);
      } else {
        return null;
      }
    } on FormatException catch (e) {
      print('invalid JSON' + e.toString());
      return null;
    }
  }

  _changeurl(String url) async {
    // url.replaceAll('m.', 'www.');
    var split = url.substring(10);
    var finalurl = 'https://www.' + split;
    // print(finalurl);
    if (finalurl.length > 43) {
      finalurl = finalurl.substring(0, 43);
      print(finalurl);
      var jsonData = await getDetail(finalurl);
      String title = jsonData['title'];
      String authorname = jsonData['author_name'];
      String thumbnail = jsonData['thumbnail_url'];
      urlList.add(url);
      titleList.add(title);
      authornameList.add(authorname);
      thumbnailList.add(thumbnail);
      print(title + ' ' + authorname + ' ' + thumbnail);
    } else {
      finalurl = finalurl;
      var jsonData = await getDetail(finalurl);
      String title = jsonData['title'];
      String authorname = jsonData['author_name'];
      String thumbnail = jsonData['thumbnail_url'];
      urlList.add(url);
      titleList.add(title);
      authornameList.add(authorname);
      thumbnailList.add(thumbnail);
      print(title + ' ' + authorname + ' ' + thumbnail);
    }
  }

  _bookmarkButton() {
    return FutureBuilder<WebViewController>(
      future: _controller.future,
      builder: (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        if (controller.hasData) {
          return FloatingActionButton(
            onPressed: () async {
              var url = await controller.data.currentUrl();
              print(url);
              print(url.length);

              if (url.length > 43) {
                print(url.substring(41, 46));
                var checkiflist = url.substring(41, 46);
                if (checkiflist == '&list') {
                  if (urlList.contains(url)) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Selected video is already on the list.'),
                      ),
                    );
                  } else {
                    _changeurl(url);
                    Get.snackbar('Successfully added.', 'Head to the download page to download now :)');
                  }
                } else {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select a video.'),
                    ),
                  );
                }
              } else {
                if (url.length == 22) {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select a video.'),
                    ),
                  );
                } else {
                  if (urlList.contains(url)) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Selected video is already on the list.'),
                      ),
                    );
                  } else {
                    _changeurl(url);
                    Get.snackbar('Successfully added.', 'Head to the download page to download now :)');
                  }
                }
              }
            },
            child: Icon(Icons.favorite),
          );
        }
        return Container();
      },
    );
  }

  _downloadFunc() async {
    var yt = YoutubeExplode();
    print(urlList.toString());
    for (var i = 0; i < urlList.length; i++) {
      var id = VideoId(urlList[i]);
      var video = await yt.videos.get(id);
      // Display info about this video.
      _isDownloading = true;
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Title: ${video.title}, Duration: ${video.duration}'),
          );
        },
      );
      // Request permission to write in an external directory.
      // (In this case downloads)
      await Permission.storage.request();

      // Get the streams manifest and the audio track.
      var manifest = await yt.videos.streamsClient.getManifest(id);
      var audio = manifest.audioOnly.last;

      // Build the directory.
      Directory appDocDir = await getApplicationDocumentsDirectory();
      // var dir = await DownloadsPathProvider.downloadsDirectory;
      var filePath = path.join(appDocDir.uri.toFilePath(), '${titleList[i]}.${audio.container.name}');
      print(filePath.toString());
      // Open the file to write.
      var file = File(filePath);
      var fileStream = file.openWrite();

      // Pipe all the content of the stream into our file.
      await yt.videos.streamsClient.get(audio).pipe(fileStream);
      /*
                        If you want to show a % of download, you should listen
                        to the stream instead of using `pipe` and compare
                        the current downloaded streams to the totalBytes,
                        see an example ii example/video_download.dart
                        */

      // Close the file.
      await fileStream.flush();
      await fileStream.close();

      // Show that the file was downloaded.
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Download completed and saved to: $filePath'),
          );
        },
      );
    }
  }

  _downloadlist() {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: new BorderRadius.only(topRight: new Radius.circular(10.0), topLeft: new Radius.circular(10.0)),
            color: Colors.white,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
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
                                  borderRadius: BorderRadius.all(Radius.circular(30)),
                                  color: Colors.blue,
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
                                ),
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.download_sharp,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  print("CLICKED DOWNLOAD");
                                  // _downloadFunc();
                                },
                              ),
                            ],
                          ),
                        )
                      : Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            color: Colors.blue,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.download_sharp,
                              size: 20,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              print("CLICKED DOWNLOAD");
                              _downloadFunc();
                            },
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 75.0,
          ),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 0.0),
                child: Container(
                    height: Get.height,
                    width: Get.width,
                    color: Colors.white,
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
                                authornameList.remove(authornameList[index]);
                                thumbnailList.remove(thumbnailList[index]);
                                urlList.remove(urlList[index]);
                              } else {
                                titleList.remove(titleList[index]);
                                authornameList.remove(authornameList[index]);
                                thumbnailList.remove(thumbnailList[index]);
                                urlList.remove(urlList[index]);
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
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                      color: Colors.white,
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 30, spreadRadius: 5)],
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        padding: EdgeInsets.only(left: 8.0, top: 10),
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(thumbnailList[index].toString()),
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
                                          ),
                                        ),
                                      ),
                                      subtitle: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              width: Get.width,
                                              child: LinearProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(top: 0.0, left: 8),
                                              child: AutoSizeText(
                                                authornameList[index].toString(),
                                                maxLines: 1,
                                                maxFontSize: 12,
                                                minFontSize: 12,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
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
                    )),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.height,
        decoration: BoxDecoration(
          gradient: new LinearGradient(
              colors: [
                Color(0xff2C3E50),
                Color(0xff355C7D),
                Color(0xff28313B),
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
                padding: const EdgeInsets.only(top: 0.0, left: 0, right: 0),
                child: Container(
                  width: Get.width,
                  height: 160,
                  child: Column(
                    children: [
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 0.0, right: 0, bottom: 10, top: 15),
                                child: Text(
                                  'Browse & Save',
                                  style: GoogleFonts.poppins(
                                    fontSize: 30,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(left: 0.0, right: 0, bottom: 0, top: 0),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.archive,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      showCupertinoModalBottomSheet(
                                        context: context,
                                        builder: (context) => _downloadlist(),
                                      );
                                    },
                                  )),
                              // Padding(
                              //   padding: const EdgeInsets.only(left: 0.0, right: 0, bottom: 8, top: 15),
                              //   child: GestureDetector(
                              //     onTap: () {
                              //       final dynamic tooltip = _toolTipKey.currentState;
                              //       tooltip.ensureTooltipVisible();
                              //     },
                              //     child: Tooltip(
                              //       key: _toolTipKey,
                              //       // ignore: missing_required_param
                              //       child: IconButton(
                              //         icon: Icon(
                              //           Icons.info,
                              //           size: 25.0,
                              //           color: Colors.white,
                              //         ),
                              //         onPressed: () {},
                              //       ),
                              //       message: 'Search and select your video then tap the ♥\nbutton to add the selection to your download list.',
                              //       padding: EdgeInsets.all(20),
                              //       margin: EdgeInsets.all(20),
                              //       showDuration: Duration(seconds: 10),
                              //       decoration: BoxDecoration(
                              //         color: Colors.blue.withOpacity(0.9),
                              //         borderRadius: const BorderRadius.all(Radius.circular(4)),
                              //       ),
                              //       textStyle: TextStyle(color: Colors.white),
                              //       preferBelow: true,
                              //       verticalOffset: 20,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                        child: Container(
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              NavigationControls(_controller.future),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Center(
            //   child: Text("Connect to youtube?"),
            // ),
            Padding(
              padding: const EdgeInsets.only(left: 0.0, right: 0, top: 140),
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
        child: _bookmarkButton(),
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              GestureDetector(
                onTap: !webViewReady ? null : () => navigate(context, controller, goBack: true),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chevron_left_outlined,
                        size: 28,
                      ),
                      Text(
                        'Back',
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'https://www.youtube.com',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: !webViewReady ? null : () => navigate(context, controller, goBack: false),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Text(
                        'Forward',
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_outlined,
                        size: 28,
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
