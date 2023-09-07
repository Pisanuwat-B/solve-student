import 'package:solve_student/feature/calendar/app_client/app_client.dart';
import 'package:solve_student/feature/calendar/app_client/endpoint.dart';
import 'package:solve_student/feature/calendar/model/course_model.dart';
import 'package:solve_student/feature/calendar/model/show_course.dart';
import 'package:solve_student/firebase/firestore.dart';

class StudentService {
  final endpoint = Endpoint();
  final client = AppClient();
  final course = FirestoreService('course_live');

  Future<List<CalendarDate>> getCalendarListForStudentById(
      String studentId) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      List<Map<String, dynamic>> calendar = [];
      final courses = await course.getDocumentsWhere('student_list', 'array-contains', studentId);
      print(courses);
      for (final course in courses) {
        if (course['data']['calendar'] != null) {
          for (final calendarEntry in course['data']['calendar']) {
            calendarEntry['id'] = course['id'];
            calendarEntry['course_name'] = course['data']['course_name'];
            calendar.add(calendarEntry);
          }
        }
      }
      calendar.sort((a, b) => a['start'].compareTo(b['start']));
      calendar = calendar.where((item) => item['start'] >= now).toList();
      Map<String, dynamic> json = {'data': calendar};
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
      final now = DateTime.now().millisecondsSinceEpoch;
      List<Map<String, dynamic>> calendar = [];
      final courses = await course.getDocumentsWhere('student_list', 'array-contains', studentId);
      for (final course in courses) {
        if (course['data']['calendar'] != null) {
          for (final calendarEntry in course['data']['calendar']) {
            calendarEntry.addAll(course['data']);
            calendarEntry['course_id'] = course['id'];
            calendar.add(calendarEntry);
          }
        }
      }
      calendar.sort((a, b) => a['start'].compareTo(b['start']));
      calendar = calendar.where((item) => item['end'] >= now).toList();
      Map<String, dynamic> json = {'data': calendar};
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
      final now = DateTime.now().millisecondsSinceEpoch;
      List<Map<String, dynamic>> calendar = [];
      final courses = await course.getDocumentsWhere('student_list', 'array-contains', studentId);
      for (final course in courses) {
        if (course['data']['calendar'] != null) {
          for (final calendarEntry in course['data']['calendar']) {
            calendarEntry.addAll(course['data']);
            calendarEntry['course_id'] = course['id'];
            calendar.add(calendarEntry);
          }
        }
      }
      calendar.sort((a, b) => b['start'].compareTo(a['start']));
      calendar = calendar.where((item) => item['end'] <= now).toList();
      Map<String, dynamic> json = {'data': calendar};
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

// class StudentServiceAPI {
//   final endpoint = Endpoint();
//   final client = AppClient();
//
//   Future<List<CalendarDate>> getCalendarListForStudentById(
//       String studentId) async {
//     try {
//       Map<String, dynamic> json =
//           await client.get(endpoint.getCalendarListForStudentById(studentId));
//       var data = json['data'];
//       return List.generate(
//         data.length,
//         (index) => CalendarDate.fromJson(data[index]),
//       );
//     } catch (error) {
//       rethrow;
//     }
//   }
//
//   Future<List<ShowCourseStudent>> getCourseToday(String studentId) async {
//     try {
//       Map<String, dynamic> json =
//           await client.get(endpoint.getCourseStudentToday(studentId));
//       var data = json['data'];
//       return List.generate(
//         data.length,
//         (index) => ShowCourseStudent.fromJson(data[index]),
//       );
//     } catch (error) {
//       rethrow;
//     }
//   }
//
//   Future<List<ShowCourseStudent>> getCoursePast(String studentId) async {
//     try {
//       // print(endpoint.getCoursePast(studentId));
//       Map<String, dynamic> json =
//           await client.get(endpoint.getCourseStudentPast(studentId));
//       var data = json['data'];
//       // print(data);
//       return List.generate(
//         data.length,
//         (index) => ShowCourseStudent.fromJson(data[index]),
//       );
//     } catch (error) {
//       rethrow;
//     }
//   }
// }
