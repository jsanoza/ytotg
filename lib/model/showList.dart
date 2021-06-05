import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yt_otg/model/dbProvider.dart';
import 'package:yt_otg/model/singleAudio.dart';

import 'downloadModel.dart';

Future<List<DlModel>> fetchEmployeesFromDatabase() async {
  var dbHelper = MemoDbProvider();
  Future<List<DlModel>> employees = dbHelper.getEmployees();
  return employees;
}

class ShowList extends StatefulWidget {
  final Function() playlist, recent;

  const ShowList({Key key, this.playlist, this.recent}) : super(key: key);
  @override
  _ShowListState createState() => _ShowListState();
}

class _ShowListState extends State<ShowList> {
  MemoDbProvider musicDB = MemoDbProvider();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // appBar: new AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.primary,
      //   title: new Text(
      //     'Hey!',
      //     style: GoogleFonts.poppins(
      //       // fontSize: 13,
      //       color: Colors.white,
      //       fontWeight: FontWeight.w500,
      //     ),
      //   ),
      // ),
      body: Container(
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
        height: Get.height,
        width: Get.width,
        child: Padding(
          padding: const EdgeInsets.only(top: 58.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0, left: 0),
                child: Container(
                  // color: Colors.blue,
                  decoration: BoxDecoration(
                    border: Border(
                      // top: (BorderSide(color: Colors.grey, width: 1)),
                      bottom: (BorderSide(color: Colors.grey, width: 1)),
                    ),
                  ),
                  height: 30,
                  width: Get.width,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0.0),
                  ),
                ),
              ),
              AutoSizeText(
                'New features coming soon 💯💯💯',
                maxLines: 1,
                maxFontSize: 14,
                minFontSize: 14,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 0.0, left: 0),
                child: Container(
                  // color: Colors.blue,
                  decoration: BoxDecoration(
                    border: Border(
                      // top: (BorderSide(color: Colors.grey, width: 1)),
                      bottom: (BorderSide(color: Colors.grey, width: 1)),
                    ),
                  ),
                  height: 30,
                  width: Get.width,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0.0),
                  ),
                ),
              ),
//next line

              Padding(
                padding: const EdgeInsets.only(bottom: 30.0, left: 0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: (BorderSide(color: Colors.grey, width: 1)),
                    ),
                  ),
                  height: 30,
                  width: Get.width,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 20),
                child: Container(
                  // color: Colors.blue,
                  height: 30,
                  width: Get.width,
                  // child: Text(
                  //   "Next update..",
                  //   style: GoogleFonts.dmSans(
                  //     color: Colors.white,
                  //     fontSize: 25,
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  // ),
                  child: AutoSizeText(
                    "Next update..",
                    maxLines: 1,
                    maxFontSize: 25,
                    minFontSize: 25,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0.0, left: 0),
                child: Container(
                  // color: Colors.blue,
                  decoration: BoxDecoration(
                    border: Border(
                      // top: (BorderSide(color: Colors.grey, width: 1)),
                      bottom: (BorderSide(color: Colors.grey, width: 1)),
                    ),
                  ),
                  height: 250,
                  width: Get.width,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 5,
                            ),
                            AutoSizeText(
                              "Lyrics.",
                              maxLines: 1,
                              maxFontSize: 14,
                              minFontSize: 14,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            AutoSizeText(
                              "Unknown bugs.",
                              maxLines: 1,
                              maxFontSize: 14,
                              minFontSize: 14,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            AutoSizeText(
                              "External Memory.",
                              maxLines: 1,
                              maxFontSize: 14,
                              minFontSize: 14,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            AutoSizeText(
                              "Battery consumption.",
                              maxLines: 1,
                              maxFontSize: 14,
                              minFontSize: 14,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            AutoSizeText(
                              "Search your own music library.",
                              maxLines: 1,
                              maxFontSize: 14,
                              minFontSize: 14,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            AutoSizeText(
                              """Sleep music after specified time. 
ex: Stop music after 2 or 3 hours etc...""",
                              maxLines: 1,
                              maxFontSize: 14,
                              minFontSize: 14,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            AutoSizeText(
                              "Search album cover directly from the app.",
                              maxLines: 1,
                              maxFontSize: 14,
                              minFontSize: 14,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            AutoSizeText(
                              "Trimmer base on milliseconds instead of seconds.",
                              maxLines: 1,
                              maxFontSize: 14,
                              minFontSize: 14,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            AutoSizeText(
                              "Moarrrr Animations!",
                              maxLines: 1,
                              maxFontSize: 14,
                              minFontSize: 14,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
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
    );
  }
}
