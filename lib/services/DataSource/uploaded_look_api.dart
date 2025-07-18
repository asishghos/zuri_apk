import 'dart:convert';
import 'dart:developer' as Developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:testing2/services/Class/uploaded_look_model.dart';
import 'package:testing2/services/DataSource/auth_api.dart';
import 'package:testing2/services/api_routes.dart';

class UploadedLooksService {
  /// Uploads an image to `/addLook`
  static Future<Map<String, dynamic>> uploadLook({
    required File imageFile,
    String userQuery = '',
  }) async {
    final uri = Uri.parse('${ApiRoutes.addUploadedLooks}?userQuery=$userQuery');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    request.headers.addAll(await AuthApiService.getHeaders(includeAuth: true));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    Developer.log(response.body);
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 204) {
      return {'message': 'Image skipped (no full-body human)', 'data': null};
    } else {
      throw Exception('Failed to upload look: ${response.body}');
    }
  }

  /// Fetch all uploaded looks
  static Future<List<UploadedLook>> getUploadedLooks() async {
    final uri = Uri.parse(ApiRoutes.getUploadedLooks);
    final response = await http.get(
      uri,
      headers: await AuthApiService.getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> looksJson = json['looks'];
      return looksJson.map((item) => UploadedLook.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch uploaded looks');
    }
  }

  /// Fetch look by ID
  static Future<Map<String, dynamic>> getLookById(String lookId) async {
    final uri = Uri.parse('${ApiRoutes.getUploadedLookById}/$lookId');
    final response = await http.get(
      uri,
      headers: await AuthApiService.getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['look'];
    } else {
      throw Exception('Failed to fetch look by ID');
    }
  }

  /// Delete a look by ID
  static Future<String> deleteLook(String lookId) async {
    final uri = Uri.parse('${ApiRoutes.deleteUploadedLook}/$lookId');

    final response = await http.delete(
      uri,
      headers: await AuthApiService.getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return json['message'];
    } else {
      throw Exception('Failed to delete look: ${response.body}');
    }
  }
}
