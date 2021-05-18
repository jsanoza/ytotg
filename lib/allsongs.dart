import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yt_otg/playlist/editplaylist.dart';

import 'model/dbProvider.dart';
import 'model/downloadModel.dart';

Future<List<DlModel>> fetchEmployeesFromDatabase() async {
  var dbHelper = MemoDbProvider();
  Future<List<DlModel>> employees = dbHelper.getEmployees();
  return employees;
}

Future<List<DlModel>> _myData = fetchEmployeesFromDatabase();

class AllSongs extends StatefulWidget {
  final String playlistName;
  final Function() check;

  const AllSongs({Key key, this.playlistName, this.check}) : super(key: key);
  @override
  _AllSongsState createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  Directory appDocDir;
  List<String> indexwhat = [];
  List<String> trackName = [];
  List<String> thumbNail = [];
  List<String> title = [];
  bool _showSave = false;
  MemoDbProvider musicDB = MemoDbProvider();
  _allfunctions() async {
    appDocDir = await getApplicationDocumentsDirectory();
  }

  @override
  void initState() {
    _allfunctions();
    print(widget.playlistName);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
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
              padding: const EdgeInsets.only(top: 58.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 50,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 30.0,
                            top: 15,
                            // bottom: 5
                          ),
                          child: Text(
                            "All Songs",
                            style: GoogleFonts.poppins(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  _showSave == true && indexwhat.length != 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                AddPlaylistModel songToAdd;
                                for (var i = 0; i < indexwhat.length; i++) {
                                  var firstres = await musicDB.getSongsPlaylist(widget.playlistName.toString());
                                  // var firstcheck = firstres.last;
                                  if (firstres.length == 0) {
                                    songToAdd = AddPlaylistModel(
                                      widget.playlistName,
                                      trackName[i],
                                      thumbNail[i],
                                      0,
                                      title[i],
                                    );
                                    await musicDB.addtoPlaylist(songToAdd).then((value) => {
                                          print('Saved!'),
                                          print("dito ako"),
                                        });
                                  } else if (firstres.length != 0) {
                                    var finalLasxt = firstres.last;
                                    var hellotherewhateverx = finalLasxt.indexinPlaylist;
                                    songToAdd = AddPlaylistModel(
                                      widget.playlistName,
                                      trackName[i],
                                      thumbNail[i],
                                      hellotherewhateverx + 1,
                                      title[i],
                                    );
                                    await musicDB.addtoPlaylist(songToAdd).then((value) => {
                                          print('Saved!'),
                                          print("dito ako2"),
                                          print(hellotherewhateverx),
                                        });
                                    hellotherewhateverx = 0;
                                  }
                                }
                                setState(() {
                                  indexwhat = [];
                                  thumbNail = [];
                                  trackName = [];
                                });
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: Text('Added to playlist!'),
                                      );
                                    }).then((value) {
                                  Get.back();
                                  widget.check();
                                });
                              },
                              child: Container(
                                height: 50,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    right: 30.0,
                                    top: 15,
                                  ),
                                  child: Icon(
                                    Icons.add_circle_outline,
                                    size: 35,
                                    color: Colors.pink[200],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 108.0),
              child: Container(
                height: Get.height,
                child: new FutureBuilder<List<DlModel>>(
                  future: _myData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (_, index) {
                            snapshot.data.forEach((element) {
                              // PlaylistAudio.path.add(element.pathList);
                              // PlaylistAudio.artist.add(element.authornameList);
                              // PlaylistAudio.image.add(element.thumbnailList);
                              // PlaylistAudio.title.add(element.titleList);
                            });

                            return Stack(
                              children: <Widget>[
                                indexwhat.contains(index.toString())
                                    ? Align(
                                        alignment: Alignment.topRight,
                                        child: Icon(
                                          Icons.verified_outlined,
                                          color: Colors.pink[200],
                                        ),
                                      )
                                    : Container(),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5.0, left: 8.0, right: 8.0),
                                  child: Container(
                                    height: 70,
                                    decoration: BoxDecoration(
                                      // color: Colors.white,
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.black,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(75.0),
                                          child: Image.file(
                                            File(
                                              appDocDir.uri.toFilePath().toString() + snapshot.data[snapshot.data.length - index - 1].thumbnailList.toString(),
                                            ),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      title: Padding(
                                        padding: const EdgeInsets.only(top: 8.0, left: 8),
                                        child: AutoSizeText(
                                          snapshot.data[snapshot.data.length - index - 1].titleList.toString(),
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
                                                snapshot.data[snapshot.data.length - index - 1].authornameList.toString().toString(),
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
                                      onTap: () async {
                                        setState(() {
                                          _showSave = true;
                                          if (indexwhat.contains(index.toString())) {
                                            indexwhat.remove(index.toString());
                                            // playlistwhat.remove(snapshot.data[snapshot.data.length - index - 1].playlistName.toString());
                                            thumbNail.remove(snapshot.data[snapshot.data.length - index - 1].thumbnailList.toString().toString());
                                            trackName.remove(snapshot.data[snapshot.data.length - index - 1].pathList.toString().toString());
                                            title.remove(snapshot.data[snapshot.data.length - index - 1].titleList.toString().toString());
                                          } else {
                                            indexwhat.add(index.toString());
                                            thumbNail.add(snapshot.data[snapshot.data.length - index - 1].thumbnailList.toString().toString());
                                            trackName.add(snapshot.data[snapshot.data.length - index - 1].pathList.toString().toString());
                                            title.add(snapshot.data[snapshot.data.length - index - 1].titleList.toString().toString());
                                            // playlistwhat.add(snapshot.data[snapshot.data.length - index - 1].playlistName.toString());
                                            print(indexwhat);
                                          }
                                        });
                                        // SingleAudio.fromwhere = '';
                                        // audios.clear();
                                        // audios = [];
                                        // var resx = await dbHelper.getEmployees();
                                        // for (var files in resx) {
                                        //   audios.add(Audio.file(
                                        //     appDocDir.uri.toFilePath().toString() + files.pathList.toString(),
                                        //     metas: Metas(
                                        //       id: files.pathList.toString(),
                                        //       title: files.titleList.toString(),
                                        //       artist: files.authornameList.toString(),
                                        //       album: files.thumbnailList.toString(),
                                        //       image: MetasImage.asset("assets/images/aa.jpeg"),
                                        //     ),
                                        //   ));
                                        // }
                                        // setState(() {
                                        //   SingleAudio.fromwhere = 'randomplay';
                                        //   SingleAudio.singlePath = snapshot.data[snapshot.data.length - index - 1].pathList.toString();
                                        //   widget.playlist();
                                        //   widget.callback(audios);
                                        //   print(SingleAudio.fromwhere.toString());
                                        // });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return new Text("${snapshot.error}");
                    }
                    return new Container(
                      alignment: AlignmentDirectional.center,
                      child: new CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
