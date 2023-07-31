class ShowCourseStudent {
  String? courseId;
  String? courseName;
  DateTime? start;
  DateTime? end;
  String? thumbnailUrl;
  String? tutorId;
  String? subjectId;
  String? levelId;
  String? detailsText;
  String? documentId;
  String? file;

  ShowCourseStudent({
    this.courseId,
    this.courseName,
    this.start,
    this.end,
    this.thumbnailUrl,
    this.tutorId,
    this.subjectId,
    this.levelId,
    this.detailsText,
    this.documentId,
    this.file,
  });

  ShowCourseStudent.fromJson(Map<String, dynamic> json) {
    courseId = json['course_id'];
    courseName = json['course_name'];

    start = DateTime.fromMillisecondsSinceEpoch(json['start']);
    end = DateTime.fromMillisecondsSinceEpoch(json['end']);
    thumbnailUrl = json['thumbnail_url'];
    tutorId = json['tutor_id'];
    subjectId = json['subject_id'];
    levelId = json['level_id'];
    detailsText = json['details_text'];
    documentId = json['document_id'];
    file = json['review_file'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['course_id'] = courseId;
    data['course_name'] = courseName;
    data['start'] = start;
    data['end'] = end;
    data['thumbnail_url'] = thumbnailUrl;
    data['tutor_id'] = tutorId;
    data['subject_id'] = subjectId;
    data['level_id'] = levelId;
    data['details_text'] = detailsText;
    data['document_id'] = documentId;
    data['review_file'] = file;
    return data;
  }
}

class ShowCourseTutor {
  String? courseId;
  String? courseName;
  DateTime? start;
  DateTime? end;
  String? thumbnailUrl;
  String? tutorId;
  String? subjectId;
  String? levelId;
  String? detailsText;
  String? documentId;

  ShowCourseTutor(
      {this.courseId,
      this.courseName,
      this.start,
      this.end,
      this.thumbnailUrl,
      this.tutorId,
      this.subjectId,
      this.levelId,
      this.detailsText,
      this.documentId});

  ShowCourseTutor.fromJson(Map<String, dynamic> json) {
    courseId = json['course_id'];
    courseName = json['course_name'];

    start = DateTime.fromMillisecondsSinceEpoch(json['start']);
    end = DateTime.fromMillisecondsSinceEpoch(json['end']);
    thumbnailUrl = json['thumbnail_url'];
    tutorId = json['tutor_id'];
    subjectId = json['subject_id'];
    levelId = json['level_id'];
    detailsText = json['details_text'];
    documentId = json['document_id'];
  }
}
