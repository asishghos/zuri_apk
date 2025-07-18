import 'dart:convert';
import 'dart:developer' as Developer;
import 'package:http/http.dart' as http;
import 'package:testing2/services/Class/zuri_magqazine_model.dart';
import 'package:testing2/services/DataSource/auth_api.dart';
import 'package:testing2/services/api_routes.dart';

class ZuriMagazineApiService {
  // Get all categories
  static Future<ZuriCategoriesResponse> getAllCategories() async {
    final res = await http.get(Uri.parse(ApiRoutes.getAllCategories));
    Developer.log(res.body);
    if (res.statusCode == 200) {
      return ZuriCategoriesResponse.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to fetch categories');
    }
  }

  static Future<List<ZuriMagazine>> allMagazine() async {
    final uri = Uri.parse(ApiRoutes.allMagazine);
    final result = await http.get(uri);
    if (result.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(result.body);
      final List<dynamic> data = json['data'];
      return data
          .map<ZuriMagazine>((item) => ZuriMagazine.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to fetch articles by category');
    }
  }

  static Future<List<ZuriMagazine>> getByCategoryMagazine(
    String category,
  ) async {
    final uri = Uri.parse(
      '${ApiRoutes.getByCategoryMagazine}?category=${Uri.encodeComponent(category)}',
    );

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(res.body);
      final List<dynamic> data = json['data'];
      return data
          .map<ZuriMagazine>((item) => ZuriMagazine.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to fetch articles by category');
    }
  }

  // Get article by ID
  static Future<ZuriMagazine> getByIdMagazine(String id) async {
    final res = await http.get(Uri.parse('${ApiRoutes.getByIdMagazine}/$id'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body)['data'];
      return ZuriMagazine.fromJson(data);
    } else {
      throw Exception('Failed to fetch article');
    }
  }

  static Future<List<ZuriMagazine>> getAllBookmarkedArticles() async {
    final url = Uri.parse(ApiRoutes.getBookmarksMagazine);

    try {
      final response = await http.get(
        url,
        headers: await AuthApiService.getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> articles = jsonData['data'];
        return articles
            .map<ZuriMagazine>((item) => ZuriMagazine.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load bookmarks (${response.statusCode})');
      }
    } catch (e) {
      print('getAllBookmarkedArticles error: $e');
      rethrow;
    }
  }

  static Future<String> toggleBookmark(String magazineId) async {
    final url = Uri.parse(
      ('${ApiRoutes.toggleBookmarkMagazine}/${magazineId}'),
    );

    try {
      final response = await http.post(
        url,
        headers: await AuthApiService.getHeaders(includeAuth: true),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return jsonData['msg'] ?? 'Bookmark toggled';
      } else {
        throw Exception('Failed to toggle bookmark (${response.statusCode})');
      }
    } catch (e) {
      print('toggleBookmark error: $e');
      throw Exception('Could not toggle bookmark');
    }
  }
}
