import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TempUserDataStore {
  static final TempUserDataStore _instance = TempUserDataStore._internal();
  factory TempUserDataStore() => _instance;
  TempUserDataStore._internal();

  String? _bodyShape;
  String? _skinTone;
  File? _imageFile;

  /// Save any of the fields (strings or file, optional)
  Future<void> save({
    File? imageFile,
    String? bodyShape,
    String? skinTone,
  }) async {
    final tempDir = await getTemporaryDirectory();

    String? imagePath;

    if (imageFile != null) {
      final savedImage = await imageFile.copy('${tempDir.path}/temp_image.png');
      imagePath = savedImage.path;
      _imageFile = savedImage;
    }

    if (bodyShape != null) _bodyShape = bodyShape;
    if (skinTone != null) _skinTone = skinTone;

    final jsonData = {
      'bodyShape': _bodyShape,
      'skinTone': _skinTone,
      'imagePath': imagePath ?? _imageFile?.path,
    };

    final jsonFile = File('${tempDir.path}/temp_data.json');
    await jsonFile.writeAsString(jsonEncode(jsonData));
  }

  /// Load whatever data is present (file or strings)
  Future<bool> load() async {
    final tempDir = await getTemporaryDirectory();
    final jsonFile = File('${tempDir.path}/temp_data.json');

    if (!jsonFile.existsSync()) return false;

    final content = await jsonFile.readAsString();
    final data = jsonDecode(content);

    _bodyShape = data['bodyShape'];
    _skinTone = data['skinTone'];

    final imagePath = data['imagePath'];
    if (imagePath != null && File(imagePath).existsSync()) {
      _imageFile = File(imagePath);
    } else {
      _imageFile = null;
    }

    return true;
  }

  /// Getters (can return null)
  String? get bodyShape => _bodyShape;
  String? get skinTone => _skinTone;
  File? get imageFile => _imageFile;

  /// Clear stored temp data
  Future<void> clear() async {
    final tempDir = await getTemporaryDirectory();
    await File('${tempDir.path}/temp_data.json').delete().catchError((_) {});
    await File('${tempDir.path}/temp_image.png').delete().catchError((_) {});

    _bodyShape = null;
    _skinTone = null;
    _imageFile = null;
  }
}

/// 📄 TempUserDataStore
///
/// This singleton class is used to temporarily store user-provided data
/// (either an image file, two strings, or both) during the onboarding/auth
/// flow of the app.
///
/// ✅ Why use this:
/// - To persist data like profile image and user details across screens (e.g., Splash → Signup → Login → Result)
/// - Avoids passing large data (like File) through routes or state management
/// - Stores data in the device's temporary directory
///
/// 🧠 Notes:
/// - Image is saved as a physical file in the temp directory (`temp_image.png`)
/// - Strings are saved in a JSON file (`temp_data.json`)
/// - Both are automatically loaded back with `.load()`
/// - Everything is kept **in-memory** after loading for fast access
///
/// 📦 Supported operations:
/// - `save({ imageFile, text1, text2 })`: Save any or all fields
/// - `load()`: Loads previously stored values (if present)
/// - `clear()`: Deletes all stored temp data (image + json)
///
/// 🔄 Use Case Example:
/// ```dart
/// await TempUserDataStore().save(
///   imageFile: pickedImageFile,
///   text1: 'username',
///   text2: 'location',
/// );
///
/// // Later (after login)
/// await TempUserDataStore().load();
/// File? file = TempUserDataStore().imageFile;
/// String? name = TempUserDataStore().text1;
/// String? location = TempUserDataStore().text2;
/// ```
///
/// 🚫 Data is not persistent and may be cleared by the system.
/// Ideal for temporary use only within one app session.
