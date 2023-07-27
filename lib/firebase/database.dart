import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';

class DatabaseService {
  final db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getUserById(userId) async {
    final docRef = db.collection('users');
    try {
      final snapshot = await docRef.doc(userId).get();
      if (snapshot.exists) {
        final user = snapshot.data()!;
        print(user);
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
}
