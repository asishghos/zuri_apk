import 'dart:convert';
import 'dart:developer' as Developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart';
import 'package:testing2/services/Class/styling_model.dart';
import 'package:testing2/services/DataSource/auth_api.dart';
import 'package:testing2/services/api_routes.dart';

class GenerateLookService {
  static Future<GeneratedOccasionResponse?> generateLookForOccasion(
    String occasion,
  ) async {
    try {
      final uri = Uri.parse('${ApiRoutes.getStyledOutfits}?occasion=$occasion');

      final response = await http.post(
        uri,
        headers: await AuthApiService.getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return GeneratedOccasionResponse.fromJson(jsonData);
      } else {
        debugPrint("❌ Error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Exception in generateLookForOccasion: $e");
      return null;
    }
  }

  static Future<StyleRecommendationResponse?> uploadAndGetRecommendation({
    required List<File> imageFiles,
    required String occasion,
  }) async {
    try {
      final uri = Uri.parse(ApiRoutes.getStyleRecommender);

      final request = http.MultipartRequest('POST', uri);
      final headers = await AuthApiService.getHeaders(includeAuth: true);
      if (headers.containsKey('Authorization')) {
        request.headers['Authorization'] = headers['Authorization']!;
      }

      for (File file in imageFiles) {
        final mimeType = lookupMimeType(file.path);
        if (mimeType == null || !mimeType.contains('/')) {
          Developer.log("❌ Invalid MIME type for file: ${file.path}");
          return null;
        }
        final mimeParts = mimeType.split('/');

        final multipartFile = await http.MultipartFile.fromPath(
          'images', // field name in backend
          file.path,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
          // contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return StyleRecommendationResponse.fromJson(jsonData);
      } else {
        print("❌ Error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Exception: $e");
      return null;
    }
  }
}
