// // ignore_for_file: body_might_complete_normally_catch_error

// import 'dart:convert';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';

// class TempUserDataStore {
//   static final TempUserDataStore _instance = TempUserDataStore._internal();
//   factory TempUserDataStore() => _instance;
//   TempUserDataStore._internal();

//   String? _bodyShape;
//   String? _skinTone;
//   File? _imageFile;

//   /// Save any of the fields (strings or file, optional)
//   Future<void> save({
//     File? imageFile,
//     String? bodyShape,
//     String? skinTone,
//   }) async {
//     final tempDir = await getTemporaryDirectory();

//     String? imagePath;

//     if (imageFile != null) {
//       final savedImage = await imageFile.copy('${tempDir.path}/temp_image.png');
//       imagePath = savedImage.path;
//       _imageFile = savedImage;
//     }

//     if (bodyShape != null) _bodyShape = bodyShape;
//     if (skinTone != null) _skinTone = skinTone;

//     final jsonData = {
//       'bodyShape': _bodyShape,
//       'skinTone': _skinTone,
//       'imagePath': imagePath ?? _imageFile?.path,
//     };

//     final jsonFile = File('${tempDir.path}/temp_data.json');
//     await jsonFile.writeAsString(jsonEncode(jsonData));
//   }

//   /// Load whatever data is present (file or strings)
//   Future<bool> load() async {
//     final tempDir = await getTemporaryDirectory();
//     final jsonFile = File('${tempDir.path}/temp_data.json');

//     if (!jsonFile.existsSync()) return false;

//     final content = await jsonFile.readAsString();
//     final data = jsonDecode(content);

//     _bodyShape = data['bodyShape'];
//     _skinTone = data['skinTone'];

//     final imagePath = data['imagePath'];
//     if (imagePath != null && File(imagePath).existsSync()) {
//       _imageFile = File(imagePath);
//     } else {
//       _imageFile = null;
//     }

//     return true;
//   }

//   /// Getters (can return null)
//   String? get bodyShape => _bodyShape;
//   String? get skinTone => _skinTone;
//   File? get imageFile => _imageFile;

//   /// Clear stored temp data
//   Future<void> clear() async {
//     final tempDir = await getTemporaryDirectory();
//     await File('${tempDir.path}/temp_data.json').delete().catchError((_) {});
//     await File('${tempDir.path}/temp_image.png').delete().catchError((_) {});

//     _bodyShape = null;
//     _skinTone = null;
//     _imageFile = null;
//   }
// }

// /// 📄 TempUserDataStore
// ///
// /// This singleton class is used to temporarily store user-provided data
// /// (either an image file, two strings, or both) during the onboarding/auth
// /// flow of the app.
// ///
// /// ✅ Why use this:
// /// - To persist data like profile image and user details across screens (e.g., Splash → Signup → Login → Result)
// /// - Avoids passing large data (like File) through routes or state management
// /// - Stores data in the device's temporary directory
// ///
// /// 🧠 Notes:
// /// - Image is saved as a physical file in the temp directory (`temp_image.png`)
// /// - Strings are saved in a JSON file (`temp_data.json`)
// /// - Both are automatically loaded back with `.load()`
// /// - Everything is kept **in-memory** after loading for fast access
// ///
// /// 📦 Supported operations:
// /// - `save({ imageFile, text1, text2 })`: Save any or all fields
// /// - `load()`: Loads previously stored values (if present)
// /// - `clear()`: Deletes all stored temp data (image + json)
// ///
// /// 🔄 Use Case Example:
// /// ```dart
// /// await TempUserDataStore().save(
// ///   imageFile: pickedImageFile,
// ///   text1: 'username',
// ///   text2: 'location',
// /// );
// ///
// /// // Later (after login)
// /// await TempUserDataStore().load();
// /// File? file = TempUserDataStore().imageFile;
// /// String? name = TempUserDataStore().text1;
// /// String? location = TempUserDataStore().text2;
// /// ```
// ///
// /// 🚫 Data is not persistent and may be cleared by the system.
// /// Ideal for temporary use only within one app session.
import 'dart:convert';
import 'dart:io' show File; // For mobile only
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TempUserDataStore {
  static final TempUserDataStore _instance = TempUserDataStore._internal();
  factory TempUserDataStore() => _instance;
  TempUserDataStore._internal();

  String? _bodyShape;
  String? _skinTone;
  File? _imageFile;
  String? _imageBase64; // For Web

  Future<void> save({
    File? imageFile,
    String? bodyShape,
    String? skinTone,
    String? imageBase64, // For Web
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (kIsWeb && imageBase64 != null) {
      _imageBase64 = imageBase64;
      await prefs.setString('imageBase64', imageBase64);
    }

    if (!kIsWeb && imageFile != null) {
      final tempDir = await getTemporaryDirectory();
      final savedImage = await imageFile.copy('${tempDir.path}/temp_image.png');
      _imageFile = savedImage;
    }

    if (bodyShape != null) _bodyShape = bodyShape;
    if (skinTone != null) _skinTone = skinTone;

    await prefs.setString('bodyShape', _bodyShape ?? '');
    await prefs.setString('skinTone', _skinTone ?? '');
  }

  Future<bool> load() async {
    final prefs = await SharedPreferences.getInstance();

    _bodyShape = prefs.getString('bodyShape');
    _skinTone = prefs.getString('skinTone');

    if (kIsWeb) {
      _imageBase64 = prefs.getString('imageBase64');
    } else {
      final tempDir = await getTemporaryDirectory();
      final imagePath = '${tempDir.path}/temp_image.png';
      if (File(imagePath).existsSync()) {
        _imageFile = File(imagePath);
      }
    }

    return _bodyShape != null || _skinTone != null;
  }

  String? get bodyShape => _bodyShape;
  String? get skinTone => _skinTone;
  File? get imageFile => _imageFile;
  String? get imageBase64 => _imageBase64; // Use for displaying in web

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bodyShape');
    await prefs.remove('skinTone');
    await prefs.remove('imageBase64');

    if (!kIsWeb) {
      final tempDir = await getTemporaryDirectory();
      await File('${tempDir.path}/temp_image.png').delete().catchError((_) {});
    }

    _bodyShape = null;
    _skinTone = null;
    _imageFile = null;
    _imageBase64 = null;
  }
}
