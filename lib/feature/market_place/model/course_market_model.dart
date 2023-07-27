// To parse this JSON data, do
//
//     final courseMarketModel = courseMarketModelFromJson(jsonString);

import 'dart:convert';

import 'package:slove_student/feature/market_place/model/lesson_market_model.dart';

CourseMarketModel courseMarketModelFromJson(String str) =>
    CourseMarketModel.fromJson(json.decode(str));

String courseMarketModelToJson(CourseMarketModel data) =>
    json.encode(data.toJson());

class CourseMarketModel {
  String? subjectId;
  List<dynamic>? calendar;
  String? tutorId;
  String? recommendText;
  String? courseName;
  String? levelId;
  String? documentId;
  String? thumbnailUrl;
  String? updateUser;
  String? courseType;
  String? detailsText;
  String? createUser;
  bool? publishing;
  DateTime? firstDay;
  DateTime? lastDay;
  DateTime? createTime;
  DateTime? updateTime;
  List<Lesson>? lessons;

  CourseMarketModel({
    this.subjectId,
    this.calendar,
    this.tutorId,
    this.recommendText,
    this.courseName,
    this.levelId,
    this.documentId,
    this.thumbnailUrl,
    this.updateUser,
    this.courseType,
    this.detailsText,
    this.createUser,
    this.publishing,
    this.firstDay,
    this.lastDay,
    this.createTime,
    this.updateTime,
    this.lessons,
  });

  factory CourseMarketModel.fromJson(Map<String, dynamic> json) =>
      CourseMarketModel(
        subjectId: json["subject_id"],
        calendar: json["calendar"] == null
            ? []
            : List<dynamic>.from(json["calendar"]!.map((x) => x)),
        tutorId: json["tutor_id"],
        recommendText: json["recommend_text"],
        courseName: json["course_name"],
        levelId: json["level_id"],
        documentId: json["document_id"],
        thumbnailUrl: json["thumbnail_url"],
        updateUser: json["update_user"],
        courseType: json["course_type"],
        detailsText: json["details_text"],
        createUser: json["create_user"],
        publishing: json["publishing"],
        firstDay: DateTime.fromMicrosecondsSinceEpoch(json["first_day"]),
        lastDay: DateTime.fromMicrosecondsSinceEpoch(json["last_day"]),
        createTime: DateTime.fromMicrosecondsSinceEpoch(json["create_time"]),
        updateTime: DateTime.fromMicrosecondsSinceEpoch(json["update_time"]),
        lessons: json["lessons"] == null
            ? []
            : List<Lesson>.from(
                json["lessons"]!.map((x) => Lesson.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "subject_id": subjectId,
        "calendar":
            calendar == null ? [] : List<dynamic>.from(calendar!.map((x) => x)),
        "tutor_id": tutorId,
        "recommend_text": recommendText,
        "course_name": courseName,
        "level_id": levelId,
        "document_id": documentId,
        "thumbnail_url": thumbnailUrl,
        "update_user": updateUser,
        "course_type": courseType,
        "details_text": detailsText,
        "create_user": createUser,
        "publishing": publishing,
        "first_day": firstDay?.millisecondsSinceEpoch,
        "last_day": lastDay?.millisecondsSinceEpoch,
        "create_time": createTime?.millisecondsSinceEpoch,
        "update_time": updateTime?.millisecondsSinceEpoch,
        "lessons": lessons == null
            ? []
            : List<dynamic>.from(lessons!.map((x) => x.toJson())),
      };
}
