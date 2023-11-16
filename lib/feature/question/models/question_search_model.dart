import 'dart:convert';

QuestionSearchModel questionSearchModelFromJson(String str) =>
    QuestionSearchModel.fromJson(json.decode(str));

String questionSearchModelToJson(QuestionSearchModel data) =>
    json.encode(data.toJson());

class QuestionSearchModel {
  int? id;
  int? showTime;
  String? questionText;
  String? videoPath;
  String? soundPath;
  String? lecturePath;

  QuestionSearchModel({
    this.id,
    this.showTime,
    this.questionText,
    this.videoPath,
    this.soundPath,
    this.lecturePath,
  });

  factory QuestionSearchModel.fromJson(Map<String, dynamic> json) =>
      QuestionSearchModel(
        id: json["id"],
        showTime: json["show_time"],
        questionText: json["question_text"],
        videoPath: json["video_path"],
        soundPath: json["sound_path"],
        lecturePath: json["lecture_path"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "show_time": showTime,
        "question_text": questionText,
        "video_path": videoPath,
        "sound_path": soundPath,
        "lecture_path": lecturePath,
      };
}
