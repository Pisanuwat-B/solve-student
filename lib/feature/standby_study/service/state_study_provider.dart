import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:solve_student/feature/standby_study/models/user_state_study_model.dart';
import 'package:uuid/uuid.dart';

class StandbyStudyProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  var uuid = const Uuid();

  Future<String> goToRoomState(
    String classId,
    UserStandbyStudy user,
  ) async {
    String roomId = '';
    var source = await firebaseFirestore
        .collection('state_study')
        .where('classId', isEqualTo: classId)
        .get();
    if (source.docs.isNotEmpty && source.docs.last['classId'] == classId) {
      //update
      log("update");
      roomId = source.docs.last.id;
      await updateUserInRoomState(source.docs.last.id, classId, user);
    } else {
      //create.
      log("create");
      roomId = await createRoomState(classId, user);
    }
    return roomId;
  }

  Future<String> createRoomState(
    String classId,
    UserStandbyStudy user,
  ) async {
    String uId = uuid.v4();
    await firebaseFirestore.collection('state_study').doc(uId).set(
      {
        'classId': classId,
        'userIn': [user.toJson()]
      },
    );
    return uId;
  }

  Future<void> updateUserInRoomState(
    String roomId,
    String classId,
    UserStandbyStudy user,
  ) async {
    try {
      var source =
          await firebaseFirestore.collection('state_study').doc(roomId).get();
      List<UserStandbyStudy> oldList =
          userStateStudyFromJson(json.encode(source['userIn']));
      var find = oldList.where((v) => v.id == user.id).isEmpty;
      if (find) {
        oldList.add(user);
        List data = [];
        for (var i = 0; i < oldList.length; i++) {
          data.add(oldList[i].toJson());
        }
        await firebaseFirestore
            .collection('state_study')
            .doc(roomId)
            .update({'userIn': data});
      }
    } catch (e) {
      await createRoomState(classId, user);
    }
  }

  Future<void> removeUserInRoomState(
    String roomId,
    String classId,
    UserStandbyStudy user,
  ) async {
    var source =
        await firebaseFirestore.collection('state_study').doc(roomId).get();
    List<UserStandbyStudy> oldList =
        userStateStudyFromJson(json.encode(source['userIn']));
    var find = oldList.where((v) => v.id == user.id).isNotEmpty;
    if (find) {
      oldList.removeWhere((element) => element.id == user.id);
      List data = [];
      for (var i = 0; i < oldList.length; i++) {
        data.add(oldList[i].toJson());
      }
      await firebaseFirestore
          .collection('state_study')
          .doc(roomId)
          .update({'userIn': data});
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserCountInRoom(
      String roomId) {
    return firebaseFirestore.collection('state_study').doc(roomId).snapshots();
  }
}
