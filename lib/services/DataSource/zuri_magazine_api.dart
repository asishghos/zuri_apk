import 'dart:convert';
import 'dart:developer' as Developer;
import 'package:http/http.dart' as http;
import 'package:testing2/services/Class/zuri_magqazine_model.dart';
import 'package:testing2/services/api_routes.dart';

class ZuriMagazineApiService {
  // Get all categories
  static Future<ZuriCategoriesResponse> getAllCategoriesMagazine() async {
    final res = await http.get(Uri.parse(ApiRoutes.getAllCategoriesMagazine));
    Developer.log(res.body);
    if (res.statusCode == 200) {
      return ZuriCategoriesResponse.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to fetch categories');
    }
  }

  static Future<List<ZuriArticle>> getByCategoryMagazine(
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
          .map<ZuriArticle>((item) => ZuriArticle.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to fetch articles by category');
    }
  }

  // Get article by ID
  static Future<ZuriArticle> getByIdMagazine(String id) async {
    final res = await http.get(Uri.parse('${ApiRoutes.getByIdMagazine}/$id'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body)['data'];
      return ZuriArticle.fromJson(data);
    } else {
      throw Exception('Failed to fetch article');
    }
  }
}
