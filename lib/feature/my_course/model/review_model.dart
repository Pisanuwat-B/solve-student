// To parse this JSON data, do
//
//     final reviewModel = reviewModelFromJson(jsonString);

import 'dart:convert';

ReviewModel reviewModelFromJson(String str) =>
    ReviewModel.fromJson(json.decode(str));

String reviewModelToJson(ReviewModel data) => json.encode(data.toJson());

class ReviewModel {
  String? id;
  String? courseId;
  String? userId;
  int? rate;
  String? reviewMessage;
  DateTime? createdAt;

  ReviewModel({
    this.id,
    this.courseId,
    this.userId,
    this.rate,
    this.reviewMessage,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: json["id"],
        courseId: json["course_id"],
        userId: json["user_id"],
        rate: json["rate"],
        reviewMessage: json["review_message"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.fromMicrosecondsSinceEpoch(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "course_id": courseId,
        "user_id": userId,
        "rate": rate,
        "review_message": reviewMessage,
        "created_at": createdAt?.millisecondsSinceEpoch,
      };
}
