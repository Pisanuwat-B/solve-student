// // To parse this JSON data, do
// //
// //     final courseLiveModel = courseLiveModelFromJson(jsonString);

// import 'dart:convert';

// import 'package:solve_student/feature/market_place/model/lesson_market_model.dart';

// CourseLiveModel courseLiveModelFromJson(String str) =>
//     CourseLiveModel.fromJson(json.decode(str));

// String courseLiveModelToJson(CourseLiveModel data) =>
//     json.encode(data.toJson());

// class CourseLiveModel {
//   String? subjectId;
//   List<Calendar>? calendar;
//   String? tutorId;
//   String? recommendText;
//   String? courseName;
//   String? levelId;
//   String? documentId;
//   String? thumbnailUrl;
//   String? currentMeetingCode;
//   String? courseType;
//   String? updateUser;
//   List<StudentDetail>? studentDetails;
//   String? detailsText;
//   String? createUser;
//   List<String>? studentList;
//   bool? publishing;
//   List<Lesson>? lessons;
//   DateTime? firstDay;
//   DateTime? lastDay;
//   DateTime? createTime;
//   DateTime? updateTime;

//   CourseLiveModel({
//     this.subjectId,
//     this.calendar,
//     this.tutorId,
//     this.recommendText,
//     this.createTime,
//     this.courseName,
//     this.levelId,
//     this.documentId,
//     this.thumbnailUrl,
//     this.currentMeetingCode,
//     this.updateTime,
//     this.courseType,
//     this.updateUser,
//     this.studentDetails,
//     this.detailsText,
//     this.createUser,
//     this.lastDay,
//     this.studentList,
//     this.publishing,
//     this.lessons,
//     this.firstDay,
//   });

//   factory CourseLiveModel.fromJson(Map<String, dynamic> json) =>
//       CourseLiveModel(
//         subjectId: json["subject_id"],
//         calendar: json["calendar"] == null
//             ? []
//             : List<Calendar>.from(
//                 json["calendar"]!.map((x) => Calendar.fromJson(x))),
//         tutorId: json["tutor_id"],
//         recommendText: json["recommend_text"],
//         courseName: json["course_name"],
//         levelId: json["level_id"],
//         documentId: json["document_id"],
//         thumbnailUrl: json["thumbnail_url"],
//         currentMeetingCode: json["currentMeetingCode"],
//         courseType: json["course_type"],
//         updateUser: json["update_user"],
//         studentDetails: json["student_details"] == null
//             ? []
//             : List<StudentDetail>.from(
//                 json["student_details"]!.map((x) => StudentDetail.fromJson(x))),
//         detailsText: json["details_text"],
//         createUser: json["create_user"],
//         studentList: json["student_list"] == null
//             ? []
//             : List<String>.from(json["student_list"]!.map((x) => x)),
//         publishing: json["publishing"],
//         lessons: json["lessons"] == null
//             ? []
//             : List<Lesson>.from(
//                 json["lessons"]!.map((x) => Lesson.fromJson(x))),
//         firstDay: DateTime.fromMicrosecondsSinceEpoch(json["first_day"]),
//         lastDay: DateTime.fromMicrosecondsSinceEpoch(json["last_day"]),
//         createTime: DateTime.fromMicrosecondsSinceEpoch(json["create_time"]),
//         updateTime: DateTime.fromMicrosecondsSinceEpoch(json["update_time"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "subject_id": subjectId,
//         "calendar": calendar == null
//             ? []
//             : List<dynamic>.from(calendar!.map((x) => x.toJson())),
//         "tutor_id": tutorId,
//         "recommend_text": recommendText,
//         "create_time": createTime,
//         "course_name": courseName,
//         "level_id": levelId,
//         "document_id": documentId,
//         "thumbnail_url": thumbnailUrl,
//         "currentMeetingCode": currentMeetingCode,
//         "update_time": updateTime,
//         "course_type": courseType,
//         "update_user": updateUser,
//         "student_details": studentDetails == null
//             ? []
//             : List<dynamic>.from(studentDetails!.map((x) => x.toJson())),
//         "details_text": detailsText,
//         "create_user": createUser,
//         "last_day": lastDay,
//         "student_list": studentList == null
//             ? []
//             : List<dynamic>.from(studentList!.map((x) => x)),
//         "publishing": publishing,
//         "lessons":
//             lessons == null ? [] : List<dynamic>.from(lessons!.map((x) => x)),
//         "first_day": firstDay,
//       };
// }

// class Calendar {
//   String? courseId;
//   String? courseName;
//   int? start;
//   int? end;
//   String? reviewFile;

//   Calendar({
//     this.courseId,
//     this.courseName,
//     this.start,
//     this.end,
//     this.reviewFile,
//   });

//   factory Calendar.fromJson(Map<String, dynamic> json) => Calendar(
//         courseId: json["course_id"],
//         courseName: json["course_name"],
//         start: json["start"],
//         end: json["end"],
//         reviewFile: json["review_file"],
//       );

//   Map<String, dynamic> toJson() => {
//         "course_id": courseId,
//         "course_name": courseName,
//         "start": start,
//         "end": end,
//         "review_file": reviewFile,
//       };
// }

// class StudentDetail {
//   String? solvepadSize;
//   String? image;
//   String? attend;
//   int? createTime;
//   String? name;
//   String? id;
//   String? statusShare;

//   StudentDetail({
//     this.solvepadSize,
//     this.image,
//     this.attend,
//     this.createTime,
//     this.name,
//     this.id,
//     this.statusShare,
//   });

//   factory StudentDetail.fromJson(Map<String, dynamic> json) => StudentDetail(
//         solvepadSize: json["solvepad_size"],
//         image: json["image"],
//         attend: json["attend"],
//         createTime: json["create_time"],
//         name: json["name"],
//         id: json["id"],
//         statusShare: json["status_share"],
//       );

//   Map<String, dynamic> toJson() => {
//         "solvepad_size": solvepadSize,
//         "image": image,
//         "attend": attend,
//         "create_time": createTime,
//         "name": name,
//         "id": id,
//         "status_share": statusShare,
//       };
// }
