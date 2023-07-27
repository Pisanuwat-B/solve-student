import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:slove_student/feature/class/models/class_model.dart';
import 'package:uuid/uuid.dart';

class ClassProvider extends ChangeNotifier {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  FirebaseStorage storage = FirebaseStorage.instance;

  var uuid = const Uuid();

  Future<bool> createOrUpdateClass(
      {required ClassModel item,
      required bool isTutor,
      required bool isCreate,
      String isSelectImage = ""}) async {
    try {
      String uId = uuid.v4();
      ClassModel bookingModel = item;
      // bookingModel.id = uId;
      if (isCreate) {
        bookingModel.id = uId;
        if (item.image != null) {
          final ext = item.image!.split('.').last;
          String path = 'image_class/${item.image!.split('/').last}';
          File file = File(item.image!);
          final ref = storage.ref().child(path);

          await ref
              .putFile(file, SettableMetadata(contentType: 'image/$ext'))
              .then((p0) {
            log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
          });
          item.image = await ref.getDownloadURL();
        }
      } else {
        bookingModel = item;
        // print('======= isUpdate =======');
        if (item.image != null && isSelectImage != "") {
          // print('======= is update Image =======');
          final ref = storage.refFromURL(item.image!);
          await ref.putFile(File(isSelectImage));
          item.image = await ref.getDownloadURL();
        } else if (item.image == null && isSelectImage != "") {
          // print('======= is update new Image =======');
          final ext = isSelectImage.split('.').last;
          String path = 'image_class/${isSelectImage.split('/').last}';
          File file = File(isSelectImage);
          final ref = storage.ref().child(path);

          await ref
              .putFile(file, SettableMetadata(contentType: 'image/$ext'))
              .then((p0) {
            log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
          });
          item.image = await ref.getDownloadURL();
        }
      }

      // print('object: ${item.toJson()}');

      if (isTutor) {
        await firestore
            .collection('class_tutor')
            .doc(bookingModel.id)
            .set(bookingModel.toJson());
      } else {
        await firestore
            .collection('class_study')
            .doc(bookingModel.id)
            .set(bookingModel.toJson());
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllClassById(
      String userId, bool isTutor) {
    // firestore.collection('class_tutor').limit(5).
    if (isTutor) {
      return firestore
          .collection('class_tutor')
          // .orderBy('created_at',descending: false)
          .where('userId', isEqualTo: userId)
          .snapshots();
    } else {
      return firestore
          .collection('class_study')
          .where('userId', isEqualTo: userId)
          // .orderBy('created_at')
          .snapshots();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllClass(
      {required bool isTutor}) {
    // var a = firestore.collection('class_study').orderBy('id').startAt([""]).limit(3).get();
    // log('aaaa: ${a.then((value) {
    //   log('ttttt: ${value.size}');
    //   log('xxxxxxx: ${value.docs.length}');
    //   for (var i = 0; i < value.docs.length; i++) {
    //     log('zzzzz $i: ${value.docs[i].data()["name"]} ${value.docs[i].data()["id"]}');
    //     log('yyy: ${value.docs[i].data()["id"].hashCode}');
    //   }
    // })}');
    if (!isTutor) {
      return firestore.collection('class_tutor').snapshots();
    } else {
      return firestore.collection('class_study').snapshots();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllClassBySchoolSubject(
      {required String className,
      required String schoolSubject,
      required bool isTutor}) {
    if (!isTutor) {
      return firestore
          .collection('class_tutor')
          .where('schoolSubject', isEqualTo: schoolSubject)
          .where('name', isEqualTo: className)
          .snapshots();
    } else {
      // var a = firestore
      //     .collection('class_study')
      //     .where('schoolSubject', isEqualTo: schoolSubject)
      //     .count();

      // var b = firestore
      //     .collection('class_study')
      //     .where('schoolSubject', isEqualTo: schoolSubject)
      //     .orderBy('name')
      //     .startAfter(['A']).limit(1);
      // print('aaaa: ${b.get().then((value) {
      //   print(value);
      // })}');

      // print('xxxxx: ${a.get().then((value) {
      //   print('zzzzzz: ${value.count}');
      // })}');
      return firestore
          .collection('class_study')
          .where('schoolSubject', isEqualTo: schoolSubject)
          // .where('name', arrayContainsAny: ['F'])
          .snapshots();
      // return firestore
      //     .collection('class_study')
      //     .where('schoolSubject', isEqualTo: schoolSubject)
      //     .where('name', isEqualTo: 'Find Tutor Thai 1')
      //     .snapshots();
    }
  }

  setBookingClass(
      {required String classId, required String role, int value = 0}) async {
    // 0 จองได้
    // 1 จองแล้ว
    bool isTutor = role == "tutor" ? true : false;
    if (isTutor) {
      await firestore
          .collection('class_tutor')
          .doc(classId)
          .update({"isBooking": value});
    } else {
      await firestore
          .collection('class_study')
          .doc(classId)
          .update({"isBooking": value});
    }
  }
}


 // URL = https://stackoverflow.com/questions/51717407/flutter-firestore-pagination

  // I think Firestore.instance.collection('user').where('name', isEqualTo: 'Tom').orderBy('age').startAfter(_lastDocument).limit(1).getDocuments() here. The _lastDocument causes the error

  // Firestore.instance.collection('user').where('name', isEqualTo: 'Tom').orderBy('age').startAfter(_lastDocument).limit(1).getDocuments().then((snapshot) {
  //        snapshot.documents.forEach((snap) {
  //           print(snap.data);
  //         });
  //        });

  // Firestore.instance.collection('user').where('name', isEqualTo: 'Tom').orderBy('age').startAfter([{'name': 'Tom'}]).limit(1).getDocuments().then((snapshot) {
  //        snapshot.documents.forEach((snap) {
  //           print(snap.data);
  //         });
  //        });