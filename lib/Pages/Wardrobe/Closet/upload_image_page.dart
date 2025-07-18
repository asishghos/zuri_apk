// add_new_item_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Pages/Wardrobe/Closet/guidelines_page.dart';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:testing2/Pages/Wardrobe/Closet/image_preview_page.dart';

class UploadInwardrobePage extends StatefulWidget {
  final String? fromPage;
  const UploadInwardrobePage({Key? key, this.fromPage}) : super(key: key);

  @override
  State<UploadInwardrobePage> createState() => _UploadInwardrobePageState();
}

class _UploadInwardrobePageState extends State<UploadInwardrobePage> {
  List<AssetEntity> _selectedImages = [];
  List<AssetEntity> _mediaList = [];
  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _currentAlbum;
  int _currentPreviewIndex = 0;
  bool _isLoading = true;
  bool _hasPermission = false;
  String _errorMessage = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadMedia();
  }

  Future<void> _requestPermissionAndLoadMedia() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      _hasPermission = ps.isAuth || ps.hasAccess;

      if (!_hasPermission) {
        // Optional: Handle limited access (iOS) if needed
        setState(() {
          _errorMessage =
              'Photo access permission is required to view gallery.';
          _isLoading = false;
        });
        PhotoManager.openSetting(); // Prompt user to manually enable permission
        return;
      }

      await _loadAlbums();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading gallery: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAlbums() async {
    try {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true, // Start with "Recent" album only
      );

      if (albums.isNotEmpty) {
        setState(() {
          _albums = albums;
          _currentAlbum = albums.first;
        });
        await _loadMedia();
      } else {
        setState(() {
          _errorMessage = 'No albums found';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading albums: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadMedia() async {
    if (_currentAlbum != null) {
      try {
        // Use cache to avoid refetching already loaded assets
        final int totalAssets = await _currentAlbum!.assetCountAsync;

        // If already loaded, reuse _mediaList
        if (_mediaList.isNotEmpty && _mediaList.length == totalAssets) {
          // Already cached, no need to fetch again
          return;
        }

        final List<AssetEntity> media = await _currentAlbum!.getAssetListRange(
          start: 0,
          end: totalAssets,
        );
        setState(() {
          _mediaList = media;
        });
        print('Loaded ${media.length} images'); // Debug print
      } catch (e) {
        setState(() {
          _errorMessage = 'Error loading media: $e';
        });
        print('Error loading media: $e'); // Debug print
      }
    }
  }

  void _toggleImageSelection(AssetEntity asset) {
    setState(() {
      if (_selectedImages.contains(asset)) {
        _selectedImages.remove(asset);
        if (_currentPreviewIndex >= _selectedImages.length &&
            _selectedImages.isNotEmpty) {
          _currentPreviewIndex = _selectedImages.length - 1;
        }
      } else {
        _selectedImages.add(asset);
        _currentPreviewIndex = _selectedImages.length - 1;
      }
    });
  }

  int _getSelectionNumber(AssetEntity asset) {
    return _selectedImages.indexOf(asset) + 1;
  }

  Future<void> _openCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo != null) {
        // Refresh media list after taking photo
        await Future.delayed(const Duration(milliseconds: 500));
        await _loadMedia();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening camera: $e')));
    }
  }

  Future<void> _loadAllAlbums() async {
    try {
      final List<AssetPathEntity> allAlbums =
          await PhotoManager.getAssetPathList(
            type: RequestType.image,
            onlyAll: false,
          );
      setState(() {
        _albums = allAlbums;
      });
    } catch (e) {
      print('Error loading all albums: $e');
    }
  }

  void _showAlbumSelector() async {
    if (_albums.length <= 1) {
      await _loadAllAlbums();
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF9FAFB),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _albums
                .map(
                  (album) => ListTile(
                    title: FutureBuilder<int>(
                      future: album.assetCountAsync,
                      builder: (context, snapshot) => Text(
                        '${album.name} (${snapshot.data ?? 0})',
                        style: GoogleFonts.libreFranklin(
                          color: AppColors.titleTextColor,
                          fontSize: MediaQuery.of(context).textScaler.scale(16),
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _currentAlbum = album;
                      });
                      _loadMedia();
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Fixed Header Section
              Container(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (widget.fromPage == 'fromAllItems') {
                              context.goNamed('allItemsWardrobe', extra: 0);
                            } else if (widget.fromPage ==
                                'fromrecentCategory') {
                              context.goNamed('allItemsWardrobe', extra: 1);
                            } else if (widget.fromPage == 'fromtopsCategory') {
                              context.goNamed('allItemsWardrobe', extra: 2);
                            } else if (widget.fromPage ==
                                'frombottomsCategory') {
                              context.goNamed('allItemsWardrobe', extra: 3);
                            } else if (widget.fromPage ==
                                'fromethnicCategory') {
                              context.goNamed('allItemsWardrobe', extra: 4);
                            } else if (widget.fromPage ==
                                'fromdressesCategory') {
                              context.goNamed('allItemsWardrobe', extra: 5);
                            } else if (widget.fromPage ==
                                'fromcoordsetCategory') {
                              context.goNamed('allItemsWardrobe', extra: 6);
                            } else if (widget.fromPage ==
                                'fromswimwearCategory') {
                              context.goNamed('allItemsWardrobe', extra: 7);
                            } else if (widget.fromPage ==
                                'fromfootwearCategory') {
                              context.goNamed('allItemsWardrobe', extra: 8);
                            } else if (widget.fromPage ==
                                'fromaccessoriesCategory') {
                              context.goNamed('allItemsWardrobe', extra: 9);
                            } else {
                              context.goNamed('myWardrobe');
                            }
                          },
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowLeft01,
                            color: AppColors.titleTextColor,
                          ),
                        ),
                        SizedBox(width: dw * 0.02),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "Add New Item",
                                style: GoogleFonts.libreFranklin(
                                  color: AppColors.titleTextColor,
                                  fontSize: MediaQuery.of(
                                    context,
                                  ).textScaler.scale(18),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GuidelinesPage(),
                              ),
                            );
                          },
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedInformationCircle,
                            color: AppColors.titleTextColor,
                            size: 22,
                          ),
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: _selectedImages.isEmpty
                              ? null
                              : () {
                                  // Here I Not using GoRouter -- <<<<<<<<<< Navigator.push >>>>>>>>>
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ImagePreviewInwardrobePgae(
                                            selectedImages: _selectedImages,
                                            fromPage: widget.fromPage,
                                          ),
                                    ),
                                  );
                                },
                          child: Text(
                            'Preview',
                            style: GoogleFonts.libreFranklin(
                              color: _selectedImages.isEmpty
                                  ? AppColors.subTitleTextColor
                                  : AppColors.textPrimary,
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(14),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                color: Colors.white,
                child: _selectedImages.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: dh * 0.1,
                              color: Colors.transparent,
                            ),
                            Text(
                              'Add Photos from your phone \non Zuri',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.libreFranklin(
                                color: AppColors.titleTextColor,
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(18),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Hey, babe. This closet is about to glow-up! \nUpload your outfit pics, and let me serve\n you looks hotter than your morning coffee.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.libreFranklin(
                                color: AppColors.subTitleTextColor,
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(14),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          Center(
                            child: FutureBuilder<File?>(
                              future:
                                  _selectedImages[_currentPreviewIndex].file,
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  return Image.file(
                                    snapshot.data!,
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    height: dh * 0.56,
                                  );
                                }
                                return const CircularProgressIndicator(
                                  color: Colors.black,
                                );
                              },
                            ),
                          ),
                          // Positioned(
                          //   top: 15,
                          //   right: 15,
                          //   child: Container(
                          //     width: 24,
                          //     height: 24,
                          //     decoration: const BoxDecoration(
                          //       color: Color(0xFF007AFF),
                          //       shape: BoxShape.circle,
                          //     ),
                          //     child: Center(
                          //       child: Text(
                          //         '${_currentPreviewIndex + 1}',
                          //         style: GoogleFonts.libreFranklin(
                          //           color: Colors.white,
                          //           fontSize: 12,
                          //           fontWeight: FontWeight.bold,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
              ),
            ],
          ),

          // Draggable Gallery Section
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 1,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    // Drag Handle
                    Divider(endIndent: dw * 0.35, indent: dw * 0.35),
                    // Section Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _showAlbumSelector,
                            child: Row(
                              children: [
                                Text(
                                  _currentAlbum?.name ?? 'Recents',
                                  style: GoogleFonts.libreFranklin(
                                    color: AppColors.textPrimary,
                                    fontSize: MediaQuery.of(
                                      context,
                                    ).textScaler.scale(18),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const HugeIcon(
                                  icon: HugeIcons.strokeRoundedArrowDown01,
                                  color: AppColors.titleTextColor,
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: _selectedImages.isEmpty
                                ? null
                                : () {
                                    // Here I Not using GoRouter -- <<<<<<<<<< Navigator.push >>>>>>>>>
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ImagePreviewInwardrobePgae(
                                              selectedImages: _selectedImages,
                                              fromPage: widget.fromPage,
                                            ),
                                      ),
                                    );
                                  },
                            child: Text(
                              // can change to submit also ..
                              'Save',
                              style: GoogleFonts.libreFranklin(
                                color: _selectedImages.isEmpty
                                    ? AppColors.subTitleTextColor
                                    : AppColors.textPrimary,
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(14),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Gallery Grid or Error/Loading State
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            )
                          : _errorMessage.isNotEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _errorMessage,
                                    style: GoogleFonts.libreFranklin(
                                      color: Colors.red,
                                      fontSize: MediaQuery.of(
                                        context,
                                      ).textScaler.scale(16),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _requestPermissionAndLoadMedia,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              controller: scrollController,
                              // padding: const EdgeInsets.all(8),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 2,
                                    mainAxisSpacing: 2,
                                  ),
                              itemCount:
                                  _mediaList.length + 1, // +1 for camera button
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  // Camera button
                                  return GestureDetector(
                                    onTap: _openCamera,
                                    child: Container(
                                      color: const Color(0xFF333333),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.grey,
                                        size: 32,
                                      ),
                                    ),
                                  );
                                }

                                final asset = _mediaList[index - 1];
                                final isSelected = _selectedImages.contains(
                                  asset,
                                );
                                final selectionNumber = isSelected
                                    ? _getSelectionNumber(asset)
                                    : 0;

                                return GestureDetector(
                                  onTap: () => _toggleImageSelection(asset),
                                  child: Stack(
                                    children: [
                                      AssetEntityImage(
                                        asset: asset,
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFF007AFF)
                                                : Colors.black54,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: isSelected
                                                ? Text(
                                                    selectionNumber.toString(),
                                                    style:
                                                        GoogleFonts.libreFranklin(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                        ),
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
