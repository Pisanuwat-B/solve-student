import 'dart:io';

import 'package:solve_student/feature/calendar/app_client/app_client.dart';
import 'package:solve_student/feature/calendar/app_client/endpoint.dart';
import 'package:solve_student/feature/calendar/model/course_model.dart';
import 'package:solve_student/feature/calendar/model/level_model.dart';
import 'package:solve_student/feature/calendar/model/subject_model.dart';
import 'package:solve_student/firebase/firestore.dart';

class CourseService {
  final endpoint = Endpoint();
  final client = AppClient();
  final course = FirestoreService('course');

  Future<List<CourseModel>> getCourseListByTutorId(String id) async {
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

  Future<CourseModel> getCourseById(String id) async {
    try {
      final courses = await course.getDocumentById(id);
      final medias = FirestoreService('medias/${courses!['data']['tutor_id']}/docs_list');
      if (courses['data']['document_id'] != null) {
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

  Future<String> createCourse(CourseModel courseData) async {
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

  Future<void> deleteCourseById(String id) async {
    try {
      await course.deleteDocumentById(id);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateCourseDestails(
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

  Future<void> updateCoursePublishing(
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

// class CourseServiceAPI {
//   final endpoint = Endpoint();
//   final client = AppClient();
//
//   Future<List<CourseModel>> getCourseListByTutorId(String id) async {
//     try {
//       Map<String, dynamic> json =
//       await client.get(endpoint.getCourseListByTutorId(id));
//       var data = json['data'];
//       return List.generate(
//         data.length,
//             (index) => CourseModel.fromJson(json['data'][index]),
//       );
//     } catch (error) {
//       rethrow;
//     }
//   }
//
//   Future<CourseModel> getCourseById(String id) async {
//     try {
//       Map<String, dynamic> json = await client.get(endpoint.getCourseById(id));
//       print(json['data']);
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
//             (index) => LevelModel.fromJson(data[index]),
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
//             (index) => SubjectModel.fromJson(data[index]),
//       );
//     } catch (error) {
//       rethrow;
//     }
//   }
//
//   Future<String> createCourse(CourseModel courseData) async {
//     try {
//       Map<String, dynamic> json =
//       await client.post(endpoint.createCourse(), body: courseData.toJson());
//       return json['data'];
//     } catch (error) {
//       rethrow;
//     }
//   }
//
//   Future<void> deleteCourseById(String id) async {
//     try {
//       await client.delete(endpoint.deleteCourse(id));
//     } catch (error) {
//       rethrow;
//     }
//   }
//
//   Future<void> updateCourseDestails(
//       CourseModel courseData,
//       ) async {
//     try {
//       await client.put(endpoint.createCourse(), body: {
//         "id": courseData.id,
//         "tutor_id": courseData.tutorId,
//         "update_data": courseData.toJson()
//       });
//     } catch (error) {
//       rethrow;
//     }
//   }
//
//   Future<void> updateCoursePublishing(
//       CourseModel courseData,
//       bool value,
//       ) async {
//     try {
//       await client.put(endpoint.createCourse(), body: {
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
//       Map<String, dynamic> json = await client.uploadFiles(
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
//   Future<List<String>> uploadVideo(
//       {required File file, required String tutorId, required String id}) async {
//     try {
//       Map<String, dynamic> json = await client.uploadFiles(
//           endpoint.uploadVideo(),
//           files: [file],
//           tutorId: tutorId,
//           id: id,
//           dupilcate: true);
//       print(json);
//       List<String> data = [];
//       if (json['data'] != null) {
//         data = <String>[];
//         json['data'].forEach((v) {
//           data.add(v);
//         });
//       }
//       return data;
//     } catch (error) {
//       rethrow;
//     }
//   }
//
//   Future<List<CalendarDate>> getCalendarList(String tutorId) async {
//     try {
//       Map<String, dynamic> json =
//       await client.get(endpoint.getCalendarList(tutorId));
//       var data = json['data'];
//
//       return List.generate(
//         data.length,
//             (index) => CalendarDate.fromJson(data[index]),
//       );
//     } catch (error) {
//       rethrow;
//     }
//   }
//
//   Future<void> deleteFileById(
//       {required String tutorId,
//         required String documentId,
//         required String fileId}) async {
//     try {
//       await client.delete(
//         endpoint.deleteFileById(
//           tutorId: tutorId,
//           documentId: documentId,
//           fileId: fileId,
//         ),
//       );
//     } catch (error) {
//       rethrow;
//     }
//   }
// }
