import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:solve_student/authentication/models/user_model.dart';
import 'package:solve_student/authentication/service/auth_provider.dart';
import 'package:solve_student/feature/chat/models/chat_model.dart';
import 'package:solve_student/feature/market_place/model/course_market_model.dart';
import 'package:solve_student/feature/order/model/order_class_model.dart';
import 'package:uuid/uuid.dart';

class MarketCourseDetailProvider extends ChangeNotifier {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  AuthProvider? auth;
  CourseMarketModel? courseDetail;
  UserModel? tutor;
  String subject = 'ไม่พบข้อมูล';
  String level = 'ไม่พบข้อมูล';
  bool isLoading = true;
  init({required BuildContext context, required String courseId}) async {
    auth = Provider.of<AuthProvider>(context, listen: false);
    courseDetail = null;
    tutor = null;
    subject = 'ไม่พบข้อมูล';
    level = 'ไม่พบข้อมูล';
    courseDetail = await getCourseInfo(courseId);
    tutor = await getTutorInfo(courseDetail?.tutorId ?? "");
    subject = await getSubjectInfo(courseDetail?.subjectId ?? "");
    level = await getLevelInfo(courseDetail?.levelId ?? "");
    isLoading = false;
    notifyListeners();
  }

  Future<CourseMarketModel> getCourseInfo(String id) async {
    log("getCourseInfo");
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

  Future<List<CourseMarketModel>> getRecommendCourse() async {
    List<CourseMarketModel> courseList = [];
    return await firebaseFirestore
        .collection('course_live')
        // .where('subject_id', isEqualTo: courseDetail?.subjectId)
        .where('level_id', isEqualTo: courseDetail?.levelId)
        .where('publishing', isEqualTo: true)
        .get()
        .then((data) async {
      if (data.size != 0) {
        for (var i = 0; i < data.docs.length; i++) {
          // log("json : ${json.encode(data.docs[i].data())}");
          var only = CourseMarketModel.fromJson(data.docs[i].data());
          courseList.add(only);
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
        paymentOn: true,
        paymentStatus: 'pending',
      );
      await firebaseFirestore
          .collection('orders')
          .doc(orderUid)
          .set(order.toJson());
    }
    return order;
  }

  Future<ChatModel?> createMarketChat(String orderId, String tutorId) async {
    String me = auth?.user?.id ?? "";

    String chatId = "${orderId}_${me}_${tutorId}";
    await firebaseFirestore.collection('chats').doc(chatId).set({
      'chat_id': chatId,
      'order_id': '$orderId',
      'customer_id': '$me',
      'tutor_id': '$tutorId',
    });
    await sendFirstMessage(chatId);
    await sendToFirstMessage(
      tutorId,
      chatId,
    );
    return getChatInfo(chatId);
  }

  Future<void> sendFirstMessage(String orderId) async {
    await firebaseFirestore
        .collection('users')
        .doc(auth?.uid)
        .collection('my_order_chat')
        .doc(orderId)
        .set({});
  }

  Future<void> sendToFirstMessage(String userTo, String orderId) async {
    await firebaseFirestore
        .collection('users')
        .doc(userTo)
        .collection('my_order_chat')
        .doc(orderId)
        .set({});
  }

  Future<ChatModel?> getChatInfo(String chatId) async {
    log("getSelfInfo");
    ChatModel? chat;
    await firebaseFirestore
        .collection('chats')
        .doc(chatId)
        .get()
        .then((userFirebase) async {
      if (userFirebase.exists) {
        chat = ChatModel.fromJson(userFirebase.data()!);
      }
    });
    return chat;
  }
}
