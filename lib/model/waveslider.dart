import 'dart:math';

import 'package:flutter/material.dart';

class WaveSlider extends StatefulWidget {
  final double initialBarPosition;
  final double barWidth;
  final int maxBarHight;
  final double width;
  WaveSlider({
    this.initialBarPosition = 0.0,
    this.barWidth = 5.0,
    this.maxBarHight = 50,
    this.width = 60.0,
  });
  @override
  State<StatefulWidget> createState() => WaveSliderState();
}

class WaveSliderState extends State<WaveSlider> {
  List<int> bars = [];
  double barPosition;
  double barWidth;
  int maxBarHight;
  double width;

  int numberOfBars;

  void randomNumberGenerator() {
    Random r = Random();
    for (var i = 0; i < numberOfBars; i++) {
      bars.add(r.nextInt(maxBarHight - 10) + 10);
    }
  }

  _onTapDown(TapDownDetails details) {
    var x = details.globalPosition.dx;
    print("tap down " + x.toString());
    setState(() {
      barPosition = x;
    });
  }

  @override
  void initState() {
    super.initState();
    barPosition = widget.initialBarPosition;
    barWidth = widget.barWidth;
    maxBarHight = widget.maxBarHight.toInt();
    width = widget.width;
    if (bars.isNotEmpty) bars = [];
    numberOfBars = width ~/ barWidth;
    randomNumberGenerator();
  }

  @override
  Widget build(BuildContext context) {
    int barItem = 0;
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: GestureDetector(
          onTapDown: (TapDownDetails details) => _onTapDown(details),
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            setState(() {
              barPosition = details.globalPosition.dx;
            });
          },
          child: Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: bars.map((int height) {
                Color color = barItem + 1 < barPosition / barWidth ? Colors.white : Colors.grey[600];
                barItem++;
                return Row(
                  children: <Widget>[
                    Container(
                      width: .1,
                      height: height.toDouble(),
                      color: Colors.black,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(1.0),
                          topRight: const Radius.circular(1.0),
                        ),
                      ),
                      height: height.toDouble(),
                      width: 4.8,
                    ),
                    Container(
                      width: .1,
                      height: height.toDouble(),
                      color: Colors.black,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
