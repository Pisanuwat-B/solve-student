import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:slove_student/authentication/models/user_model.dart';
import 'package:slove_student/authentication/service/auth_provider.dart';
import 'package:slove_student/feature/calendar/model/course_model.dart';
import 'package:slove_student/feature/market_place/model/course_market_model.dart';

class HomeProvider extends ChangeNotifier {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  AuthProvider? auth;

  init({AuthProvider? auth}) {
    this.auth = auth;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMargetPlaceCourse() {
    return firebaseFirestore.collection('course').snapshots();
  }

  Future<CourseMarketModel> getCourseInfo(String id) async {
    // log("getCourseInfo");
    return await firebaseFirestore
        .collection('course')
        .doc(id)
        .get()
        .then((userFirebase) async {
      if (userFirebase.exists) {
        return CourseMarketModel.fromJson(userFirebase.data()!);
      } else {
        return CourseMarketModel();
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
