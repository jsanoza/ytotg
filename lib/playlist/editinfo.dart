import 'dart:io';
import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ffmpeg/media_information.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marquee/marquee.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yt_otg/model/dbProvider.dart';
import 'package:yt_otg/model/waveslider.dart';
import 'package:path/path.dart' as path;

class EditInfo extends StatefulWidget {
  final String pathList;
  final String titleList;
  final String authornameList;
  final String thumbnailList;
  final String urlList;
  final Function hello;

  const EditInfo({Key key, this.pathList, this.titleList, this.authornameList, this.thumbnailList, this.hello, this.urlList}) : super(key: key);

  @override
  _EditInfoState createState() => _EditInfoState();
}

class _EditInfoState extends State<EditInfo> {
  File _image;
  final picker = ImagePicker();
  Directory appDocDir;
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  final FlutterFFprobe _flutterFFprobe = new FlutterFFprobe();

  final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer();
  RangeValues _currentRangeValues = RangeValues(0, 0);
  List<int> bars = [];
  bool _isPlaying = false;
  TextEditingController _titleTextController;
  TextEditingController _artistTextContoller;
  MemoDbProvider musicDB = MemoDbProvider();
  TextEditingController _playlistTextController;
  TextEditingController _endplaylistTextController;
  // double initialBarPosition = 0.0;
  // double barWidth = 5.0;
  // int maxBarHight = 50,
  // double width 60.0;

  // void randomNumberGenerator() {

  //   Random r = Random();
  //   for (var i = 0; i < numberOfBars; i++) {
  //     bars.add(r.nextInt(maxBarHight - 10) + 10);
  //   }
  // }

  // _onTapDown(TapDownDetails details) {
  //   var x = details.globalPosition.dx;
  //   print("tap down " + x.toString());
  //   setState(() {
  //     barPosition = x;
  //   });
  // }

  double seconds = 0;

  Future<double> lenghOfAudio(File audio) async {
    final FlutterFFprobe flutterFFprobe = FlutterFFprobe();
    MediaInformation mediaInformation = await flutterFFprobe.getMediaInformation(audio.path);
    Map<dynamic, dynamic> mp = mediaInformation.getMediaProperties();
    var duration = double.parse(mp['duration']);
    // print(mp);
    //
    setState(() {});
    print("duration: $duration");
    return duration;
  }

  Future<void> _openImagePicker() async {
    final pickedImage = await picker.getImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      _cropImage(pickedImage.path);
      setState(() {
        _image = File(pickedImage.path);
      });
    }
    String hello;
    return hello;
  }

  _cropImage(filePath) async {
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: filePath,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
              ]
            : [
                CropAspectRatioPreset.square,
              ],
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
        ),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
          minimumAspectRatio: 1.0,
          rotateButtonsHidden: true,
          resetButtonHidden: true,
        ));

    if (croppedImage != null) {
      _image = File(croppedImage.path);
      setState(() {});
    }
  }

  _allfunctions() async {
    appDocDir = await getApplicationDocumentsDirectory();

    _image = File(appDocDir.uri.toFilePath().toString() + widget.thumbnailList);
    seconds = await lenghOfAudio(File(appDocDir.uri.toFilePath().toString() + widget.pathList));

    setState(() {
      _currentRangeValues = RangeValues(0, seconds.toDouble());
      print(seconds.toString() + "HAHAHAHAHAHAH");
    });
  }

  Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }

  showAlertDialog(BuildContext context, urlList, authornameList, thumbnailList, pathList, titleList, newTitle, newArtist) {
    Widget continueButton = FlatButton(
      child: Text(
        "Update",
        style: GoogleFonts.poppins(
          color: Colors.pink,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: () async {
        await Permission.storage.request();
        bool firstdone = false;
        bool secondone = false;
        bool thirdone = false;
        Duration first;
        Duration second;
        if (newTitle == '') {
          newTitle = widget.titleList;
        }
        if (newArtist == '') {
          newArtist = widget.authornameList;
        }

        if (_playlistTextController.text != '') {
          setState(() {
            first = parseDuration(_playlistTextController.text);
          });
          // second = parseDuration(_endplaylistTextController.text);
          print('EDited');
        }

        if (_playlistTextController.text == '') {
          setState(() {
            first = _currentRangeValues.start.seconds;
          });
          // second = _currentRangeValues.end.seconds;
        }

        if (_endplaylistTextController.text != '') {
          setState(() {
            second = parseDuration(_endplaylistTextController.text);
          });
          // second = parseDuration(_endplaylistTextController.text);
          print('EDited');
        }

        if (_endplaylistTextController.text == '') {
          setState(() {
            second = _currentRangeValues.end.seconds;
          });
          // second = parseDuration(_endplaylistTextController.text);
          print('EDited');
        }

        File file2 = new File(path.join(appDocDir.uri.toFilePath(), '${widget.thumbnailList}'));
        if (_image.toString() != file2.toString()) {
          if (await file2.exists()) {
            await file2.delete().then((value) async {
              imageCache.clear();
              File frompicker = _image;
              File copyLast = await frompicker.copy(appDocDir.uri.toFilePath() + '${widget.thumbnailList}');
              setState(() {
                _image = copyLast;
                firstdone = !firstdone;
              });
            });
          }
        } else {
          firstdone = !firstdone;
        }

        await musicDB.updateMeta(urlList, authornameList, thumbnailList, pathList, titleList, newTitle, newArtist).then((value) async {
          secondone = !secondone;
        });

        File file2x2 = new File(path.join(appDocDir.uri.toFilePath(), '${widget.pathList}')); //original

        print(widget.pathList);
        var tempTitle = '${widget.pathList}'.replaceAll(r'1', '_temp');
        File filePath2 = new File(path.join(appDocDir.uri.toFilePath(), '$tempTitle'));
        print(tempTitle);
        if (await file2x2.exists()) {
          String okay2 = '\"${file2x2.path}\"';
          String okay = '\"${filePath2.path}\"';
          await _flutterFFmpeg.execute("-ss $first -i $okay2 -to $second -c copy $okay").then((rt) async {
            print('[TRIMMED VIDEO RESULT] : $rt');
            File zz = new File(path.join(appDocDir.uri.toFilePath(), '${widget.pathList}'));
            zz.delete().then((value) async {
              File file2x = new File(path.join(appDocDir.uri.toFilePath(), '${widget.pathList}')); //original
              String newokay2 = '\"${file2x.path}\"';
              String newokay = '\"${filePath2.path}\"';
              await _flutterFFmpeg.execute("-ss $first -i $newokay -to $second -c copy $newokay2").then((value) {
                print('[TRIMMED VIDEO RESULT #2] : $value');
                File lastDelete = new File(path.join(appDocDir.uri.toFilePath(), '$tempTitle'));
                lastDelete.delete().then((value) {
                  print('DELETED AND FINALIZED');
                  thirdone = !thirdone;
                });
              });
            });
          });
        }

        if ((firstdone = true) && (secondone = true) && (thirdone = true)) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text('Done.'),
              );
            },
          ).then((value) {
            widget.hello();
            Get.back();
          });
        }

        //   print(newTitle);
        //   print(newArtist);
        //   await musicDB.updateMeta(urlList, authornameList, thumbnailList, pathList, titleList, newTitle, newArtist).then((value) async {
        //     setState(() {});
        //     print('DONE');

        //     try {
        //       File file2 = new File(path.join(appDocDir.uri.toFilePath(), '${widget.thumbnailList}'));
        //       if (await file2.exists()) {
        //         await file2.delete().then((value) async {
        //           imageCache.clear();
        //           File frompicker = _image;
        //           File copyLast = await frompicker.copy(appDocDir.uri.toFilePath() + '${widget.thumbnailList}');
        //           setState(() {
        //             _image = copyLast;
        //           });
        //           return null;
        //         }).then((value) async {
        //           try {
        //             File file2 = new File(path.join(appDocDir.uri.toFilePath(), '${widget.pathList}')); //original
        //             print(widget.pathList);
        //             var tempTitle = '${widget.pathList}'.replaceAll(r'1', '_temp');
        //             File filePath2 = new File(path.join(appDocDir.uri.toFilePath(), '$tempTitle'));
        //             print(tempTitle);
        //             if (await file2.exists()) {
        //               String okay2 = '\"${file2.path}\"';
        //               String okay = '\"${filePath2.path}\"';
        //               await _flutterFFmpeg.execute("-ss ${_currentRangeValues.start.seconds} -i $okay2 -to ${_currentRangeValues.end.seconds} -c copy $okay").then((rt) async {
        //                 print('[TRIMMED VIDEO RESULT] : $rt');
        //                 File zz = new File(path.join(appDocDir.uri.toFilePath(), '${widget.pathList}'));
        //                 zz.delete().then((value) async {
        //                   File file2x = new File(path.join(appDocDir.uri.toFilePath(), '${widget.pathList}')); //original
        //                   String newokay2 = '\"${file2x.path}\"';
        //                   String newokay = '\"${filePath2.path}\"';
        //                   await _flutterFFmpeg.execute("-ss ${_currentRangeValues.start.seconds} -i $newokay -to ${_currentRangeValues.end.seconds} -c copy $newokay2").then((value) {
        //                     print('[TRIMMED VIDEO RESULT #2] : $value');
        //                     File lastDelete = new File(path.join(appDocDir.uri.toFilePath(), '$tempTitle'));
        //                     lastDelete.delete().then((value) {
        //                       print('DELETED AND FINALIZED');
        //                     });
        //                   });
        //                 });
        //               });
        //             }
        //           } catch (e) {
        //             showDialog(
        //               context: context,
        //               builder: (context) {
        //                 return AlertDialog(
        //                   content: Text('Error updating metadata. Please try again.1'),
        //                 );
        //               },
        //             ).then((value) {
        //               Get.back();
        //             });
        //           }
        //         }).then((value) {
        //           showDialog(
        //             context: context,
        //             builder: (context) {
        //               return AlertDialog(
        //                 content: Text('Track Meta Updated!'),
        //               );
        //             },
        //           ).then((value) {
        //             // widget.hello();
        //             Get.toEnd(() => 2);
        //           });

        //           return null;
        //         });
        //         setState(() {});
        //       }
        //     } catch (e) {
        //       showDialog(
        //         context: context,
        //         builder: (context) {
        //           return AlertDialog(
        //             content: Text('Error updating metadata. Please try again.2'),
        //           );
        //         },
        //       ).then((value) {
        //         Get.back();
        //       });
        //     }
        //   });
      },
    );
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancel",
        style: GoogleFonts.poppins(
          // fontSize: 25,
          color: Colors.black87,
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
        "Confirm",
        style: GoogleFonts.poppins(
          // fontSize: 25,
          color: Colors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
      content: Text(
        '''
Are you sure you want to trim, change the thumbnail, title and author name?
Please double check.
                                                                              ''',
        maxLines: 20,
        style: GoogleFonts.poppins(
          // fontSize: 25,
          color: Colors.black87,
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
  void initState() {
    // TODO: implement initState
    _allfunctions();
    Random r = Random();
    for (var i = 0; i < 50; i++) {
      bars.add(r.nextInt(200));
    }
    _playlistTextController = TextEditingController();
    _titleTextController = TextEditingController();

    _artistTextContoller = TextEditingController();

    _endplaylistTextController = TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
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
            ),
            Padding(
              padding: const EdgeInsets.only(top: 54.0, left: 20, bottom: 0),
              child: Container(
                child: Row(
                  children: [
                    Text(
                      "Audio Metadata",
                      style: GoogleFonts.poppins(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 370,
              width: Get.width,
              // color: Colors.red,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 119.0),
                    child: Container(
                      width: 200,
                      height: 200,
                      // color: Colors.grey[300],
                      child: _image != null
                          ? AspectRatio(
                              aspectRatio: 487 / 451,
                              child: Image.file(_image, fit: BoxFit.cover),
                            )
                          : Text('Please select an image'),
                    ),
                  ),
                  Container(
                    height: 40,
                    width: Get.width / 1.3,
                    child: Marquee(
                      text: widget.titleList,
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
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 350.0),
              child: Container(
                height: 50,
                width: Get.width,
                // color: Colors.red,
                child: Column(
                  children: [
                    ElevatedButton(
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
                          _openImagePicker();
                        },
                        child: Icon(
                          Icons.image_outlined,
                          size: 30,
                          color: Colors.white,
                        )),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 420.0),
              child: Container(
                height: 50,
                width: Get.width,
                // color: Colors.blue,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20),
                      child: RangeSlider(
                        values: _currentRangeValues,
                        activeColor: Colors.white,
                        inactiveColor: Colors.black45,
                        min: 0,
                        max: seconds,
                        onChanged: (RangeValues values) async {
                          setState(() {
                            _currentRangeValues = values;

                            print(_currentRangeValues.start);
                            _assetsAudioPlayer.seek(_currentRangeValues.start.seconds);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 470.0),
              child: Container(
                height: 60,
                width: Get.width,
                // color: Colors.red,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Start Trim Time: ',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'End Trim Time: ',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Text(
                        //   durationToString(_currentRangeValues.start.seconds),
                        //   style: GoogleFonts.poppins(
                        //     fontWeight: FontWeight.w500,
                        //     color: Colors.white,
                        //   ),
                        // ),
                        Focus(
                            child: Container(
                              height: 39,
                              width: 70,
                              child: TextField(
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  // fontSize: 25,
                                ),
                                // maxLength: 15,
                                controller: _playlistTextController,
                                maxLength: 5,
                                inputFormatters: [
                                  MaskTextInputFormatter(mask: "##:##"),
                                ],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  counterText: '',
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(left: 25.0),
                                  hintText: durationToString(_currentRangeValues.start.seconds),
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
                            ),
                            onFocusChange: (hasFocus) {
                              if (!hasFocus) {
                                setState(() {
                                  // _showSave = false;
                                  if (_playlistTextController.text != '') {
                                    if (_playlistTextController.text.length < 5) {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              content: Text('Start Trim time is invalid.'),
                                            );
                                          }).then((value) {
                                        _playlistTextController.text = '';
                                        FocusScope.of(context).requestFocus(new FocusNode());
                                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                                      });
                                    } else {
                                      var hello = parseDuration(_playlistTextController.text);
                                      print(hello.inSeconds.toString() + "FINAL");
                                      print(seconds.toString() + "FINAL");
                                      if (hello.inSeconds > seconds || hello.inSeconds < 0) {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                content: Text('Start Trim time is invalid.'),
                                              );
                                            }).then((value) {
                                          _playlistTextController.text = '';
                                          FocusScope.of(context).requestFocus(new FocusNode());
                                          SystemChannels.textInput.invokeMethod('TextInput.hide');
                                        });
                                      }
                                    }
                                  }
                                });
                              } else {
                                setState(() {
                                  // _showSave = true;
                                  if (_playlistTextController.text != '') {
                                    if (_playlistTextController.text.length < 5) {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              content: Text('Start Trim time is invalid.'),
                                            );
                                          }).then((value) {
                                        _playlistTextController.text = '';
                                      });
                                    } else {
                                      var hello = parseDuration(_playlistTextController.text);
                                      print(hello.inSeconds.toString() + "FINAL");
                                      print(seconds.toString() + "FINAL");
                                      if (hello.inSeconds > seconds || hello.inSeconds < 0) {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                content: Text('Start Trim time is invalid.'),
                                              );
                                            }).then((value) {
                                          _playlistTextController.text = '';
                                        });
                                      }
                                    }
                                  }
                                });
                              }
                            }),
                        // Text(
                        //   durationToString(_currentRangeValues.end.seconds),
                        //   style: GoogleFonts.poppins(
                        //     fontWeight: FontWeight.w500,
                        //     color: Colors.white,
                        //   ),
                        // ),
                        Focus(
                            child: Container(
                              height: 39,
                              width: 70,
                              child: TextField(
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  // fontSize: 25,
                                ),
                                maxLength: 5,
                                inputFormatters: [
                                  MaskTextInputFormatter(mask: "##:##"),
                                ],
                                keyboardType: TextInputType.number,
                                controller: _endplaylistTextController,
                                decoration: InputDecoration(
                                  counterText: '',
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(left: 25.0),
                                  hintText: durationToString(_currentRangeValues.end.seconds),
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
                            ),
                            onFocusChange: (hasFocus) {
                              if (!hasFocus) {
                                setState(() {
                                  // _showSave = false;

                                  if (_endplaylistTextController.text != '') {
                                    if (_playlistTextController.text.length < 5) {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              content: Text('End Trim time is invalid.'),
                                            );
                                          }).then((value) {
                                        _endplaylistTextController.text = '';
                                        FocusScope.of(context).requestFocus(new FocusNode());
                                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                                      });
                                    } else {
                                      var hello = parseDuration(_endplaylistTextController.text);
                                      print(hello.inSeconds.toString() + "FINAL");
                                      print(seconds.toString() + "FINAL");
                                      if (hello.inSeconds > seconds || hello.inSeconds <= 0) {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                content: Text('End Trim time is invalid.'),
                                              );
                                            }).then((value) {
                                          _endplaylistTextController.text = '';
                                          FocusScope.of(context).requestFocus(new FocusNode());
                                          SystemChannels.textInput.invokeMethod('TextInput.hide');
                                        });
                                      }
                                    }
                                  }
                                });
                              } else {
                                setState(() {
                                  // _showSave = true;
                                  if (_endplaylistTextController.text != '') {
                                    if (_endplaylistTextController.text.length < 5) {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              content: Text('End Trim time is invalid.'),
                                            );
                                          }).then((value) {
                                        _endplaylistTextController.text = '';
                                      });
                                    } else {
                                      var hello = parseDuration(_endplaylistTextController.text);
                                      print(hello.inSeconds.toString() + "FINAL");
                                      print(seconds.toString() + "FINAL");
                                      if (hello.inSeconds > seconds || hello.inSeconds <= 0) {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                content: Text('End Trim time is invalid.'),
                                              );
                                            }).then((value) {
                                          _endplaylistTextController.text = '';
                                        });
                                      }
                                    }
                                  }
                                });
                              }
                            }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 469.0),
              child: Container(
                height: 50,
                width: Get.width,
                // color: Colors.red,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
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
                            // setState(() {
                            //   _isPlaying = !_isPlaying;
                            // });
                            if (!_isPlaying) {
                              await _assetsAudioPlayer
                                  .open(
                                Audio.file(
                                  appDocDir.uri.toFilePath().toString() + widget.pathList,
                                ),
                                showNotification: true,
                                loopMode: LoopMode.none,
                                playInBackground: PlayInBackground.disabledRestoreOnForeground,
                                audioFocusStrategy: AudioFocusStrategy.none(),
                                seek: _currentRangeValues.start.seconds,
                              )
                                  .then((value) {
                                setState(() {
                                  _isPlaying = !_isPlaying;
                                });
                              });
                            } else {
                              _assetsAudioPlayer.playOrPause();
                              setState(() {
                                _isPlaying = !_isPlaying;
                              });
                            }
                          },
                          child: _isPlaying
                              ? Icon(
                                  Icons.pause_circle_filled_rounded,
                                  size: 30,
                                  color: Colors.white,
                                )
                              : Icon(
                                  Icons.play_circle_filled_outlined,
                                  size: 30,
                                  color: Colors.white,
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 531.0),
              child: Container(
                height: 150,
                width: Get.width,
                // color: Colors.red,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              width: Get.width,
                              child: TextField(
                                style: TextStyle(color: Colors.white),
                                // maxLength: 15,
                                controller: _titleTextController,
                                decoration: InputDecoration(
                                  counterText: '',
                                  isDense: true,
                                  labelText: 'Title',
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                  contentPadding: EdgeInsets.only(left: 25.0),
                                  hintText: widget.titleList,
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
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              width: Get.width,
                              child: TextField(
                                style: TextStyle(color: Colors.white),
                                // maxLength: 15,
                                controller: _artistTextContoller,
                                decoration: InputDecoration(
                                  counterText: '',
                                  isDense: true,
                                  labelText: 'Artist',
                                  labelStyle: TextStyle(color: Colors.white),
                                  prefixIcon: Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                  contentPadding: EdgeInsets.only(left: 25.0),
                                  hintText: widget.authornameList,
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 670.0),
              child: Container(
                height: 50,
                width: Get.width,
                // color: Colors.red,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          height: 50,
                          width: Get.width / 2,
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
                              showAlertDialog(
                                context,
                                widget.urlList,
                                widget.authornameList,
                                widget.thumbnailList,
                                widget.pathList,
                                widget.titleList,
                                _titleTextController.text,
                                _artistTextContoller.text,
                              );
                            },
                            child: Text(
                              "SAVE",
                              style: GoogleFonts.poppins(
                                // fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    // return Scaffold(
    //   resizeToAvoidBottomInset: true,
    //   backgroundColor: Color(0xffC06C84),
    //   body: SingleChildScrollView(
    //     child: Container(
    //       height: Get.height,
    //       width: Get.width,
    //       decoration: BoxDecoration(
    //         gradient: new LinearGradient(
    //             colors: [
    //               Color(0xffC06C84),
    //               Color(0xff355C7D),
    //               Color(0xff6C5B7B),
    //             ],
    //             begin: const FractionalOffset(0.0, 0.0),
    //             end: const FractionalOffset(1.0, 1.0),
    //             stops: [0.0, 1.0, 1.0],
    //             tileMode: TileMode.clamp),
    //       ),
    //       child: Column(
    //         children: [
    //           // SizedBox(
    //           //   height: 65,
    //           // ),
    //           Column(
    //             children: <Widget>[
    //               Row(
    //                 children: [
    //                   Padding(
    //                     padding: const EdgeInsets.only(top: 20.0, left: 20, bottom: 0),
    //                     child: Text(
    //                       "Edit Audio Metadata",
    //                       style: GoogleFonts.poppins(
    //                         fontSize: 30,
    //                         fontWeight: FontWeight.w500,
    //                         color: Colors.white,
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               Padding(
    //                 padding: const EdgeInsets.all(12.0),
    //                 child: Container(
    //                   width: 480,
    //                   child: Column(
    //                     children: [
    //                       Padding(
    //                         padding: const EdgeInsets.only(
    //                           top: 10.0,
    //                         ),
    //                         child: Center(
    //                           child: Column(
    //                             children: [
    //                               Padding(
    //                                 padding: const EdgeInsets.all(10.0),
    //                                 child: Container(
    //                                   alignment: Alignment.center,
    //                                   width: 250,
    //                                   height: 250,
    //                                   // color: Colors.grey[300],
    //                                   child: _image != null
    //                                       ? AspectRatio(
    //                                           aspectRatio: 487 / 451,
    //                                           child: Image.file(_image, fit: BoxFit.cover),
    //                                         )
    //                                       : Text('Please select an image'),
    //                                 ),
    //                               )
    //                             ],
    //                           ),
    //                         ),
    //                       ),
    //                       Center(
    //                         child: ElevatedButton(
    //                             style: ButtonStyle(
    //                               backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
    //                               shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
    //                               shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //                                 RoundedRectangleBorder(
    //                                   borderRadius: BorderRadius.circular(90.0),
    //                                   side: BorderSide(color: Colors.white),
    //                                 ),
    //                               ),
    //                             ),
    //                             onPressed: () async {
    //                               _openImagePicker();
    //                             },
    //                             child: Icon(
    //                               Icons.image_outlined,
    //                               size: 30,
    //                               color: Colors.white,
    //                             )),
    //                         // child: Text('Select An Image'),
    //                         // onPressed: () async {
    //                         //   _openImagePicker();
    //                         // },
    //                         // ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //               // Padding(
    //               //   padding: const EdgeInsets.all(8.0),
    //               //   child: Container(
    //               //     height: 45,
    //               //     child: TextField(
    //               //       style: TextStyle(color: Colors.white),
    //               //       // maxLength: 15,
    //               //       controller: _titleTextController,
    //               //       decoration: InputDecoration(
    //               //         counterText: '',
    //               //         isDense: true,
    //               //         labelText: 'Title',
    //               //         labelStyle: TextStyle(
    //               //           color: Colors.white,
    //               //         ),
    //               //         prefixIcon: Icon(
    //               //           Icons.edit_outlined,
    //               //           color: Colors.white,
    //               //           size: 25,
    //               //         ),
    //               //         contentPadding: EdgeInsets.only(left: 25.0),
    //               //         hintText: widget.titleList,
    //               //         hintStyle: TextStyle(color: Colors.white),
    //               //         enabledBorder: OutlineInputBorder(
    //               //           borderSide: BorderSide(color: Colors.white, width: 1),
    //               //         ),
    //               //         focusedBorder: OutlineInputBorder(
    //               //           borderSide: BorderSide(color: Colors.white, width: 1),
    //               //           borderRadius: BorderRadius.circular(20.0),
    //               //         ),
    //               //       ),
    //               //     ),
    //               //   ),
    //               // ),
    //               // Padding(
    //               //   padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8, bottom: 70),
    //               //   child: Container(
    //               //     height: 45,
    //               //     child: TextField(
    //               //       style: TextStyle(color: Colors.white),
    //               //       // maxLength: 15,
    //               //       controller: _artistTextContoller,
    //               //       decoration: InputDecoration(
    //               //         counterText: '',
    //               //         isDense: true,
    //               //         labelText: 'Artist',
    //               //         labelStyle: TextStyle(color: Colors.white),
    //               //         prefixIcon: Icon(
    //               //           Icons.edit_outlined,
    //               //           color: Colors.white,
    //               //           size: 25,
    //               //         ),
    //               //         contentPadding: EdgeInsets.only(left: 25.0),
    //               //         hintText: widget.authornameList,
    //               //         hintStyle: TextStyle(color: Colors.white),
    //               //         enabledBorder: OutlineInputBorder(
    //               //           borderSide: BorderSide(color: Colors.white, width: 1),
    //               //         ),
    //               //         focusedBorder: OutlineInputBorder(
    //               //           borderSide: BorderSide(color: Colors.white, width: 1),
    //               //           borderRadius: BorderRadius.circular(20.0),
    //               //         ),
    //               //       ),
    //               //     ),
    //               //   ),
    //               // ),
    //             ],
    //           ),
    //           Expanded(
    //             child: Padding(
    //               padding: const EdgeInsets.only(left: 8.0),
    //               child: Container(
    //                 // height: 50,
    //                 width: Get.width,
    //                 child: Column(
    //                   children: [
    //                     Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceAround,
    //                       children: [
    //                         Text(
    //                           'Start Trim Time: ',
    //                           style: GoogleFonts.poppins(
    //                             fontWeight: FontWeight.w500,
    //                             color: Colors.white,
    //                           ),
    //                         ),
    //                         Text(
    //                           'End Trim Time: ',
    //                           style: GoogleFonts.poppins(
    //                             fontWeight: FontWeight.w500,
    //                             color: Colors.white,
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                     Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceAround,
    //                       children: [
    //                         Text(
    //                           durationToString(_currentRangeValues.start.seconds),
    //                           style: GoogleFonts.poppins(
    //                             fontWeight: FontWeight.w500,
    //                             color: Colors.white,
    //                           ),
    //                         ),
    //                         Text(
    //                           durationToString(_currentRangeValues.end.seconds),
    //                           style: GoogleFonts.poppins(
    //                             fontWeight: FontWeight.w500,
    //                             color: Colors.white,
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                     RangeSlider(
    //                       values: _currentRangeValues,
    //                       activeColor: Colors.white,
    //                       inactiveColor: Colors.black45,
    //                       min: 0,
    //                       max: seconds,
    //                       // divisions: 5,
    //                       // labels: RangeLabels(
    //                       //   _currentRangeValues.start.round().toString(),
    //                       //   _currentRangeValues.end.round().toString(),
    //                       // ),
    //                       onChanged: (RangeValues values) async {
    //                         setState(() {
    //                           _currentRangeValues = values;

    //                           print(_currentRangeValues.end);
    //                         });

    //                         await _assetsAudioPlayer
    //                             .open(
    //                           Audio.file(
    //                             appDocDir.uri.toFilePath().toString() + widget.pathList,
    //                           ),
    //                           showNotification: true,
    //                           loopMode: LoopMode.none,
    //                           playInBackground: PlayInBackground.disabledRestoreOnForeground,
    //                           audioFocusStrategy: AudioFocusStrategy.none(),
    //                           seek: _currentRangeValues.start.seconds,
    //                         )
    //                             .then((value) {
    //                           setState(() {
    //                             _isPlaying = true;
    //                           });
    //                         });
    //                       },
    //                     ),
    //                     Row(
    //                       mainAxisAlignment: MainAxisAlignment.center,
    //                       children: [
    //                         Center(
    //                           child: ElevatedButton(
    //                               style: ButtonStyle(
    //                                 backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
    //                                 shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
    //                                 shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //                                   RoundedRectangleBorder(
    //                                     borderRadius: BorderRadius.circular(90.0),
    //                                     side: BorderSide(color: Colors.white),
    //                                   ),
    //                                 ),
    //                               ),
    //                               onPressed: () async {
    //                                 _assetsAudioPlayer.playOrPause();
    //                                 setState(() {
    //                                   _isPlaying = !_isPlaying;
    //                                 });
    //                               },
    //                               child: _isPlaying
    //                                   ? Icon(
    //                                       Icons.pause_circle_filled_rounded,
    //                                       size: 30,
    //                                       color: Colors.white,
    //                                     )
    //                                   : Icon(
    //                                       Icons.play_circle_filled_outlined,
    //                                       size: 30,
    //                                       color: Colors.white,
    //                                     )),
    //                         ),
    //                         Center(
    //                           child: ElevatedButton(
    //                             style: ButtonStyle(
    //                               backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
    //                               shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
    //                               shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //                                 RoundedRectangleBorder(
    //                                   borderRadius: BorderRadius.circular(90.0),
    //                                   side: BorderSide(color: Colors.white),
    //                                 ),
    //                               ),
    //                             ),
    //                             onPressed: () async {
    //                               setState(() {});

    //                               //for info
    //                               // showAlertDialog(
    //                               //   context,
    //                               //   widget.urlList,
    //                               //   widget.authornameList,
    //                               //   widget.thumbnailList,
    //                               //   widget.pathList,
    //                               //   widget.titleList,
    //                               //   _titleTextController.text,
    //                               //   _artistTextContoller.text
    //                               // );
    //                               // print(_titleTextController.text);

    //                               //for image
    //                               // await Permission.storage.request();
    //                               // try {
    //                               //   File file2 = new File(path.join(appDocDir.uri.toFilePath(), '${widget.thumbnailList}'));
    //                               //   if (await file2.exists()) {
    //                               //     await file2.delete().then((value) async {
    //                               //       imageCache.clear();
    //                               //       File frompicker = _image;
    //                               //       File copyLast = await frompicker.copy(appDocDir.uri.toFilePath() + '${widget.thumbnailList}');
    //                               //       setState(() {
    //                               //         //this is where the problem lies
    //                               //         _image = copyLast;
    //                               //       });
    //                               //       return null;
    //                               //     });
    //                               //     setState(() {});
    //                               //   }
    //                               // } catch (e) {}

    //                               //for audio
    //                               // await Permission.storage.request();
    //                               // try {
    //                               //   File file2 = new File(path.join(appDocDir.uri.toFilePath(), '${widget.pathList}')); //original
    //                               //   print(widget.pathList);
    //                               //   var tempTitle = '${widget.pathList}'.replaceAll(r'1', '_temp');
    //                               //   File filePath2 = new File(path.join(appDocDir.uri.toFilePath(), '$tempTitle'));
    //                               //   print(tempTitle);
    //                               //   if (await file2.exists()) {
    //                               //     String okay2 = '\"${file2.path}\"';
    //                               //     String okay = '\"${filePath2.path}\"';
    //                               //     await _flutterFFmpeg.execute("-ss ${_currentRangeValues.start.seconds} -i $okay2 -to ${_currentRangeValues.end.seconds} -c copy $okay").then((rt) async {
    //                               //       print('[TRIMMED VIDEO RESULT] : $rt');
    //                               //       File zz = new File(path.join(appDocDir.uri.toFilePath(), '${widget.pathList}'));
    //                               //       zz.delete().then((value) async {
    //                               //         File file2x = new File(path.join(appDocDir.uri.toFilePath(), '${widget.pathList}')); //original
    //                               //         String newokay2 = '\"${file2x.path}\"';
    //                               //         String newokay = '\"${filePath2.path}\"';
    //                               //         await _flutterFFmpeg.execute("-ss ${_currentRangeValues.start.seconds} -i $newokay -to ${_currentRangeValues.end.seconds} -c copy $newokay2").then((value) {
    //                               //           print('[TRIMMED VIDEO RESULT #2] : $value');
    //                               //           File lastDelete = new File(path.join(appDocDir.uri.toFilePath(), '$tempTitle'));
    //                               //           lastDelete.delete().then((value) {
    //                               //             print('DELETED AND FINALIZED');
    //                               //           });
    //                               //         });
    //                               //       });
    //                               //     });
    //                               //   }
    //                               // } catch (e) {}
    //                             },
    //                             child: Icon(
    //                               Icons.save,
    //                               size: 30,
    //                               color: Colors.white,
    //                             ),
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               // child: WaveSlider(
    //               //   initialBarPosition: 180.0,
    //               //   barWidth: 5.0,
    //               //   maxBarHight: 50,
    //               //   width: MediaQuery.of(context).size.width,
    //               // ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}

class Bar extends StatelessWidget {
  final double position;
  final GestureDragUpdateCallback callback;

  Bar({this.position, this.callback});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: position >= 0.0 ? position : 0.0),
      child: GestureDetector(
        onHorizontalDragUpdate: callback,
        child: Container(
          color: Colors.red,
          height: 200.0,
          width: 5.0,
        ),
      ),
    );
  }
}

String durationToString(Duration duration) {
  String twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour));
  final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(Duration.secondsPerMinute));

  return '$twoDigitMinutes:$twoDigitSeconds';
}
