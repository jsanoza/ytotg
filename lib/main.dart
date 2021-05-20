import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yt_otg/model/colors.dart';
import 'dashplayer.dart';

void main() {
  Get.lazyPut<ThemeController>(() => ThemeController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeController.to.getThemeModeFromPreferences();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YT ot G!',
      // initialBinding: SampleBind(),
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.pink[800],
        radioTheme: RadioThemeData(fillColor: MaterialStateProperty.all<Color>(Colors.white)),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            side: BorderSide(color: Colors.white, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(90.0)),
            // textStyle: TextStyle(color: Colors.white, fontSize: 20, wordSpacing: 2, letterSpacing: 2),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.green,
        ),
        colorScheme: ColorScheme.light(
          primary: Color(0xff6C5B7B),
          primaryVariant: Color(0xff355C7D),
          secondary: Color(0xffC06C84),

          // Color(0xffC06C84),
          // Color(0xff355C7D),
          // Color(0xff6C5B7B),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.grey[850],
        primaryTextTheme: TextTheme(
          headline1: TextStyle(color: Colors.white),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.grey[850],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            side: BorderSide(color: Colors.white, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(90.0)),
            // textStyle: TextStyle(color: Colors.black, fontSize: 20, wordSpacing: 2, letterSpacing: 2),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.grey[850],
        ),
        colorScheme: ColorScheme.light(
          primary: Colors.grey[850],
          primaryVariant: Colors.grey[850],
          secondary: Colors.grey[850],
        ),
      ),
      themeMode: ThemeController.to.themeMode,
      // getPages: [
      //   GetPage(
      //     name: "/Trial",
      //     page: () => Trial(),
      //     binding: SampleBind(),
      //   ),
      // ],
      home: Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  go() {
    Get.offAll(() => DashPlayer());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    new Timer(new Duration(milliseconds: 1000), () {
      go();
    });
  }

  @override
  Widget build(BuildContext context) {
    NowPlaying y = Get.find<NowPlaying>();
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
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
          ),
          Container(
              child: Stack(
            children: <Widget>[
              Center(
                  child: CircularProgressIndicator(
                backgroundColor: Colors.white,
                valueColor: new AlwaysStoppedAnimation<Color>(
                  Color(0xffC06C84),
                ),
              )),
            ],
          ))
        ],
      ),
    );
  }
}

//STEP 9 - add our ThemeController
class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  SharedPreferences prefs;
  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode themeMode) async {
    Get.changeThemeMode(themeMode);
    _themeMode = themeMode;
    update();
    prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', themeMode.toString().split('.')[1]);
  }

  getThemeModeFromPreferences() async {
    ThemeMode themeMode;
    prefs = await SharedPreferences.getInstance();
    String themeText = prefs.getString('theme') ?? 'system';
    try {
      themeMode = ThemeMode.values.firstWhere((e) => describeEnum(e) == themeText);
    } catch (e) {
      themeMode = ThemeMode.system;
    }
    setThemeMode(themeMode);
  }
}
