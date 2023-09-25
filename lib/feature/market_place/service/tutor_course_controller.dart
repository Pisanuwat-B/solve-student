import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:solve_student/authentication/models/user_model.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/feature/market_place/model/course_live_model.dart';
import 'package:solve_student/feature/market_place/model/course_market_model.dart';

class TutorCourseController extends ChangeNotifier {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  TutorCourseController(this.context, {required this.tutor});
  BuildContext context;
  UserModel tutor;

  AuthProvider? auth;

  init() {}

  Future<List<CourseMarketModel>> getCourseList() async {
    List<CourseMarketModel> courseList = [];
    return await firebaseFirestore
        .collection('course')
        .where('create_user', isEqualTo: tutor.id ?? "")
        .where('publishing', isEqualTo: true)
        .get()
        .then((data) async {
      if (data.size != 0) {
        for (var i = 0; i < data.docs.length; i++) {
          // log("json : ${json.encode(data.docs[i].data())}");
          var source = data.docs[i].data();
          CourseMarketModel course = CourseMarketModel.fromJson(source);
          course.id = data.docs[i].id;
          courseList.add(course);
        }
        return courseList;
      } else {
        return courseList;
      }
    });
  }

  Future<UserModel> getTutorInfo(String id) async {
    // log("getTutorInfo");
    return await firebaseFirestore
        .collection('users')
        .doc(id)
        .get()
        .then((userFirebase) async {
      if (userFirebase.exists) {
        return UserModel.fromJson(userFirebase.data()!);
      } else {
        return UserModel();
      }
    });
  }

  Future<String> getSubjectInfo(String id) async {
    // log("getSubjectInfo");
    return await firebaseFirestore
        .collection('courseSubjects')
        .doc(id)
        .get()
        .then((userFirebase) async {
      if (userFirebase.exists) {
        return userFirebase.get('subject_name');
      } else {
        return 'ไม่พบข้อมูล';
      }
    });
  }

  Future<String> getLevelInfo(String id) async {
    // log("getLevelInfo");
    return await firebaseFirestore
        .collection('courseLevels')
        .doc(id)
        .get()
        .then((userFirebase) async {
      if (userFirebase.exists) {
        return userFirebase.get('level_name');
      } else {
        return 'ไม่พบข้อมูล';
      }
    });
  }
}
