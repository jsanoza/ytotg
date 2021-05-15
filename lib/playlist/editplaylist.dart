import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yt_otg/allsongs.dart';

import '../model/dbProvider.dart';
import '../model/downloadModel.dart';
import '../model/downloadModel.dart';
import '../model/downloadModel.dart';
import '../model/downloadModel.dart';
import '../model/downloadModel.dart';
import '../model/singleAudio.dart';

Future<List<AddPlaylistModel>> getSongsPlaylist(playlistName1) async {
  var dbHelper = MemoDbProvider();
  Future<List<AddPlaylistModel>> songsThumbs = dbHelper.getSongsPlaylist(playlistName1);
  return songsThumbs;
}

Future<List<DlModel>> getSongs() async {
  var dbHelper = MemoDbProvider();
  Future<List<DlModel>> songsThumbs = dbHelper.getEmployees();
  return songsThumbs;
}

class ScreenTwo extends StatefulWidget {
  final String playlistName;

  const ScreenTwo({Key key, this.playlistName}) : super(key: key);

  @override
  _ScreenTwoState createState() => _ScreenTwoState();
}

class _ScreenTwoState extends State<ScreenTwo> {
  Directory appDocDir;
  var dbHelper = MemoDbProvider();
  Future<List<AddPlaylistModel>> _myThumbs;
  // Future<List<DlModel>> _mySongs;
  // ignore: deprecated_member_use
  List<AddPlaylistModel> myList = List<AddPlaylistModel>();
  // ignore: deprecated_member_use
  List<AddPlaylistModel> _titles = List<AddPlaylistModel>();

  // ignore: deprecated_member_use
  List<AddPlaylistModel> _newList = List<AddPlaylistModel>();
  // ignore: deprecated_member_use
  List<DlModel> filteredList = List<DlModel>();
  bool _showSave = false;

  void _onReorder(int oldIndex, int newIndex) async {
    if (newIndex > myList.length) newIndex = myList.length;
    if (oldIndex < newIndex) newIndex -= 1;
    final AddPlaylistModel item = myList[oldIndex];

    setState(() {
      myList.removeAt(oldIndex);
      print(item.thumbnailList);
      // myList2.insert(oldIndex, item);
      myList.insert(newIndex, item);
    });
    // AddPlaylistModel hello;
    AddPlaylistModel hellothere;
    final _newList = myList;
    myList.forEach((element) async {
      // await dbHelper.updatePlaylist(oldIndex, newIndex, widget.playlistName, element.songspathList).then((value) {
      //   print('SAVED!');
      // });

      await dbHelper.updatePlaylist(oldIndex, newIndex, widget.playlistName, element.songspathList).then((value) {
        print('Deleted!');
      }).then((value) {});
    });

    _newList.forEach((element) async {
      hellothere = AddPlaylistModel(
        element.playlistName,
        element.songspathList,
        element.thumbnailList,
        element.indexinPlaylist,
      );
      await dbHelper.addtoPlaylist(hellothere).then((value) {
        print('Updated!');
      });
    });

    print(_newList.length);
  }

  _allfunctions() async {
    appDocDir = await getApplicationDocumentsDirectory();
    _myThumbs = getSongsPlaylist(widget.playlistName);
    // _mySongs = getSongs();
    setState(() {});
  }

  @override
  void initState() {
    _allfunctions();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
              child: Container(
                height: Get.height,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0, top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                height: 60,
                                width: 250,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 0.0,
                                    top: 18,
                                  ),
                                  child: Focus(
                                      child: TextField(
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          fontSize: 25,
                                        ),
                                        // maxLength: 15,
                                        // controller: _playlistTextController,
                                        decoration: InputDecoration(
                                          counterText: '',
                                          isDense: true,
                                          contentPadding: EdgeInsets.only(left: 25.0),
                                          hintText: widget.playlistName,
                                          hintStyle: TextStyle(color: Colors.white),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.transparent, width: 1),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.white, width: 1),
                                            // borderRadius: BorderRadius.circular(20.0),
                                          ),
                                        ),
                                      ),
                                      onFocusChange: (hasFocus) {
                                        if (!hasFocus) {
                                          setState(() {
                                            _showSave = false;
                                          });
                                        } else {
                                          setState(() {
                                            _showSave = true;
                                          });
                                        }
                                      }),
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          _showSave
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        print('clicked');
                                      },
                                      child: Container(
                                        height: 50,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 10.0,
                                            top: 10,
                                          ),
                                          child: Icon(
                                            Icons.add_circle_outline,
                                            size: 30,
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
                      padding: const EdgeInsets.only(top: 100),
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              height: 250,
                              width: 200,
                              child: FutureBuilder<List<AddPlaylistModel>>(
                                future: _myThumbs,
                                builder: (context, snapshotx) {
                                  _titles = snapshotx.data;
                                  if (snapshotx.hasData) {
                                    return GridView.builder(
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: snapshotx.data.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            // borderRadius: BorderRadius.all(Radius.circular(30)),
                                            color: Colors.green,
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
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 350.0),
                      child: Container(
                        // color: Colors.white,
                        // decoration: BoxDecoration(
                        //   gradient: new LinearGradient(
                        //       colors: [
                        //         Color(0xffC06C84),
                        //         Color(0xff355C7D),
                        //         Color(0xff6C5B7B),
                        //       ],
                        //       begin: const FractionalOffset(0.0, 0.0),
                        //       end: const FractionalOffset(1.0, 1.0),
                        //       stops: [0.0, 1.0, 1.0],
                        //       tileMode: TileMode.clamp),
                        // ),
                        height: 300,
                        child: ListView(
                          children: [
                            SizedBox(
                              height: Get.height,
                              child: FutureBuilder<List<AddPlaylistModel>>(
                                  future: _myThumbs,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      myList = snapshot.data;
                                      _titles = snapshot.data;
                                      return Theme(
                                        data: ThemeData(canvasColor: Colors.transparent),
                                        child: ReorderableListView(
                                          onReorder: _onReorder,
                                          children: List.generate(snapshot.data.length, (index) {
                                            return ListTile(
                                              key: Key('$index'),
                                              // title: Text(snapshot.data[index].songspathList.toString()),
                                              // subtitle: Text(snapshot.data[index].indexinPlaylist.toString()),
                                              leading: CircleAvatar(
                                                backgroundColor: Colors.black,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(75.0),
                                                  child: Image.file(
                                                    File(
                                                      appDocDir.uri.toFilePath().toString() + snapshot.data[index].thumbnailList.toString(),
                                                    ),
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                              title: AutoSizeText(
                                                snapshot.data[index].songspathList.toString(),
                                                maxLines: 1,
                                                maxFontSize: 14,
                                                minFontSize: 14,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              onTap: () {},
                                            );
                                          }),
                                        ),
                                      );
                                    }

                                    return Container();
                                  }),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // child: Container(
                //   width: 200,
                //   height: 250,
                //   child: FutureBuilder<List<AddPlaylistModel>>(
                //     future: _myThumbs,
                //     builder: (context, snapshotx) {
                //       if (snapshotx.hasData) {
                //         return GridView.builder(
                //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                //           itemCount: snapshotx.data.length,
                //           itemBuilder: (BuildContext context, int index) {
                //             return Container(
                //               width: 200,
                //               height: 50,
                //               decoration: BoxDecoration(
                //                 shape: BoxShape.rectangle,
                //                 borderRadius: BorderRadius.all(Radius.circular(30)),
                //                 color: Colors.transparent,
                //                 boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
                //               ),
                //               child: Image.file(
                //                 File(
                //                   appDocDir.uri.toFilePath().toString() + snapshotx.data[snapshotx.data.length - index - 1].thumbnailList.toString(),
                //                 ),
                //                 fit: BoxFit.cover,
                //               ),
                //             );
                //           },
                //         );
                //       }
                //       return Container();
                //     },
                //   ),
                // ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 0.0,
                top: 340,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 180.0),
                    child: GestureDetector(
                      onTap: () {
                        Get.to(AllSongs());
                        print('clicked');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 50,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 0.0,
                              ),
                              child: Icon(
                                Icons.add_circle_outline,
                                size: 25,
                                color: Colors.pink[200],
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
          ],
        ),
      ),
    );
  }
}
