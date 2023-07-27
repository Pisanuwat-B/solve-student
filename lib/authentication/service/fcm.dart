import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FCM {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  final dataCtrl = StreamController.broadcast();
  final tittleCtrl = StreamController.broadcast();
  final bodyCtrl = StreamController.broadcast();

  setNotification(BuildContext context) async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      forgroundNotification(context);
      backgroundNotification(context);
      terminateNotification(context);
    }
    final token = firebaseMessaging
        .getToken()
        .then((value) => print("FCM Token : $value"));
  }

  //ระหว่างเปิดแอป
  forgroundNotification(BuildContext context) {
    FirebaseMessaging.onMessage.listen((event) {
      print("forgroundNotification");
      if (Platform.isIOS) {
        print("in ios");
        log("message notification");
      } else {
        print("in android");
        log("message notification");
      }
    });
  }

  //ปิดแอป แต่ไม่เคลียร์แอป
  backgroundNotification(BuildContext context) {
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print("backgroundNotification");
      log("message notification");
    });
  }

  //ปิดแอปแล้วเปิดมาใหม่
  terminateNotification(BuildContext context) async {
    print("terminateNotification");
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      log("message notification");
    }
  }

  @override
  void dispose() {
    dataCtrl.close();
    tittleCtrl.close();
    bodyCtrl.close();
  }
}
