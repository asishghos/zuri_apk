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
  static Future<OutfitAnalysisResponse?> generateLookForOccasion({
    required String occasion,
    String? description,
  }) async {
    try {
      final uri = Uri.parse(
        ApiRoutes.getStyledOutfits,
      ); // Remove query param from URL

      final response = await http.post(
        uri,
        headers: await AuthApiService.getHeaders(includeAuth: true)
          ..addAll({'Content-Type': 'application/json'}),
        body: json.encode({
          'occasion': occasion,
          'description':
              description ?? "No specific description", // Send dummy if null
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        Developer.log(jsonData.toString());
        Developer.log("✅ Image generate successfully");
        return OutfitAnalysisResponse.fromJson(jsonData);
      } else {
        debugPrint("❌ Error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Exception in generateLookForOccasion: $e");
      return null;
    }
  }

  static Future<OutfitAnalysisResponse?> getStyleRecommender({
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
        return OutfitAnalysisResponse.fromJson(decoded);
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
