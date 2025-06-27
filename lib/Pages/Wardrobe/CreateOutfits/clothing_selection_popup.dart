import 'dart:developer' as Developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/services/Class/digital_wardrobe_model.dart';
import 'package:testing2/services/DataSource/digital_wardrobe_api.dart';

class ClothingSelectionPopup extends StatefulWidget {
  @override
  _ClothingSelectionPopupState createState() => _ClothingSelectionPopupState();
}

class _ClothingSelectionPopupState extends State<ClothingSelectionPopup> {
  int? selectedIndex;
  List<GarmentItem> _garmentItems = [];
  bool _isLoadingGarments = false;
  String _errorMessage = '';

  // Image upload related
  File? _uploadedImage;
  bool _isUploadingImage = false;
  final ImagePicker _picker = ImagePicker();
  List<File> uploadedImages = []; // Assuming this exists in your context

  @override
  void initState() {
    super.initState();
    _loadGarments();
  }

  Future<void> _loadGarments() async {
    setState(() {
      _isLoadingGarments = true;
      _errorMessage = '';
    });

    try {
      _garmentItems = await _getGarments(category: 'Recent');
      setState(() {
        _isLoadingGarments = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingGarments = false;
        _errorMessage = 'Failed to load garments';
      });
      Developer.log("❌ Failed to load garments: $e");
    }
  }

  Future<List<GarmentItem>> _getGarments({required String category}) async {
    try {
      List<GarmentItem> garments =
          await WardrobeApiService.fetchGarmentsByCategory(category: category);
      for (var garment in garments) {
        Developer.log("🧥 ${garment.itemName} - ${garment.imageUrl}");
      }
      return garments;
    } catch (e) {
      Developer.log("❌ Failed to load garments: $e");
      throw e;
    }
  }

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
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.titleTextColor,
                  ),
                ),
                SizedBox(height: 20),
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
                              SizedBox(height: 8),
                              Text(
                                'Gallery',
                                style: GoogleFonts.libreFranklin(
                                  fontSize: 16,
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
                              SizedBox(height: 8),
                              Text(
                                'Camera',
                                style: GoogleFonts.libreFranklin(
                                  fontSize: 16,
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
                SizedBox(height: 20),
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
              backgroundColor: AppColors.error,
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
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }

      setState(() {
        _isUploadingImage = true;
      });

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _uploadedImage = File(pickedFile.path);
          selectedIndex = null;
        });
        setState(() {
          _isUploadingImage = false;
        });
      } else {
        setState(() {
          _isUploadingImage = false;
        });
      }
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });
      debugPrint('Error in _pickImage: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  bool get _canUpload {
    return selectedIndex != null || _uploadedImage != null;
  }

  void _handleUpload() {
    if (!_canUpload) return;
    dynamic result;
    if (selectedIndex != null) {
      final selectedGarment = _garmentItems[selectedIndex!];
      Developer.log("Selected garment: ${selectedGarment.itemName}");
      result = selectedGarment;
    } else if (_uploadedImage != null) {
      Developer.log("Uploaded image: ${_uploadedImage!.path}");
      result = _uploadedImage;
    }
    Navigator.pop(
      context,
      result,
    ); // Pass the selected garment or uploaded image
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 40),
            // Header
            Row(
              children: [
                Text(
                  'Recent',
                  style: GoogleFonts.libreFranklin(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.tune, size: 24, color: Colors.grey[600]),
                Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close, size: 24, color: AppColors.error),
                ),
              ],
            ),

            SizedBox(height: 8),

            // Subtitle
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose a top from your zuri closet or upload from gallery',
                style: GoogleFonts.libreFranklin(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Grid of clothing items
            _buildGarmentGrid(),

            const SizedBox(height: 20),

            // Upload button
            GlobalPinkButton(
              text: "Upload",
              onPressed: () {
                // _canUpload && !_isUploadingImage ? _handleUpload : null;
                _handleUpload();
              },
              backgroundColor: _canUpload && !_isUploadingImage
                  ? AppColors.textPrimary
                  : Color(0xFFE5E7EA),
              foregroundColor: _canUpload && !_isUploadingImage
                  ? Colors.white
                  : Color(0xFF9EA2AE),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGarmentGrid() {
    if (_isLoadingGarments) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Loading garments...',
                style: GoogleFonts.libreFranklin(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              SizedBox(height: 16),
              Text(
                _errorMessage,
                style: GoogleFonts.libreFranklin(
                  color: AppColors.error,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadGarments,
                child: Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: GridView.builder(
        physics: BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.8,
        ),
        itemCount: _garmentItems.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: _showPicker,
              child: Container(
                decoration: BoxDecoration(
                  color: _uploadedImage != null
                      ? AppColors.textPrimary.withOpacity(0.1)
                      : const Color(0xFF333333),
                  border: _uploadedImage != null
                      ? Border.all(color: AppColors.textPrimary, width: 2)
                      : null,
                ),
                child: _isUploadingImage
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      )
                    : _uploadedImage != null
                    ? ClipRRect(
                        child: Image.file(
                          _uploadedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, color: Colors.grey, size: 32),
                          SizedBox(height: 4),
                          Text(
                            "Gallery",
                            style: GoogleFonts.libreFranklin(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            );
          }

          final garmentIndex = index - 1;
          final garment = _garmentItems[garmentIndex];
          final isSelected = selectedIndex == garmentIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = isSelected ? null : garmentIndex;
                _uploadedImage =
                    null; // Clear uploaded image when selecting garment
              });
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? AppColors.textPrimary : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: garment.imageUrl.isNotEmpty
                    ? Image.network(
                        garment.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[100],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[100],
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey[400],
                                size: 30,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[100],
                        child: Center(
                          child: Icon(
                            Icons.image,
                            color: Colors.grey[400],
                            size: 30,
                          ),
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Keep your existing ClothingItem and ClothingOverlay classes
class ClothingItem {
  final int id;
  final String imageUrl;
  final String name;

  ClothingItem({required this.id, required this.imageUrl, required this.name});
}

class ClothingOverlay {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => ClothingSelectionPopup(),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
