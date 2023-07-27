class LevelModel {
  String? levelId;
  String? levelName;

  LevelModel({this.levelId, this.levelName});

  LevelModel.fromJson(Map<String, dynamic> json) {
    levelId = json['id'];
    levelName = json['data']['level_name'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = levelId;
    data['data']['level_name'] = levelName;
    return data;
  }
}
