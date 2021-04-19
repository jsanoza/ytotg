import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'downloadModel.dart';

class MemoDbProvider {
  Future<Database> init() async {
    Directory directory =
        await getApplicationDocumentsDirectory(); //returns a directory which stores permanent files
    final path = join(directory.path, "hello.db"); //create path to database

    return await openDatabase(
        //open the database or create a database if there isn't any
        path,
        version: 1, onCreate: (Database db, int version) async {
      await db.execute("""
          CREATE TABLE Music(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          urlList TEXT,
          titleList TEXT,
          authornameList TEXT,
          thumbnailList TEXT,
          pathList TEXT)""");
    });
  }

  Future<int> addItem(DlModel item) async {
    //returns number of items inserted as an integer
    final db = await init(); //open database
    return db.insert(
      "Music", item.toMap(), //toMap() function from MemoModel
      conflictAlgorithm:
          ConflictAlgorithm.ignore, //ignores conflicts due to duplicate entries
    );
  }

  // Future<List<DlModel>> fetchMemos() async {
  //   //returns the memos as a list (array)
  //   final db = await init();
  //   final maps = await db
  //       .query("Music"); //query all the rows in a table as an array of maps

  //   return List.generate(maps.length, (i) {
  //     //create a list of memos
  //     return DlModel(
     
  //       maps[i]['urlList'],
  //       maps[i]['titleList'],
  //       maps[i]['authornameList'],
  //       maps[i]['thumbnailList'],
  //       maps[i]['pathList'],
  //     );
  //   });
  // }


  Future<List<DlModel>> getEmployees() async {
    var dbClient = await init();
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Music');
    // ignore: deprecated_member_use
    List<DlModel> employees = new List();
    for (int i = 0; i < list.length; i++) {
      employees.add(
        new DlModel(
        
          list[i]["urlList"], 
          list[i]["titleList"], 
          list[i]["authornameList"],
          list[i]["thumbnailList"],
          list[i]["pathList"]));
    }
    print(employees.length);
    return employees;
  }


  Future<int> deleteMemo(String pathList) async{ //returns number of items deleted
    final db = await init();
  
    int result = await db.delete(
      "Music", //table name
      where: "pathList = ?",
      whereArgs: [pathList] // use whereArgs to avoid SQL injection
    );

    return result;
  }



}
 
