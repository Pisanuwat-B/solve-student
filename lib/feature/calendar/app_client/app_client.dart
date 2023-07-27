import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:http_parser/http_parser.dart';

class AppClient {
  final log = Logger('AppClient');
  http.Client client = Client();

  Future<Map<String, dynamic>> get(
    Uri uri, {
    bool useUserCredential = true,
    Map<String, String>? preferHeader,
    bool validateResponseFormat = true,
  }) async {
    try {
      Map<String, String> headers = {};

      headers.addAll({});

      if (preferHeader != null) headers.addAll(preferHeader);

      headers = await _addAuthorizationTokenToHeader(
        headers,
        useUserCredential,
      );

      log.fine('GET: $uri');
      log.fine('headers $headers');

      var response = await client.get(uri, headers: headers);
      await _validateResponseStatus(uri.toString(), response);

      var json = jsonDecode(response.body);

      if (validateResponseFormat) _validateResponsePattern(json);

      return json;
    } catch (error) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(
    Uri uri, {
    required Map<String, dynamic> body,
    bool useUserCredential = true,
    Map<String, String>? preferHeader,
    bool shouldRemoveAuthorizedHeaderFields = false,
    bool validateResponseFormat = true,
  }) async {
    try {
      log.fine('POST: body = $body');

      Map<String, String> headers = {};

      headers.addAll({});

      if (preferHeader != null) headers.addAll(preferHeader);

      // * sometime we will not need authorization headers
      // * for example: refresh token
      if (shouldRemoveAuthorizedHeaderFields == false) {
        headers = await _addAuthorizationTokenToHeader(
          headers,
          useUserCredential,
        );
      }

      headers['Content-Type'] = 'application/json';

      log.fine('POST: $uri');
      log.fine('headers $headers');

      var response = await client.post(
        uri,
        body: jsonEncode(body),
        headers: headers,
      );

      await _validateResponseStatus(uri.toString(), response);

      var json = jsonDecode(response.body);

      if (validateResponseFormat) _validateResponsePattern(json);

      return json;
    } catch (error) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(
    Uri uri, {
    required Map<String, dynamic> body,
    bool useUserCredential = true,
    Map<String, String>? preferHeader,
    bool shouldRemoveAuthorizedHeaderFields = false,
    bool validateResponseFormat = true,
  }) async {
    try {
      log.fine('POST: body = $body');

      Map<String, String> headers = {};

      headers.addAll({});

      if (preferHeader != null) headers.addAll(preferHeader);

      // * sometime we will not need authorization headers
      // * for example: refresh token
      if (shouldRemoveAuthorizedHeaderFields == false) {
        headers = await _addAuthorizationTokenToHeader(
          headers,
          useUserCredential,
        );
      }

      headers['Content-Type'] = 'application/json';

      log.fine('POST: $uri');
      log.fine('headers $headers');

      var response = await client.put(
        uri,
        body: jsonEncode(body),
        headers: headers,
      );

      await _validateResponseStatus(uri.toString(), response);

      var json = jsonDecode(response.body);

      if (validateResponseFormat) _validateResponsePattern(json);

      return json;
    } catch (error) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> patch(
    Uri uri, {
    required Map<String, dynamic> body,
    bool useUserCredential = true,
    Map<String, String>? preferHeader,
    bool shouldRemoveAuthorizedHeaderFields = false,
    bool validateResponseFormat = true,
  }) async {
    try {
      log.fine('POST: body = $body');

      Map<String, String> headers = {};

      headers.addAll({});

      if (preferHeader != null) headers.addAll(preferHeader);

      // * sometime we will not need authorization headers
      // * for example: refresh token
      if (shouldRemoveAuthorizedHeaderFields == false) {
        headers = await _addAuthorizationTokenToHeader(
          headers,
          useUserCredential,
        );
      }

      headers['Content-Type'] = 'application/json';

      log.fine('PATCH: $uri');
      log.fine('headers $headers');

      var response = await client.patch(
        uri,
        body: jsonEncode(body),
        headers: headers,
      );

      await _validateResponseStatus(uri.toString(), response);

      var json = jsonDecode(response.body);

      if (validateResponseFormat) _validateResponsePattern(json);

      return json;
    } catch (error) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> delete(
    Uri uri, {
    bool useUserCredential = true,
    Map<String, String>? preferHeader,
    bool shouldRemoveAuthorizedHeaderFields = false,
    bool validateResponseFormat = true,
  }) async {
    try {
      Map<String, String> headers = {};

      headers.addAll({});

      if (preferHeader != null) headers.addAll(preferHeader);

      // * sometime we will not need authorization headers
      // * for example: refresh token
      if (shouldRemoveAuthorizedHeaderFields == false) {
        headers = await _addAuthorizationTokenToHeader(
          headers,
          useUserCredential,
        );
      }

      headers['Content-Type'] = 'application/json';

      log.fine('DELETE: $uri');
      log.fine('headers $headers');

      var response = await client.delete(
        uri,
        headers: headers,
      );

      await _validateResponseStatus(uri.toString(), response);

      var json = jsonDecode(response.body);

      if (validateResponseFormat) _validateResponsePattern(json);

      return json;
    } catch (error) {
      rethrow;
    }
  }

  Future<Map<String, String>> _addAuthorizationTokenToHeader(
    Map<String, String> headers,
    bool useUserCredential,
  ) async {
    // if (useUserCredential) {
    final accessToken = '';
    headers['Authorization'] = 'Bearer $accessToken';
    return headers;
    // } else if (headers['Authorization'] != null) {
    //   // custom headers
    //   return headers;
    // } else {
    // headers['Authorization'] = 'Bearer $appApiKey';
    // return headers;
    // }
  }

  Future<Map<String, dynamic>> uploadFile(Uri uri,
      {required List<File> files,
      required String tutorId,
      String? documentId,
      required String id,
      bool dupilcate = false,
      Map<String, String>? preferHeader}) async {
    //** dupilcate คือ เงื่อนไขการกำหนด id ภาพสามารถอัพเดททับชื่อเดิมได้
    try {
      Map<String, String> headers = {};

      headers.addAll({});

      if (preferHeader != null) {
        headers = preferHeader;
      } else {
        // always force authentication when any upload.
        headers = await _addAuthorizationTokenToHeader(
          headers,
          true,
        );
      }

      headers.addAll({
        'Content-Type': 'multipart/form-data; charset=UTF-8',
      });

      var request = http.MultipartRequest('POST', uri);
      request.fields
          .addAll({'tutor_id': tutorId, 'document_id': documentId ?? ''});
      request.files
          .add(await http.MultipartFile.fromPath('file', files.first.path));

      http.StreamedResponse response = await request.send();

      var responseBody = await response.stream.bytesToString();

      var json = jsonDecode(responseBody);

      _validateResponsePattern(json);

      return json;
    } catch (error) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadFiles(Uri uri,
      {required List<File> files,
      required String tutorId,
      String? documentId,
      required String id,
      bool dupilcate = false,
      Map<String, String>? preferHeader}) async {
    //** dupilcate คือ เงื่อนไขการกำหนด id ภาพสามารถอัพเดททับชื่อเดิมได้
    try {
      Map<String, String> headers = {};

      headers.addAll({});

      if (preferHeader != null) {
        headers = preferHeader;
      } else {
        // always force authentication when any upload.
        headers = await _addAuthorizationTokenToHeader(
          headers,
          true,
        );
      }

      headers.addAll({
        'Content-Type': 'multipart/form-data; charset=UTF-8',
      });

      log.fine('POST: $uri');
      log.fine('headers $headers');

      var request = http.MultipartRequest("POST", uri);
      if (dupilcate) {
        request.fields['tutor_id'] = tutorId;
        request.fields['course_id'] = id;
      } else {
        request.fields['tutor_id'] = tutorId;
        request.fields['document_id'] = documentId ?? '';
      }

      for (var i = 0; i < files.length; i++) {
        var ext = files[i].path.split('.').last;
        var dt = DateTime.now().millisecondsSinceEpoch;
        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            files[i].path,
            filename: dupilcate ? '$id.$ext' : '${id}_$dt.$ext',
            contentType: MediaType('image', ext),
          ),
        );
      }

      request.headers.addAll(headers);

      var response = await request.send();
      log.fine('headers after sent ${request.headers}');

      var responseBody = await response.stream.bytesToString();
      log.fine(response.statusCode);

      // await _validateResponseStatus(uri.toString(), response);

      var json = jsonDecode(responseBody);
      _validateResponsePattern(json);

      return json;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> _validateResponseStatus(
    String url,
    http.Response response,
  ) async {
    log.fine('validate response status from $url, code ${response.statusCode}');
    switch (response.statusCode) {
      case 200:
        return;
      case 201:
        return;
      case 400:
        throw HttpException(response);
      case 401:
        throw HttpException(response);
      case 403:
        throw HttpException(response);
      case 404:
        throw HttpException(response);
      case 422:
        throw HttpException(response);
      case 500:
        throw HttpException(response);
      default:
        log.fine(response.body);
        throw Exception(
          'Invalid response status code ${response.statusCode}: ${response.body}',
        );
    }
  }

  void _validateResponsePattern(Map<String, dynamic> json) {
    if (json['data'] == null) {
      throw Exception('Invalid response pattern: $json');
    }

    // TODO: add varlidation response pattern here

    return;
  }
}

class HttpException implements Exception {
  Response response;
  HttpException(this.response);

  @override
  String toString() {
    return response.body;
  }
}
