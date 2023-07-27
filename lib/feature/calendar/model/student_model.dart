class StudentModel {
  String? id;
  String? name;
  DateTime? createTime;

  StudentModel({this.id, this.name, this.createTime});

  StudentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    createTime = DateTime.fromMillisecondsSinceEpoch(json['create_time']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    data['create_time'] = createTime?.toUtc().millisecondsSinceEpoch;
    return data;
  }
}
