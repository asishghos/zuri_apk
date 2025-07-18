import 'dart:convert';
import 'dart:io';
import 'dart:developer' as Developer;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:testing2/services/Class/fullbody_check_model.dart';
import 'package:testing2/services/api_routes.dart';

class FullbodyImageCheckApiServices {
  static Future<ImageCheckClass?> fullbodyImageCheckApiServices(
    File imageFile,
  ) async {
    Developer.log("🔍 Starting generateImageService...");
    try {
      final uri = Uri.parse(ApiRoutes.imageCheck);
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

      Developer.log("📤 Sending request to generate Image API...");
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      Developer.log("📥 Response received: $responseBody");

      if (response.statusCode == 200) {
        try {
          final decoded = jsonDecode(responseBody);
          Developer.log("✅ Decoded JSON successfully.");
          return ImageCheckClass.fromJson(decoded);
        } catch (jsonError) {
          Developer.log("❌ JSON decoding error: $jsonError");
          return null;
        }
      } else {
        Developer.log(
          "❗Server responded with error ${response.statusCode}: $responseBody",
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
