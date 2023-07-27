import 'dart:developer';
import 'dart:io';

import 'package:solve_student/feature/calendar/app_client/app_client.dart';
import 'package:solve_student/feature/calendar/app_client/endpoint.dart';
import 'package:solve_student/feature/calendar/model/course_model.dart';
import 'package:solve_student/feature/calendar/model/level_model.dart';
import 'package:solve_student/feature/calendar/model/show_course.dart';
import 'package:solve_student/feature/calendar/model/subject_model.dart';

class CourseLiveService {
  final endpoint = Endpoint();
  final client = AppClient();

  Future<List<CourseModel>> getCourseLiveListByTutorId(String id) async {
    try {
      Map<String, dynamic> json =
          await client.get(endpoint.getCourseLiveListByTutorId(id));
      var data = json['data'];

      return List.generate(
        data.length,
        (index) => CourseModel.fromJson(json['data'][index]),
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<CourseModel> getCourseLiveById(String id) async {
    try {
      Map<String, dynamic> json =
          await client.get(endpoint.getCourseLiveById(id));
      // print(json['data']);
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

  Future<String> createCourseLive(CourseModel courseData) async {
    try {
      log("createCourseLive");

      Map<String, dynamic> json = await client.post(endpoint.createCourseLive(),
          body: courseData.toJson());
      log("success");
      return json['data'];
    } catch (error) {
      log("err : $error");
      rethrow;
    }
  }

  Future<void> deleteCourseLiveById(String id) async {
    try {
      await client.delete(endpoint.deleteCourseLive(id));
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateCourseLiveDestails(
    CourseModel courseData,
  ) async {
    try {
      await client.put(endpoint.createCourseLive(), body: {
        "id": courseData.id,
        "tutor_id": courseData.tutorId,
        "update_data": courseData.toJson()
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateCourseLivePublishing(
    CourseModel courseData,
    bool value,
  ) async {
    try {
      await client.put(endpoint.createCourseLive(), body: {
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
      Map<String, dynamic> json = await client.uploadFile(
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

  Future<List<CalendarDate>> getCalendarLiveList(String tutorId) async {
    try {
      Map<String, dynamic> json =
          await client.get(endpoint.getCalendarLiveList(tutorId));
      var data = json['data'];

      return List.generate(
        data.length,
        (index) => CalendarDate.fromJson(data[index]),
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<List<ShowCourseTutor>> getCourseTutorToday(String tutorId) async {
    try {
      Map<String, dynamic> json =
          await client.get(endpoint.getCourseTutorToday(tutorId));
      var data = json['data'];

      return List.generate(
        data.length,
        (index) => ShowCourseTutor.fromJson(data[index]),
      );
    } catch (error) {
      rethrow;
    }
  }
}
