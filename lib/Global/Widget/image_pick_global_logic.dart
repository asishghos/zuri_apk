import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<void> showImageSourcePicker({
    required BuildContext context,
    required Function(File imageFile) onValidImagePicked,
    required VoidCallback onInvalidImage,
    required VoidCallback onStartLoading,
    required VoidCallback onStopLoading,
  }) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(
                    context: context,
                    source: ImageSource.gallery,
                    onValidImagePicked: onValidImagePicked,
                    onInvalidImage: onInvalidImage,
                    onStartLoading: onStartLoading,
                    onStopLoading: onStopLoading,
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(
                    context: context,
                    source: ImageSource.camera,
                    onValidImagePicked: onValidImagePicked,
                    onInvalidImage: onInvalidImage,
                    onStartLoading: onStartLoading,
                    onStopLoading: onStopLoading,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage({
    required BuildContext context,
    required ImageSource source,
    required Function(File imageFile) onValidImagePicked,
    required VoidCallback onInvalidImage,
    required VoidCallback onStartLoading,
    required VoidCallback onStopLoading,
  }) async {
    try {
      if (source == ImageSource.camera &&
          !(await Permission.camera.request().isGranted)) {
        _showPermissionDenied(context, 'Camera');
        return;
      }

      if (source == ImageSource.gallery &&
          !(await Permission.photos.request().isGranted)) {
        _showPermissionDenied(context, 'Gallery');
        return;
      }

      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        onStartLoading();
        onStopLoading();
      }
    } catch (e) {
      onStopLoading();
      debugPrint("Error in _pickImage: $e");
    }
  }

  void _showPermissionDenied(BuildContext context, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type permission denied'),
        backgroundColor: Color(0xFF8D6E63),
      ),
    );
  }
}

// -----------------------Use It Anywhere (e.g., in a Widget)--------------------

// final _imagePickerService = ImagePickerService();

// void _handlePickImage() {
//   _imagePickerService.showImageSourcePicker(
//     context: context,
//     onStartLoading: () {
//       setState(() => _isLoading = true);
//     },
//     onStopLoading: () {
//       setState(() => _isLoading = false);
//     },
//     onValidImagePicked: (imageFile) {
//       _imageFile = imageFile;
//       context.goNamed('autoUpload');
//     },
//     onInvalidImage: () {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => GlobalDialogBox(
//           title: "Uh Oh!",
//           description:
//               "We can't see your FULL FAB self. Upload head-to-toe pic(s) so we can scan your shape like a pro. Pretty please?",
//           buttonText: "Upload Again",
//           onTap: () {
//             Navigator.of(context).pop();
//             _handlePickImage(); // Retry
//           },
//         ),
//       );
//     },
//   );
// }
