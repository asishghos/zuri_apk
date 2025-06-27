import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

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
}
