import 'dart:developer';
import 'dart:io';

import 'package:solve_student/feature/calendar/app_client/app_client.dart';
import 'package:solve_student/feature/calendar/app_client/endpoint.dart';
import 'package:solve_student/feature/calendar/model/course_model.dart';
import 'package:solve_student/feature/calendar/model/level_model.dart';
import 'package:solve_student/feature/calendar/model/show_course.dart';
import 'package:solve_student/feature/calendar/model/subject_model.dart';
import 'package:solve_student/firebase/firestore.dart';

class CourseLiveService {
  final endpoint = Endpoint();
  final client = AppClient();
  final course = FirestoreService('course_live');

  Future<List<CourseModel>> getCourseLiveListByTutorId(String id) async {
    try {
      final get = await course.getDocumentsWhere('tutor_id', '==', id);
      Map<String, dynamic> json = {'data': get};
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
      final courses = await course.getDocumentById(id);
      final medias = FirestoreService('medias/${courses!['data']['tutor_id']}/docs_list');
      if (courses['data']['document_id'] != null && courses['data']['document_id'] != '') {
        final docData = await medias.getDocumentById(courses['data']['document_id']);
        if (docData != null) {
          courses['data']['document'] = docData['data'];
          await course.updateDocumentById(id, {'document_count': docData['data']['doc_files'].length}, courses['data']['tutor_id']);
          courses['data']['document_count'] = docData['data']['doc_files'].length;
        } else {
          await course.updateDocumentById(id, {'document_id': '', 'document_count': 0}, courses['data']['tutor_id']);
          courses['data']['document_id'] = '';
        }
      }
      Map<String, dynamic> json = {'data': courses};
      print(json['data']);
      var data = json['data'];
      return CourseModel.fromJson(data);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<LevelModel>> getLevelsList() async {
    try {
      final levels = await FirestoreService('courseLevels').getDocuments();
      // const levels = SchoolSubjectConstants.schoolClassLevel;
      Map<String, dynamic> json = {'data': levels};
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
      final subjects = await FirestoreService('courseSubjects').getDocuments();
      // const subjects = SchoolSubjectConstants.schoolSubjectList;
      Map<String, dynamic> json = {'data': subjects};
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
      Map<String, dynamic> body = {
        "tutor_id": courseData.tutorId,
        "data": courseData.toJson()
      };
      final created = await course.addDocument(body['data'], body['tutor_id']);
      Map<String, dynamic> json = {'data': created};
      return json['data'];
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteCourseLiveById(String id) async {
    try {
      await course.deleteDocumentById(id);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateCourseLiveDestails(
      CourseModel courseData,
      ) async {
    try {
      Map<String, dynamic> body = {
        "id": courseData.id,
        "tutor_id": courseData.tutorId,
        "update_data": courseData.toJson()
      };
      await course.updateDocumentById(body['id'], body['update_data'], body['tutor_id']);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateCourseLivePublishing(
      CourseModel courseData,
      bool value,
      ) async {
    try {
      Map<String, dynamic> body = {
        "id": courseData.id,
        "tutor_id": courseData.tutorId,
        "update_data": {"publishing": value}
      };
      await course.updateDocumentById(body['id'], body['update_data'], body['tutor_id']);
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

  Future<List<CalendarDate>> getCalendarLiveList(String tutorId) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      List<Map<String, dynamic>> calendar = [];
      final courses = await course.getDocumentsWhere('tutor_id', '==', tutorId);
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

  Future<List<ShowCourseTutor>> getCourseTutorToday(String tutorId) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      List<Map<String, dynamic>> calendar = [];
      final courses = await course.getDocumentsWhere('tutor_id', '==', tutorId);
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
            (index) => ShowCourseTutor.fromJson(data[index]),
      );
    } catch (error) {
      rethrow;
    }
  }
}

// class CourseLiveServiceAPI {
//   final endpoint = Endpoint();
//   final client = AppClient();
//
//   Future<List<CourseModel>> getCourseLiveListByTutorId(String id) async {
//     try {
//       Map<String, dynamic> json =
//           await client.get(endpoint.getCourseLiveListByTutorId(id));
//       var data = json['data'];
//
//       return List.generate(
//         data.length,
//         (index) => CourseModel.fromJson(json['data'][index]),
//       );
//     } catch (error) {
//       rethrow;
//     }
//   }
//
//   Future<CourseModel> getCourseLiveById(String id) async {
//     try {
//       Map<String, dynamic> json =
//           await client.get(endpoint.getCourseLiveById(id));
//       // print(json['data']);
//       var data = json['data'];
//       return CourseModel.fromJson(data);
//     } catch (error) {
//       rethrow;
//     }
//   }
//
//   Future<List<LevelModel>> getLevelsList() async {
//     try {
//       Map<String, dynamic> json = await client.get(endpoint.getLevelsList());
//       var data = json['data'];
//       return List.generate(
//         data.length,
//         (index) => LevelModel.fromJson(data[index]),
//       );
//     } catch (error) {
//       rethrow;
//     }
//   }
//
//   Future<List<SubjectModel>> getSubjectList() async {
//     try {
//       Map<String, dynamic> json = await client.get(endpoint.getSubjectList());
//       var data = json['data'];
//       return List.generate(
//         data.length,
//         (index) => SubjectModel.fromJson(data[index]),
//       );
//     } catch (error) {
//       rethrow;
//     }
//   }
//
//   Future<String> createCourseLive(CourseModel courseData) async {
//     try {
//       Map<String, dynamic> json = await client.post(endpoint.createCourseLive(),
//           body: courseData.toJson());
//       // log("success");
//       return json['data'];
//     } catch (error) {
//       log("err : $error");
//       rethrow;
//     }
//   }
//
//   Future<void> deleteCourseLiveById(String id) async {
//     try {
//       await client.delete(endpoint.deleteCourseLive(id));
//     } catch (error) {
//       rethrow;
//     }
//   }
//
//   Future<void> updateCourseLiveDetails(
//     CourseModel courseData,
//   ) async {
//     try {
//       // log("data service : ${courseData.toJson()}");
//       await client.put(endpoint.createCourseLive(), body: {
//         "id": courseData.id,
//         "tutor_id": courseData.tutorId,
//         "update_data": courseData.toJson()
//       });
//     } catch (error) {
//       rethrow;
//     }
//   }
//
//   Future<void> updateCourseLivePublishing(
//     CourseModel courseData,
//     bool value,
//   ) async {
//     try {
//       await client.put(endpoint.createCourseLive(), body: {
//         "id": courseData.id,
//         "tutor_id": courseData.tutorId,
//         "update_data": {"publishing": value}
//       });
//     } catch (error) {
//       rethrow;
//     }
//   }
//
//   Future<String> uploadThumbnail(
//       {required File file, required String tutorId, required String id}) async {
//     try {
//       Map<String, dynamic> json = await client.uploadFile(
//           endpoint.uploadThumbnail(),
//           files: [file],
//           tutorId: tutorId,
//           id: id,
//           dupilcate: true);
//
//       return json['data'];
//     } catch (error) {
//       rethrow;
//     }
//   }
//
//   Future<List<CalendarDate>> getCalendarLiveList(String tutorId) async {
//     try {
//       Map<String, dynamic> json =
//           await client.get(endpoint.getCalendarLiveList(tutorId));
//       var data = json['data'];
//
//       return List.generate(
//         data.length,
//         (index) => CalendarDate.fromJson(data[index]),
//       );
//     } catch (error) {
//       rethrow;
//     }
//   }
//
//   Future<List<ShowCourseTutor>> getCourseTutorToday(String tutorId) async {
//     try {
//       Map<String, dynamic> json =
//           await client.get(endpoint.getCourseTutorToday(tutorId));
//       var data = json['data'];
//
//       return List.generate(
//         data.length,
//         (index) => ShowCourseTutor.fromJson(data[index]),
//       );
//     } catch (error) {
//       rethrow;
//     }
//   }
// }

