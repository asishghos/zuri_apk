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
        Developer.log("✅ Image generate successfully");
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

  static Future<StyledOutfitResponse?> getStyleRecommender({
    required List<File> images,
    required String occasion,
    String? description,
  }) async {
    try {
      final uri = Uri.parse(ApiRoutes.getStyleRecommender);
      final request = http.MultipartRequest('POST', uri);
      final headers = await AuthApiService.getHeaders(includeAuth: true);
      if (headers.containsKey('Authorization')) {
        request.headers['Authorization'] = headers['Authorization']!;
      }
      // Add fields
      request.fields['occasion'] = occasion;
      if (description != null && description.trim().isNotEmpty) {
        request.fields['description'] = description;
      }

      // Add image files
      for (var imageFile in images) {
        final mimeType = lookupMimeType(imageFile.path);
        if (mimeType == null || !mimeType.contains('/')) {
          Developer.log("❌ Invalid MIME type for: ${imageFile.path}");
          continue;
        }
        final mimeParts = mimeType.split('/');
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            imageFile.path,
            contentType: MediaType(mimeParts[0], mimeParts[1]),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        Developer.log("✅ Image generate successfully");
        print(response.body.trim());
        return StyledOutfitResponse.fromJson(decoded);
      } else {
        Developer.log("❌ Error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      Developer.log("❌ Exception in recommendStyle: $e");
      return null;
    }
  }
}
