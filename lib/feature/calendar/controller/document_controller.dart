import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solve_student/feature/calendar/model/document_model.dart';
import 'package:solve_student/feature/calendar/service/document_service.dart';

class DocumentController extends ChangeNotifier {
  String id = '';
  var keywordTextEditingController = TextEditingController();
  var documentListFilter = <DocumentModel>[];
  var documentList = <DocumentModel>[];
  var isLoading = false;
  var document = DocumentModel();
  var docmentName = TextEditingController();
  var haveEorrorLevel = '';
  var haveEorrorSubject = '';
  var selectedIndex = 0;

  final ImagePicker _picker = ImagePicker();
  List<dynamic> imagePaths = [];
  Timer? _timer;

  void initialize() {
    keywordTextEditingController.addListener(() {
      String keyword = keywordTextEditingController.text;
      _timer?.cancel();
      debugPrint('filter object fosr keyword = $keyword');

      _timer = Timer(const Duration(milliseconds: 500), () {
        documentListFilter.clear();
        notifyListeners();
        if (documentList.isNotEmpty) {
          for (var i = 0; i < documentList.length; i++) {
            if (documentList[i]
                    .data
                    ?.documentName
                    ?.toLowerCase()
                    .contains(keyword.toLowerCase()) ==
                true) {
              documentListFilter.add(documentList[i]);
            }
            notifyListeners();
          }
        }
      });
    });
  }

  setRequestData() {
    docmentName.text = document.data?.documentName ?? '';
  }

  claerData() {
    if (docmentName.text.isNotEmpty) {
      docmentName.clear();
    }
  }

  dlastChangeName(String value) {
    docmentName.text = value;
  }

  setLevel(String value) {
    document.data?.levelId = value;
    notifyListeners();
  }

  setSubject(String value) {
    document.data?.subjectId = value;
    notifyListeners();
  }

  Future<String> createDocumentId(Data documentData) async {
    try {
      return id = await DocumentService().creaetDocument(documentData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getDocumentByDocumentId(
      {required String tutorId, required String documentId}) async {
    try {
      isLoading = true;
      document = await DocumentService()
          .getDocumentByDocumentId(tutorId: tutorId, documentId: documentId);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getDocumentListByTutorId(String tutorId) async {
    try {
      isLoading = true;
      documentList = [];
      documentListFilter = [];
      final List<DocumentModel> data =
          await DocumentService().getDocumentListByTutorId(tutorId);
      documentList.addAll(data);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshDocumentListByTutorId(String tutorId) async {
    try {
      isLoading = true;
      documentList = [];
      documentListFilter = [];
      final List<DocumentModel> data =
          await DocumentService().getDocumentListByTutorId(tutorId);
      documentList.addAll(data);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void removeImage(int index) async {
    document.data?.docFiles?.removeAt(index);
    notifyListeners();
  }

  Future<void> openFiles({
    required BuildContext context,
    required String tutorId,
    required String documentId,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
        ],
      );
      if (result == null) return;
      if (result.files.isNotEmpty) {
        File file = File(result.files.single.path ?? '');
        List<File> files = [];
        files.add(file);
        final List<String> images = (await DocumentService().uploadFilesPdf(
              files,
              documentId: documentId,
              tutorId: tutorId,
            )) ??
            [];
        for (var i in images) {
          document.data?.docFiles?.add(i);
        }

        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> openGallery({
    required BuildContext context,
    required String tutorId,
    required String documentId,
  }) async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 100,
        requestFullMetadata: true,
      );

      if (pickedFiles.isEmpty) return;

      List<File> files = [];
      if (pickedFiles.isNotEmpty) {
        for (var i in pickedFiles) {
          files.add(File(i.path));
        }
      }

      final images = (await DocumentService().uploadFilesImage(files,
              documentId: documentId, tutorId: tutorId)) ??
          [];
      for (var i in images) {
        document.data?.docFiles?.add(i);
      }
      notifyListeners();
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateDocumentDestails(DocumentModel documentData) async {
    try {
      await DocumentService().updateDocumentDestails(documentData);

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> deleteDocument(
      {required String tutorId, required String documentId}) async {
    try {
      await DocumentService().deleteDocument(
        tutorId: tutorId,
        documentId: documentId,
      );
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> deleteFileById({
    required String tutorId,
    required String documentId,
    required String fileId,
  }) async {
    try {
      await DocumentService().deleteFileById(
          tutorId: tutorId, documentId: documentId, fileId: fileId);
      return true;
    } catch (error) {
      return false;
    }
  }

  validator(bool validate) {
    final levelId = document.data?.levelId;
    final subjectId = document.data?.subjectId;

    if (validate == false) {
      return false;
    }

    if (levelId?.isEmpty == true || levelId == null) {
      haveEorrorLevel = 'กรุณาเลือกระดับชั้นปีการศึกษา';
      notifyListeners();
      return false;
    } else {
      haveEorrorLevel = '';
    }
    if (subjectId?.isEmpty == true || subjectId == null) {
      haveEorrorSubject = 'กรุณาเลือกเลือกหมวดหมู่';
      notifyListeners();
      return false;
    } else {
      haveEorrorSubject = '';
    }
    notifyListeners();
    return true;
  }

  setIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}
