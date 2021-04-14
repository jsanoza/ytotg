import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashplayer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
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
