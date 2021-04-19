import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yt_otg/model/dbProvider.dart';
import 'package:yt_otg/model/singleAudio.dart';

import 'downloadModel.dart';

Future<List<DlModel>> fetchEmployeesFromDatabase() async {
  var dbHelper = MemoDbProvider();
  Future<List<DlModel>> employees = dbHelper.getEmployees();
  return employees;
}

class ShowList extends StatefulWidget {
  final Function() notifyParent;

  const ShowList({Key key, this.notifyParent}) : super(key: key);
  @override
  _ShowListState createState() => _ShowListState();
}

class _ShowListState extends State<ShowList> {
  MemoDbProvider musicDB = MemoDbProvider();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Color(0xff6C5B7B),
        title: new Text('Hey!'),
      ),
      body: Container(
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
        height: Get.height,
        width: Get.width,
        child: Center(
          child: Text(
            'New features coming soon :)',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}