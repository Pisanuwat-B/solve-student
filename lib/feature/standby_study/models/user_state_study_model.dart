import 'dart:convert';

List<UserStandbyStudy> userStateStudyFromJson(String str) =>
    List<UserStandbyStudy>.from(
        json.decode(str).map((x) => UserStandbyStudy.fromJson(x)));

String userStateStudyToJson(List<UserStandbyStudy> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserStandbyStudy {
  String? id;
  String? name;

  UserStandbyStudy({
    this.id,
    this.name,
  });

  factory UserStandbyStudy.fromJson(Map<String, dynamic> json) =>
      UserStandbyStudy(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
