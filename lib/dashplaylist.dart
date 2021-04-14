import 'dart:io';
import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yt_otg/trial.dart';
import 'package:path/path.dart' as path;
import 'dashplayer.dart';
import 'downloader.dart';
import 'model./singleAudio.dart';

class DashPlaylist extends StatefulWidget {
  final Function() notifyParent;

  const DashPlaylist({Key key, this.notifyParent}) : super(key: key);

  @override
  _DashPlaylistState createState() => _DashPlaylistState();
}

class _DashPlaylistState extends State<DashPlaylist> {
  List<Audio> audios = [];
  List<String> pathfin2 = [];
  List<String> pathfinal = [];

  _allfunctions() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> _files;
    List<FileSystemEntity> _songs = [];
    _files = appDocDir.listSync(recursive: true, followLinks: false);
    for (FileSystemEntity entity in _files) {
      String path = entity.path;
      if (path.endsWith('.webm')) {
        _songs.add(entity);
        var pos = entity.toString().lastIndexOf('/');
        String result = (pos != -1) ? entity.toString().substring(pos + 1) : entity.toString();
        result = result.substring(0, result.length - 1);
        pathfin2.add(result);
        var resultpath = appDocDir.uri.toFilePath().toString() + result;
        pathfinal.add(resultpath);
      }
    }
    setState(() {
      print(pathfinal);
      print(pathfin2);
    });

    // url.add('https://i1.sndcdn.com/artworks-000419491731-f34a2h-t500x500.jpg');
    // pathfin2.forEach((element) {
    //   audios.add(Audio.file(
    //     path.join(appDocDir.uri.toFilePath(), element).toString(),
    //     metas: Metas(
    //       id: path.join(appDocDir.uri.toFilePath(), element).toString(),
    //       title: 'Hello There!',
    //       artist: 'John',
    //       album: 'Soft',
    //       image: MetasImage.network('https://images.genius.com/7c1259227a882c3db656e53184128862.1000x1000x1.jpg'),
    //     ),
    //   ));
    // });

    // print(audios);
  }

  @override
  void initState() {
    // TODO: implement initState
    _allfunctions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
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
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
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
                      Padding(
                        padding: const EdgeInsets.only(left: 0.0, top: 40),
                        child: IconButton(
                          icon: Icon(
                            Icons.notes,
                            size: 40,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            print('Pressed');
                            Get.to(PickDL());
                          },
                        ),
                      ),
                    ],
                  ),
                ],
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
                            itemCount: pathfin2.length,
                            itemBuilder: (_, index) {
                              return Dismissible(
                                key: Key('item ${pathfin2[index]}'),
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
                                    // titleList.remove(titleList[index]);
                                    // authornameList.remove(authornameList[index]);
                                    // thumbnailList.remove(thumbnailList[index]);
                                    // urlList.remove(urlList[index]);
                                  } else {
                                    // titleList.remove(titleList[index]);
                                    // authornameList.remove(authornameList[index]);
                                    // thumbnailList.remove(thumbnailList[index]);
                                    // urlList.remove(urlList[index]);
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
                                            child: Icon(Icons.music_note),
                                            // child: CircleAvatar(
                                            //     // backgroundImage: NetworkImage(pathfin2[index].toString()),
                                            //     ),
                                          ),
                                          title: Padding(
                                            padding: const EdgeInsets.only(top: 8.0, left: 8),
                                            child: AutoSizeText(
                                              pathfin2[index].toString(),
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
                                                child: Padding(
                                                  padding: EdgeInsets.only(top: 0.0, left: 8),
                                                  child: AutoSizeText(
                                                    pathfinal[index].toString(),
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
                                          onTap: () {
                                            print(pathfinal[index].toString());
                                            setState(() {
                                              SingleAudio.singlePath = pathfinal[index].toString();
                                            });
                                            widget.notifyParent();
                                          },
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
      ),
    );
  }
}
