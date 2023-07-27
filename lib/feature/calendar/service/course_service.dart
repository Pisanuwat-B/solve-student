import 'dart:io';

import 'package:solve_student/feature/calendar/app_client/app_client.dart';
import 'package:solve_student/feature/calendar/app_client/endpoint.dart';
import 'package:solve_student/feature/calendar/model/course_model.dart';
import 'package:solve_student/feature/calendar/model/level_model.dart';
import 'package:solve_student/feature/calendar/model/subject_model.dart';

class CourseService {
  final endpoint = Endpoint();
  final client = AppClient();

  Future<List<CourseModel>> getCourseListByTutorId(String id) async {
    try {
      Map<String, dynamic> json =
          await client.get(endpoint.getCourseListByTutorId(id));
      var data = json['data'];
      return List.generate(
        data.length,
        (index) => CourseModel.fromJson(json['data'][index]),
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<CourseModel> getCourseById(String id) async {
    try {
      Map<String, dynamic> json = await client.get(endpoint.getCourseById(id));
      print(json['data']);
      var data = json['data'];
      return CourseModel.fromJson(data);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<LevelModel>> getLevelsList() async {
    try {
      Map<String, dynamic> json = await client.get(endpoint.getLevelsList());
      var data = json['data'];
      return List.generate(
        data.length,
        (index) => LevelModel.fromJson(data[index]),
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<List<SubjectModel>> getSubjectList() async {
    try {
      Map<String, dynamic> json = await client.get(endpoint.getSubjectList());
      var data = json['data'];
      return List.generate(
        data.length,
        (index) => SubjectModel.fromJson(data[index]),
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<String> createCourse(CourseModel courseData) async {
    try {
      Map<String, dynamic> json =
          await client.post(endpoint.createCourse(), body: courseData.toJson());
      return json['data'];
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteCourseById(String id) async {
    try {
      await client.delete(endpoint.deleteCourse(id));
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateCourseDestails(
    CourseModel courseData,
  ) async {
    try {
      await client.put(endpoint.createCourse(), body: {
        "id": courseData.id,
        "tutor_id": courseData.tutorId,
        "update_data": courseData.toJson()
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateCoursePublishing(
    CourseModel courseData,
    bool value,
  ) async {
    try {
      await client.put(endpoint.createCourse(), body: {
        "id": courseData.id,
        "tutor_id": courseData.tutorId,
        "update_data": {"publishing": value}
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<String> uploadThumbnail(
      {required File file, required String tutorId, required String id}) async {
    try {
      Map<String, dynamic> json = await client.uploadFiles(
          endpoint.uploadThumbnail(),
          files: [file],
          tutorId: tutorId,
          id: id,
          dupilcate: true);

      return json['data'];
    } catch (error) {
      rethrow;
    }
  }

  Future<List<String>> uploadVideo(
      {required File file, required String tutorId, required String id}) async {
    try {
      Map<String, dynamic> json = await client.uploadFiles(
          endpoint.uploadVideo(),
          files: [file],
          tutorId: tutorId,
          id: id,
          dupilcate: true);
      print(json);
      List<String> data = [];
      if (json['data'] != null) {
        data = <String>[];
        json['data'].forEach((v) {
          data.add(v);
        });
      }
      return data;
    } catch (error) {
      rethrow;
    }
  }

  Future<List<CalendarDate>> getCalendarList(String tutorId) async {
    try {
      Map<String, dynamic> json =
          await client.get(endpoint.getCalendarList(tutorId));
      var data = json['data'];

      return List.generate(
        data.length,
        (index) => CalendarDate.fromJson(data[index]),
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteFileById(
      {required String tutorId,
      required String documentId,
      required String fileId}) async {
    try {
      await client.delete(
        endpoint.deleteFileById(
          tutorId: tutorId,
          documentId: documentId,
          fileId: fileId,
        ),
      );
    } catch (error) {
      rethrow;
    }
  }
}
