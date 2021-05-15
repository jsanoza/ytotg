import 'dart:io';
import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:yt_otg/playlist/editplaylist.dart';
import 'playlist/addtoplaylist.dart';
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

Future<List<PlaylistModel>> getPlaylistfromDB() async {
  var dbHelper = MemoDbProvider();
  Future<List<PlaylistModel>> playlistName = dbHelper.getPlaylist();
  return playlistName;
}

Future<List<AddPlaylistModel>> getSongsPlaylist(playlistName1) async {
  var dbHelper = MemoDbProvider();
  Future<List<AddPlaylistModel>> songsThumbs = dbHelper.getSongsPlaylist(playlistName1);
  return songsThumbs;
}

// Future<List<AddPlaylistModel>> _myThumbs = getSongsPlaylist(playlistName1);
Future<List<DlModel>> _myData = fetchEmployeesFromDatabase();
Future<List<PlaylistModel>> _myPlaylist = getPlaylistfromDB();
typedef void StringCallback(List<Audio> val);

class DashPlaylist extends StatefulWidget {
  final StringCallback callback;
  final Function() playlist;
  final List<String> path;

  const DashPlaylist({Key key, this.playlist, this.path, this.callback}) : super(key: key);

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
  var dbHelper = MemoDbProvider();

  List<String> mResultArray = [];
  TextEditingController _playlistTextController;
  RoundedLoadingButtonController _buttonController;

  _allfunctions() async {
    appDocDir = await getApplicationDocumentsDirectory();
  }

  @override
  void initState() {
    // TODO: implement initState
    _allfunctions();
    _playlistTextController = TextEditingController();
    _buttonController = RoundedLoadingButtonController();
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
                    // brightness: Brightness.dark,
                    elevation: 0.0,
                    backgroundColor: Colors.transparent,
                    floating: true,
                    pinned: false,
                    snap: false,
                    // shadowColor: Color(0xff6C5B7B),
                    actions: [
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          size: 25,
                        ),
                        onPressed: () async {
                          await musicDB.listTables();
                          // Do something
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.search,
                          size: 25,
                        ),
                        onPressed: () {
                          Get.to(PickDL(
                            notifyList: refreshme,
                          ));
                          // Do something
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text(
                        "Play G!",
                        style: GoogleFonts.dmSans(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
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
//for SOLO / RECENTLY ADDED
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
                                          return FocusedMenuHolder(
                                            menuWidth: MediaQuery.of(context).size.width * 0.50,
                                            blurSize: 5.0,
                                            menuItemExtent: 45,
                                            menuBoxDecoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                            duration: Duration(milliseconds: 100),
                                            animateMenuItems: true,
                                            blurBackgroundColor: Colors.black54,
                                            // openWithTap: true, // Open Focused-Menu on Tap rather than Long Press
                                            menuOffset: 10.0, // Offset value to show menuItem from the selected item
                                            bottomOffsetHeight: 80.0, // Offset height to consider, for showing the menu item ( for example bottom navigation bar), so that the popup menu will be shown on top of selected item.
                                            menuItems: <FocusedMenuItem>[
                                              FocusedMenuItem(
                                                  title: Text("Play"),
                                                  trailingIcon: Icon(Icons.play_arrow),
                                                  onPressed: () async {
                                                    SingleAudio.fromwhere = '';
                                                    setState(() {
                                                      SingleAudio.singlePath = snapshot.data[snapshot.data.length - index - 1].pathList.toString();
                                                      SingleAudio.title = snapshot.data[snapshot.data.length - index - 1].titleList.toString();
                                                      SingleAudio.artist = snapshot.data[snapshot.data.length - index - 1].authornameList.toString();
                                                      SingleAudio.image = snapshot.data[snapshot.data.length - index - 1].thumbnailList.toString();
                                                      SingleAudio.album = 'from YT';
                                                      SingleAudio.fromwhere = 'solo';
                                                    });
                                                    widget.playlist();
                                                  }),
                                              FocusedMenuItem(
                                                title: Text("Add to Playlist"),
                                                trailingIcon: Icon(Icons.playlist_add_check),
                                                onPressed: () {
                                                  var toSave = snapshot.data[snapshot.data.length - index - 1].pathList.toString();
                                                  var toSaveThumb = snapshot.data[snapshot.data.length - index - 1].thumbnailList.toString();
                                                  var title = snapshot.data[snapshot.data.length - index - 1].titleList.toString();
                                                  print(toSaveThumb);
                                                  Get.to(AddToPlaylist(trackName: toSave, title: title, thumbnail: toSaveThumb));
                                                  // showModalBottomSheet(
                                                  //     isScrollControlled: true,
                                                  //     isDismissible: true,
                                                  //     context: context,
                                                  //     builder: (builder) {
                                                  //       return StatefulBuilder(
                                                  //         builder: (BuildContext context, StateSetter mystate) {
                                                  //           return Container(
                                                  //             height: Get.height * 0.75,
                                                  //             child: Scaffold(
                                                  //               resizeToAvoidBottomInset: false,
                                                  //               body: Container(
                                                  //                 height: Get.height,
                                                  //                 width: Get.width,
                                                  //                 decoration: BoxDecoration(
                                                  //                   gradient: new LinearGradient(
                                                  //                       colors: [
                                                  //                         Color(0xffC06C84),
                                                  //                         Color(0xff355C7D),
                                                  //                         Color(0xff6C5B7B),
                                                  //                       ],
                                                  //                       begin: const FractionalOffset(0.0, 0.0),
                                                  //                       end: const FractionalOffset(1.0, 1.0),
                                                  //                       stops: [0.0, 1.0, 1.0],
                                                  //                       tileMode: TileMode.clamp),
                                                  //                 ),
                                                  //                 child: Stack(
                                                  //                   children: [
                                                  //                     Padding(
                                                  //                       padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
                                                  //                       child: Container(
                                                  //                         height: Get.height,
                                                  //                         decoration: BoxDecoration(
                                                  //                           shape: BoxShape.rectangle,
                                                  //                           borderRadius: new BorderRadius.only(topRight: new Radius.circular(10.0), topLeft: new Radius.circular(10.0)),
                                                  //                         ),
                                                  //                         child: FutureBuilder<List<PlaylistModel>>(
                                                  //                           future: _myPlaylist,
                                                  //                           builder: (context, snapshota) {
                                                  //                             if (snapshota.hasData) {
                                                  //                               Future<List<AddPlaylistModel>> _myCheck = (getSongsPlaylist(snapshota.data[snapshota.data.length - index - 1].playlistName.toString()));
                                                  //                               return GridView.builder(
                                                  //                                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                                                  //                                 itemCount: snapshota.data.length,
                                                  //                                 itemBuilder: (BuildContext context, int index) {
                                                  //                                   return Card(
                                                  //                                     color: Colors.green,
                                                  //                                     child: ListTile(
                                                  //                                       title: Text(
                                                  //                                         snapshota.data[snapshota.data.length - index - 1].playlistName.toString(),
                                                  //                                       ),
                                                  //                                       onTap: () async {
                                                  //                                         var check = await musicDB.existSonginPlaylist(
                                                  //                                           toSave.toString(),
                                                  //                                           snapshota.data[snapshota.data.length - index - 1].playlistName.toString(),
                                                  //                                         );
                                                  //                                         if (check.toString() == '1') {
                                                  //                                           print(toSave.toString());
                                                  //                                           ScaffoldMessenger.of(context).showSnackBar(
                                                  //                                             SnackBar(
                                                  //                                               content: Text('This song is already on this playlist.'),
                                                  //                                             ),
                                                  //                                           );
                                                  //                                         } else {
                                                  //                                           final songToAdd = AddPlaylistModel(
                                                  //                                             snapshota.data[snapshota.data.length - index - 1].playlistName.toString(),
                                                  //                                             toSave.toString(),
                                                  //                                             toSaveThumb.toString(),
                                                  //                                           );
                                                  //                                           await musicDB.addtoPlaylist(songToAdd).then((value) => {
                                                  //                                                 print('Saved!'),
                                                  //                                               });
                                                  //                                         }
                                                  //                                       },
                                                  //                                     ),
                                                  //                                   );
                                                  //                                   // return Container(

                                                  //                                   //   width: 200,
                                                  //                                   //   height: 250,
                                                  //                                   //   child: FutureBuilder<List<AddPlaylistModel>>(
                                                  //                                   //     future: _myCheck,
                                                  //                                   //     builder: (context, snapshotx) {
                                                  //                                   //       if (snapshotx.hasData) {
                                                  //                                   //         return GridView.builder(
                                                  //                                   //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                                                  //                                   //           itemCount: snapshotx.data.length,
                                                  //                                   //           itemBuilder: (BuildContext context, int index) {
                                                  //                                   //             // return Card(
                                                  //                                   //             //   color: Colors.green,
                                                  //                                   //             //   child:
                                                  //                                   //             // );
                                                  //                                   //             return Container(
                                                  //                                   //               width: 200,
                                                  //                                   //               height: 50,
                                                  //                                   //               decoration: BoxDecoration(
                                                  //                                   //                 shape: BoxShape.rectangle,
                                                  //                                   //                 borderRadius: BorderRadius.all(Radius.circular(30)),
                                                  //                                   //                 color: Colors.transparent,
                                                  //                                   //                 boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, spreadRadius: 5)],
                                                  //                                   //               ),
                                                  //                                   //               child: Image.file(
                                                  //                                   //                 File(
                                                  //                                   //                   appDocDir.uri.toFilePath().toString() + snapshotx.data[snapshotx.data.length - index - 1].thumbnailList.toString(),
                                                  //                                   //                 ),
                                                  //                                   //                 fit: BoxFit.cover,
                                                  //                                   //               ),
                                                  //                                   //             );
                                                  //                                   //           },
                                                  //                                   //         );
                                                  //                                   //       }
                                                  //                                   //       return Container();
                                                  //                                   //     },
                                                  //                                   //   ),
                                                  //                                   // );
                                                  //                                 },
                                                  //                               );
                                                  //                             } else if (snapshot.hasError) {
                                                  //                               return new Text("${snapshot.error}");
                                                  //                             }

                                                  //                             return new Container(
                                                  //                               alignment: AlignmentDirectional.center,
                                                  //                               child: new CircularProgressIndicator(),
                                                  //                             );
                                                  //                           },
                                                  //                         ),
                                                  //                       ),
                                                  //                     ),
                                                  //                   ],
                                                  //                 ),
                                                  //               ),
                                                  //             ),
                                                  //           );
                                                  //         },
                                                  //       );
                                                  //     });
                                                },
                                              ),
                                              FocusedMenuItem(
                                                title: Text("Edit"),
                                                trailingIcon: Icon(Icons.edit_outlined),
                                                onPressed: () {},
                                              ),
                                              FocusedMenuItem(
                                                  title: Text(
                                                    "Delete",
                                                    style: TextStyle(color: Colors.redAccent),
                                                  ),
                                                  trailingIcon: Icon(
                                                    Icons.delete,
                                                    color: Colors.redAccent,
                                                  ),
                                                  onPressed: () async {
                                                    await musicDB.deleteMemo(snapshot.data[snapshot.data.length - index - 1].pathList.toString());
                                                    setState(() {
                                                      _myData = fetchEmployeesFromDatabase();
                                                    });
                                                  }),
                                            ],
                                            onPressed: () {
                                              setState(() {
                                                SingleAudio.singlePath = snapshot.data[snapshot.data.length - index - 1].pathList.toString();
                                                SingleAudio.title = snapshot.data[snapshot.data.length - index - 1].titleList.toString();
                                                SingleAudio.artist = snapshot.data[snapshot.data.length - index - 1].authornameList.toString();
                                                SingleAudio.image = snapshot.data[snapshot.data.length - index - 1].thumbnailList.toString();
                                                SingleAudio.album = 'from YT';
                                                SingleAudio.fromwhere = 'solo';
                                              });
                                              widget.playlist();
                                            },
                                            child: Container(
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

//for PLAYLIST
                              Row(
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
                                            top: 18,
                                          ),
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
                                  Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          showModalBottomSheet(
                                              isScrollControlled: true,
                                              isDismissible: false,
                                              context: context,
                                              builder: (builder) {
                                                return WillPopScope(
                                                  onWillPop: () {
                                                    return null;
                                                  },
                                                  child: StatefulBuilder(
                                                    builder: (BuildContext context, StateSetter mystate) {
                                                      return Container(
                                                        height: Get.height * 0.75,
                                                        child: Scaffold(
                                                          resizeToAvoidBottomInset: false,
                                                          body: Container(
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
                                                              children: [
                                                                Container(
                                                                  height: Get.height,
                                                                  decoration: BoxDecoration(
                                                                    shape: BoxShape.rectangle,
                                                                    borderRadius: new BorderRadius.only(topRight: new Radius.circular(10.0), topLeft: new Radius.circular(10.0)),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(left: 18.0, right: 18, top: 50, bottom: 18),
                                                                  child: Column(
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          Text(
                                                                            "Create Playlist",
                                                                            style: GoogleFonts.poppins(
                                                                              fontSize: 30,
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
                                                                  padding: const EdgeInsets.only(
                                                                    top: 130.0,
                                                                    right: 20,
                                                                    left: 20,
                                                                  ),
                                                                  child: Container(
                                                                    height: 180,
                                                                    child: TextField(
                                                                      style: TextStyle(color: Colors.white),
                                                                      // maxLength: 15,
                                                                      controller: _playlistTextController,
                                                                      decoration: InputDecoration(
                                                                        counterText: '',
                                                                        isDense: true,
                                                                        labelText: 'Enter Playlist Name',
                                                                        labelStyle: TextStyle(color: Colors.white),
                                                                        prefixIcon: Icon(
                                                                          Icons.edit_outlined,
                                                                          color: Colors.white,
                                                                          size: 25,
                                                                        ),
                                                                        contentPadding: EdgeInsets.only(left: 25.0),
                                                                        hintText: "Enter Playlist Name",
                                                                        hintStyle: TextStyle(color: Colors.white),
                                                                        enabledBorder: OutlineInputBorder(
                                                                          borderSide: BorderSide(color: Colors.white, width: 1),
                                                                        ),
                                                                        focusedBorder: OutlineInputBorder(
                                                                          borderSide: BorderSide(color: Colors.white, width: 1),
                                                                          borderRadius: BorderRadius.circular(20.0),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(
                                                                    top: 0.0,
                                                                    right: 20,
                                                                    left: 20,
                                                                  ),
                                                                  child: Center(
                                                                    child: Container(
                                                                      height: 40,
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
                                                                            final memo = PlaylistModel(
                                                                              _playlistTextController.text,
                                                                            );
                                                                            var check = await musicDB.existPlaylist(_playlistTextController.text.toString());
                                                                            if (check.toString() == '1') {
                                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                                SnackBar(
                                                                                  content: Text('Playlist Existing.'),
                                                                                ),
                                                                              );
                                                                              _buttonController.reset();
                                                                            } else {
                                                                              await musicDB.addPlaylist(memo).then((value) {
                                                                                Get.back();
                                                                                // _buttonController.reset();
                                                                                setState(() {
                                                                                  _myPlaylist = getPlaylistfromDB();
                                                                                  _playlistTextController.text = '';
                                                                                });
                                                                              });
                                                                            }
                                                                          },
                                                                          child: Icon(
                                                                            Icons.playlist_add,
                                                                            size: 30,
                                                                            color: Colors.white,
                                                                          )),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                );
                                              });
                                        },
                                        child: Container(
                                          height: 50,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 30.0,
                                              top: 18,
                                            ),
                                            child: Icon(
                                              Icons.playlist_add,
                                              size: 35,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(
                                height: 223,
                                child: new FutureBuilder<List<PlaylistModel>>(
                                  future: _myPlaylist,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: snapshot.data.length,
                                        itemBuilder: (_, index) {
                                          snapshot.data.forEach((element) {});

                                          Future<List<AddPlaylistModel>> _myCheck = (getSongsPlaylist(snapshot.data[snapshot.data.length - index - 1].playlistName.toString()));
                                          return Container(
                                            margin: EdgeInsets.only(left: 16, right: 16),
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
                                                      FocusedMenuHolder(
                                                        menuWidth: MediaQuery.of(context).size.width * 0.50,
                                                        blurSize: 5.0,
                                                        menuItemExtent: 45,
                                                        menuBoxDecoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                                        duration: Duration(milliseconds: 100),
                                                        animateMenuItems: true,
                                                        blurBackgroundColor: Colors.black54,
                                                        bottomOffsetHeight: 100,
                                                        // openWithTap: true,
                                                        menuItems: <FocusedMenuItem>[
                                                          FocusedMenuItem(
                                                              title: Text("Play Playlist"),
                                                              trailingIcon: Icon(Icons.play_arrow),
                                                              onPressed: () async {
                                                                SingleAudio.fromwhere = '';
                                                                List<String> path = [];

                                                                audios.clear();
                                                                audios = [];

                                                                var resx = await dbHelper.getSongsPlaylist(snapshot.data[snapshot.data.length - index - 1].playlistName.toString());
                                                                resx.forEach((element) {
                                                                  path.add(element.songspathList);
                                                                });

                                                                for (var filename in path) {
                                                                  var infosx = await dbHelper.getSongsPlaylistInfo(filename);
                                                                  for (var files in infosx) {
                                                                    print(files.titleList.toString());
                                                                    audios.add(Audio.file(
                                                                      appDocDir.uri.toFilePath().toString() + files.pathList.toString(),
                                                                      metas: Metas(
                                                                        id: files.pathList.toString(),
                                                                        title: files.titleList.toString(),
                                                                        artist: files.authornameList.toString(),
                                                                        album: files.thumbnailList.toString(),
                                                                        image: MetasImage.asset("assets/images/aa.jpeg"),
                                                                      ),
                                                                    ));
                                                                  }
                                                                }
                                                                setState(() {
                                                                  SingleAudio.fromwhere = 'homepageplaylist';
                                                                  widget.playlist();
                                                                  widget.callback(audios);
                                                                });
                                                              }),
                                                          FocusedMenuItem(
                                                            title: Text("Add / Edit Songs"),
                                                            trailingIcon: Icon(Icons.edit_outlined),
                                                            onPressed: () async {
                                                              Get.to(ScreenTwo(playlistName: snapshot.data[snapshot.data.length - index - 1].playlistName.toString()));
                                                            },
                                                          ),
                                                          FocusedMenuItem(title: Text("Favorite"), trailingIcon: Icon(Icons.favorite_border), onPressed: () {}),
                                                          FocusedMenuItem(
                                                              title: Text(
                                                                "Delete",
                                                                style: TextStyle(color: Colors.redAccent),
                                                              ),
                                                              trailingIcon: Icon(
                                                                Icons.delete,
                                                                color: Colors.redAccent,
                                                              ),
                                                              onPressed: () {}),
                                                        ],
                                                        onPressed: () async {
                                                          SingleAudio.fromwhere = '';
                                                          List<String> path = [];

                                                          audios.clear();
                                                          audios = [];

                                                          var resx = await dbHelper.getSongsPlaylist(snapshot.data[snapshot.data.length - index - 1].playlistName.toString());
                                                          resx.forEach((element) {
                                                            path.add(element.songspathList);
                                                          });

                                                          for (var filename in path) {
                                                            var infosx = await dbHelper.getSongsPlaylistInfo(filename);
                                                            for (var files in infosx) {
                                                              print(files.titleList.toString());
                                                              audios.add(Audio.file(
                                                                appDocDir.uri.toFilePath().toString() + files.pathList.toString(),
                                                                metas: Metas(
                                                                  id: files.pathList.toString(),
                                                                  title: files.titleList.toString(),
                                                                  artist: files.authornameList.toString(),
                                                                  album: files.thumbnailList.toString(),
                                                                  image: MetasImage.asset("assets/images/aa.jpeg"),
                                                                ),
                                                              ));
                                                            }
                                                          }
                                                          setState(() {
                                                            SingleAudio.fromwhere = 'homepageplaylist';
                                                            widget.playlist();
                                                            widget.callback(audios);
                                                          });
                                                        },
                                                        child: Container(
                                                          width: 200,
                                                          height: 250,
                                                          child: Center(
                                                            child: Stack(
                                                              children: [
                                                                Container(
                                                                  width: 200,
                                                                  height: 250,
                                                                  child: FutureBuilder<List<AddPlaylistModel>>(
                                                                    future: _myCheck,
                                                                    builder: (context, snapshotx) {
                                                                      if (snapshotx.hasData) {
                                                                        return GridView.builder(
                                                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                                                                          itemCount: snapshotx.data.length,
                                                                          physics: NeverScrollableScrollPhysics(),
                                                                          itemBuilder: (BuildContext context, int index) {
                                                                            // return Card(
                                                                            //   color: Colors.green,
                                                                            //   child:
                                                                            // );
                                                                            return Container(
                                                                              width: 200,
                                                                              height: 110,
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
                                                                  alignment: Alignment.center,
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(left: 18.0, right: 8, bottom: 8, top: 35),
                                                                        child: Icon(
                                                                          Icons.play_arrow,
                                                                          size: 60,
                                                                          color: Colors.white.withOpacity(0.2),
                                                                        ),
                                                                      ),
                                                                    ],
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
                                                              ],
                                                            ),
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

//for ALL SONGS
                              Row(
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
                                            top: 18,
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          SingleAudio.fromwhere = '';
                                          audios.clear();
                                          audios = [];
                                          var resx = await dbHelper.getEmployees();
                                          for (var files in resx) {
                                            audios.add(Audio.file(
                                              appDocDir.uri.toFilePath().toString() + files.pathList.toString(),
                                              metas: Metas(
                                                id: files.pathList.toString(),
                                                title: files.titleList.toString(),
                                                artist: files.authornameList.toString(),
                                                album: files.thumbnailList.toString(),
                                                image: MetasImage.asset("assets/images/aa.jpeg"),
                                              ),
                                            ));
                                          }
                                          setState(() {
                                            SingleAudio.fromwhere = 'playall';
                                            widget.playlist();
                                            widget.callback(audios);
                                            print(SingleAudio.fromwhere.toString());
                                          });
                                        },
                                        child: Container(
                                          height: 50,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 30.0,
                                              top: 18,
                                            ),
                                            child: Icon(
                                              Icons.play_arrow,
                                              size: 35,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(
                                height: 400,
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
                                              PlaylistAudio.path.add(element.pathList);
                                              PlaylistAudio.artist.add(element.authornameList);
                                              PlaylistAudio.image.add(element.thumbnailList);
                                              PlaylistAudio.title.add(element.titleList);
                                            });

                                            return Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 5.0, left: 8.0, right: 8.0),
                                                  child: Container(
                                                    height: 70,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
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
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      onTap: () async {
                                                        SingleAudio.fromwhere = '';
                                                        audios.clear();
                                                        audios = [];
                                                        var resx = await dbHelper.getEmployees();
                                                        for (var files in resx) {
                                                          audios.add(Audio.file(
                                                            appDocDir.uri.toFilePath().toString() + files.pathList.toString(),
                                                            metas: Metas(
                                                              id: files.pathList.toString(),
                                                              title: files.titleList.toString(),
                                                              artist: files.authornameList.toString(),
                                                              album: files.thumbnailList.toString(),
                                                              image: MetasImage.asset("assets/images/aa.jpeg"),
                                                            ),
                                                          ));
                                                        }
                                                        setState(() {
                                                          SingleAudio.fromwhere = 'randomplay';
                                                          SingleAudio.singlePath = snapshot.data[snapshot.data.length - index - 1].pathList.toString();
                                                          widget.playlist();
                                                          widget.callback(audios);
                                                          print(SingleAudio.fromwhere.toString());
                                                        });
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
