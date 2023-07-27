class DocumentModel {
  String? id;
  Data? data;

  DocumentModel({this.id, this.data});

  DocumentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? tutorId;
  String? updateUser;
  String? documentName;
  String? levelId;
  String? subjectId;
  String? createUser;
  String? documentCount;
  DateTime? createTime;
  List<String>? docFiles;

  DateTime? updateTime;

  Data(
      {this.tutorId,
      this.updateUser,
      this.documentName,
      this.levelId,
      this.subjectId,
      this.createUser,
      this.createTime,
      this.documentCount,
      this.docFiles,
      this.updateTime});

  Data.fromJson(Map<String, dynamic> json) {
    tutorId = json['tutor_id'] ?? "";
    updateUser = json['update_user'] ?? "";
    documentName = json['document_name'] ?? "";
    levelId = json['level_id'] ?? "";
    subjectId = json['subject_id'] ?? "";
    createUser = json['create_user'];
    createTime = DateTime.fromMillisecondsSinceEpoch(json['create_time'] ?? 0);
    documentCount = json['document_count'];
    if (json['doc_files'] != null) {
      docFiles = <String>[];
      json['doc_files'].forEach((v) {
        docFiles?.add(v);
      });
    }
    updateTime = DateTime.fromMillisecondsSinceEpoch(json['update_time'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['tutor_id'] = tutorId ?? '';
    // data['update_user'] = updateUser;
    data['document_name'] = documentName ?? '';
    data['level_id'] = levelId ?? '';
    data['subject_id'] = subjectId ?? '';
    // data['create_user'] = createUser;
    // if (createTime != null) {
    //   data['create_time'] = createTime;
    // }
    data['doc_files'] = docFiles ?? <String>[];
    // if (updateTime != null) {
    //   data['update_time'] = updateTime;
    // }
    return data;
  }
}
