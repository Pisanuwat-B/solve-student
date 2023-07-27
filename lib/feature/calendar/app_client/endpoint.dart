import 'dart:developer';

class Endpoint {
  final apiHost = "https://us-central1-solve-f1778.cloudfunctions.net";

  final mode = "dev";

  Uri getCourseList() {
    return Uri.parse('$apiHost/$mode/course/courses');
  }

  Uri getCourseListByTutorId(String id) {
    return Uri.parse('$apiHost/$mode/course/tutor/$id');
  }

  Uri getCourseById(String id) {
    return Uri.parse('$apiHost/$mode/course/$id');
  }

  Uri getLevelsList() {
    return Uri.parse('$apiHost/$mode/course/levels');
  }

  Uri getSubjectList() {
    return Uri.parse('$apiHost/$mode/course/subjects');
  }

  Uri createCourse() {
    return Uri.parse('$apiHost/$mode/course');
  }

  Uri deleteCourse(String id) {
    return Uri.parse('$apiHost/$mode/course/$id');
  }

  Uri updateCourse(String id) {
    return Uri.parse('$apiHost/$mode/dev/course');
  }

  Uri uploadThumbnail() {
    return Uri.parse('$apiHost/$mode/medias/upload-thumbnail');
  }

  Uri uploadVideo() {
    return Uri.parse('$apiHost/$mode/medias/upload-files-course');
  }

  Uri getCalendarList(String tutorId) {
    return Uri.parse('$apiHost/$mode/course_live/calendar/tutor/$tutorId');
  }

  Uri getCourseLiveListByTutorId(String id) {
    return Uri.parse('$apiHost/$mode/course_live/tutor/$id');
  }

  Uri getCourseLiveById(String id) {
    return Uri.parse('$apiHost/$mode/course_live/$id');
  }

  Uri createCourseLive() {
    return Uri.parse('$apiHost/$mode/course_live');
  }

  Uri deleteCourseLive(String id) {
    return Uri.parse('$apiHost/$mode/course_live/$id');
  }

  Uri updateCourseLive(String id) {
    return Uri.parse('$apiHost/$mode/dev/course_live');
  }

  Uri getCalendarLiveList(String tutorId) {
    return Uri.parse('$apiHost/$mode/course_live/calendar/tutor/$tutorId');
  }

  Uri getCourseTutorPast(String studentId) {
    var id = studentId.trim();
    return Uri.parse('$apiHost/$mode/course_live/past/tutor/$id');
  }

  Uri getCourseTutorToday(String studentId) {
    var id = studentId.trim();
    return Uri.parse('$apiHost/$mode/course_live/upcoming/tutor/$id');
  }

/////////////////////////////////////-Document-////////////////////////////////////////////////
  Uri getDocumentListByTutorId(String id) {
    return Uri.parse('$apiHost/$mode/medias/tutor/$id');
  }

  Uri getDocumentByDocumentId(
      {required String tutorId, required String documentId}) {
    return Uri.parse('$apiHost/$mode/medias/$tutorId/$documentId');
  }

  Uri createDocument() {
    return Uri.parse('$apiHost/$mode/medias');
  }

  Uri getUploadFiles() {
    return Uri.parse('$apiHost/$mode/medias/upload-files');
  }

  Uri uploadPdfConvert() {
    return Uri.parse('$apiHost/$mode/medias/upload-pdf-convert');
  }

  Uri updateDocument() {
    return Uri.parse('$apiHost/$mode/medias');
  }

  Uri deleteDocument({required String tutorId, required String documentId}) {
    return Uri.parse('$apiHost/$mode/medias/doc/$tutorId/$documentId');
  }

  Uri deleteFileById(
      {required String tutorId,
      required String documentId,
      required String fileId}) {
    return Uri.parse('$apiHost/$mode/medias/file/$tutorId/$documentId/$fileId');
  }

/////////////////////////////////////-Student-////////////////////////////////////////////
  Uri getCourseStudentPast(String studentId) {
    var id = studentId.trim();
    return Uri.parse('$apiHost/$mode/course_live/past/student/$id');
  }

  Uri getCourseStudentToday(String studentId) {
    var id = studentId.trim();
    log("message : $studentId");
    return Uri.parse('$apiHost/$mode/course_live/upcoming/student/$id');
  }

  Uri getCalendarListForStudentById(String studentId) {
    var id = studentId.trim();
    return Uri.parse('$apiHost/$mode/course_live/calendar/student/$id');
  }

  Uri getCourseLiveList() {
    return Uri.parse('$apiHost/$mode/course_live/courses');
  }
}
