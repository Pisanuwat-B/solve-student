class Lesson {
  String? lessonName;
  String? media;
  int? lessonId;

  Lesson({
    this.lessonName,
    this.media,
    this.lessonId,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        lessonName: json["lesson_name"],
        media: json["media"],
        lessonId: json["lesson_id"],
      );

  Map<String, dynamic> toJson() => {
        "lesson_name": lessonName,
        "media": media,
        "lesson_id": lessonId,
      };
}
