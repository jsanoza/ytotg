import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class EditInfo extends StatefulWidget {
  final String pathList;
  final String titleList;
  final String authornameList;
  final String thumbnailList;
  final Function hello;

  const EditInfo({Key key, this.pathList, this.titleList, this.authornameList, this.thumbnailList, this.hello}) : super(key: key);

  @override
  _EditInfoState createState() => _EditInfoState();
}

class _EditInfoState extends State<EditInfo> {
  File _image;
  final picker = ImagePicker();
  Directory appDocDir;

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
    setState(() {});
    _image = File(appDocDir.uri.toFilePath().toString() + widget.thumbnailList);
  }

  @override
  void initState() {
    // TODO: implement initState
    _allfunctions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   child: Text(widget.pathList + widget.titleList + widget.authornameList + widget.thumbnailList),
    // );
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xffC06C84),
      body: SingleChildScrollView(
        child: Container(
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
          child: Column(
            children: [
              SizedBox(
                height: 65,
              ),
              Column(
                children: <Widget>[
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, left: 20, bottom: 0),
                        child: Text(
                          "Edit Audio Metadata",
                          style: GoogleFonts.poppins(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: 480,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 10.0,
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 250,
                                      height: 250,
                                      // color: Colors.grey[300],
                                      child: _image != null
                                          ? AspectRatio(
                                              aspectRatio: 487 / 451,
                                              child: Image.file(_image, fit: BoxFit.cover),
                                            )
                                          : Text('Please select an image'),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Center(
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
                                  _openImagePicker();
                                },
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 30,
                                  color: Colors.white,
                                )),
                            // child: Text('Select An Image'),
                            // onPressed: () async {
                            //   _openImagePicker();
                            // },
                            // ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(right: 12.0, left: 12, top: 10, bottom: 12),
                          //   child: Container(
                          //     width: 480,
                          //     child: Column(
                          //       children: [
                          //         TextField(
                          //           keyboardType: TextInputType.number,
                          //           maxLength: 11,
                          //           controller: _contactRegTextController,
                          //           decoration: InputDecoration(
                          //               counterText: '',
                          //               isDense: true,
                          //               prefixIcon: IconButton(
                          //                 color: Color(0xff085078),
                          //                 icon: Icon(Icons.contact_page),
                          //                 iconSize: 20.0,
                          //                 onPressed: () {},
                          //               ),
                          //               contentPadding: EdgeInsets.only(left: 25.0),
                          //               hintText: 'Contact Number',
                          //               border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0))),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 50,
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    // maxLength: 15,
                    // controller: _playlistTextController,
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 180,
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    // maxLength: 15,
                    // controller: _playlistTextController,
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
      ),
    );
  }
}
