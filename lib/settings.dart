// @dart=2.9
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';

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
      body: Container(
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
        child: Column(
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
                child: Text(
                  "FAQ",
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
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
                  child: Text(
                    "Will be added later.",
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
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
