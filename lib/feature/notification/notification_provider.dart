// lib/providers/notification_provider.dart
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  bool _hasNewNotification = false;
  bool get hasNewNotification => _hasNewNotification;

  final List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications => _notifications;

  void listenForNewQuestions(String studentId) {
    FirebaseFirestore.instance
        .collection('answer_market')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .listen((snapshot) {
      for (final docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          final data = docChange.doc.data();
          if (data != null) {
            final enrichedData = {
              'id': docChange.doc.id,
              ...data,
            };

            log('listening to question');
            log(enrichedData.toString());

            _notifications.insert(0, enrichedData);
            _hasNewNotification = true;
            notifyListeners();
          }
        }
      }
    });
  }

  void markAllAsRead() {
    _hasNewNotification = false;
    notifyListeners();
  }
}
