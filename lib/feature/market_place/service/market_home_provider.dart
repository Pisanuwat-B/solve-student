import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:solve_student/authentication/models/user_model.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/feature/market_place/model/course_market_model.dart';

class MarketHomeProvider extends ChangeNotifier {
  // final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  AuthProvider? auth;

  init({AuthProvider? auth}) {
    this.auth = auth;
  }

  Future<List<CourseMarketModel>> getCourseList() async {
    List<CourseMarketModel> courseList = [];
    try {
      await firebaseFirestore
          .collection('course')
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
        }
      });
      return courseList;
    } catch (e) {
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
