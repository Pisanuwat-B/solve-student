import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/authentication/models/user_model.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/feature/market_place/model/course_live_model.dart';
import 'package:solve_student/feature/my_course/model/review_model.dart';
import 'package:solve_student/feature/order/model/order_class_model.dart';
import 'package:uuid/uuid.dart';

class MyCourseLiveDetailController extends ChangeNotifier {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  MyCourseLiveDetailController(this.context, {required this.courseId});
  BuildContext context;
  String courseId;
  AuthProvider? auth;
  CourseLiveModel? courseDetail;
  UserModel? tutor;
  List<ReviewModel> reviewList = [];
  num avgReview = 5;
  int totalReview = 0;
  int rateSelected = 5;
  TextEditingController reviewMessage = TextEditingController();
  String subject = 'ไม่พบข้อมูล';
  String level = 'ไม่พบข้อมูล';
  bool isLoading = true;
  init() async {
    auth = Provider.of<AuthProvider>(context, listen: false);
    courseDetail = null;
    tutor = null;
    subject = 'ไม่พบข้อมูล';
    level = 'ไม่พบข้อมูล';
    await getCourseInfo();
    await getTutorInfo(courseDetail?.tutorId ?? "");
    subject = await getSubjectInfo(courseDetail?.subjectId ?? "");
    level = await getLevelInfo(courseDetail?.levelId ?? "");
    isLoading = false;
    notifyListeners();
  }

  getCourseInfo() async {
    await firebaseFirestore
        .collection('course_live')
        .doc(courseId)
        .get()
        .then((userFirebase) async {
      if (userFirebase.exists) {
        courseDetail = CourseLiveModel.fromJson(userFirebase.data()!);
        courseDetail!.id = courseId;
      } else {
        courseDetail = CourseLiveModel();
      }
    });
    log("courseDetail : ${courseDetail!.toJson()}");
    notifyListeners();
  }

  getTutorInfo(String id) async {
    await firebaseFirestore
        .collection('users')
        .doc(id)
        .get()
        .then((userFirebase) async {
      if (userFirebase.exists) {
        tutor = UserModel.fromJson(userFirebase.data()!);
      }
    });
    notifyListeners();
  }

  Future<num> getCourseTotalTutor() async {
    return await firebaseFirestore
        .collection('course')
        .where('create_user', isEqualTo: tutor?.id ?? "")
        .where('publishing', isEqualTo: true)
        .get()
        .then((data) async {
      if (data.size != 0) {
        return data.size;
      } else {
        return 0;
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
    log("getLevelInfo");
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

  Future<OrderClassModel> createMarketOrder(
    String courseId,
    String courseTitle,
    String courseContent,
    String tutorId,
  ) async {
    var uuid = const Uuid();
    String refId = "#${(uuid.hashCode + 1).toString().padLeft(5, '0')}";
    String orderUid = uuid.v4();
    String me = auth?.user?.id ?? "";

    orderUid = "${courseId}_${me}_${tutorId}";
    OrderClassModel? order;
    var ref = await firebaseFirestore.collection('orders').doc(orderUid).get();
    if (ref.data()?.isNotEmpty ?? false) {
      order = OrderClassModel.fromJson(ref.data()!);
    } else {
      order = OrderClassModel(
        id: orderUid,
        tutorId: tutorId,
        studentId: me,
        classId: courseId,
        refId: refId,
        title: courseTitle,
        content: courseContent,
        fromMarketPlace: true,
      );
      await firebaseFirestore
          .collection('orders')
          .doc(orderUid)
          .set(order.toJson());
    }
    return order;
  }

  String? dateTimeFromTimeStamp(num data) {
    var date = DateTime.fromMicrosecondsSinceEpoch(data.toInt());
    var outputFormat = DateFormat('dd/MM/yyyy H:mm');
    String? outputDate = outputFormat.format(date);
    return outputDate;
  }

  getCourseReview() async {
    reviewList = [];
    await firebaseFirestore
        .collection('reviews')
        .where('course_id', isEqualTo: courseDetail?.id)
        .get()
        .then((data) async {
      if (data.size != 0) {
        for (var i = 0; i < data.docs.length; i++) {
          var only = ReviewModel.fromJson(data.docs[i].data());
          reviewList.add(only);
        }
        totalReview = data.docs.length;
        avgReview =
            reviewList.map((m) => (m.rate ?? 0)).reduce((a, b) => a + b) /
                (reviewList.length);
        return reviewList;
      } else {
        return reviewList;
      }
    });
    notifyListeners();
  }

  Future<bool> checkMeReviewed() async {
    return await firebaseFirestore
        .collection('reviews')
        .where('user_id', isEqualTo: auth?.uid ?? "")
        .where('course_id', isEqualTo: courseDetail?.id)
        .get()
        .then((data) async {
      if (data.size != 0) {
        return true;
      } else {
        return false;
      }
    });
  }

  updateRateSelected(int value) {
    rateSelected = value;
    notifyListeners();
  }

  updateReviewMessage(String value) {
    reviewMessage = TextEditingController(text: value);
    notifyListeners();
  }

  createReview() async {
    var review = ReviewModel(
      courseId: courseId,
      userId: auth?.uid ?? "",
      rate: rateSelected,
      reviewMessage: reviewMessage.text,
      createdAt: DateTime.now(),
    );
    final ref = firebaseFirestore.collection('reviews/');
    var created = await ref.add(review.toJson());
    await ref.doc(created.id).update({"id": created.id});
    await getCourseReview();
    notifyListeners();
  }

  double calculatePercent(double rate) {
    double percent = 0;
    if (reviewList.isNotEmpty) {
      var rateLenght =
          reviewList.where((element) => element.rate == rate).length;
      percent = (double.parse("$rateLenght") / reviewList.length) * 100;
    }
    return percent;
  }

  Future<UserModel?> getUserInfo(String id) async {
    UserModel? tutor;
    await firebaseFirestore
        .collection('users')
        .doc(id)
        .get()
        .then((userFirebase) async {
      if (userFirebase.exists) {
        tutor = UserModel.fromJson(userFirebase.data()!);
      }
    });
    return tutor;
  }
}
