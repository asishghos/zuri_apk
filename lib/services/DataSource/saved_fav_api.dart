import 'dart:convert';
import 'dart:developer' as Developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:testing2/Global/Function/global_function.dart';
import 'package:testing2/services/Class/saved_fav_model.dart';
import 'package:testing2/services/DataSource/auth_api.dart';
import 'package:testing2/services/api_routes.dart';

class SavedFavouritesService {
  // POST: Add to Saved Favourites
  static Future<SavedFavouriteResponse?> addToSavedFavourites({
    required String imageUrl,
    required String tag,
    required String occasion,
    required String description,
  }) async {
    final url = Uri.parse(ApiRoutes.addFavouriteSavedFavourites);
    // Convert base64 image to File
    final File imageFile = await GlobalFunction.urlToFile(imageUrl);

    final request = http.MultipartRequest('POST', url)
      ..headers.addAll(await AuthApiService.getHeaders(includeAuth: true))
      ..fields['tag'] = tag
      ..fields['occasion'] = occasion
      ..fields['description'] = description
      ..files.add(
        await http.MultipartFile.fromPath(
          'files',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = jsonDecode(response.body);
    Developer.log(data.toString());
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return SavedFavouriteResponse.fromJson(data);
    } else {
      return null;
    }
  }

  // GET: Get Saved Favourites
  static Future<FavouritesResponse?> getSavedFavourites() async {
    final url = Uri.parse(ApiRoutes.getFavouritesSavedFavourites);
    final response = await http.get(
      url,
      headers: await AuthApiService.getHeaders(includeAuth: true),
    );
    Developer.log(response.body);
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return FavouritesResponse.fromJson(data);
    } else {
      return null;
    }
  }

  // DELETE: Delete Saved Favourite
  static Future<Map<String, dynamic>> deleteSavedFavourite(
    String favouriteId,
  ) async {
    final url = Uri.parse(
      '${ApiRoutes.deleteFavouriteSavedFavourites}/$favouriteId',
    );

    final response = await http.delete(
      url,
      headers: await AuthApiService.getHeaders(includeAuth: true),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'success': true, 'msg': data['msg']};
    } else {
      return {'success': false, 'msg': data['msg'] ?? 'Unknown error'};
    }
  }
}
