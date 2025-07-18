import 'dart:developer' as Developer;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/Global/Widget/global_dialogbox.dart';
import 'package:testing2/services/DataSource/fullbody_check_api.dart';
import 'package:testing2/services/Temp/TempUserDataStore.dart';

class AutoImageUploadPage extends StatefulWidget {
  final File file;
  AutoImageUploadPage({Key? key, required this.file}) : super(key: key);

  @override
  State<AutoImageUploadPage> createState() => _AutoImageUploadPageState();
}

class _AutoImageUploadPageState extends State<AutoImageUploadPage> {
  List<File> uploadedImages = [];
  final ImagePicker _picker = ImagePicker();
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initPrefs();
    // Add the required file to uploadedImages when the page initializes
    uploadedImages.add(widget.file);
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                SizedBox(height: 35),
                Container(child: _buildPhotoGrid()),
                const Spacer(),
                Text(
                  "More pics= Hotter tips 🔥",
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(16),
                    fontWeight: FontWeight.w600,
                    color: AppColors.titleTextColor,
                  ),
                ),
                SizedBox(height: 35),
                _buildUploadButton(),
                SizedBox(height: 25),
                _buildRevealButton(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.0343249,
                ),
              ],
            ),
          ),
          if (_isLoading) LoadingPage(),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    switch (uploadedImages.length) {
      case 0:
        return _buildEmptyState();
      case 1:
        return _buildSingleImageLayout();
      case 2:
        return _buildTwoImageLayout();
      case 3:
        return _buildThreeImageLayout();
      default:
        return _buildThreeImageLayout();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: _buildPhotoPlaceholder(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.5,
        onTap: _pickAndCheckImage,
      ),
    );
  }

  Widget _buildSingleImageLayout() {
    return Center(
      child: _buildImageContainer(
        image: uploadedImages[0],
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.5,
        index: 0,
      ),
    );
  }

  Widget _buildTwoImageLayout() {
    return Row(
      children: [
        Expanded(
          child: _buildImageContainer(
            image: uploadedImages[0],
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.5,
            index: 0,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: _buildImageContainer(
            image: uploadedImages[1],
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.5,
            index: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildThreeImageLayout() {
    return Row(
      children: [
        Expanded(
          child: _buildImageContainer(
            image: uploadedImages[0],
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.5,
            index: 0,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: _buildImageContainer(
            image: uploadedImages[1],
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.5,
            index: 1,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: _buildImageContainer(
            image: uploadedImages[2],
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.5,
            index: 2,
          ),
        ),
      ],
    );
  }

  // edit delete full and conatiner edit --- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  Widget _buildImageContainer({
    required File image,
    required double width,
    required double height,
    required int index,
  }) {
    return GestureDetector(
      onTap: () => _showImagePreview(image, index),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(image: FileImage(image), fit: BoxFit.cover),
        ),
        child: Stack(
          children: [
            // Top right corner button for full view
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => _showImagePreview(image, index),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(
                    Icons.fullscreen,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            // Bottom action buttons
            Positioned(
              bottom: 10,
              right: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _cropImage(image, index),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder({
    required double width,
    required double height,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.pink,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            Icons.add_photo_alternate_outlined,
            size: 50,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    bool isDisabled = uploadedImages.length >= 3;
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.06407322,
      child: ElevatedButton(
        onPressed: isDisabled ? null : _pickAndCheckImage,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconlyLight.upload,
              size: 20,
              color: isDisabled ? Colors.grey[600] : Colors.white,
            ),
            SizedBox(width: 16),
            Text(
              "Upload More",
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(16),
                fontWeight: FontWeight.w600,
                color: isDisabled ? Colors.grey[600] : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevealButton() {
    // bool hasPhotos = uploadedImages.isNotEmpty;
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.06407322,
      child: OutlinedButton(
        onPressed: () async {
          await TempUserDataStore().save(imageFile: uploadedImages[0]);
          context.goNamed('signup');
          // setState(() {
          //   _isLoading = true;
          // });
          // try {
          // final result = await StyleAnalyzeApiService.autoAanalyzeservice(
          //   uploadedImages[0],
          // );
          //   await prefs.setString(
          //     "bodyShape",
          //     result!.bodyShapeResult?.bodyShape ?? '',
          //   );
          //   await prefs.setString(
          //     "skinTone",
          //     result.bodyShapeResult?.skinTone ?? '',
          //   );
          //   Developer.log(result.toString());
          //   if (!mounted) return;
          //   setState(() {
          //     _isLoading = false;
          //   });
          //   context.goNamed('signup');
          //   // context.goNamed("styleAnalyze", extra: result);
          // } catch (e) {
          //   setState(() {
          //     _isLoading = false;
          //   });
          //   showErrorSnackBar(context, 'Error: $e');
          // }
        },

        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Color(0xFFDC4C72),
            width: MediaQuery.of(context).size.width * 0.004975124,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Text(
          "Reveal my best look, Already!",
          style: GoogleFonts.libreFranklin(
            fontSize: MediaQuery.of(context).textScaler.scale(18),
            fontWeight: FontWeight.w600,
            color: Color(0xFFDC4C72),
          ),
        ),
      ),
    );
  }

  File? _imageFile;
  bool _isLoading = false;

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Image Source',
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(18),
                    fontWeight: FontWeight.w600,
                    color: AppColors.titleTextColor,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.022883295,
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          _pickImage(ImageSource.gallery);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.photo_library,
                                size: 40,
                                color: AppColors.textPrimary,
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height *
                                    0.009153318,
                              ),
                              Text(
                                'Gallery',
                                style: GoogleFonts.libreFranklin(
                                  fontSize: MediaQuery.of(
                                    context,
                                  ).textScaler.scale(16),
                                  color: AppColors.titleTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          _pickImage(ImageSource.camera);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: AppColors.textPrimary,
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height *
                                    0.009153318,
                              ),
                              Text(
                                'Camera',
                                style: GoogleFonts.libreFranklin(
                                  fontSize: MediaQuery.of(
                                    context,
                                  ).textScaler.scale(16),
                                  color: AppColors.titleTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.022883295,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request permissions
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
          _isLoading = true;
          _imageFile = File(pickedFile.path);
        });

        final response =
            await FullbodyImageCheckApiServices.fullbodyImageCheckApiServices(
              _imageFile!,
            );
        Developer.log(response.toString());
        setState(() {
          _isLoading = false;
        });

        if (response != null && response.isFullBody) {
          setState(() {
            uploadedImages.add(_imageFile!);
          });
        } else {
          showDialog(
            context: context,
            barrierDismissible: false, // Prevents closing on tap outside
            builder: (BuildContext context) {
              return GlobalDialogBox(
                needCancleButton: true,
                buttonNeed: true,
                title: "Uh Oh!",
                description:
                    "We can't see your FULL FAB self. Upload head-to-toe pic(s) so we can scan your shape like a pro. Pretty please?",
                buttonText: "Upload Again",
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndCheckImage();
                },
              );
            },
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Developer.log('Error in _pickImage: $e');
    }
  }

  Future<void> _pickAndCheckImage() async {
    _showPicker();
  }

  Future<void> _cropImage(File imageFile, int index) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(toolbarTitle: 'Crop Image'),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        uploadedImages[index] = File(croppedFile.path);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      uploadedImages.removeAt(index);
    });
  }

  void _showImagePreview(File image, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePreviewPage(
          image: image,
          onCrop: () => _cropImage(image, index),
          onDelete: () {
            Navigator.pop(context);
            _removeImage(index);
          },
        ),
      ),
    );
  }
}

class ImagePreviewPage extends StatelessWidget {
  final File image;
  final VoidCallback onCrop;
  final VoidCallback onDelete;

  const ImagePreviewPage({
    Key? key,
    required this.image,
    required this.onCrop,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: onCrop,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: onDelete,
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(child: Image.file(image, fit: BoxFit.contain)),
      ),
    );
  }
}
