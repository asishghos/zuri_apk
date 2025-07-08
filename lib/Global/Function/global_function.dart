import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:testing2/services/DataSource/product_api.dart';

class GlobalFunction {
  static Future<File> urlToFile(String imageUrl) async {
    // Get temporary directory of the device
    final Directory tempDir = await getTemporaryDirectory();

    // Create a unique filename based on the URL
    final String fileName = basename(imageUrl);

    // Create the full path for the file
    final File file = File('${tempDir.path}/$fileName');

    // Fetch image bytes from the network
    final http.Response response = await http.get(Uri.parse(imageUrl));

    // Write the bytes to the file
    await file.writeAsBytes(response.bodyBytes);

    return file;
  }

  static Future<File> base64ToFile(String base64Str) async {
    // Get temporary directory
    final Directory tempDir = await getTemporaryDirectory();

    // Decode base64 string to bytes
    final Uint8List bytes = base64Decode(base64Str);

    // Create a unique filename using current timestamp
    final String fileName =
        'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Create the file path
    final String filePath = '${tempDir.path}/$fileName';
    final File file = File(filePath);

    // Write the bytes to the file
    await file.writeAsBytes(bytes);

    return file;
  }

  Future<void> addWishList() async {
    final productData = {
      "productId": "123",
      "productTitle": "Stylish Shirt",
      "productImage": "https://img.com/shirt.png",
      "price": 999,
      "originalPrice": 1299,
      "discountPercent": 23,
      "platform": "Myntra",
      "rating": 4.5,
      "productUrl": "https://myntra.com/product/123",
    };
    try {
      final result = await ProductApiServices.toggleWishlistItem(productData);
      if (result['success']) {
        print(result['message']);
      } else {
        print('Error: ${result['message']}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  static String capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }
}
