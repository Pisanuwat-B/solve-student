import 'dart:io';
import 'package:solve_student/feature/calendar/app_client/app_client.dart';
import 'package:solve_student/feature/calendar/app_client/endpoint.dart';
import 'package:solve_student/feature/calendar/model/document_model.dart';

class DocumentService {
  final endpoint = Endpoint();
  final client = AppClient();

  Future<String> creaetDocument(Data documentData) async {
    try {
      Map<String, dynamic> json = await client.post(endpoint.createDocument(),
          body: documentData.toJson());
      var id = json['data'];
      return id;
    } catch (error) {
      rethrow;
    }
  }

  Future<List<DocumentModel>> getDocumentListByTutorId(String tutorId) async {
    try {
      Map<String, dynamic> json =
          await client.get(endpoint.getDocumentListByTutorId(tutorId));
      var data = json['data'];
      return List.generate(
        data.length,
        (index) => DocumentModel.fromJson(json['data'][index]),
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<DocumentModel> getDocumentByDocumentId(
      {required String tutorId, required String documentId}) async {
    try {
      Map<String, dynamic> json = await client.get(endpoint
          .getDocumentByDocumentId(tutorId: tutorId, documentId: documentId));
      var data = json['data'];
      return DocumentModel.fromJson(data);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<dynamic>?> uploadFilesImage(List<File> files,
      {required String tutorId, required String documentId}) async {
    try {
      Map<String, dynamic> json = await client.uploadFiles(
        endpoint.getUploadFiles(),
        files: files,
        tutorId: tutorId,
        documentId: documentId,
        id: documentId,
      );
      List<String> data = [];
      if (json['data'] != null) {
        data = <String>[];
        json['data'].forEach((v) {
          data.add(v);
        });
      }
      return data;
    } catch (error) {
      rethrow;
    }
  }

  Future<List<String>?> uploadFilesPdf(List<File> files,
      {required String tutorId, required String documentId}) async {
    try {
      print(
        endpoint.uploadPdfConvert(),
      );
      Map<String, dynamic> json = await client.uploadFile(
        endpoint.uploadPdfConvert(),
        files: files,
        tutorId: tutorId,
        documentId: documentId,
        id: documentId,
      );
      List<String> data = [];
      if (json['data'] != null) {
        data = <String>[];
        json['data'].forEach((v) {
          data.add(v);
        });
      }
      return data;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateDocumentDestails(
    DocumentModel documentDate,
  ) async {
    try {
      await client.put(endpoint.updateDocument(), body: {
        "id": documentDate.id,
        "tutor_id": documentDate.data?.tutorId,
        "update_data": documentDate.data?.toJson()
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteDocument(
      {required String tutorId, required String documentId}) async {
    try {
      await client.delete(
        endpoint.deleteDocument(
          tutorId: tutorId,
          documentId: documentId,
        ),
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteFileById(
      {required String tutorId,
      required String documentId,
      required String fileId}) async {
    try {
      await client.delete(
        endpoint.deleteFileById(
          tutorId: tutorId,
          documentId: documentId,
          fileId: fileId,
        ),
      );
    } catch (error) {
      rethrow;
    }
  }
}
