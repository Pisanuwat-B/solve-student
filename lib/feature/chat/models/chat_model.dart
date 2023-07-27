// To parse this JSON data, do
//
//     final chatModel = chatModelFromJson(jsonString);

import 'dart:convert';

ChatModel chatModelFromJson(String str) => ChatModel.fromJson(json.decode(str));

String chatModelToJson(ChatModel data) => json.encode(data.toJson());

class ChatModel {
  String? chatId;
  String? customerId;
  String? orderId;
  String? tutorId;

  ChatModel({
    this.chatId,
    this.customerId,
    this.orderId,
    this.tutorId,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        chatId: json["chat_id"] ?? "",
        customerId: json["customer_id"] ?? "",
        orderId: json["order_id"] ?? "",
        tutorId: json["tutor_id"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "chat_id": chatId,
        "customer_id": customerId,
        "order_id": orderId,
        "tutor_id": tutorId,
      };
}
