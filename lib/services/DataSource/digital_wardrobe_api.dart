import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:testing2/services/Class/digital_wardrobe_model.dart';
import 'package:testing2/services/DataSource/auth_api.dart';
import 'package:testing2/services/api_routes.dart';

class WardrobeApiService {
  // Add garments to wardrobe
  static Future<DigitalWardrobeResponse?> uploadGarments(
    List<File> imageFiles,
  ) async {
    final uri = Uri.parse(ApiRoutes.addGarments);
    final request = http.MultipartRequest('POST', uri);
    // Get the token from SharedPreferences using your helper method
    final headers = await AuthApiService.getHeaders(includeAuth: true);
    if (headers.containsKey('Authorization')) {
      request.headers['Authorization'] = headers['Authorization']!;
    }

    for (File imageFile in imageFiles) {
      final mimeType = lookupMimeType(imageFile.path);
      if (mimeType == null || !mimeType.contains('/')) {
        developer.log("❌ Invalid MIME type for file: ${imageFile.path}");
        return null;
      }

      final mimeParts = mimeType.split('/');
      final multipartFile = await http.MultipartFile.fromPath(
        'images', // should match backend's req.files
        imageFile.path,
        contentType: MediaType(mimeParts[0], mimeParts[1]),
        filename: basename(imageFile.path),
      );

      request.files.add(multipartFile);
    }

    try {
      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(resBody);
        return DigitalWardrobeResponse.fromJson(jsonResponse);
      } else {
        developer.log("❌ Upload failed: $resBody");
        return null;
      }
    } catch (e) {
      developer.log("❌ Exception during upload: $e");
      return null;
    }
  }

  static Future<CategoryUploadResult?> uploadGarmentsByCategory(
    List<File> imageFiles,
    String category,
  ) async {
    final uri = Uri.parse(
      '${ApiRoutes.addGarmentsByCategory}?category=$category',
    );

    final request = http.MultipartRequest('POST', uri);
    final headers = await AuthApiService.getHeaders(includeAuth: true);
    if (headers.containsKey('Authorization')) {
      request.headers['Authorization'] = headers['Authorization']!;
    }

    for (File image in imageFiles) {
      final mimeType = lookupMimeType(image.path);
      if (mimeType == null || !mimeType.contains('/')) {
        developer.log("❌ Invalid MIME type: ${image.path}");
        continue;
      }

      final parts = mimeType.split('/');
      final multipart = await http.MultipartFile.fromPath(
        'images',
        image.path,
        filename: basename(image.path),
        contentType: MediaType(parts[0], parts[1]),
      );

      request.files.add(multipart);
    }

    try {
      final streamedResponse = await request.send();
      final body = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final jsonData = json.decode(body);
        return CategoryUploadResult.fromJson(jsonData);
      } else {
        developer.log("❌ Upload failed: $body");
        return null;
      }
    } catch (e) {
      developer.log("❌ Exception: $e");
      return null;
    }
  }

  // Get garments by various filters (using query params instead of path params)
  static Future<List<GarmentItem>> fetchGarmentsByCategory({
    required String category,
  }) async {
    final uri = Uri.parse(
      '${ApiRoutes.getGarmentsByCategory}?category=$category',
    );

    final response = await http.get(
      uri,
      headers: await AuthApiService.getHeaders(includeAuth: true),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List results = jsonResponse['results'];

      return results.map((item) => GarmentItem.fromJson(item)).toList();
    } else {
      developer.log('❌ Failed to fetch garments: ${response.body}');
      throw Exception('Error: ${response.statusCode}');
    }
  }

  // Category counts
  static Future<CategoryCounts?> fetchCategoryCounts() async {
    final uri = Uri.parse(ApiRoutes.getCategoryCounts);

    try {
      final response = await http.get(
        uri,
        headers: await AuthApiService.getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return CategoryCounts.fromJson(jsonResponse);
      } else {
        developer.log("❌ Failed to fetch category counts: ${response.body}");
        return null;
      }
    } catch (e) {
      developer.log("❌ Exception during category count fetch: $e");
      return null;
    }
  }

  // Garment details
  static Future<GarmentDetails?> fetchGarmentDetails(String garmentId) async {
    final uri = Uri.parse('${ApiRoutes.getGarmentDetails}/$garmentId');

    try {
      final response = await http.get(
        uri,
        headers: await AuthApiService.getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return GarmentDetails.fromJson(jsonResponse['garmentDetails']);
      } else {
        developer.log("❌ Failed to fetch garment details: ${response.body}");
        return null;
      }
    } catch (e) {
      developer.log("❌ Exception while fetching garment details: $e");
      return null;
    }
  }

  //Deelete garment
  static Future<bool> deleteGarmentImage(String garmentId) async {
    final uri = Uri.parse('${ApiRoutes.deleteGarment}/$garmentId');
    try {
      final response = await http.delete(
        uri,
        headers: await AuthApiService.getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        developer.log("✅ Garment deleted successfully");
        return true;
      } else {
        developer.log("❌ Failed to delete garment: ${response.body}");
        return false;
      }
    } catch (e) {
      developer.log("❌ Exception during deleteGarmentImage: $e");
      return false;
    }
  }

  static Future<List<GarmentItem>> filterGarments({
    List<String>? category,
    List<String>? color,
    List<String>? fabric,
    List<String>? occasion,
    List<String>? season,
  }) async {
    final queryParams = {
      if (category != null && category.isNotEmpty)
        'category': category.join(','),
      if (color != null && color.isNotEmpty) 'color': color.join(','),
      if (fabric != null && fabric.isNotEmpty) 'fabric': fabric.join(','),
      if (occasion != null && occasion.isNotEmpty)
        'occasion': occasion.join(','),
      if (season != null && season.isNotEmpty) 'season': season.join(','),
    };

    final uri = Uri.parse(
      ApiRoutes.filterGarments,
    ).replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: await AuthApiService.getHeaders(includeAuth: true),
    );

    developer.log(
      "🔍 Filtering garments with params: ${response.body.toString()}",
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['results'];
      return data.map((e) => GarmentItem.fromJson(e)).toList();
    } else {
      developer.log("❌ Filter fetch failed: ${response.body}");
      throw Exception('Failed to filter garments');
    }
  }

  static Future<Map<String, dynamic>?> updateGarment({
    required String garmentId,
    required Map<String, dynamic> updatedFields,
  }) async {
    final url = Uri.parse('${ApiRoutes.updateGarment}/$garmentId');

    try {
      final response = await http.put(
        url,
        headers: await AuthApiService.getHeaders(includeAuth: true),
        body: jsonEncode(updatedFields),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Map<String, dynamic>.from(data['updated']);
      } else {
        developer.log("Update failed: ${response.body}");
        return null;
      }
    } catch (e) {
      developer.log("Error updating garment: $e");
      return null;
    }
  }
}
