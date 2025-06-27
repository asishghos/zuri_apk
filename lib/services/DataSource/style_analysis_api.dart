import 'dart:convert';
import 'dart:io';
import 'dart:developer' as Developer;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:testing2/services/Class/style_analyze_model.dart';
import 'package:testing2/services/DataSource/auth_api.dart';
import 'package:testing2/services/api_routes.dart';

class StyleAnalyzeApiService {
  static Future<StyleAnalyzeClass?> autoAanalyzeservice(File imageFile) async {
    Developer.log("Starting autoAanalyzeservice...");
    try {
      final uri = Uri.parse(ApiRoutes.autoAnalyze);
      Developer.log("API URL: $uri");

      final mimeType = lookupMimeType(imageFile.path);
      final mimeParts = mimeType?.split('/');
      Developer.log("MIME type: $mimeType");

      var request = http.MultipartRequest('POST', uri);
      final headers = await AuthApiService.getHeaders(includeAuth: true);
      if (headers.containsKey('Authorization')) {
        request.headers['Authorization'] = headers['Authorization']!;
      }
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: mimeParts != null
              ? MediaType(mimeParts[0], mimeParts[1])
              : null,
        ),
      );

      Developer.log("Sending request to autoAnalyze...");
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      Developer.log("Response received: $responseBody");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(responseBody);
        Developer.log("Decoded JSON: $decoded");
        return StyleAnalyzeClass.fromJson(decoded);
      } else {
        Developer.log(
          'AutoAnalyze Server error ${response.statusCode}: $responseBody',
        );
        return null;
      }
    } catch (e) {
      Developer.log('AutoAnalyze API error: $e');
      return null;
    }
  }

  static Future<StyleAnalyzeClass?> manualAanalyzeservice(
    String body_shape,
    String skin_tone,
  ) async {
    Developer.log("Starting manualAanalyzeservice...");
    try {
      final uri = Uri.parse(ApiRoutes.manualAnalyze);
      Developer.log("API URL: $uri");
      Developer.log(
        "Payload: body_shape = $body_shape, skin_tone = $skin_tone",
      );

      final response = await http.post(
        uri,
        headers: await AuthApiService.getHeaders(includeAuth: true),
        body: jsonEncode({"body_shape": body_shape, "skin_tone": skin_tone}),
      );

      Developer.log("Response status: ${response.statusCode}");
      Developer.log("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        Developer.log("Decoded JSON: $decoded");
        return StyleAnalyzeClass.fromJson(decoded);
      } else {
        Developer.log(
          'ManualAnalyze Server error ${response.statusCode}: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      Developer.log('ManualAnalyze API error: $e');
      return null;
    }
  }

  static Future<StyleAnalyzeClass?> hybridAanalyzeservice(
    File imageFile,
    String bodyShape,
  ) async {
    Developer.log("🔍 Starting hybridAanalyzeservice...");

    try {
      final uri = Uri.parse(ApiRoutes.autoAnalyze);
      Developer.log("🌐 API URL: $uri");

      final mimeType = lookupMimeType(imageFile.path);
      if (mimeType == null || !mimeType.contains('/')) {
        Developer.log("❌ Invalid MIME type for file: ${imageFile.path}");
        return null;
      }

      final mimeParts = mimeType.split('/');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath(
          "image",
          imageFile.path,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        ),
      );

      request.fields["body_shape"] = bodyShape;
      Developer.log("📦 Added body_shape field: $bodyShape");

      Developer.log("📤 Sending request to hybrid autoAnalyze...");
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      Developer.log("📥 Response received: $responseBody");

      if (response.statusCode == 200) {
        try {
          final decoded = jsonDecode(responseBody);
          Developer.log("✅ Decoded JSON successfully.");
          return StyleAnalyzeClass.fromJson(decoded);
        } catch (jsonError) {
          Developer.log("❌ JSON decoding error: $jsonError");
          return null;
        }
      } else {
        Developer.log(
          "❗ Server responded with error ${response.statusCode}: $responseBody",
        );
        return null;
      }
    } catch (e, stacktrace) {
      Developer.log("❌ Exception during hybridAnalyze API call: $e");
      Developer.log("🪵 Stacktrace: $stacktrace");
      return null;
    }
  }
}
