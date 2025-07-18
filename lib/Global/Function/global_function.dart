import 'dart:convert';
import 'dart:developer' as Developer;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;

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

  static String capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  static Future<List<Map<String, String>>> searchProductsByKeywords(
    List<String> keywords,
  ) async {
    final jsonStr = await rootBundle.loadString('assets/json/products.json');
    final jsonData = json.decode(jsonStr);

    List<Map<String, String>> matchedProducts = [];

    // Create a lowercase set of all input tokens (split by space)
    Set<String> inputTokens = keywords
        .expand((kw) => kw.toLowerCase().split(RegExp(r'\s+')))
        .toSet();

    // Developer.log('Input tokens: $inputTokens');

    for (final key in jsonData.keys) {
      Set<String> titleTokens = key.toLowerCase().split(RegExp(r'\s+')).toSet();

      int intersectionSize = inputTokens.intersection(titleTokens).length;

      // Developer.log('Checking key: "$key"');
      // Developer.log('titleTokens: $titleTokens');
      // Developer.log('intersectionSize: $intersectionSize');

      // If at least one token matches, add products from this key
      if (intersectionSize >= 1) {
        final products = jsonData[key] as List;

        for (final product in products) {
          matchedProducts.add({
            "title": product["title"] ?? "",
            "price": product["price"] ?? "",
            "platform": product["platform"] ?? "",
            "link": product["link"] ?? "",
            "image": product["image"] ?? "",
          });
        }
      }
    }

    matchedProducts.shuffle(Random());

    return matchedProducts;
  }

  static Future<List<String>> findKeywordsUserSpecific(
    String bodyShape,
    String underTone,
  ) async {
    final String jsonStr = await rootBundle.loadString(
      'assets/json/styling_keywords.json',
    );
    final List<dynamic> jsonData = json.decode(jsonStr);

    for (final entry in jsonData) {
      if ((entry['body'] as String).toLowerCase() == bodyShape.toLowerCase() &&
          (entry['undertone'] as String).toLowerCase() ==
              underTone.toLowerCase()) {
        final List<dynamic> keywords = entry['keywords'];
        return keywords.map((e) => e.toString()).toList();
      }
    }

    return []; // Return empty list if no match found
  }

  static String generateRandomId(int i, {int length = 12}) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(
      length,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();
  }
}
