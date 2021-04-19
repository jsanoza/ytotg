class DlModel {

   String urlList;
   String titleList;
   String authornameList;
   String thumbnailList;
   String pathList;

  DlModel( this.urlList, this.titleList, this.authornameList,
      this.thumbnailList, this.pathList);

  DlModel.fromMap(Map map) {
   
    urlList = map[urlList];
    titleList = map[titleList];
    authornameList = map[authornameList];
    thumbnailList = map[pathList];
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

