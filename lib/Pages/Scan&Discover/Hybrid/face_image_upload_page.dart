import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/services/Class/result_class.dart';
import 'package:testing2/services/DataSource/style_analysis_api.dart';

class FaceImageUploadPage extends StatefulWidget {
  final String body_shape;
  const FaceImageUploadPage({Key? key, required this.body_shape})
    : super(key: key);

  @override
  State<FaceImageUploadPage> createState() => _FaceImageUploadPageState();
}

class _FaceImageUploadPageState extends State<FaceImageUploadPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        var status = await Permission.camera.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Camera permission denied'),
              backgroundColor: Color(0xFF8D6E63),
            ),
          );
          return;
        }
      } else if (source == ImageSource.gallery) {
        var status = await Permission.photos.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gallery permission denied'),
              backgroundColor: Color(0xFF8D6E63),
            ),
          );
          return;
        }
      }

      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEEEED),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(color: Color(0xFFFEEEED)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Header text
                  if (_imageFile == null) ...[
                    SizedBox(height: 20),
                    Text(
                      'Choose Your Photo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Select an image from your gallery or take a new photo',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Color(0xFF8D6E63)),
                    ),
                    SizedBox(height: 40),
                  ],
                  // Main content based on image selection state
                  Expanded(
                    child: Center(
                      child: _imageFile != null
                          ? _buildSelectedImageSection()
                          : _buildImageSelectionSection(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading) LoadingPage(),
        ],
      ),
    );
  }

  Widget _buildSelectedImageSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 400,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFCBA6A5).withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Image.file(_imageFile!, fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: () async {
            if (_imageFile == null) return;
            setState(() {
              _isLoading = true;
            });
            try {
              final result = await StyleAnalyzeApiService.hybridAanalyzeservice(
                _imageFile!,
                widget.body_shape,
              );
              print(result);
              if (!mounted) return;
              setState(() {
                _isLoading = false;
              });
              if (result != null) {
                context.goNamed("result1", extra: result);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ResultPage(result: result),
                //   ),
                // );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Image analysis failed.'),
                    backgroundColor: Color(0xFF8D6E63),
                  ),
                );
              }
            } catch (e) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Color(0xFF8D6E63),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 30),
            backgroundColor: Color(0xFFF8BBB9),
            foregroundColor: Color(0xFF5D4037),
            elevation: 8,
            shadowColor: Color(0xFFCBA6A5).withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_upload, size: 22),
              SizedBox(width: 10),
              Text(
                'Upload This Image',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        SizedBox(height: 15),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _imageFile = null;
            });
          },
          icon: Icon(Icons.refresh, color: Color(0xFF8D6E63)),
          label: Text(
            'Choose Different Image',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF8D6E63),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSelectionSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 180,
          width: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFFD6D5),
          ),
          child: Icon(Icons.image_outlined, size: 80, color: Color(0xFF8D6E63)),
        ),
        SizedBox(height: 40),
        Text(
          'No image selected',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF5D4037),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 60),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSourceButton(
              title: 'Camera',
              icon: Icons.camera_alt,
              onTap: () => _pickImage(ImageSource.camera),
            ),
            SizedBox(width: 20),
            _buildSourceButton(
              title: 'Gallery',
              icon: Icons.photo_library,
              onTap: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSourceButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFFF8BBB9),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFCBA6A5).withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, size: 32, color: Color(0xFF5D4037)),
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5D4037),
            ),
          ),
        ],
      ),
    );
  }
}
