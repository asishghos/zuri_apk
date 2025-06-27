import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:testing2/services/Class/product_model.dart';
import 'package:testing2/services/api_routes.dart';

class ProductApiService {
  static Future<List<ProductClass>?> productAPIService(
    List<List<String>> data,
  ) async {
    try {
      final uri = Uri.parse(ApiRoutes.product);

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'keywords': data}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // Expecting a List of product maps
        return decoded
            .map<ProductClass>((item) => ProductClass.fromJson(item))
            .toList();
      } else {
        print('Server error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('API error: $e');
      return null;
    }
  }
}
