import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

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
        log('Document does not exist');
        return {};
      }
    } catch (e) {
      log('Error getting course: $e');
      return {};
    }
  }

  Future<String> getUserNameById(userId) async {
    final docRef = db.collection('users');
    try {
      final snapshot = await docRef.doc(userId).get();
      if (snapshot.exists) {
        final name = snapshot.data()!['name'];
        return name;
      } else {
        log('Document does not exist');
        return '';
      }
    } catch (e) {
      log('Error getting course: $e');
      return '';
    }
  }

  Future<dynamic> getMarketCourseSolvepadData(String solvepadId) async {
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

  Future<String> getMarketCourseAudioFile(fileURL) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/solve_voice.mp4');
    final url = Uri.parse(fileURL);
    final response = await http.get(url);
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  Future<Map<String, List<String>>> getQuestionList(
      String courseId, String chapterId, int page) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference questionGroups =
        firestore.collection('question_group_market');

    QuerySnapshot querySnapshot = await questionGroups
        .where('course_id', isEqualTo: courseId)
        .where('chapter_id', isEqualTo: chapterId)
        .where('page', isEqualTo: page)
        .get();

    List<String> questions = [];
    List<String> groupIds = [];

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      List<dynamic> questionList = data['questions'] ?? [];
      String groupId = doc.id;

      for (var question in questionList) {
        questions.add(question);
        groupIds.add(groupId);
      }
    }

    return {
      'questions': questions,
      'groupIds': groupIds,
    };
  }

  Future<Map<String, String>> getSolvepadAnswer(String questionGroupId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get the answer_id from question_group_market
    DocumentSnapshot questionGroupDoc = await firestore
        .collection('question_group_market')
        .doc(questionGroupId)
        .get();

    if (!questionGroupDoc.exists) {
      throw Exception('Question group not found');
    }

    var questionGroupData = questionGroupDoc.data() as Map<String, dynamic>;
    String answerId = questionGroupData['answer_id'];

    // Get the solvepad_qa_market_id from answer_market
    DocumentSnapshot answerDoc =
        await firestore.collection('answer_market').doc(answerId).get();

    if (!answerDoc.exists) {
      throw Exception('Answer not found');
    }

    var answerData = answerDoc.data() as Map<String, dynamic>;
    String solvepadQaId = answerData['solvepad_qa_market_id'];

    // Get the solvepad and voice from solvepad_qa_market
    DocumentSnapshot solvepadQaDoc = await firestore
        .collection('solvepad_qa_market')
        .doc(solvepadQaId)
        .get();

    if (!solvepadQaDoc.exists) {
      throw Exception('Solvepad QA not found');
    }

    var solvepadQaData = solvepadQaDoc.data() as Map<String, dynamic>;
    String solvepad = solvepadQaData['solvepad'];
    String voice = solvepadQaData['voice'];

    return {
      'solvepad': solvepad,
      'voice': voice,
    };
  }
}
