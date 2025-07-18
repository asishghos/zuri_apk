import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:testing2/services/DataSource/auth_api.dart';
import 'package:testing2/services/api_routes.dart';

/// API service class
class ProductApiServices {
  static Future<Map<String, dynamic>> toggleWishlistItem(
    Map<String, String> productData,
  ) async {
    final url = Uri.parse(ApiRoutes.addProductsWishList);

    try {
      final response = await http.post(
        url,
        headers: await AuthApiService.getHeaders(includeAuth: true),
        body: json.encode(productData),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': data['msg'], 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['msg'] ?? 'Something went wrong',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  /// Get all wishlist items
  static Future<Map<String, dynamic>> getWishlistItems() async {
    final url = Uri.parse(ApiRoutes.getProductsWishList);

    try {
      final response = await http.get(
        url,
        headers: await AuthApiService.getHeaders(includeAuth: true),
      );
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['msg'],
          'count': data['count'],
          'items': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['msg'] ?? 'Failed to load wishlist',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}
