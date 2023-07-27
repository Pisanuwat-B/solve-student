class Lesson {
  String? lessonName;
  String? videoFiles;
  int? lessonId;

  Lesson({
    this.lessonName,
    this.videoFiles,
    this.lessonId,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        lessonName: json["lesson_name"],
        videoFiles: json["video_files"],
        lessonId: json["lesson_id"],
      );

  Map<String, dynamic> toJson() => {
        "lesson_name": lessonName,
        "video_files": videoFiles,
        "lesson_id": lessonId,
      };
}
