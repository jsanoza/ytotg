import 'dart:io';
import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
import 'package:yt_otg/playlist/editinfo.dart';
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
  List<Audio> audios = [];
  List<String> pathfin2 = [];
  List<String> pathfinal = [];
  MemoDbProvider musicDB = MemoDbProvider();
  Directory appDocDir;
  var dbHelper = MemoDbProvider();
  int _index = 0;
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
    print(file.path);
  }

  refresh() {
    _allfunctions();
    _myData = fetchEmployeesFromDatabase();
    _myPlaylist = getPlaylistfromDB();
    setState(() {});
    //  return 'success';
  }

  refresh2() {
    _allfunctions();
    _myData = fetchEmployeesFromDatabase();
    _myPlaylist = getPlaylistfromDB();
    setState(() {});
    return 'success';
  }

  refreshme() {
    print('refreshing');
    setState(() {
      _myData = fetchEmployeesFromDatabase(); //<== (3) that will trigger the UI to rebuild an run the Future again
    });
  }

  showAlertDialog(BuildContext context, index) {
    Widget continueButton = FlatButton(
      child: Text(
        "Delete",
        style: GoogleFonts.dmSans(
          // fontSize: 25,
          color: Colors.pink,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: () async {
        // sendData();
        await musicDB.deleteMemo(index);
        setState(() {
          _myData = fetchEmployeesFromDatabase();
        });
        deleteFile(File(index));
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Track Deleted!'),
            );
          },
        ).then((value) => {
              Get.back(),
            });

        // Navigator.of(context).pop(true);
      },
    );
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancel",
        style: GoogleFonts.dmSans(
          // fontSize: 25,
          // color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: () {
        // sendData();
        Get.back();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "Delete",
        style: GoogleFonts.dmSans(
          // fontSize: 25,
          color: Colors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
      content: Text(
        '''
Are you sure you want to delete this track?
                                                                              ''',
        maxLines: 20,
        style: GoogleFonts.dmSans(
          // fontSize: 25,
          // color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
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

  showAlertDialogPlaylist(BuildContext context, index) {
    Widget continueButton = FlatButton(
      child: Text(
        "Delete",
        style: GoogleFonts.dmSans(
          // fontSize: 25,
          color: Colors.pink,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: () async {
        // sendData();
        // await musicDB.deleteMemo(index);
        await musicDB.deletePlaylist(index);
        setState(() {
          _myData = fetchEmployeesFromDatabase();
          _myPlaylist = getPlaylistfromDB();
        });
        // deleteFile(File(index));
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Playlist Deleted!'),
            );
          },
        ).then((value) => {
              Get.back(),
            });

        // Navigator.of(context).pop(true);
      },
    );
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancel",
        style: GoogleFonts.dmSans(
          // fontSize: 25,
          // color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: () {
        // sendData();
        Get.back();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "Delete",
        style: GoogleFonts.dmSans(
          // fontSize: 25,
          color: Colors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
      content: Text(
        '''
Are you sure you want to delete this playlist?
                                                                              ''',
        maxLines: 20,
        style: GoogleFonts.dmSans(
          // fontSize: 25,
          // color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
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
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.primaryVariant,
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 1.0),
                stops: [
                  0.0,
                  1.0,
                  1.0,
                ],
                tileMode: TileMode.clamp),
          ),
          child: Stack(
            children: <Widget>[
              RefreshIndicator(
                backgroundColor: Color(0xffC06C84),
                onRefresh: () {
                  refresh();
                  return Future.value(true);
                },
                child: CustomScrollView(
                  physics: BouncingScrollPhysics(),
                  slivers: <Widget>[
                    SliverAppBar(
                      brightness: Brightness.light,
                      elevation: 0.0,
                      backgroundColor: Colors.transparent,
                      floating: true,
                      pinned: false,
                      snap: false,
                      actions: [
                        IconButton(
                          icon: Icon(
                            Icons.search,
                            size: 25,
                          ),
                          onPressed: () async {
                            await musicDB.listTables();
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.add,
                            size: 25,
                          ),
                          onPressed: () async {
                            Get.to(PickDL(
                              notifyList: refreshme,
                            ));
                          },
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        stretchModes: const <StretchMode>[
                          StretchMode.zoomBackground,
                          StretchMode.blurBackground,
                        ],
                        background: Container(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 58.0),
                              child: Text(
                                "Play G!",
                                style: GoogleFonts.dmSans(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
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
                                          style: GoogleFonts.dmSans(
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
                                        return CarouselSlider.builder(
                                          itemCount: snapshot.data.length,
                                          itemBuilder: (_, index, __) {
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
                                                    title: Text(
                                                      "Play",
                                                      style: TextStyle(color: Colors.black),
                                                    ),
                                                    trailingIcon: Icon(Icons.play_arrow, color: Colors.black),
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
                                                  title: Text(
                                                    "Add to Queue",
                                                    style: TextStyle(color: Colors.black),
                                                  ),
                                                  trailingIcon: Icon(Icons.queue_play_next_sharp, color: Colors.black),
                                                  onPressed: () {
                                                    SingleAudio.fromwhere = '';
                                                    setState(() {
                                                      SingleAudio.singlePath = snapshot.data[snapshot.data.length - index - 1].pathList.toString();
                                                      SingleAudio.title = snapshot.data[snapshot.data.length - index - 1].titleList.toString();
                                                      SingleAudio.artist = snapshot.data[snapshot.data.length - index - 1].authornameList.toString();
                                                      SingleAudio.image = snapshot.data[snapshot.data.length - index - 1].thumbnailList.toString();
                                                      SingleAudio.album = 'from YT';
                                                      SingleAudio.fromwhere = 'queue';
                                                    });
                                                    widget.playlist();
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            content: Text(
                                                              'Added to queue!',
                                                              style: GoogleFonts.dmSans(
                                                                // fontSize: 13,
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.w500,
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                  },
                                                ),
                                                FocusedMenuItem(
                                                  title: Text(
                                                    "Add to Playlist",
                                                    style: TextStyle(color: Colors.black),
                                                  ),
                                                  trailingIcon: Icon(Icons.playlist_add_check, color: Colors.black),
                                                  onPressed: () {
                                                    var toSave = snapshot.data[snapshot.data.length - index - 1].pathList.toString();
                                                    var toSaveThumb = snapshot.data[snapshot.data.length - index - 1].thumbnailList.toString();
                                                    var title = snapshot.data[snapshot.data.length - index - 1].titleList.toString();
                                                    print(toSaveThumb);
                                                    Get.to(AddToPlaylist(trackName: toSave, title: title, thumbnail: toSaveThumb));
                                                  },
                                                ),
                                                FocusedMenuItem(
                                                  title: Text(
                                                    "Edit",
                                                    style: TextStyle(color: Colors.black),
                                                  ),
                                                  trailingIcon: Icon(Icons.edit_outlined, color: Colors.black),
                                                  onPressed: () {
                                                    Get.to(EditInfo(
                                                      pathList: snapshot.data[snapshot.data.length - index - 1].pathList.toString(),
                                                      titleList: snapshot.data[snapshot.data.length - index - 1].titleList.toString(),
                                                      authornameList: snapshot.data[snapshot.data.length - index - 1].authornameList.toString(),
                                                      thumbnailList: snapshot.data[snapshot.data.length - index - 1].thumbnailList.toString(),
                                                      urlList: snapshot.data[snapshot.data.length - index - 1].urlList.toString(),
                                                      hello: refresh,
                                                    ));
                                                  },
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
                                                      showAlertDialog(context, snapshot.data[snapshot.data.length - index - 1].pathList.toString());
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
                                                height: 500,
                                                width: 500,
                                                color: Colors.transparent,
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      height: 500,
                                                      width: 500,
                                                      child: snapshot.data.length > 0
                                                          ? Image.file(
                                                              File(
                                                                appDocDir.uri.toFilePath().toString() + snapshot.data[snapshot.data.length - index - 1].thumbnailList.toString(),
                                                              ),
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Container(),
                                                    ),
                                                    Align(
                                                      alignment: Alignment.center,
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: 0.0, right: 0, bottom: 0, top: 0),
                                                            child: snapshot.data.length > 0
                                                                ? Icon(
                                                                    Icons.play_arrow,
                                                                    size: 90,
                                                                    color: Colors.white.withOpacity(0.8),
                                                                  )
                                                                : Container(),
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
                                                            padding: const EdgeInsets.only(left: 18.0, right: 8, bottom: 0),
                                                            child: AutoSizeText(
                                                              snapshot.data.length > 0 ? snapshot.data[snapshot.data.length - index - 1].titleList.toString() : '',
                                                              maxLines: 1,
                                                              maxFontSize: 14,
                                                              minFontSize: 14,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: GoogleFonts.dmSans(
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
                                          options: CarouselOptions(
                                            autoPlay: false,
                                            enableInfiniteScroll: snapshot.data.length < 3 ? false : true,
                                            enlargeCenterPage: true,
                                            initialPage: 0,
                                            aspectRatio: 2.0,
                                            viewportFraction: 0.7,
                                          ),
                                        );
                                      } else if (snapshot.hasError) {
                                        return new Text("${snapshot.error}");
                                      } else if (snapshot.isBlank) {
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
                                          height: 70,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 30.0,
                                              top: 30,
                                              bottom: 0,
                                            ),
                                            child: Text(
                                              "All Songs",
                                              style: GoogleFonts.dmSans(
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
                                          padding: const EdgeInsets.only(top: 0.0),
                                          child: ListView.builder(
                                            itemCount: snapshot.data.length,
                                            itemBuilder: (_, index) {
                                              snapshot.data.forEach((element) {
                                                PlaylistAudio.path.add(element.pathList);
                                                PlaylistAudio.artist.add(element.authornameList);
                                                PlaylistAudio.image.add(element.thumbnailList);
                                                PlaylistAudio.title.add(element.titleList);
                                              });

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
                                                      title: Text(
                                                        "Play",
                                                        style: TextStyle(color: Colors.black),
                                                      ),
                                                      trailingIcon: Icon(Icons.play_arrow, color: Colors.black),
                                                      onPressed: () async {
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
                                                      }),
                                                  FocusedMenuItem(
                                                    title: Text(
                                                      "Add to Queue",
                                                      style: TextStyle(color: Colors.black),
                                                    ),
                                                    trailingIcon: Icon(Icons.queue_play_next_sharp, color: Colors.black),
                                                    onPressed: () {
                                                      SingleAudio.fromwhere = '';
                                                      setState(() {
                                                        SingleAudio.singlePath = snapshot.data[snapshot.data.length - index - 1].pathList.toString();
                                                        SingleAudio.title = snapshot.data[snapshot.data.length - index - 1].titleList.toString();
                                                        SingleAudio.artist = snapshot.data[snapshot.data.length - index - 1].authornameList.toString();
                                                        SingleAudio.image = snapshot.data[snapshot.data.length - index - 1].thumbnailList.toString();
                                                        SingleAudio.album = 'from YT';
                                                        SingleAudio.fromwhere = 'queue';
                                                      });
                                                      widget.playlist();
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              content: Text(
                                                                'Added to queue!',
                                                                style: GoogleFonts.dmSans(
                                                                  color: Colors.white,
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                            );
                                                          });
                                                    },
                                                  ),
                                                  FocusedMenuItem(
                                                    title: Text(
                                                      "Add to Playlist",
                                                      style: TextStyle(color: Colors.black),
                                                    ),
                                                    trailingIcon: Icon(Icons.playlist_add_check, color: Colors.black),
                                                    onPressed: () {
                                                      var toSave = snapshot.data[snapshot.data.length - index - 1].pathList.toString();
                                                      var toSaveThumb = snapshot.data[snapshot.data.length - index - 1].thumbnailList.toString();
                                                      var title = snapshot.data[snapshot.data.length - index - 1].titleList.toString();
                                                      print(toSaveThumb);
                                                      Get.to(AddToPlaylist(
                                                        trackName: toSave,
                                                        title: title,
                                                        thumbnail: toSaveThumb,
                                                        check: refresh,
                                                      ));
                                                    },
                                                  ),
                                                  FocusedMenuItem(
                                                    title: Text(
                                                      "Edit",
                                                      style: TextStyle(color: Colors.black),
                                                    ),
                                                    trailingIcon: Icon(
                                                      Icons.edit_outlined,
                                                      color: Colors.black,
                                                    ),
                                                    onPressed: () {
                                                      Get.to(EditInfo(
                                                        pathList: snapshot.data[snapshot.data.length - index - 1].pathList.toString(),
                                                        titleList: snapshot.data[snapshot.data.length - index - 1].titleList.toString(),
                                                        authornameList: snapshot.data[snapshot.data.length - index - 1].authornameList.toString(),
                                                        thumbnailList: snapshot.data[snapshot.data.length - index - 1].thumbnailList.toString(),
                                                        urlList: snapshot.data[snapshot.data.length - index - 1].urlList.toString(),
                                                        hello: refresh,
                                                      ));
                                                    },
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
                                                        showAlertDialog(context, snapshot.data[snapshot.data.length - index - 1].pathList.toString());
                                                      }),
                                                ],
                                                onPressed: () {},

                                                child: Column(
                                                  children: <Widget>[
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
                                                              style: GoogleFonts.dmSans(
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
                                                                    style: GoogleFonts.dmSans(
                                                                      fontWeight: FontWeight.w500,
                                                                      color: Colors.white,
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
                                                ),
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

//for PLAYLIST
                                Padding(
                                  padding: const EdgeInsets.only(top: 38.0),
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
                                                top: 18,
                                              ),
                                              child: Text(
                                                "Playlists",
                                                style: GoogleFonts.dmSans(
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
                                                                                style: GoogleFonts.dmSans(
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
                                ),

                                SizedBox(
                                  height: 500,
                                  child: new FutureBuilder<List<PlaylistModel>>(
                                    future: _myPlaylist,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return GridView.builder(
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: snapshot.data.length,
                                          itemBuilder: (_, index) {
                                            snapshot.data.forEach((element) {});

                                            Future<List<AddPlaylistModel>> _myCheck = (getSongsPlaylist(snapshot.data[snapshot.data.length - index - 1].playlistName.toString()));
                                            return Container(
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
                                                                title: Text(
                                                                  "Play Playlist",
                                                                  style: TextStyle(color: Colors.black),
                                                                ),
                                                                trailingIcon: Icon(Icons.play_arrow, color: Colors.black),
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
                                                              title: Text(
                                                                "Add / Edit Songs",
                                                                style: TextStyle(color: Colors.black),
                                                              ),
                                                              trailingIcon: Icon(Icons.edit_outlined, color: Colors.black),
                                                              onPressed: () async {
                                                                Get.to(ScreenTwo(playlistName: snapshot.data[snapshot.data.length - index - 1].playlistName.toString(), check: refresh));
                                                              },
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
                                                                onPressed: () {
                                                                  showAlertDialogPlaylist(context, snapshot.data[snapshot.data.length - index - 1].playlistName.toString());
                                                                }),
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
                                                            margin: EdgeInsets.only(left: 0, right: 0),
                                                            width: 250,
                                                            height: 250,
                                                            child: Stack(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.only(bottom: 0.0),
                                                                  child: Container(
                                                                    width: 200,
                                                                    height: 240,
                                                                    child: Center(
                                                                      child: Stack(
                                                                        children: [
                                                                          Container(
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
                                                                                  padding: const EdgeInsets.only(left: 18.0, right: 8, bottom: 28, top: 35),
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
                                                                                        style: GoogleFonts.dmSans(
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

                                Padding(
                                  padding: const EdgeInsets.only(bottom: 58.0),
                                  child: Container(height: 250, color: Colors.transparent),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: 1,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
