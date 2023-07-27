import 'package:slove_student/feature/calendar/app_client/app_client.dart';
import 'package:slove_student/feature/calendar/app_client/endpoint.dart';
import 'package:slove_student/feature/calendar/model/course_model.dart';
import 'package:slove_student/feature/calendar/model/show_course.dart';

class StudentService {
  final endpoint = Endpoint();
  final client = AppClient();

  Future<List<CalendarDate>> getCalendarListForStudentById(
      String studentId) async {
    try {
      Map<String, dynamic> json =
          await client.get(endpoint.getCalendarListForStudentById(studentId));
      var data = json['data'];
      return List.generate(
        data.length,
        (index) => CalendarDate.fromJson(data[index]),
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<List<ShowCourseStudent>> getCourseToday(String studentId) async {
    try {
      Map<String, dynamic> json =
          await client.get(endpoint.getCourseStudentToday(studentId));
      var data = json['data'];
      return List.generate(
        data.length,
        (index) => ShowCourseStudent.fromJson(data[index]),
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<List<ShowCourseStudent>> getCoursePast(String studentId) async {
    try {
      // print(endpoint.getCoursePast(studentId));
      Map<String, dynamic> json =
          await client.get(endpoint.getCourseStudentPast(studentId));
      var data = json['data'];
      // print(data);
      return List.generate(
        data.length,
        (index) => ShowCourseStudent.fromJson(data[index]),
      );
    } catch (error) {
      rethrow;
    }
  }
}
