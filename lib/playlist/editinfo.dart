import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  @override
  Widget build(BuildContext context) {
    // return Container(
    //   child: Text(widget.pathList + widget.titleList + widget.authornameList + widget.thumbnailList),
    // );
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
        child: Column(
          children: [
            // Text(widget.pathList + widget.titleList + widget.authornameList + widget.thumbnailList),
            SizedBox(
              height: 120,
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
                    labelText: widget.titleList,
                    labelStyle: TextStyle(
                      color: Colors.white,
                    ),
                    prefixIcon: Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 25,
                    ),
                    contentPadding: EdgeInsets.only(left: 25.0),
                    hintText: 'Title',
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
                    labelText: widget.authornameList,
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 25,
                    ),
                    contentPadding: EdgeInsets.only(left: 25.0),
                    hintText: 'Artist',
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
    );
  }
}
