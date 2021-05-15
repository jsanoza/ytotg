import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import '../model/dbProvider.dart';
import '../model/downloadModel.dart';

Future<List<AddPlaylistModel>> getSongsPlaylist(playlistName1) async {
  var dbHelper = MemoDbProvider();
  Future<List<AddPlaylistModel>> songsThumbs = dbHelper.getSongsPlaylist(playlistName1);
  return songsThumbs;
}

Future<List<PlaylistModel>> getPlaylistfromDB() async {
  var dbHelper = MemoDbProvider();
  Future<List<PlaylistModel>> playlistName = dbHelper.getPlaylist();
  return playlistName;
}

Future<List<PlaylistModel>> _myPlaylist = getPlaylistfromDB();

class AddToPlaylist extends StatefulWidget {
  final String trackName, title, thumbnail;

  const AddToPlaylist({Key key, this.trackName, this.title, this.thumbnail}) : super(key: key);

  @override
  _AddToPlaylistState createState() => _AddToPlaylistState();
}

class _AddToPlaylistState extends State<AddToPlaylist> {
  // Future<List<AddPlaylistModel>> _myData;
  Directory appDocDir;

  List<String> indexwhat = [];
  List<String> playlistwhat = [];
  MemoDbProvider musicDB = MemoDbProvider();

  _allfunctions() async {
    appDocDir = await getApplicationDocumentsDirectory();
  }

  @override
  void initState() {
    // TODO: implement initState
    // _myData = getSongsPlaylist(widget.trackName);
    _myPlaylist = getPlaylistfromDB();
    _allfunctions();
    print(widget.thumbnail);
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
              padding: const EdgeInsets.only(top: 40.0),
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
                            top: 14,
                          ),
                          child: Text(
                            "Add to Playlist",
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 60,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20, right: 40),
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.all(Radius.circular(90)),
                              color: Colors.transparent,
                              // boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.add_circle_outline,
                                size: 20,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                // List<String> names = [];

                                AddPlaylistModel songToAdd;
                                for (var i = 0; i < indexwhat.length; i++) {
                                  var firstres = await musicDB.getSongsPlaylist(playlistwhat[i].toString());
                                  // var firstcheck = firstres.last;
                                  if (firstres.length == 0) {
                                    songToAdd = AddPlaylistModel(
                                      playlistwhat[i],
                                      widget.trackName,
                                      widget.thumbnail,
                                      0,
                                    );
                                    await musicDB.addtoPlaylist(songToAdd).then((value) => {
                                          print('Saved!'),
                                          print("dito ako"),
                                        });
                                  } else if (firstres.length != 0) {
                                    var finalLasxt = firstres.last;
                                    var hellotherewhateverx = finalLasxt.indexinPlaylist;
                                    songToAdd = AddPlaylistModel(
                                      playlistwhat[i],
                                      widget.trackName,
                                      widget.thumbnail,
                                      hellotherewhateverx + 1,
                                    );
                                    await musicDB.addtoPlaylist(songToAdd).then((value) => {
                                          print('Saved!'),
                                          print("dito ako2"),
                                          print(hellotherewhateverx),
                                        });
                                    hellotherewhateverx = 0;
                                  }
                                }
                                setState(() {});

                                // if (resx.length == 0) {
                                //   print('hello');
                                //   for (var i = 0; i < indexwhat.length; i++) {
                                //     songToAdd = AddPlaylistModel(
                                //       playlistwhat[i],
                                //       widget.trackName,
                                //       widget.thumbnail,
                                //       0,
                                //     );
                                //     await musicDB.addtoPlaylist(songToAdd).then((value) => {
                                //           print('Saved!'),
                                //           print("dito ako"),
                                //         });
                                //   }
                                // }

                                // if (resx.length != 0) {
                                //   for (var i = 0; i < indexwhat.length; i++) {
                                //     var resxx = await musicDB.getSongsPlaylist(playlistwhat.last[i].toString());
                                //     var finalLasxt = resxx.last;
                                //     var hellotherewhateverx = finalLasxt.indexinPlaylist;
                                //     songToAdd = AddPlaylistModel(
                                //       playlistwhat[i],
                                //       widget.trackName,
                                //       widget.thumbnail,
                                //       hellotherewhateverx + 1,
                                //     );
                                //     await musicDB.addtoPlaylist(songToAdd).then((value) => {
                                //           print('Saved!'),
                                //           print("dito ako2"),
                                //           print(hellotherewhateverx),
                                //         });
                                //     hellotherewhateverx = 0;
                                //   }
                                // }

                                // if (hellotherewhatever != 0) {
                                //   for (var i = 0; i < indexwhat.length; i++) {
                                //     var resx = await musicDB.getSongsPlaylist(playlistwhat.last.toString());
                                //     var finalLasxt = resx.last;
                                //     var hellotherewhateverx = finalLasxt.indexinPlaylist;
                                //     songToAdd = AddPlaylistModel(
                                //       playlistwhat[i],
                                //       widget.trackName,
                                //       widget.thumbnail,
                                //       hellotherewhateverx + 1,
                                //     );
                                //     await musicDB.addtoPlaylist(songToAdd).then((value) => {
                                //           print('Saved!'),
                                //           print("dito ako2"),
                                //         });
                                //   }
                                // }

                                // var hello = await musicDB.lastIndex(playlistwhat);
                                // print(hello.toString() + "THIS IS THE LAST INSERTED INDEX");

                                // for (var i = 0; i < indexwhat.length; i++) {
                                //   songToAdd = AddPlaylistModel(
                                //     playlistwhat[i],
                                //     widget.trackName,
                                //     widget.thumbnail,
                                //     0,
                                //   );
                                //   await musicDB.addtoPlaylist(songToAdd).then((value) => {
                                //         print('Saved!'),
                                //       });
                                // }
                                // print(playlistwhat);

                                // for (var filename in resx) {
                                //   print(filename.indexinPlaylist);
                                // }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: FutureBuilder<List<PlaylistModel>>(
                future: _myPlaylist,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return GridView.builder(
                      itemCount: snapshot.data.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                      itemBuilder: (_, index) {
                        Future<List<AddPlaylistModel>> _myCheck = (getSongsPlaylist(snapshot.data[snapshot.data.length - index - 1].playlistName.toString()));

                        return Stack(
                          children: [
                            // Container(color: Colors.red[(index * 100) % 900]),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (indexwhat.contains(index.toString())) {
                                    indexwhat.remove(index.toString());
                                    playlistwhat.remove(snapshot.data[snapshot.data.length - index - 1].playlistName.toString());
                                  } else {
                                    indexwhat.add(index.toString());
                                    playlistwhat.add(snapshot.data[snapshot.data.length - index - 1].playlistName.toString());
                                  }
                                });
                                print(playlistwhat);
                              },
                              child: Container(
                                margin: EdgeInsets.only(left: 10, right: 10),
                                width: 250,
                                height: 176,
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 0.0),
                                      child: Container(
                                        width: 200,
                                        height: 200,
                                        child: Center(
                                          child: Stack(
                                            children: [
                                              Container(
                                                width: 200,
                                                height: 223,
                                                child: FutureBuilder<List<AddPlaylistModel>>(
                                                  future: _myCheck,
                                                  builder: (context, snapshotx) {
                                                    if (snapshotx.hasData) {
                                                      return GridView.builder(
                                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                                                        physics: NeverScrollableScrollPhysics(),
                                                        itemCount: snapshotx.data.length,
                                                        itemBuilder: (BuildContext context, int index) {
                                                          return Container(
                                                            width: 200,
                                                            height: 50,
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.rectangle,
                                                              borderRadius: BorderRadius.all(Radius.circular(30)),
                                                              color: Colors.transparent,
                                                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
                                                            ),
                                                            child: Image.file(
                                                              File(
                                                                appDocDir.uri.toFilePath().toString() + snapshotx.data[snapshotx.data.length - index - 1].thumbnailList.toString(),
                                                              ),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    }
                                                    return Container();
                                                  },
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.bottomCenter,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    color: Colors.white.withOpacity(0.2),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 0),
                                                          child: AutoSizeText(
                                                            snapshot.data[snapshot.data.length - index - 1].playlistName.toString(),
                                                            maxLines: 1,
                                                            maxFontSize: 14,
                                                            minFontSize: 14,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: GoogleFonts.poppins(
                                                              fontWeight: FontWeight.w500,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              indexwhat.contains(index.toString())
                                                  ? Align(
                                                      alignment: Alignment.topRight,
                                                      child: Icon(
                                                        Icons.verified_outlined,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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
          ],
        ),
      ),
    );
  }
}
