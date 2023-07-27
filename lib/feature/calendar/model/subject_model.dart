class SubjectModel {
  String? subjectId;
  String? subjectName;

  SubjectModel({this.subjectId, this.subjectName});

  SubjectModel.fromJson(Map<String, dynamic> json) {
    subjectId = json['id'];
    subjectName = json['data']['subject_name'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = subjectId;
    data['data']['level_name'] = subjectName;
    return data;
  }
}
