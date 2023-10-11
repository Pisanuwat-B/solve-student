import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getUserById(userId) async {
    final docRef = db.collection('users');
    try {
      final snapshot = await docRef.doc(userId).get();
      if (snapshot.exists) {
        final user = snapshot.data()!;
        return user;
      } else {
        print('Document does not exist');
        return {};
      }
    } catch (e) {
      print('Error getting course: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getUserNameById(userId) async {
    final docRef = db.collection('users');
    try {
      final snapshot = await docRef.doc(userId).get();
      if (snapshot.exists) {
        final name = snapshot.data()!['name'];
        return name;
      } else {
        print('Document does not exist');
        return {};
      }
    } catch (e) {
      print('Error getting course: $e');
      return {};
    }
  }

  Future<dynamic> getSolvepadData(String solvepadId) async {
    final collectionRef = db.collection('solvepad');
    String voiceUrl = '';
    Map<String, dynamic> solvepadData;

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/downloadedSolvepad.txt');

    final event = await collectionRef.doc(solvepadId).get();
    voiceUrl = (event.data() as Map)['voice'];
    var solvepadUrl = (event.data() as Map)['solvepad'];
    final url = Uri.parse(solvepadUrl);
    final response = await http.get(url);
    await file.writeAsBytes(response.bodyBytes);
    var fileContent = await file.readAsString();
    solvepadData = json.decode(fileContent);

    return [solvepadData, voiceUrl];
  }

  List<Map<String, dynamic>> _convertStringAction(String actionHistoryString) {
    List<Map<String, dynamic>> actionList = [];
    String dbAction = actionHistoryString
        .substring(1, actionHistoryString.length - 1)
        .replaceAll(' ', '');
    String extractValue(String key, String rawString) {
      final match = RegExp('$key:(((?!,data|}).)*)').firstMatch(rawString);
      return match != null ? match.group(1).toString() : '';
    }

    final regex = RegExp(r'{([^}]+)}');
    final matches = regex.allMatches(dbAction);

    for (final match in matches) {
      final actionObj = match[0];
      String actionVal = extractValue('action', actionObj.toString());
      String dataVal = extractValue('data', actionObj.toString());

      if (actionVal[0] == 'D') {
        dataVal = dataVal.replaceAll(RegExp(r'^\[|\]$'), '').trim();
        final RegExp regExp =
            RegExp(r'Offset\(\s*(\d+\.\d+)\s*,\s*(\d+\.\d+)\s*\)|null');

        List<Offset?> offsets = [];
        for (Match match in regExp.allMatches(dataVal)) {
          if (match.group(0) == 'null') {
            offsets.add(null);
          } else {
            final double dx = double.parse(match.group(1)!);
            final double dy = double.parse(match.group(2)!);
            offsets.add(Offset(dx, dy));
          }
        }

        actionList.add({'action': actionVal, 'data': offsets});
      } else {
        actionList.add({'action': actionVal, 'data': num.parse(dataVal)});
      }
    }
    return actionList;
  }

  List<List<int>> convertStringTime(List<dynamic> timeHistoryDynamic) {
    List<List<int>> timeHistoryList = List<List<int>>.from(
      timeHistoryDynamic.map(
        (list) => List<int>.from(list),
      ),
    );
    return timeHistoryList;
  }

  Future<String> downloadAudio(fileURL) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/solve_voice.mp4');
    final url = Uri.parse(fileURL);
    final response = await http.get(url);
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }
}
