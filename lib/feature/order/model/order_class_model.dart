// To parse this JSON data, do
//
//     final orderMockModel = orderMockModelFromJson(jsonString);

import 'dart:convert';

OrderClassModel orderMockModelFromJson(String str) =>
    OrderClassModel.fromJson(json.decode(str));

String orderMockModelToJson(OrderClassModel data) => json.encode(data.toJson());

class OrderClassModel {
  String? id;
  String? tutorId;
  String? studentId;
  String? classId;
  String? refId;
  String? title;
  String? content;
  int? type;
  String? chatId;
  String? path;
  String? image;
  num? rate;
  bool paymentOn;
  String? paymentStatus;
  bool fromMarketPlace;
  bool fromAnnounce;

  OrderClassModel({
    this.id,
    this.tutorId,
    this.studentId,
    this.classId,
    this.refId,
    this.title,
    this.content,
    this.type,
    this.chatId,
    this.path,
    this.image,
    this.rate,
    this.paymentOn = false,
    this.paymentStatus,
    this.fromMarketPlace = false,
    this.fromAnnounce = false,
  });

  factory OrderClassModel.fromJson(Map<String, dynamic> json) =>
      OrderClassModel(
        id: json["id"],
        tutorId: json["tutorId"],
        studentId: json["studentId"],
        classId: json["classId"],
        refId: json["refId"],
        title: json["title"],
        content: json["content"],
        type: json["type"],
        chatId: json["chatId"],
        path: json["path"],
        image: json["image"],
        rate: json["rate"],
        paymentOn: json["paymentOn"] ?? false,
        paymentStatus: json["paymentStatus"],
        fromMarketPlace: json["fromMarketPlace"] ?? false,
        fromAnnounce: json["fromAnnounce"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tutorId": tutorId,
        "studentId": studentId,
        "classId": classId,
        "refId": refId,
        "title": title,
        "content": content,
        "type": type,
        "chatId": chatId,
        "path": path,
        "image": image,
        "rate": rate,
        "paymentOn": paymentOn,
        "paymentStatus": paymentStatus,
        "fromMarketPlace": fromMarketPlace,
        "fromAnnounce": fromAnnounce,
      };
}
