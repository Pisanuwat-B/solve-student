import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/authentication/models/user_model.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/feature/market_place/model/course_live_model.dart';

class MyCourseLiveController extends ChangeNotifier {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  MyCourseLiveController(this.context);
  BuildContext context;
  AuthProvider? auth;

  List<CourseLiveModel> myCourseList = [];
  init() {
    auth = Provider.of<AuthProvider>(context, listen: false);
    getMyCourseList();
  }

  getMyCourseList() async {
    myCourseList = [];
    await firebaseFirestore.collection('course_live').get().then((data) async {
      if (data.size != 0) {
        for (var i = 0; i < data.docs.length; i++) {
          List<String> studentList = [];
          if (data.docs[i].data()['student_list'] != null) {
            studentList =
                data.docs[i].data()['student_list'].cast<String>().toList();
            // String? course = studentList
            //     .where((element) => element == ("RCqVTMI7PVSZRUz94EpdJr9FPiK2"))
                .firstOrNull;
            String? course = studentList
                .where((element) => element == (auth?.uid ?? ""))
                .firstOrNull;
            if (course != null) {
              CourseLiveModel only =
                  CourseLiveModel.fromJson(data.docs[i].data());
              only.id = data.docs[i].id;
              myCourseList.add(only);
            }
          }
        }
      }
    });
    log("message : ${myCourseList.length}");
    notifyListeners();
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
