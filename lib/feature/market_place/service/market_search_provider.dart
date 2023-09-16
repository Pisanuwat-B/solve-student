import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:solve_student/authentication/models/user_model.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/feature/market_place/model/course_live_model.dart';
import 'package:solve_student/feature/market_place/model/course_market_model.dart';

class MarketSearchProvider extends ChangeNotifier {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  AuthProvider? auth;
  List<Map<String, String>> subjectList = [];
  List<Map<String, String>> levelList = [];
  Map<String, String>? subjectSelected;
  Map<String, String>? levelSelected;
  TextEditingController? courseNameSearch;

  init({
    AuthProvider? auth,
    required bool filter,
    String? subject,
    String? level,
  }) async {
    this.auth = auth;
    await getSubjectList();
    await getLevelList();
    courseNameSearch = null;
    subjectSelected = null;
    levelSelected = null;
    if (filter) {
      if (subject != null) {
        subjectSelected = subjectList
            .where((element) => element.values.first == subject)
            .first;
      }
      if (level != null) {
        levelSelected =
            levelList.where((element) => element.values.first == level).first;
      }
    }
    notifyListeners();
  }

  Future<List<CourseMarketModel>> getCourseInfo() async {
    List<CourseMarketModel> courseList = [];
    try {
      return await firebaseFirestore
          .collection('course')
          .where('course_name', isGreaterThanOrEqualTo: courseNameSearch?.text)
          .where('subject_id', isEqualTo: subjectSelected?.keys.first)
          .where('level_id', isEqualTo: levelSelected?.keys.first)
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
    } catch (e) {
      log("getCourseInfo : $e");
      return courseList;
    }
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

  getSubjectList() async {
    subjectList = [];
    await firebaseFirestore
        .collection('courseSubjects')
        .get()
        .then((userFirebase) async {
      for (var i = 0; i < userFirebase.size; i++) {
        var data = userFirebase.docs[i].data();
        String id = userFirebase.docs[i].id;
        String name = data['subject_name'];
        Map<String, String> last = {id: name};
        subjectList.add(last);
      }
    });
    // if (subjectList.isNotEmpty) {
    //   subjectSelected = subjectList.first;
    // }
    notifyListeners();
  }

  getLevelList() async {
    levelList = [];
    await firebaseFirestore
        .collection('courseLevels')
        .get()
        .then((userFirebase) async {
      for (var i = 0; i < userFirebase.size; i++) {
        var data = userFirebase.docs[i].data();
        String id = userFirebase.docs[i].id;
        String name = data['level_name'];
        Map<String, String> last = {id: name};
        levelList.add(last);
      }
    });
    // if (levelList.isNotEmpty) {
    //   levelSelected = levelList.first;
    // }
    notifyListeners();
  }

  Future<String> getSubjectInfo(String id) async {
    // log("getTutorInfo");
    return await firebaseFirestore
        .collection('courseSubjects')
        .doc(id)
        .get()
        .then((userFirebase) async {
      if (userFirebase.exists) {
        var data = userFirebase.data();
        String name = data!['subject_name'];
        return name;
      } else {
        return "ไม่พบข้อมูล";
      }
    });
  }

  Future<String> getLevelInfo(String id) async {
    // log("getTutorInfo");
    return await firebaseFirestore
        .collection('courseLevels')
        .doc(id)
        .get()
        .then((userFirebase) async {
      if (userFirebase.exists) {
        var data = userFirebase.data();
        String name = data!['level_name'];
        return name;
      } else {
        return "ไม่พบข้อมูล";
      }
    });
  }

  setSubjectSelected(Map<String, String>? data) {
    subjectSelected = data;
    notifyListeners();
  }

  setLevelSelected(Map<String, String>? data) {
    levelSelected = data;
    notifyListeners();
  }

  searchCourseName(String courseName) {
    courseNameSearch = TextEditingController(text: courseName);
    notifyListeners();
  }

  clearFilter() {
    courseNameSearch?.clear();
    courseNameSearch = null;
    subjectSelected = null;
    levelSelected = null;
    notifyListeners();
  }
}
