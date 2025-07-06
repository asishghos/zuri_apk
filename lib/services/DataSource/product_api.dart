import 'dart:convert';
import 'dart:developer' as Developer;
import 'package:http/http.dart' as http;
import 'package:testing2/services/Class/product_model.dart';
import 'package:testing2/services/DataSource/auth_api.dart';
import 'package:testing2/services/api_routes.dart';

/// API service class
class ProductApiServices {
  static Future<List<ProductItem>> fetchProducts(List<String> keywords) async {
    final url = Uri.parse(ApiRoutes.product);

    try {
      final response = await http.post(
        url,
        headers: await AuthApiService.getHeaders(includeAuth: true),
        body: jsonEncode({
          'keywords': keywords.map((k) => [k]).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        Developer.log(data.toString());
        return data
            .map<ProductItem>(
              (item) => ProductItem.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to fetch products: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      Developer.log("API error: $e");
      throw Exception('Something went wrong. Please try again later.');
    }
  }
}
