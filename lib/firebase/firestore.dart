import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  late FirebaseFirestore db;
  late CollectionReference collection;

  FirestoreService(String collectionName) {
    db = FirebaseFirestore.instance;
    collection = db.collection(collectionName);
  }

  Future<String> addDocument(Map<String, dynamic> data, String user) async {
    try {
      final documentRef = collection.doc();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await documentRef.set({
        ...data,
        'create_time': timestamp,
        'create_user': user,
        'update_time': timestamp,
        'update_user': user,
      });
      return documentRef.id;
    } catch (error) {
      print('Error adding document: $error');
      throw Exception('Failed to add document');
    }
  }

  Future<String> createDocument(String id, Map<String, dynamic> data, String user) async {
    try {
      final checked = await getDocumentById(id);
      if (checked != null) {
        return 'duplicate';
      }

      final documentRef = collection.doc(id);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await documentRef.set({
        ...data,
        'create_time': timestamp,
        'create_user': user,
        'update_time': timestamp,
        'update_user': user,
      });
      return documentRef.id;
    } catch (error) {
      print('Error creating document: $error');
      throw Exception('Failed to create document');
    }
  }

  Future<List> getDocuments() async {
    try {
      final querySnapshot = await collection.get();
      final documents = [];
      if (querySnapshot.docs.isEmpty) {
        return documents;
      }
      querySnapshot.docs.forEach((doc) {
        documents.add({'id': doc.id, 'data': doc.data()});
      });
      return documents;
    } catch (error) {
      print('Error querying documents: $error');
      throw Exception('Failed to query documents');
    }
  }

  Future<Map<String, dynamic>?> getDocumentById(String id) async {
    try {
      final documentRef = collection.doc(id);
      final doc = await documentRef.get();
      if (doc.exists) {
        return {'id': doc.id, 'data': doc.data()};
      } else {
        return null;
      }
    } catch (error) {
      print('Error getting document: $error');
      throw Exception('Failed to get document');
    }
  }

  Future<List> getDocumentsWhere(String field, dynamic operator, dynamic value) async {
    try {
      Query query;

      switch (operator) {
        case '==':
          query = collection.where(field, isEqualTo: value);
          break;
        case '!=':
          query = collection.where(field, isNotEqualTo: value);
          break;
        case '<':
          query = collection.where(field, isLessThan: value);
          break;
        case '>':
          query = collection.where(field, isGreaterThan: value);
          break;
        case '<=':
          query = collection.where(field, isLessThanOrEqualTo: value);
          break;
        case '>=':
          query = collection.where(field, isGreaterThanOrEqualTo: value);
          break;
        case 'array-contains':
          query = collection.where(field, arrayContains: value);
          break;
        case 'array-contains-any':
          query = collection.where(field, arrayContainsAny: value);
          break;
        case '??':
          query = collection.where(field, isNull: value);
          break;
        default:
          throw Exception('Unsupported operator: $operator');
      }

      final querySnapshot = await query.get();
      final documents = [];
      if (querySnapshot.docs.isEmpty) {
        return documents;
      }
      querySnapshot.docs.forEach((doc) {
        documents.add({'id': doc.id, 'data': doc.data()});
      });
      return documents;
    } catch (error) {
      print('Error querying documents: $error');
      throw Exception('Failed to query documents');
    }
  }

  Future<bool> updateDocumentById(String id, Map<String, dynamic> data, String user) async {
    try {
      final documentRef = collection.doc(id);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await documentRef.update({
        ...data,
        'update_time': timestamp,
        'update_user': user,
      });
      return true;
    } catch (error) {
      print('Error updating document: $error');
      throw Exception('Failed to update document');
    }
  }

  Future<bool> deleteDocumentById(String id) async {
    try {
      final documentRef = collection.doc(id);
      await documentRef.delete();
      return true;
    } catch (error) {
      print('Error deleting document: $error');
      throw Exception('Failed to delete document');
    }
  }

  Future<bool> createDocumentsInBatch(List<Map<String, dynamic>> dataArray, String user) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      dataArray.forEach((data) {
        final id = data['id'];
        final documentData = Map<String, dynamic>.from(data);
        documentData.remove('id');
        final documentRef = collection.doc(id);
        batch.set(documentRef, {
          ...documentData,
          'create_time': timestamp,
          'create_user': user,
          'update_time': timestamp,
          'update_user': user,
        });
      });
      await batch.commit();
      return true;
    } catch (error) {
      print('Error creating documents in batch: $error');
      throw Exception('Failed to create documents in batch');
    }
  }

  Future<bool> updateDocumentsInBatch(List<Map<String, dynamic>> updatesArray, String user) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      updatesArray.forEach((update) {
        final id = update['id'];
        final documentData = Map<String, dynamic>.from(update);
        documentData.remove('id');
        final documentRef = collection.doc(id);
        batch.set(documentRef, {
          ...documentData,
          'update_time': timestamp,
          'update_user': user,
        });
      });
      await batch.commit();
      return true;
    } catch (error) {
      print('Error updating documents in batch: $error');
      throw Exception('Failed to update documents in batch');
    }
  }

  Future<bool> deleteDocumentsInBatch(List<String> documentIds) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      documentIds.forEach((id) {
        final documentRef = collection.doc(id);
        batch.delete(documentRef);
      });
      await batch.commit();
      return true;
    } catch (error) {
      print('Error deleting documents in batch: $error');
      throw Exception('Failed to delete documents in batch');
    }
  }

  Future<bool> performBatchOperations(List<Map<String, dynamic>> operations, String user) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      operations.forEach((operation) {
        final id = operation['id'];
        final data = Map<String, dynamic>.from(operation['data']);
        final type = operation['type'];
        final documentRef = collection.doc(id);

        switch (type) {
          case 'set':
            batch.set(documentRef, {
              ...data,
              'create_time': timestamp,
              'update_time': timestamp,
              'create_user': user,
              'update_user': user,
            });
            break;
          case 'update':
            batch.update(documentRef, {
              ...data,
              'update_time': timestamp,
              'update_user': user,
            });
            break;
          case 'delete':
            batch.delete(documentRef);
            break;
          default:
            print('Invalid operation type: $type');
        }
      });

      await batch.commit();
      return true;
    } catch (error) {
      print('Error performing batch operations: $error');
      throw Exception('Failed to perform batch operations');
    }
  }
}