import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:slove_student/authentication/models/user_model.dart';
import 'package:slove_student/authentication/service/auth_provider.dart';
import 'package:slove_student/feature/chat/models/chat_model.dart';
import 'package:slove_student/feature/class/models/class_model.dart';
import 'package:slove_student/feature/order/model/order_class_model.dart';
import 'package:uuid/uuid.dart';

class OrderMockProvider extends ChangeNotifier {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  AuthProvider? auth;

  init({AuthProvider? auth}) {
    this.auth = auth;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllOrder() {
    return firebaseFirestore.collection('orders').snapshots();
  }

  Future<OrderClassModel> createOrder(
    ClassModel classDetail,
  ) async {
    var me = auth?.user?.getRoleType();
    var uuid = const Uuid();
    String refId = "#${(uuid.hashCode + 1).toString().padLeft(5, '0')}";
    String orderUid = uuid.v4();
    String studentId = classDetail.userId ?? "";
    String tutorId = auth?.user?.id ?? "";
    log("message1 : s : $studentId, t : $tutorId");
    // format classId_studentId_tutorId
    if (me == RoleType.student) {
      studentId = auth?.user?.id ?? "";
      tutorId = classDetail.userId ?? "";
    }
    orderUid = "${classDetail.id}_${studentId}_${tutorId}";
    OrderClassModel? order;
    var ref = await firebaseFirestore.collection('orders').doc(orderUid).get();
    if (ref.data()?.isNotEmpty ?? false) {
      order = OrderClassModel.fromJson(ref.data()!);
    } else {
      order = OrderClassModel(
        id: orderUid,
        tutorId: tutorId,
        studentId: studentId,
        classId: classDetail.id,
        refId: refId,
        title: classDetail.name ?? "",
        content: classDetail.detail ?? "",
      );
      // OrderClassModel order =
      //     OrderClassModel(id: orderUid, tutorId: auth?.uid, title: "class");
      await firebaseFirestore
          .collection('orders')
          .doc(orderUid)
          .set(order.toJson());
    }
    return order;
  }

  Future<ClassModel> getClassTutorInfo(String classId) async {
    log("getClassInfo");
    ClassModel? classModel;
    var classInStudent =
        await firebaseFirestore.collection('class_tutor').doc(classId).get();
    classModel = ClassModel.fromJson(classInStudent.data()!);
    return classModel;
  }

  Future<ChatModel?> createChat(
      OrderClassModel order, UserModel cutomer) async {
    String me = auth?.user?.id ?? "";
    String chatId = "${order.classId}_${me}_${order.tutorId}";
    await firebaseFirestore.collection('chats').doc(chatId).set({
      'chat_id': chatId,
      'order_id': '${order.classId}',
      'customer_id': '${me}',
      'tutor_id': '${order.tutorId}',
    });
    await sendFirstMessage(chatId);
    await sendToFirstMessage(
      order.tutorId ?? "",
      chatId,
    );
    return getChatInfo(chatId);
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

  Future<OrderClassModel> updateOrderStatus(
      String orderId, String status) async {
    log("updateOrderStatus");
    var orders = firebaseFirestore.collection("orders");
    await orders.doc(orderId).update({'status': status});
    var result = await orders.doc(orderId).get();
    OrderClassModel? order = OrderClassModel.fromJson(result.data()!);
    return order;
  }

  Future<OrderClassModel> getOrderDetail(String orderId) async {
    var ref = await firebaseFirestore.collection('orders').doc(orderId).get();
    OrderClassModel? order = OrderClassModel.fromJson(ref.data()!);
    return order;
  }
}
