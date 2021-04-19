import 'dart:io';
import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dashplayer.dart';
import 'downloader.dart';
import 'model/dbProvider.dart';
import 'model/downloadModel.dart';
import 'model/singleAudio.dart';

Future<List<DlModel>> fetchEmployeesFromDatabase() async {
  var dbHelper = MemoDbProvider();
  Future<List<DlModel>> employees = dbHelper.getEmployees();
  return employees;
}

Future<List<DlModel>> _myData = fetchEmployeesFromDatabase();

class DashPlaylist extends StatefulWidget {
  final Function() notifyParent;

  const DashPlaylist({Key key, this.notifyParent}) : super(key: key);

  @override
  _DashPlaylistState createState() => _DashPlaylistState();
}

class _DashPlaylistState extends State<DashPlaylist> {
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  List<Audio> audios = [];
  List<String> pathfin2 = [];
  List<String> pathfinal = [];
  MemoDbProvider musicDB = MemoDbProvider();
  Directory appDocDir;

  _allfunctions() async {
    appDocDir = await getApplicationDocumentsDirectory();
  }

  @override
  void initState() {
    // TODO: implement initState
    _allfunctions();
    super.initState();
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

  refresh() {
    // _allfunctions();
    setState(() {});
  }

  refreshme() {
    print('refreshing');
    setState(() {
      _myData = fetchEmployeesFromDatabase(); //<== (3) that will trigger the UI to rebuild an run the Future again
    });
  }

  showAlertDialog(BuildContext context, index) {
    Widget continueButton = FlatButton(
      child: Text("Delete"),
      onPressed: () {
        // sendData();

        deleteFile(File(index));
        Navigator.of(context).pop(true);
      },
    );
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        // sendData();
        Get.back();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete"),
      content: Text(
        '''
Are you sure you want to delete this?
                                                                              ''',
        maxLines: 20,
        style: TextStyle(fontSize: 16.0, color: Colors.black),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(children: <Widget>[
        Container(
          height: Get.height,
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
            children: <Widget>[
              CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: <Widget>[
                  SliverAppBar(
                    brightness: Brightness.dark,
                    backgroundColor: Color(0xff6C5B7B),
                    floating: true,
                    pinned: true,
                    snap: false,
                    shadowColor: Color(0xff6C5B7B),
                    flexibleSpace: FlexibleSpaceBar(
                      // centerTitle: true,
                      title: Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "Play G!",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Spacer(),
                            Spacer(),
                            Spacer(),
                            Spacer(),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(left: 0.0, top: 8),
                              child: IconButton(
                                icon: Icon(
                                  Icons.notes,
                                  size: 25,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  print('Pressed');
                                  Get.to(PickDL(
                                    notifyList: refreshme,
                                  ));
                                },
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                      // background: Image.network(
                      //   'https://t3.ftcdn.net/jpg/02/43/28/42/360_F_243284276_pSwURDLR5G6PNqQpej1FEpZNZwFMLkn0.jpg',
                      //   fit: BoxFit.cover,
                      // ),
                    ),
                    expandedHeight: 100,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int pdIndex) {
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 50,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 30.0, top: 18),
                                      child: Text(
                                        "Recently Added",
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

                              SizedBox(
                                height: 250,
                                child: new FutureBuilder<List<DlModel>>(
                                  future: _myData,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: snapshot.data.length,
                                        itemBuilder: (_, index) {
                                          // print(snapshot.data[index].thumbnailList.toString());
                                          // var split = snapshot.data[index].thumbnailList.toString().substring(7);
                                          // var tmp = split.substring(0, split.length - 1);
                                          // print(tmp);
                                          return Container(
                                            margin: EdgeInsets.all(16),
                                            width: 200,
                                            // height: 200,
                                            // color: Colors.green,
                                            child: Stack(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 0.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Center(
                                                        child: GestureDetector(
                                                          onLongPress: () async {
                                                            await musicDB.deleteMemo(snapshot.data[snapshot.data.length - index - 1].pathList.toString());
                                                            // print(await memoDb.fetchMemos()); //[]
                                                            setState(() {
                                                              _myData = fetchEmployeesFromDatabase(); //<== (3) that will trigger the UI to rebuild an run the Future again
                                                            });
                                                          },
                                                          onTap: () async {
                                                            // print(snapshot.data[index].);
                                                            setState(() {
                                                              SingleAudio.singlePath = snapshot.data[snapshot.data.length - index - 1].pathList.toString();
                                                              SingleAudio.title = snapshot.data[snapshot.data.length - index - 1].titleList.toString();
                                                              SingleAudio.artist = snapshot.data[snapshot.data.length - index - 1].authornameList.toString();
                                                              SingleAudio.image = snapshot.data[snapshot.data.length - index - 1].thumbnailList.toString();
                                                              SingleAudio.album = 'from YT';
                                                            });
                                                            widget.notifyParent();
                                                          },
                                                          child: Container(
                                                            width: 200,
                                                            height: 200,
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.rectangle,
                                                              borderRadius: BorderRadius.all(Radius.circular(30)),
                                                              color: Colors.transparent,
                                                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
                                                            ),
                                                            child: Image.file(
                                                              File(
                                                                appDocDir.uri.toFilePath().toString() + snapshot.data[snapshot.data.length - index - 1].thumbnailList.toString(),
                                                              ),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.bottomCenter,
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 18.0, right: 8, bottom: 8),
                                                        child: AutoSizeText(
                                                          snapshot.data[snapshot.data.length - index - 1].titleList.toString(),
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
                                              ],
                                            ),
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

                              Row(
                                children: [
                                  Container(
                                    height: 50,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 30.0, top: 18),
                                      child: Text(
                                        "Playlist",
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
                              SizedBox(
                                height: 250,
                                child: Center(
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                    iconSize: 30,
                                    onPressed: () {},
                                  ),
                                ),
                              ),

                              ///
                              // SizedBox(
                              //   height: 250,
                              //   child: ListView.builder(
                              //     scrollDirection: Axis.horizontal,
                              //     itemCount: pathfin2.length,
                              //     itemBuilder: (_, index) {
                              //       return Container(
                              //         margin: EdgeInsets.all(8),
                              //         width: 250,
                              //         // color: Colors.green,
                              //         child: Stack(
                              //           children: [
                              //             Padding(
                              //               padding: const EdgeInsets.only(bottom: 0.0),
                              //               child: Row(
                              //                 mainAxisAlignment: MainAxisAlignment.center,
                              //                 children: [
                              //                   Center(
                              //                     child: GestureDetector(
                              //                       onLongPress: () async {
                              //                         var aa = await showAlertDialog(context, pathfinal[index].toString());
                              //                         if (aa == true) {
                              //                           setState(() {});
                              //                         }
                              //                       },
                              //                       onTap: () {
                              //                         //  setState(() {
                              //                         //   SingleAudio.singlePath = pathfin2[index].toString();
                              //                         //   widget.notifyParent();

                              //                         // });
                              //                         widget.notifyParent();

                              //                         // print(pathfinal[index].toString());
                              //                         // var filey = File(pathfinal[index]);
                              //                         // String okay = '\"${filey.path}\"';

                              //                         // var filePath2 = path.join(appDocDir.uri.toFilePath(), 'converted');
                              //                         // var filex = File(filePath2);
                              //                         // String okay2 = '\"${filex.path}\"';

                              //                         // _flutterFFmpeg.execute("-i $okay -q:a 0 -map a $okay2.mp4").then((rt) async {
                              //                         //   print('[TRIMMED VIDEO RESULT] : $rt');
                              //                         // });

                              //                         // // print(pathfinal[index].toString());
                              //                         // // setState(() {
                              //                         // //   SingleAudio.singlePath = pathfin2[index].toString();
                              //                         // //   widget.notifyParent();

                              //                         // // });
                              //                         // // setState(() {
                              //                         // //   SingleAudio.singlePath = pathfin2[index].toString();
                              //                         // //   // SingleAudio.title = snapshot.data[index].titleList.toString();
                              //                         // //   // SingleAudio.artist = snapshot.data[index].authornameList.toString();
                              //                         // //   // SingleAudio.image = snapshot.data[index].thumbnailList.toString();
                              //                         // //   // SingleAudio.album = 'from YT';
                              //                         // // });
                              //                         // // widget.notifyParent();
                              //                       },
                              //                       child: Container(
                              //                         decoration: BoxDecoration(
                              //                           shape: BoxShape.rectangle,
                              //                           borderRadius: BorderRadius.all(Radius.circular(30)),
                              //                           color: Colors.transparent,
                              //                           boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
                              //                         ),
                              //                         child: Image.network(
                              //                           'https://fsa.zobj.net/crop.php?r=Aw9_DwYLnh6gWUWo_SGHN9OzWiB32TPqz8uWAzU1WjoVXgg_xy-Hn-Dqpdk8mmuwHpT8bqrmA-r4qg59_ptY_2NQTpDBw5C6nbl87rHg4lcEmtvH8tqhY-t885ZQ778fbapGoWbLYu6C6ItZ', // _assetsAudioPlayer.

                              //                           fit: BoxFit.fill,
                              //                         ),
                              //                       ),
                              //                     ),
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //             Align(
                              //               alignment: Alignment.bottomCenter,
                              //               child: Column(
                              //                 mainAxisSize: MainAxisSize.min,
                              //                 children: [
                              //                   Padding(
                              //                     padding: const EdgeInsets.only(left: 18.0, right: 8, bottom: 8),
                              //                     child: AutoSizeText(
                              //                       pathfin2[index].toString(),
                              //                       maxLines: 1,
                              //                       maxFontSize: 14,
                              //                       minFontSize: 14,
                              //                       overflow: TextOverflow.ellipsis,
                              //                       style: GoogleFonts.poppins(
                              //                         fontWeight: FontWeight.w500,
                              //                         color: Colors.white,
                              //                       ),
                              //                     ),
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //       );
                              //     },
                              //   ),
                              // ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 58.0),
                                child: Container(height: 250, color: Colors.transparent),
                              ),
                            ],
                          ),
                        );
                      },
                      // Builds 1000 ListTiles
                      childCount: 1,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
