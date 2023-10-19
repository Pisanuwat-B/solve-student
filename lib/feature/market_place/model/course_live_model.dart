// To parse this JSON data, do
//
//     final courseLiveModel = courseLiveModelFromJson(jsonString);

import 'dart:convert';

CourseLiveModel courseLiveModelFromJson(String str) =>
    CourseLiveModel.fromJson(json.decode(str));

String courseLiveModelToJson(CourseLiveModel data) =>
    json.encode(data.toJson());

class CourseLiveModel {
  List<Calendar>? calendar;
  String? subjectId;
  String? tutorId;
  num? documentCount;
  String? recommendText;
  num? createTime;
  String? courseName;
  String? levelId;
  String? thumbnailUrl;
  String? documentId;
  num? updateTime;
  String? currentMeetingCode;
  String? courseType;
  String? updateUser;
  List<StudentDetail>? studentDetails;
  String? detailsText;
  String? createUser;
  num? lastDay;
  List<String>? studentList;
  bool? publishing;
  List<dynamic>? lessons;
  num? firstDay;

  CourseLiveModel({
    this.calendar,
    this.subjectId,
    this.tutorId,
    this.documentCount,
    this.recommendText,
    this.createTime,
    this.courseName,
    this.levelId,
    this.thumbnailUrl,
    this.documentId,
    this.updateTime,
    this.currentMeetingCode,
    this.courseType,
    this.updateUser,
    this.studentDetails,
    this.detailsText,
    this.createUser,
    this.lastDay,
    this.studentList,
    this.publishing,
    this.lessons,
    this.firstDay,
  });

  factory CourseLiveModel.fromJson(Map<String, dynamic> json) =>
      CourseLiveModel(
        calendar: json["calendar"] == null
            ? []
            : List<Calendar>.from(
                json["calendar"]!.map((x) => Calendar.fromJson(x))),
        subjectId: json["subject_id"],
        tutorId: json["tutor_id"],
        documentCount: json["document_count"],
        recommendText: json["recommend_text"],
        createTime: json["create_time"],
        courseName: json["course_name"],
        levelId: json["level_id"],
        thumbnailUrl: json["thumbnail_url"],
        documentId: json["document_id"],
        updateTime: json["update_time"],
        currentMeetingCode: json["currentMeetingCode"],
        courseType: json["course_type"],
        updateUser: json["update_user"],
        studentDetails: json["student_details"] == null
            ? []
            : List<StudentDetail>.from(
                json["student_details"]!.map((x) => StudentDetail.fromJson(x))),
        detailsText: json["details_text"],
        createUser: json["create_user"],
        lastDay: json["last_day"],
        studentList: json["student_list"] == null
            ? []
            : List<String>.from(json["student_list"]!.map((x) => x)),
        publishing: json["publishing"],
        lessons: json["lessons"] == null
            ? []
            : List<dynamic>.from(json["lessons"]!.map((x) => x)),
        firstDay: json["first_day"],
      );

  Map<String, dynamic> toJson() => {
        "calendar": calendar == null
            ? []
            : List<dynamic>.from(calendar!.map((x) => x.toJson())),
        "subject_id": subjectId,
        "tutor_id": tutorId,
        "document_count": documentCount,
        "recommend_text": recommendText,
        "create_time": createTime,
        "course_name": courseName,
        "level_id": levelId,
        "thumbnail_url": thumbnailUrl,
        "document_id": documentId,
        "update_time": updateTime,
        "currentMeetingCode": currentMeetingCode,
        "course_type": courseType,
        "update_user": updateUser,
        "student_details": studentDetails == null
            ? []
            : List<dynamic>.from(studentDetails!.map((x) => x.toJson())),
        "details_text": detailsText,
        "create_user": createUser,
        "last_day": lastDay,
        "student_list": studentList == null
            ? []
            : List<dynamic>.from(studentList!.map((x) => x)),
        "publishing": publishing,
        "lessons":
            lessons == null ? [] : List<dynamic>.from(lessons!.map((x) => x)),
        "first_day": firstDay,
      };
}

class Calendar {
  String? courseId;
  String? courseName;
  num? start;
  num? end;

  Calendar({
    this.courseId,
    this.courseName,
    this.start,
    this.end,
  });

  factory Calendar.fromJson(Map<String, dynamic> json) => Calendar(
        courseId: json["course_id"],
        courseName: json["course_name"],
        start: json["start"],
        end: json["end"],
      );

  Map<String, dynamic> toJson() => {
        "course_id": courseId,
        "course_name": courseName,
        "start": start,
        "end": end,
      };
}

class StudentDetail {
  num? createTime;
  String? name;
  String? id;

  StudentDetail({
    this.createTime,
    this.name,
    this.id,
  });

  factory StudentDetail.fromJson(Map<String, dynamic> json) => StudentDetail(
        createTime: json["create_time"],
        name: json["name"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "create_time": createTime,
        "name": name,
        "id": id,
      };
}
