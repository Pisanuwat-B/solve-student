// To parse this JSON data, do
//
//     final bookingModel = bookingModelFromJson(jsonString);

import 'dart:convert';

ClassModel bookingModelFromJson(String str) =>
    ClassModel.fromJson(json.decode(str));

String bookingModelToJson(ClassModel data) => json.encode(data.toJson());

class ClassModel {
  String? userId;
  String? id;
  String? schoolSubject;
  String? classLevel; //
  String? count; //
  String? price; //
  String? name;
  String? detail;
  bool? status;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? startTime;
  DateTime? endTime;
  String? image;
  int? isBooking;
  String? creatorName;
  DateTime? createdAt;

  ClassModel({
    this.userId,
    this.id,
    this.schoolSubject,
    this.classLevel,
    this.count,
    this.price,
    this.name,
    this.detail,
    this.status = true,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.image,
    this.isBooking,
    this.creatorName,
    this.createdAt,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) => ClassModel(
        userId: json["userId"],
        id: json["id"],
        name: json["name"],
        schoolSubject: json["schoolSubject"],
        classLevel: json["classLevel"],
        count: json["count"],
        price: json["price"],
        detail: json["detail"],
        status: json["status"] ?? true,
        startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
        endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
        startTime: json["startTime"] == null ? null : DateTime.parse(json["startTime"]),
        endTime: json["endTime"] == null ? null : DateTime.parse(json["endTime"]),
        image: json["image"],
        isBooking: json["isBooking"] ?? 0,
        creatorName: json["creatorName"] ?? "",
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "id": id,
        "schoolSubject": schoolSubject,
        "classLevel": classLevel,
        "count": count,
        "price": price,
        "name": name,
        "detail": detail,
        "status": status,
        "startDate": startDate?.toIso8601String(),
        "endDate": endDate?.toIso8601String(),
        "startTime": startTime?.toIso8601String(),
        "endTime": endTime?.toIso8601String(),
        "image": image,
        "isBooking": isBooking,
        "creatorName": creatorName,
        "createdAt": createdAt?.toIso8601String(),
      };
}
