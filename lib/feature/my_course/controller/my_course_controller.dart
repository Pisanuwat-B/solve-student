import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/authentication/models/user_model.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/feature/market_place/model/course_live_model.dart';
import 'package:solve_student/feature/market_place/model/course_market_model.dart';

class MyCourseController extends ChangeNotifier {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  MyCourseController(this.context);
  BuildContext context;
  AuthProvider? auth;

  List<String> idList = [];
  List<CourseMarketModel> myCourseList = [];
  init() {
    idList = [];
    auth = Provider.of<AuthProvider>(context, listen: false);
    getMyCourseList();
  }

  getMyCourseList() async {
    idList = [];
    await firebaseFirestore
        .collection('orders')
        .where('studentId', isEqualTo: auth?.uid ?? "")
        .where('paymentStatus', isEqualTo: 'paid')
        .get()
        .then((data) async {
      if (data.size != 0) {
        for (var i = 0; i < data.docs.length; i++) {
          idList.add(data.docs[i].data()['classId']);
        }
      }
    });
    myCourseList = [];
    for (var i = 0; i < idList.length; i++) {
      CourseMarketModel only = await getCourseInfo(idList[i]);
      only.id = idList[i];
      myCourseList.add(only);
    }
    notifyListeners();
  }

  Future<CourseMarketModel> getCourseInfo(String id) async {
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
