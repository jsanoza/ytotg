class DlModel {
  String urlList;
  String titleList;
  String authornameList;
  String thumbnailList;
  String pathList;

  DlModel(this.urlList, this.titleList, this.authornameList, this.thumbnailList, this.pathList);

  DlModel.fromMap(Map map) {
    urlList = map[urlList];
    titleList = map[titleList];
    authornameList = map[authornameList];
    thumbnailList = map[thumbnailList];
    pathList = map[pathList];
  }

  Map<String, dynamic> toMap() {
    // used when inserting data to the database
    return <String, dynamic>{
      "urlList": urlList,
      "titleList": titleList,
      "authornameList": authornameList,
      "thumbnailList": thumbnailList,
      "pathList": pathList,
    };
  }
}

class PlaylistModel {
  String playlistName;

  PlaylistModel(this.playlistName);

  PlaylistModel.fromMap(Map map) {
    playlistName = map[playlistName];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "playlistName": playlistName,
    };
  }
}

class AddPlaylistModel {
  String playlistName;
  String songspathList;
  String thumbnailList;
  int indexinPlaylist;

  AddPlaylistModel(
    this.playlistName,
    this.songspathList,
    this.thumbnailList,
    this.indexinPlaylist,
  );

  AddPlaylistModel.fromMap(Map map) {
    playlistName = map[playlistName];
    songspathList = map[songspathList];
    thumbnailList = map[thumbnailList];
    indexinPlaylist = map[indexinPlaylist];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "playlistName": playlistName,
      "songspathList": songspathList,
      "thumbnailList": thumbnailList,
      "indexinPlaylist": indexinPlaylist,
    };
  }
}
