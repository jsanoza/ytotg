// @dart=2.9
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'main.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  ThemeMode _themeMode;

  @override
  Widget build(BuildContext context) {
    _themeMode = ThemeController.to.themeMode;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
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
          // color: Colors.pink,
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0, left: 20),
                    child: Container(
                      // color: Colors.blue,
                      height: 100,
                      width: Get.width,
                      child: Text(
                        "Settings",
                        style: GoogleFonts.dmSans(
                          fontSize: 35,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0.0, left: 0),
                    child: Container(
                      // color: Colors.blue,
                      decoration: BoxDecoration(
                        border: Border(
                          // top: (BorderSide(color: Colors.grey, width: 1)),
                          bottom: (BorderSide(color: Colors.grey, width: 1)),
                        ),
                      ),
                      height: 35,
                      width: Get.width,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          "Theme",
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        // color: Colors.white,
                        decoration: BoxDecoration(
                          border: Border(
                            // top: (BorderSide(color: Colors.grey, width: 1)),
                            bottom: (BorderSide(color: Colors.grey, width: 1)),
                          ),
                        ),
                        height: 55,
                        width: Get.width,
                        child: RadioListTile(
                          title: Text(
                            'System',
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          value: ThemeMode.system,
                          groupValue: _themeMode,
                          onChanged: (value) {
                            setState(() {
                              _themeMode = ThemeMode.system;
                              ThemeController.to.setThemeMode(_themeMode); //STEP 8 - change this line
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        // color: Colors.green,
                        decoration: BoxDecoration(
                          border: Border(
                            // top: (BorderSide(color: Colors.grey, width: 1)),
                            bottom: (BorderSide(color: Colors.grey, width: 1)),
                          ),
                        ),
                        height: 55,
                        width: Get.width,
                        child: RadioListTile(
                          title: Text(
                            'Dark',
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          value: ThemeMode.dark,
                          groupValue: _themeMode,
                          onChanged: (value) {
                            setState(() {
                              _themeMode = ThemeMode.dark;
                              ThemeController.to.setThemeMode(_themeMode);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        // color: Colors.red,
                        decoration: BoxDecoration(
                          border: Border(
                            // top: (BorderSide(color: Colors.grey, width: 1)),
                            bottom: (BorderSide(color: Colors.grey, width: 1)),
                          ),
                        ),
                        height: 55,
                        width: Get.width,
                        child: RadioListTile(
                          title: Text(
                            'Light',
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          value: ThemeMode.light,
                          groupValue: _themeMode,
                          onChanged: (value) {
                            setState(() {
                              _themeMode = ThemeMode.light;
                              ThemeController.to.setThemeMode(_themeMode);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 20),
                    child: Container(
                      // color: Colors.blue,
                      height: 30,
                      width: Get.width,
                      child: AutoSizeText(
                        "Want to support the developer?",
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
                      height: 30,
                      width: Get.width,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: AutoSizeText(
                          """Tara na! Kilala nyo naman ako. G na yan! """,
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
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 420.0),
                child: Container(
                  height: double.infinity,
                  child: SingleChildScrollView(
                    child: Container(
                      // color: Colors.red,
                      // height: 300,
                      width: Get.width,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0, left: 20),
                            child: Container(
                              // color: Colors.blue,
                              height: 30,
                              width: Get.width,
                              child: AutoSizeText(
                                "FAQ",
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
                              height: 400,
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
                                          "Q: Bakit hindi napupunta sa download list ang pinusuan ko?",
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
                                          "A: Try to refresh the page or some of my dependencies",
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
                                          "kailangan ng updates because of YT updates.",
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
                                          "Q: Bakit wala sa app store / play store?",
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
                                          "A: I need to pay for an annual fee of \$99 to upload ",
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
                                          "my app sa appstore + \$25 sa playstore.",
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
                                          "Plus, we are using YT as our music library,",
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
                                          "baka di pumasa sa app review.",
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
                                          "Q: Anong quality ang downloaded music?",
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
                                          "A: high4320 → const VideoQuality → High quality \(4320p\).",
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
                                          "Pababa if hindi available.",
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
                                          "Q: Gaano kalaki size ng downloaded music?",
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
                                          "A: Around 2-5 MB.",
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
                                          "Q: Bakit Web View at hindi direct YT API?",
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
                                          "A: YT API only allows 10,000 units per day.",
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
                                          "Not really enough...",
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
