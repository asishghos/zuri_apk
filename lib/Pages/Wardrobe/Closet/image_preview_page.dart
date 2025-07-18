// preview_page.dart
import 'dart:developer' as Developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/services/DataSource/digital_wardrobe_api.dart';

class ImagePreviewInwardrobePgae extends StatefulWidget {
  final List<AssetEntity> selectedImages;
  final String? fromPage;

  const ImagePreviewInwardrobePgae({
    Key? key,
    required this.selectedImages,
    this.fromPage,
  }) : super(key: key);

  @override
  State<ImagePreviewInwardrobePgae> createState() =>
      _ImagePreviewInwardrobePgaeState();
}

class _ImagePreviewInwardrobePgaeState
    extends State<ImagePreviewInwardrobePgae> {
  List<AssetEntity> _images = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.selectedImages);
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _addMoreImages() {
    Navigator.pop(context);
  }

  Future<List<File>> _convertAssetEntitiesToFiles(
    List<AssetEntity> assets,
  ) async {
    final files = <File>[];
    for (final asset in assets) {
      final file = await asset.file;
      if (file != null) files.add(file);
    }
    return files;
  }

  void _uploadImages({required List<File> selectedImages}) async {
    setState(() => _isLoading = true); // Show loader

    try {
      final result = await WardrobeApiService.uploadGarments(selectedImages);
      Developer.log("✅ ${result?.message ?? 'Upload successful'}");
      Developer.log(
        "Processed: ${result?.processed}, Skipped: ${result?.skipped}",
      );

      if (!mounted) return;
      context.pop();
      context.goNamed("myWardrobe");
      showSuccessSnackBar(context, "Images uploaded successfully");
    } catch (e) {
      Developer.log("❌ Upload failed: $e");
      if (mounted) {
        showErrorSnackBar(context, "Upload failed. Please try again.");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false); // Hide loader
    }
  }

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: AppColors.titleTextColor,
          ),
        ),
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Preview",
                style: GoogleFonts.libreFranklin(
                  color: AppColors.titleTextColor,
                  fontSize: MediaQuery.of(context).textScaler.scale(18),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _addMoreImages,
            child: Text(
              'Add More  ',
              style: GoogleFonts.libreFranklin(
                color: AppColors.textPrimary,
                fontSize: MediaQuery.of(context).textScaler.scale(14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? LoadingPage()
          : Container(
              padding: EdgeInsets.all(20),
              child: Stack(
                children: [
                  // Images Grid
                  Expanded(
                    child: _images.isEmpty
                        ? Center(
                            child: Text(
                              'No images selected',
                              style: GoogleFonts.libreFranklin(
                                color: Colors.grey,
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(16),
                              ),
                            ),
                          )
                        : GridView.builder(
                            // padding: const EdgeInsets.all(20),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                  childAspectRatio: 0.9,
                                ),
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              final asset = _images[index];

                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xFF9EA2AE)),
                                ),
                                child: ClipRRect(
                                  child: Stack(
                                    children: [
                                      // Image
                                      AssetEntityImage(
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        asset: asset,
                                      ),

                                      // Remove button
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () => _removeImage(index),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(
                                              Icons.close,
                                              size: 10,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  // SizedBox(height: MediaQuery.of(context).size.height * 0.022883295), // Add spacing between grid and button
                  // Save Button at bottom
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: GlobalPinkButton(
                          text: "Save",
                          // onPressed
                          onPressed: () async {
                            final selectedImages =
                                await _convertAssetEntitiesToFiles(_images);
                            if (selectedImages.isNotEmpty) {
                              _uploadImages(selectedImages: selectedImages);
                            } else {
                              Developer.log("❌ No valid images to upload");
                            }
                          },
                        ),
                      ),
                      SizedBox(height: dh * 0.01),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

// Custom widget for displaying asset images with better error handling
class AssetEntityImage extends StatelessWidget {
  final AssetEntity asset;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AssetEntityImage({
    Key? key,
    required this.asset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: asset.file,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: MediaQuery.of(context).size.width * 0.004975124,
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            child: const Icon(Icons.error_outline, color: Colors.grey),
          );
        }

        return Image.file(
          snapshot.data!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        );
      },
    );
  }
}
