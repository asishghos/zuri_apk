import 'dart:developer' as Developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
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
  List<GarmentItem> _filteredGarmentItems = [];
  bool _isFilterActive = false;
  bool _isLoadingGarments = false;
  String _errorMessage = '';
  bool showSearchResults = false;
  final List<String> categories = [
    'All',
    'Recent',
    'Tops',
    'Bottoms',
    'Ethnic',
    'Dresses',
    'co-ord set',
    'Swimwear',
    'Footwear',
    'Accessories',
    'Search',
  ];
  final List<String> tags = ['Pink', 'Casual', 'Cotton', 'Top', 'Winter'];
  final List<String> filterOptions = [
    'Color',
    'Occasion',
    'Fabric',
    'Category',
    'Season',
  ];
  final List<String> seasons = [
    'Summer',
    'Winter',
    'Monsoon',
    'Autumn',
    'Spring',
    'All Season',
  ];
  final List<String> fabrics = [
    'Cotton',
    'Linen',
    'Silk',
    'Wool',
    'Denim',
    'Polyester',
    'Rayon',
    'Velvet',
    'Chiffon',
    'Georgette',
    'Net',
    'Satin',
    'Tulle',
  ];
  final List<Map<String, dynamic>> colors = [
    {'name': 'Black', 'hexCode': '0xFF000000'},
    {'name': 'White', 'hexCode': '0xFFFFFFFF'},
    {'name': 'Gold', 'hexCode': '0xFFFFD700'},
    {'name': 'Pink', 'hexCode': '0xFFFFC0CB'},
    {'name': 'Navy Blue', 'hexCode': '0xFF000080'},
    {'name': 'Blue', 'hexCode': '0xFF0000FF'},
    {'name': 'Green', 'hexCode': '0xFF006400'},
    {'name': 'Cream', 'hexCode': '0xFFFFFDD0'},
    {'name': 'Beige', 'hexCode': '0xFFF5F5DC'},
    {'name': 'Brown', 'hexCode': '0xFF5C4033'},
    {'name': 'Red', 'hexCode': '0xFFFF0000'},
    {'name': 'Silver', 'hexCode': '0xFFC0C0C0'},
    {'name': 'Yellow', 'hexCode': '0xFFFFFF00'},
    {'name': 'Peach', 'hexCode': '0xFFFFE5B4'},
    {'name': 'Maroon', 'hexCode': '0xFF800000'},
    {'name': 'Grey', 'hexCode': '0xFF808080'},
    {'name': 'Off White', 'hexCode': '0xFFFAF9F6'},
    {'name': 'Rose Gold', 'hexCode': '0xFFB76E79'},
    {'name': 'Orange', 'hexCode': '0xFFFFA500'},
    {'name': 'Purple', 'hexCode': '0xFF4B0082'},
    {'name': 'Magenta', 'hexCode': '0xFFFF00FF'},
    {'name': 'Teal', 'hexCode': '0xFF008080'},
    {'name': 'Lavender', 'hexCode': '0xFFE6E6FA'},
    {'name': 'Olive', 'hexCode': '0xFF808000'},
    {'name': 'Turquoise', 'hexCode': '0xFF40E0D0'},
  ];
  List<String> selectedCategories = [];
  List<String> selectedColors = [];
  List<String> selectedFabrics = [];
  List<String> selectedSeasons = [];
  List<String> selectedOcassions = [];
  TextEditingController categorySearchController = TextEditingController();

  int selectedFilterIndex = 0;

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

  void _clearFilters() {
    setState(() {
      _isFilterActive = false;
      _filteredGarmentItems.clear();
      showSearchResults = false;
      selectedCategories.clear();
      selectedFabrics.clear();
      selectedColors.clear();
      selectedOcassions.clear();
      selectedSeasons.clear();
    });
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
        _errorMessage = 'No garments found in wardrobe';
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

  Future<List<GarmentItem>> _runFilter(
    List<String>? category,
    List<String>? color,
    List<String>? fabric,
    List<String>? occasion,
    List<String>? season,
  ) async {
    try {
      List<GarmentItem> garments = await WardrobeApiService.filterGarments(
        category: category,
        color: color,
        fabric: fabric,
        occasion: occasion,
        season: season,
      );
      for (var garment in garments) {
        Developer.log(
          "👕 ${garment.itemName} | ${garment.garmentId} | ${garment.imageId}",
        );
      }
      Developer.log(garments[0].toString());
      return garments;
    } catch (e) {
      Developer.log("❌ Exception during filter: $e");
      return [];
    }
  }

  // Apply Filters Function
  Future<void> _applyFilters() async {
    setState(() {
      _isLoadingGarments = true;
    });

    try {
      final filteredResults = await _runFilter(
        selectedCategories,
        selectedColors,
        selectedFabrics,
        selectedOcassions,
        selectedSeasons,
      );

      setState(() {
        _filteredGarmentItems = filteredResults;
        _isFilterActive = true;
        _isLoadingGarments = false;
        showSearchResults = true;
      });

      Developer.log('Selected Categories: $selectedCategories');
      Developer.log('Selected Colors: $selectedColors');
      Developer.log('Selected Fabrics: $selectedFabrics');
      Developer.log('Filtered results count: ${filteredResults.length}');
    } catch (e) {
      setState(() {
        _isLoadingGarments = false;
        _errorMessage = 'Failed to apply filters';
      });
      Developer.log("❌ Exception during filter application: $e");
    }
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
            SizedBox(height: MediaQuery.of(context).size.height * 0.04576659),
            // Header
            Row(
              children: [
                Text(
                  'All',
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(20),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    _showFilterBottomSheet(context);
                  },
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedFilterHorizontal,
                    color: Color(0xFF394050),
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close, size: 24, color: AppColors.error),
                ),
              ],
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.009153318),

            // Subtitle
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose a top from your zuri closet or upload from gallery',
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(14),
                  color: Colors.grey[600],
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.0274599),

            // Grid of clothing items
            _buildGarmentGrid(),

            SizedBox(height: MediaQuery.of(context).size.height * 0.022883295),

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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.018306636,
              ),
              Text(
                'Loading garments...',
                style: GoogleFonts.libreFranklin(
                  color: Colors.grey[600],
                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // if (_errorMessage.isNotEmpty) {
    //   return Expanded(
    //     child: Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Icon(Icons.error_outline, size: 48, color: AppColors.error),
    //           SizedBox(
    //             height: MediaQuery.of(context).size.height * 0.018306636,
    //           ),
    //           Text(
    //             _errorMessage,
    //             style: GoogleFonts.libreFranklin(
    //               color: AppColors.error,
    //               fontSize: MediaQuery.of(context).textScaler.scale(16),
    //             ),
    //             textAlign: TextAlign.center,
    //           ),
    //           SizedBox(
    //             height: MediaQuery.of(context).size.height * 0.018306636,
    //           ),
    //           ElevatedButton(
    //             onPressed: _loadGarments,
    //             child: Text(
    //               'Retry',
    //               style: GoogleFonts.libreFranklin(color: Colors.white),
    //             ),
    //             style: ElevatedButton.styleFrom(
    //               backgroundColor: AppColors.textPrimary,
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    List<GarmentItem> itemsToDisplay = _isFilterActive
        ? _filteredGarmentItems
        : _garmentItems;

    // Always show at least the gallery option, even if no items
    int totalItems = itemsToDisplay.length + 1; // +1 for gallery option

    return Expanded(
      child: itemsToDisplay.isEmpty && !_isFilterActive
          ? // Show empty state with gallery option
            Column(
              children: [
                // Gallery option at the top
                Container(
                  width: double.infinity,
                  height: 120,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _showPicker,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _uploadedImage != null
                                  ? AppColors.textPrimary.withOpacity(0.1)
                                  : const Color(0xFF333333),
                              border: _uploadedImage != null
                                  ? Border.all(
                                      color: AppColors.textPrimary,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.004975124,
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _isUploadingImage
                                ? Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                      strokeWidth:
                                          MediaQuery.of(context).size.width *
                                          0.004975124,
                                    ),
                                  )
                                : _uploadedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(7),
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
                                      Icon(
                                        Icons.camera_alt,
                                        color: Colors.grey,
                                        size: 32,
                                      ),
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
                        ),
                      ),
                      // Empty spaces to maintain grid layout
                      SizedBox(width: 8),
                      Expanded(child: Container()),
                      SizedBox(width: 8),
                      Expanded(child: Container()),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Empty state message
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.checkroom_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No items in your wardrobe',
                          style: GoogleFonts.libreFranklin(
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(18),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add items to your wardrobe or upload from gallery',
                          style: GoogleFonts.libreFranklin(
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(14),
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : GridView.builder(
              physics: BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: totalItems,
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
                            ? Border.all(
                                color: AppColors.textPrimary,
                                width:
                                    MediaQuery.of(context).size.width *
                                    0.004975124,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _isUploadingImage
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth:
                                    MediaQuery.of(context).size.width *
                                    0.004975124,
                              ),
                            )
                          : _uploadedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(7),
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
                                Icon(
                                  Icons.camera_alt,
                                  color: Colors.grey,
                                  size: 32,
                                ),
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
                final garment = itemsToDisplay[garmentIndex];
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
                        color: isSelected
                            ? AppColors.textPrimary
                            : Colors.grey[300]!,
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
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[100],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                          strokeWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.004975124,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
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

  // Column-wise Filter Bottom Sheet Function
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              child: Column(
                children: [
                  Divider(
                    color: Color(0xFFD9D9D9),
                    indent: 150,
                    endIndent: 150,
                  ),
                  // Header
                  Container(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter',
                          style: GoogleFonts.libreFranklin(
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(18),
                            fontWeight: FontWeight.w600,
                            color: AppColors.titleTextColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCancelCircle,
                            color: Color(0xFF141B34),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(height: 15),
                  Divider(indent: 20, endIndent: 20, height: 0),
                  // Main Content with Column Layout
                  Expanded(
                    child: Row(
                      children: [
                        // Left Column - Filter Categories
                        Container(
                          width: 120,
                          color: Colors.grey[100],
                          child: Column(
                            children: filterOptions.asMap().entries.map((
                              entry,
                            ) {
                              int index = entry.key;
                              String option = entry.value;
                              bool isSelected = selectedFilterIndex == index;

                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    selectedFilterIndex = index;
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                    border: isSelected
                                        ? const Border(
                                            right: BorderSide(
                                              color: Color(0xFFE91E63),
                                              width: 3,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Text(
                                    option,
                                    style: GoogleFonts.libreFranklin(
                                      fontSize: MediaQuery.of(
                                        context,
                                      ).textScaler.scale(14),
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: Color(0xFF394050),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // Right Column - Filter Content
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            child: _buildFilterContent(
                              selectedFilterIndex,
                              setModalState,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Buttons
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setModalState(() {
                                selectedCategories.clear();
                                selectedFabrics.clear();
                                selectedColors.clear();
                                selectedOcassions.clear();
                                selectedSeasons.clear();
                              });
                              setState(() {
                                selectedCategories.clear();
                                selectedFabrics.clear();
                                selectedColors.clear();
                                selectedOcassions.clear();
                                selectedSeasons.clear();
                                showSearchResults = false;
                                _isFilterActive = false;
                                _filteredGarmentItems.clear();
                              });
                            },
                            child: Text(
                              'Reset All',
                              style: GoogleFonts.libreFranklin(
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(16),
                                color: AppColors.titleTextColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width:
                              MediaQuery.of(context).size.width * 0.049751243,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _applyFilters(); // Make sure to await the filter application
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.textPrimary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(
                              'Apply Filter',
                              style: GoogleFonts.libreFranklin(
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(14),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Build Filter Content based on selected index
  Widget _buildFilterContent(int index, StateSetter setModalState) {
    switch (index) {
      case 0:
        return _buildColorFilter(setModalState);
      case 1:
        return _buildOccasionFilter(setModalState);
      case 2:
        return _buildFabricsFilter(setModalState);
      case 4:
        return _buildseasonsFilter(setModalState);
      case 3:
        return _buildCategoryFilter(setModalState);
      default:
        return Container();
    }
  }

  // Color Filter Widget
  Widget _buildColorFilter(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(32),
          ),
          child: TextField(
            controller: categorySearchController,
            style: GoogleFonts.libreFranklin(
              fontSize: MediaQuery.of(context).textScaler.scale(14),
            ),
            decoration: InputDecoration(
              hintText: 'Search Color',
              hintStyle: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(14),
                color: Colors.grey[500],
              ),
              prefixIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: Color(0xFFD34169),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
            ),
          ),
        ),
        // SizedBox(height: MediaQuery.of(context).size.height * 0.022883295),

        // Category List
        Expanded(
          child: ListView.builder(
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              bool isSelected = selectedColors.contains(color['name']);

              return ListTile(
                title: Row(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.018306636,
                      width: 16,
                      // color: Color(int.parse(color['hexCode']!)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Color(int.parse(color['hexCode']!)),
                        border: Border.all(color: Color(0xFF6D717F)),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      color['name']!,
                      style: GoogleFonts.libreFranklin(
                        fontSize: MediaQuery.of(context).textScaler.scale(14),
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                trailing: Checkbox(
                  side: BorderSide(color: AppColors.textPrimary),
                  value: isSelected,
                  shape: CircleBorder(),
                  onChanged: (bool? value) {
                    setModalState(() {
                      if (isSelected) {
                        selectedColors.remove(color['name']);
                      } else {
                        selectedColors.add(color['name']);
                      }
                    });
                  },
                  activeColor: AppColors.textPrimary,
                ),
                onTap: () {
                  setModalState(() {
                    if (isSelected) {
                      selectedColors.remove(color['name']);
                    } else {
                      selectedColors.add(color['name']);
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
        ),
      ],
    );
  }

  // Add these state variables at the top of your class
  bool isSocialScenesExpanded = false;
  bool isCelebrationsExpanded = false;
  bool isWorkProfessionalExpanded = false;
  bool isChillCasualExpanded = false;

  // Occasion Filter Widget
  Widget _buildOccasionFilter(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(32),
          ),
          child: TextField(
            controller: categorySearchController,
            style: GoogleFonts.libreFranklin(
              fontSize: MediaQuery.of(context).textScaler.scale(14),
            ),
            decoration: InputDecoration(
              hintText: 'Search Occasion',
              hintStyle: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(14),
                color: Colors.grey[500],
              ),
              prefixIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: Color(0xFFD34169),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
            ),
          ),
        ),

        // Categories
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Social Scenes Section
                _buildOcationCategorySection(
                  title: 'Social Scenes',
                  isExpanded: isSocialScenesExpanded,
                  items: [
                    'Date Night',
                    'Girls\' Night Out',
                    'Brunch',
                    'Dinner',
                    'Clubbing',
                    'Concerts',
                  ],
                  setModalState: setModalState,
                  onToggle: () {
                    setModalState(() {
                      isSocialScenesExpanded = !isSocialScenesExpanded;
                    });
                  },
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.009153318,
                ),

                // Celebrations & Festivities Section
                _buildOcationCategorySection(
                  title: 'Celebrations & Festivities',
                  isExpanded: isCelebrationsExpanded,
                  items: [
                    'Birthday Parties',
                    'Weddings',
                    'Festivals',
                    'Pooja / Religious Functions',
                    'College Fests',
                  ],
                  setModalState: setModalState,
                  onToggle: () {
                    setModalState(() {
                      isCelebrationsExpanded = !isCelebrationsExpanded;
                    });
                  },
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.009153318,
                ),

                // Work & Professional Section
                _buildOcationCategorySection(
                  title: 'Work & Professional',
                  isExpanded: isWorkProfessionalExpanded,
                  items: [
                    'Office Meetings',
                    'Business Events',
                    'Conferences',
                    'Networking',
                  ],
                  setModalState: setModalState,
                  onToggle: () {
                    setModalState(() {
                      isWorkProfessionalExpanded = !isWorkProfessionalExpanded;
                    });
                  },
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.009153318,
                ),

                // Chill & Casual Section
                _buildOcationCategorySection(
                  title: 'Chill & Casual',
                  isExpanded: isChillCasualExpanded,
                  items: ['Shopping', 'Movie Night', 'Beach Day', 'Picnic'],
                  setModalState: setModalState,
                  onToggle: () {
                    setModalState(() {
                      isChillCasualExpanded = !isChillCasualExpanded;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build category sections
  Widget _buildOcationCategorySection({
    required String title,
    required bool isExpanded,
    required List<String> items,
    required StateSetter setModalState,
    required VoidCallback onToggle, // Add this parameter
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Section Header
          InkWell(
            onTap: onToggle, // Use the onToggle callback
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.libreFranklin(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF394050),
                    ),
                  ),
                  HugeIcon(
                    color: Color(0xFF394050),
                    size: 20,
                    icon: isExpanded
                        ? HugeIcons.strokeRoundedArrowUp01
                        : HugeIcons.strokeRoundedArrowDown01,
                  ),
                ],
              ),
            ),
          ),

          // Section Items (only show if expanded)
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            ...items
                .map((item) => _buildOccasionItem(item, setModalState))
                .toList(),
          ],
        ],
      ),
    );
  }

  // Helper method to build individual occasion items
  Widget _buildOccasionItem(String itemName, StateSetter setModalState) {
    bool isSelected = selectedOcassions.contains(itemName);

    return InkWell(
      onTap: () {
        setModalState(() {
          if (isSelected) {
            selectedOcassions.remove(itemName);
          } else {
            selectedOcassions.add(itemName);
          }
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(width: 16),
              Text(
                itemName,
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(11),
                  color: Color(0xFF394050),
                ),
              ),
            ],
          ),
          Checkbox(
            side: BorderSide(color: AppColors.textPrimary),
            value: isSelected,
            shape: CircleBorder(),
            onChanged: (bool? value) {
              setModalState(() {
                if (isSelected) {
                  selectedOcassions.remove(itemName);
                } else {
                  selectedOcassions.add(itemName);
                }
              });
            },
            activeColor: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  // Brands Filter Widget
  Widget _buildFabricsFilter(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(32),
          ),
          child: TextField(
            controller: categorySearchController,
            style: GoogleFonts.libreFranklin(
              fontSize: MediaQuery.of(context).textScaler.scale(14),
            ),
            decoration: InputDecoration(
              hintText: 'Search Fabric',
              hintStyle: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(14),
                color: Colors.grey[500],
              ),
              prefixIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: Color(0xFFD34169),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: fabrics.length,
            itemBuilder: (context, index) {
              final fabric = fabrics[index];
              bool isSelected = selectedFabrics.contains(fabric);

              return ListTile(
                title: Text(
                  fabric,
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(14),
                    color: Colors.black,
                  ),
                ),
                trailing: Checkbox(
                  side: BorderSide(color: AppColors.textPrimary),
                  value: isSelected,
                  shape: CircleBorder(),
                  onChanged: (bool? value) {
                    setModalState(() {
                      if (value == true) {
                        selectedFabrics.add(fabric);
                      } else {
                        selectedFabrics.remove(fabric);
                      }
                    });
                  },
                  activeColor: AppColors.textPrimary,
                ),
                onTap: () {
                  setModalState(() {
                    if (isSelected) {
                      selectedFabrics.remove(fabric);
                    } else {
                      selectedFabrics.add(fabric);
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildseasonsFilter(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(32),
          ),
          child: TextField(
            controller: categorySearchController,
            style: GoogleFonts.libreFranklin(
              fontSize: MediaQuery.of(context).textScaler.scale(14),
            ),
            decoration: InputDecoration(
              hintText: 'Search Season',
              hintStyle: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(14),
                color: Colors.grey[500],
              ),
              prefixIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: Color(0xFFD34169),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: seasons.length,
            itemBuilder: (context, index) {
              final season = seasons[index];
              bool isSelected = selectedSeasons.contains(season);

              return ListTile(
                title: Text(
                  season,
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(14),
                    color: Colors.black,
                  ),
                ),
                trailing: Checkbox(
                  side: BorderSide(color: AppColors.textPrimary),
                  value: isSelected,
                  shape: CircleBorder(),
                  onChanged: (bool? value) {
                    setModalState(() {
                      if (value == true) {
                        selectedSeasons.add(season);
                      } else {
                        selectedSeasons.remove(season);
                      }
                    });
                  },
                  activeColor: AppColors.textPrimary,
                ),
                onTap: () {
                  setModalState(() {
                    if (isSelected) {
                      selectedSeasons.remove(season);
                    } else {
                      selectedSeasons.add(season);
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
        ),
      ],
    );
  }

  // Website Filter Widget
  Widget _buildCategoryFilter(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(32),
          ),
          child: TextField(
            controller: categorySearchController,
            style: GoogleFonts.libreFranklin(
              fontSize: MediaQuery.of(context).textScaler.scale(14),
            ),
            decoration: InputDecoration(
              hintText: 'Search Category',
              hintStyle: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(14),
                color: Colors.grey[500],
              ),
              prefixIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: Color(0xFFD34169),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              bool isSelected = selectedCategories.contains(category);

              return ListTile(
                title: Text(
                  category,
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(14),
                    color: Colors.black,
                  ),
                ),
                trailing: Checkbox(
                  side: BorderSide(color: AppColors.textPrimary),
                  value: isSelected,
                  shape: CircleBorder(),
                  onChanged: (bool? value) {
                    setModalState(() {
                      if (value == true) {
                        selectedCategories.add(category);
                      } else {
                        selectedCategories.remove(category);
                      }
                    });
                  },
                  activeColor: AppColors.textPrimary,
                ),
                onTap: () {
                  setModalState(() {
                    if (isSelected) {
                      selectedCategories.remove(category);
                    } else {
                      selectedCategories.add(category);
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
        ),
      ],
    );
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
