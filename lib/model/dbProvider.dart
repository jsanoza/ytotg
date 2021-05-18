import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'downloadModel.dart';

class MemoDbProvider {
  Future<Database> init() async {
    Directory directory = await getApplicationDocumentsDirectory(); //returns a directory which stores permanent files
    final path = join(directory.path, "ggsir.db"); //create path to database

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
      await db.execute("""
          CREATE TABLE Playlist(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          playlistName TEXT)""");
      await db.execute("""
          CREATE TABLE pathPlaylist(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          playlistName TEXT,
          songspathList TEXT,
          thumbnailList TEXT,
          titleList TEXT,
          indexinPlaylist INT)""");
    });
  }

  Future<int> listTables() async {
    final db = await init();
    final tables = await db.rawQuery('SELECT * FROM sqlite_master ORDER BY name;');
    print(tables);

    (await db.query('sqlite_master', columns: ['type', 'name'])).forEach((row) {
      print(row.values);
    });
  }

  Future<int> updateMeta(String urlList, String authornameList, String thumbnailList, String pathList, String titleList, String newTitle, String newArtist) async {
    final db = await init();
    await db.rawUpdate("UPDATE Music SET titleList = ?, authornameList = ? WHERE titleList = ? AND pathList = ? AND urlList = ? ", [
      newTitle,
      newArtist,
      titleList,
      pathList,
      urlList,
    ]).then((value) async {
      await db.rawUpdate("UPDATE pathPlaylist SET titleList = ? WHERE songspathList = ? AND thumbnailList = ? AND titleList = ?", [
        newTitle,
        pathList,
        thumbnailList,
        titleList,
      ]);
      print('check');
    });
  }

  Future<int> addtoPlaylist(AddPlaylistModel item) async {
    final db = await init();
    return db.insert(
      "pathPlaylist",
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> updatePlaylist(oldIndex, newIndex, playlistName, songspathList) async {
    final db = await init();
    await db.delete("pathPlaylist", //table name
        where: "songspathList = ? AND playlistName = ?",
        whereArgs: [songspathList, playlistName] // use whereArgs to avoid SQL injection
        );
  }

  Future<int> addItem(DlModel item) async {
    //returns number of items inserted as an integer
    final db = await init(); //open database
    return db.insert(
      "Music", item.toMap(), //toMap() function from MemoModel
      conflictAlgorithm: ConflictAlgorithm.ignore, //ignores conflicts due to duplicate entries
    );
  }

  Future<int> addItem2(DlModel item) async {
    //returns number of items inserted as an integer
    final db = await init(); //open database
    return db.insert(
      "Music", item.toMap(), //toMap() function from MemoModel
      conflictAlgorithm: ConflictAlgorithm.replace, //ignores conflicts due to duplicate entries
    );
  }

  Future<int> addPlaylist(PlaylistModel name) async {
    final db = await init();
    return db.insert(
      "Playlist",
      name.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> existSonginPlaylist(pathList, playlistName) async {
    var db = await init();
    int count = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM pathPlaylist WHERE songspathList = \'$pathList' AND playlistName = \'$playlistName'"));
    return count;
  }

  Future<int> existPlaylist(id) async {
    var db = await init();
    int count = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM Playlist WHERE playlistName = \'$id'"));
    return count;
  }

  Future<List<AddPlaylistModel>> getSongsPlaylist(playlistName1) async {
    var db = await init();
    List<Map> list = await db.rawQuery("SELECT * FROM pathPlaylist WHERE playlistName = \'$playlistName1'");
    // ignore: deprecated_member_use
    List<AddPlaylistModel> playsongs = new List();
    for (int i = 0; i < list.length; i++) {
      playsongs.add(new AddPlaylistModel(
        list[i]["playlistName"],
        list[i]["songspathList"],
        list[i]["thumbnailList"],
        list[i]["indexinPlaylist"],
        list[i]['titleList'],
      ));
    }
    // print(playsongs.length);
    return playsongs;
  }

  Future<List<DlModel>> getSongsPlaylistInfo(path) async {
    var db = await init();
    List<Map> list = await db.rawQuery("SELECT * FROM Music WHERE pathList = \'$path'");
    // ignore: deprecated_member_use
    List<DlModel> info = new List();
    for (int i = 0; i < list.length; i++) {
      info.add(new DlModel(
        list[i]["urlList"],
        list[i]["titleList"],
        list[i]["authornameList"],
        list[i]["thumbnailList"],
        list[i]["pathList"],
      ));
    }
    print(info.length);
    return info;
  }

  Future<List<PlaylistModel>> getPlaylist() async {
    var db = await init();
    List<Map> list = await db.rawQuery('SELECT * FROM Playlist');
    // ignore: deprecated_member_use
    List<PlaylistModel> playlist = new List();
    for (int i = 0; i < list.length; i++) {
      playlist.add(new PlaylistModel(list[i]['playlistName']));
    }
    print(playlist.length);
    return playlist;
  }

  Future<List<DlModel>> getEmployees() async {
    var db = await init();
    List<Map> list = await db.rawQuery('SELECT * FROM Music');
    // ignore: deprecated_member_use
    List<DlModel> employees = new List();
    for (int i = 0; i < list.length; i++) {
      employees.add(new DlModel(
        list[i]["urlList"],
        list[i]["titleList"],
        list[i]["authornameList"],
        list[i]["thumbnailList"],
        list[i]["pathList"],
      ));
    }
    print(employees.length);
    return employees;
  }

  Future<int> getcount(id) async {
    var dbclient = await init();
    int count = Sqflite.firstIntValue(await dbclient.rawQuery("SELECT COUNT(*) FROM Music WHERE urlList=\'$id\'"));
    return count;
  }

  Future<int> deleteMemo(String pathList) async {
    //returns number of items deleted
    final db = await init();

    int result = await db.delete("Music", //table name
        where: "pathList = ?",
        whereArgs: [pathList] // use whereArgs to avoid SQL injection
        ).then(
      (value) async {
        await db.delete("pathPlaylist", where: "songspathList = ?", whereArgs: [pathList]);
        return;
      },
    );

    return result;
  }

  Future<int> deletePlaylist(String playlistName) async {
    final db = await init();
    int result = await db.delete("Playlist", where: "playlistName = ? ", whereArgs: [playlistName]).then((value) async {
      await db.delete("pathPlaylist", where: "playlistName = ?", whereArgs: [playlistName]);
      return;
    });
    return result;
  }

  Future<int> updatePlaylistName(String playlistName, String newName) async {
    final db = await init();
    await db.rawUpdate("UPDATE Playlist SET playlistName = ? WHERE playlistName = ?", [newName, playlistName]).then((value) async {
      await db.rawUpdate("UPDATE pathPlaylist SET playlistName = ? WHERE playlistName = ?", [newName, playlistName]);
      return null;
    });
    print('check');
    // return result;
  }

  Future<int> deleteFromPlaylist(String playlistName, String indexinPlaylist, String songspathList) async {
    final db = await init();
    await db.delete("pathPlaylist", where: "indexinPlaylist = ? AND songspathList = ? AND playlistName = ?", whereArgs: [indexinPlaylist, songspathList, playlistName]).then((value) async {
      print("OKAY");
      return null;
    });
  }
}
