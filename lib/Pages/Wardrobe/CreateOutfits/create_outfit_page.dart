import 'dart:convert';
import 'dart:developer' as Developer;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:screenshot/screenshot.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Function/global_function.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/Pages/Wardrobe/CreateOutfits/bad_item_page.dart';
import 'package:testing2/services/Class/styling_model.dart';
import 'package:testing2/services/DataSource/digital_wardrobe_api.dart';
import 'package:testing2/services/DataSource/event_api_service.dart';
import 'package:testing2/services/DataSource/saved_fav_api.dart';
import 'package:testing2/services/DataSource/styling_api.dart';

class CreateOutfitPage extends StatefulWidget {
  final String? occasion;
  final List<File>? images;
  final bool? isDialogBoxOpen;
  final String? description;
  final String? eventId;
  final String? loaction;
  final String? dayEventId;

  CreateOutfitPage({
    Key? key,
    required this.occasion,
    this.images,
    this.isDialogBoxOpen,
    this.description,
    this.eventId,
    this.loaction,
    this.dayEventId,
  }) : super(key: key);
  @override
  State<CreateOutfitPage> createState() => _CreateOutfitPageState();
}

class _CreateOutfitPageState extends State<CreateOutfitPage> {
  PageController _pageController = PageController();
  int _currentIndex = 0;
  OutfitAnalysisResponse? _generatedResponse;
  OutfitAnalysisResponse? _recommendationResponse;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showBadItemsPopup = false;
  bool _isProductLoading = false;
  // Create different products for variety
  List<Map<String, String>> _products = [];

  @override
  void initState() {
    super.initState();
    if (widget.images != null) {
      _uploadImages(selectedImages: widget.images!);
    }
    Developer.log("description" + widget.description.toString());
    _initializeData();
    // Log all incoming widget data
    Developer.log("isDialogBoxOpen: ${widget.isDialogBoxOpen}");
    Developer.log("occasion: ${widget.occasion}");
    Developer.log("description: ${widget.description}");
    Developer.log("eventId: ${widget.eventId}");
    Developer.log("location: ${widget.loaction}");
  }

  void _uploadImages({required List<File> selectedImages}) async {
    // setState(() => _isLoading = true); // Show loader
    try {
      final result = await WardrobeApiService.uploadGarments(selectedImages);
      Developer.log("✅ ${result?.message ?? 'Upload successful'}");
      Developer.log(
        "Processed: ${result?.processed}, Skipped: ${result?.skipped}",
      );
      // if (!mounted) return;
      // context.pop();
      // context.goNamed("myWardrobe");
      // showSuccessSnackBar(context, "Images uploaded successfully");
    } catch (e) {
      Developer.log("❌ Upload failed: $e");
      // if (mounted) {
      //   showErrorSnackBar(context, "Upload failed. Please try again.");
      // }
    }
  }

  void _initializeData() async {
    if (widget.images == null || widget.images!.isEmpty) {
      await _generateLook(
        widget.occasion ?? "Casual",
        widget.description ?? " ",
      );
    } else {
      await _fetchStyleRecommender(
        widget.occasion ?? "Casual",
        widget.description ?? " ",
        widget.images!,
      );
    }
  }

  void _fetchProductsWithKeywords() async {
    List<String> keywords = [];

    if (_generatedResponse != null) {
      keywords = _generatedResponse!.imageAnalysis.goodImagesKeywords;
      Developer.log("Keywords from generated response: $keywords");
    } else if (_recommendationResponse != null) {
      keywords = _recommendationResponse!.imageAnalysis.goodImagesKeywords;
      Developer.log("Keywords from recommendation response: $keywords");
    }

    if (keywords.isNotEmpty) {
      Developer.log("Fetching products with keywords: $keywords");
      await _fetchProduct(keywords);
    } else {
      Developer.log(
        "No keywords available - _generatedResponse: ${_generatedResponse != null}, _recommendationResponse: ${_recommendationResponse != null}",
      );
    }
  }

  Future<void> _fetchProduct(List<String> keywords) async {
    setState(() {
      _isProductLoading = true;
    });

    try {
      final response = await GlobalFunction.searchProductsByKeywords(keywords);

      // Print each item nicely
      for (var item in response) {
        Developer.log(jsonEncode(item)); // prints whole product map
      }

      // Or just print the full list:
      // Developer.log("Product Results: ${jsonEncode(response)}");

      setState(() {
        _products = response; // Store the products
        _isProductLoading = false;
      });
    } catch (e) {
      Developer.log("Product fetch error: $e");
      setState(() {
        _isProductLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _generateLook(String occasion, String description) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await GenerateLookService.generateLookForOccasion(
        occasion: occasion,
        description: description,
      );
      // Developer.log(response.toString());

      if (response != null && response.results.isNotEmpty) {
        Developer.log("🎉 Occasion: ${widget.occasion}");
        setState(() {
          _generatedResponse = response;
          _isLoading = false;
        });
        _populateStyledImageUrls();
        _fetchProductsWithKeywords();
      } else {
        Developer.log("❌ Failed to generate looks - Empty response");
        setState(() {
          _isLoading = false;
          _errorMessage = 'No looks generated for this occasion';
        });
      }
    } catch (e) {
      Developer.log("❌ Failed to generate looks - Error: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to generate looks. Please try again.';
      });
    }
  }

  Map<int, bool> savedStates = {}; // Track save state for each index
  Map<int, String?> savedItemIds = {}; // Track saved item IDs
  Map<int, bool> loadingStates = {};
  Future<void> _toggleSave(int index) async {
    // Get current state or default to false
    bool currentSaved = savedStates[index] ?? false;

    setState(() {
      savedStates[index] = !currentSaved;
      loadingStates[index] = true;
    });

    if (savedStates[index]!) {
      await _addToSavedFavourites(index);
    } else {
      String? savedId = savedItemIds[index];
      if (savedId != null) {
        await _deleteFromSavedFavourites(index, savedId);
      } else {
        showErrorSnackBar(context, "No ID to delete");
      }
    }

    setState(() {
      loadingStates[index] = false;
    });
  }

  Future<void> _addToSavedFavourites(int index) async {
    try {
      String imageUrl = _getImageUrl(index);
      String description = _getDescription(index);
      String tag = _getSourceText();

      final result = await SavedFavouritesService.addToSavedFavourites(
        imageUrl: imageUrl,
        tag: tag,
        occasion: widget.occasion ?? "Casual",
        description: description,
      );

      if (result != null) {
        savedItemIds[index] = result.data.id;
        Developer.log("Saved ID for index $index: ${result.data.id}");
        showSuccessSnackBar(context, result.msg);
      } else {
        showErrorSnackBar(context, "Failed to save");
        setState(() => savedStates[index] = false); // Revert
      }
    } catch (e) {
      Developer.log("Error saving: $e");
      showErrorSnackBar(context, "Error saving: $e");
      setState(() => savedStates[index] = false); // Revert
    }
  }

  Future<void> _deleteFromSavedFavourites(int index, String id) async {
    try {
      final result = await SavedFavouritesService.deleteSavedFavourite(id);

      if (result['success']) {
        Developer.log("Deleted successfully");
        showSuccessSnackBar(context, result['msg']);
        savedItemIds.remove(index);
      } else {
        showErrorSnackBar(context, result['msg']);
        setState(() => savedStates[index] = true); // Revert
      }
    } catch (e) {
      Developer.log("Error deleting: $e");
      showErrorSnackBar(context, "Error deleting: $e");
      setState(() => savedStates[index] = true); // Revert
    }
  }

  Future<void> _fetchStyleRecommender(
    String occasion,
    String description,
    List<File> images,
  ) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await GenerateLookService.getStyleRecommender(
        images: images,
        occasion: occasion,
        description: description,
      );

      if (response!.results.isNotEmpty) {
        // Developer.log(response.toString());
        Developer.log(
          "🎉 Occasion: ${widget.occasion}, Recommendations: ${response}",
        );
        setState(() {
          _recommendationResponse = response;
          _isLoading = false;
          // Show popup if there are bad items
          _showBadItemsPopup =
              response.imageAnalysis.badImageWithDescription.isNotEmpty;
        });
        _populateStyledImageUrls();
        _fetchProductsWithKeywords();

        if (response.imageAnalysis.badImageWithDescription.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BadItemsPage(
                badItems: response.imageAnalysis.badImageWithDescription,
              ),
            ),
          );
        }
      } else {
        Developer.log("❌ Failed to generate recommendations - Empty response");
        setState(() {
          _isLoading = false;
          _errorMessage = 'No recommendations generated';
        });
      }
    } catch (e) {
      Developer.log("❌ Failed to generate looks. Error is: ${e}");
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to generate recommendations. Please try again.';
      });
    }
  }

  List<String> _styledImageUrls = [];

  void _populateStyledImageUrls() {
    _styledImageUrls.clear(); // Clear existing list
    List<dynamic> validItems = _validItems;

    for (int i = 0; i < validItems.length; i++) {
      String imageUrl = _getImageUrl(i);
      if (imageUrl.isNotEmpty && imageUrl != 'null') {
        _styledImageUrls.add(imageUrl);
      }
    }
  }

  Future<void> _lockingForEvent(
    String eventId,
    String? dayEventId,
    List<String> styledImageUrls,
  ) async {
    final response = await EventApiService.addStyledImageToEvent(
      eventId: eventId,
      styledImageUrls: styledImageUrls,
      dayEventId: dayEventId,
    );
    if (response != null) {
      showSuccessSnackBar(context, "Images add successfully in event.");
      context.goNamed(
        'eventmainscreen',
        extra: {
          'eventId': widget.eventId,
          'dayEventId': widget.dayEventId,
          'openDayEventDetails': true,
        },
      );
      // context.goNamed();
    } else {
      showErrorSnackBar(context, "Failed to add images in event.");
    }
  }

  bool get _hasData {
    return (_generatedResponse != null &&
            _generatedResponse!.results.isNotEmpty) ||
        (_recommendationResponse != null &&
            _recommendationResponse!.results.isNotEmpty);
  }

  // Replace the existing _totalItems getter with this:
  int get _totalItems {
    if (_generatedResponse != null) {
      return _generatedResponse!.results
          .where(
            (item) => (item.imageUrl).isNotEmpty && item.imageUrl != 'null',
          )
          .length;
    } else if (_recommendationResponse != null) {
      return _recommendationResponse!.results
          .where(
            (item) => (item.imageUrl).isNotEmpty && item.imageUrl != 'null',
          )
          .length;
    }
    return 0;
  }

  // Add this new method to get filtered valid items:
  List<dynamic> get _validItems {
    if (_generatedResponse != null) {
      return _generatedResponse!.results
          .where(
            (item) => (item.imageUrl).isNotEmpty && item.imageUrl != 'null',
          )
          .toList();
    } else if (_recommendationResponse != null) {
      return _recommendationResponse!.results
          .where(
            (item) => (item.imageUrl).isNotEmpty && item.imageUrl != 'null',
          )
          .toList();
    }
    return [];
  }

  String _getImageUrl(int index) {
    List<dynamic> validItems = _validItems;
    if (index < validItems.length) {
      var item = validItems[index];
      return item?.imageUrl ?? '';
    }
    return '';
  }

  String _getSourceText() {
    List<dynamic> validItems = _validItems;
    if (_currentIndex < validItems.length) {
      var item = validItems[_currentIndex];
      String? type = item?.type?.toLowerCase();

      switch (type) {
        case 'wardrobe':
          return "From your Closet";
        case 'uploaded_image':
          return "From Your Upload";
        case 'ai_generated':
          return "From Zuri AI";
        default:
          return "From your Closet";
      }
    }
    return "From your Closet";
  }

  String _getDescription(int index) {
    List<dynamic> validItems = _validItems;
    if (index < validItems.length) {
      var item = validItems[index];
      String imageUrl = item?.imageUrl ?? '';

      // Look for description in imageAnalysis.goodImageWithDescription
      if (_recommendationResponse != null) {
        for (var goodItem
            in _recommendationResponse!
                .imageAnalysis
                .goodImageWithDescription) {
          if (goodItem.image == imageUrl) {
            return goodItem.description;
          }
        }
      }

      if (_generatedResponse != null) {
        for (var goodItem
            in _generatedResponse!.imageAnalysis.goodImageWithDescription) {
          if (goodItem.image == imageUrl) {
            return goodItem.description;
          }
        }
      }
    }
    return "This is the space for AI gen image description lorem ipsum lorem ipsum lorem lorem";
  }

  ScreenshotController _screenshotController = ScreenshotController();
  Future<void> _shareAllLooks() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.textPrimary),
                SizedBox(height: 16),
                Text('Preparing your looks for sharing...'),
              ],
            ),
          ),
        ),
      );

      List<XFile> imageFiles = [];
      String combinedText = 'Check out my curated looks from Zuri! 👗✨\n\n';

      // Capture all images
      for (int i = 0; i < _totalItems; i++) {
        // Temporarily switch to each page to capture
        _pageController.animateToPage(
          i,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );

        // Wait for page transition
        await Future.delayed(Duration(milliseconds: 500));

        // Capture screenshot
        final image = await _screenshotController.capture();

        if (image != null) {
          // Save to temporary file
          final directory = await getTemporaryDirectory();
          final imagePath = await File(
            '${directory.path}/zuri_outfit_${i + 1}.png',
          ).create();
          await imagePath.writeAsBytes(image);

          imageFiles.add(XFile(imagePath.path));

          // Add description to combined text
          String description = _getDescription(i);
          combinedText += 'Look ${i + 1}: $description\n\n';
        }
      }

      // Close loading dialog
      Navigator.of(context).pop();

      // Add hashtags and app promotion
      combinedText +=
          '#ZuriStyle #OOTD #FashionAI #StyleCuration\n\nGet your personalized styling at Zuri App!';

      // Share all images with combined text
      await Share.shareXFiles(
        imageFiles,
        text: combinedText,
        subject: 'My Zuri Style Collection',
      );
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share looks. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Alternative method - Create a collage of all images
  Future<void> _shareAsCollage() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.textPrimary),
                SizedBox(height: 16),
                Text('Creating your style collage...'),
              ],
            ),
          ),
        ),
      );

      List<Uint8List> images = [];
      String combinedText = 'My Zuri Style Collection! 👗✨\n\n';

      // Capture all images
      for (int i = 0; i < _totalItems; i++) {
        try {
          await _pageController.animateToPage(
            i,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );

          await Future.delayed(Duration(milliseconds: 500));

          final image = await _screenshotController.capture();
          if (image != null) {
            images.add(image);
            combinedText += 'Look ${i + 1}: ${_getDescription(i)}\n\n';
          } else {
            print('Warning: Failed to capture image for item $i');
          }
        } catch (e) {
          print('Error capturing image $i: $e');
          // Continue with other images even if one fails
        }
      }

      if (images.isEmpty) {
        throw Exception('No images were captured successfully');
      }

      // Create collage
      final collageImage = await _createCollage(images);

      // Save collage
      final directory = await getTemporaryDirectory();
      final collagePath = File('${directory.path}/zuri_style_collage.png');
      await collagePath.writeAsBytes(collageImage);

      Navigator.of(context).pop();

      combinedText += '#ZuriStyle #OOTD #FashionCollage #StyleCuration';

      await Share.shareXFiles(
        [XFile(collagePath.path)],
        text: combinedText,
        subject: 'My Zuri Style Collage',
      );
    } catch (e) {
      print('Error in _shareAsCollage: $e'); // Add this for debugging

      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create collage: ${e.toString()}',
          ), // Show actual error
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5), // Give more time to read the error
        ),
      );
    }
  }

  // Helper method to create collage (you'll need to add image package to pubspec.yaml)
  Future<Uint8List> _createCollage(List<Uint8List> images) async {
    try {
      // This is a basic implementation - you might want to use a more sophisticated image processing library

      // For now, let's create a simple vertical collage
      const int maxWidth = 800;
      const int imageHeight = 600;
      const int spacing = 20;

      final int totalHeight =
          (images.length * imageHeight) +
          ((images.length - 1) * spacing) +
          40; // 40 for top/bottom padding

      // Create a canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Background
      final paint = Paint()..color = Colors.white;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, maxWidth.toDouble(), totalHeight.toDouble()),
        paint,
      );

      // Add images
      for (int i = 0; i < images.length; i++) {
        final imageBytes = images[i];
        final codec = await ui.instantiateImageCodec(imageBytes);
        final frame = await codec.getNextFrame();
        final image = frame.image;

        final double y = 20 + (i * (imageHeight + spacing)).toDouble();

        canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          Rect.fromLTWH(0, y, maxWidth.toDouble(), imageHeight.toDouble()),
          Paint(),
        );
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(maxWidth, totalHeight);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      print('Error in _createCollage: $e');
      rethrow;
    }
  }

  // Also make sure you have these imports at the top of your file:
  // import 'dart:ui' as ui;
  // import 'dart:typed_data';
  // import 'dart:io';
  // import 'package:path_provider/path_provider.dart';
  // import 'package:share_plus/share_plus.dart';
  Future<void> _shareCurrentLook() async {
    // Capture screenshot
    final image = await _screenshotController.capture();
    // Save to temporary file
    final directory = await getTemporaryDirectory();
    final imagePath = await File('${directory.path}/zuri_outfit.png').create();
    await imagePath.writeAsBytes(image!);
    // Share with text
    await Share.shareXFiles(
      [XFile(imagePath.path)],
      text:
          'Check out my curated look from Zuri! 👗✨ #ZuriStyle #OOTD ' +
          _getDescription(_currentIndex),
    );
  }

  // Method to show sharing options
  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Share Your Looks',
              style: GoogleFonts.libreFranklin(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.titleTextColor,
              ),
            ),
            SizedBox(height: 20),

            // Share current look
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedOneCircle,
                  color: AppColors.textPrimary,
                ),
              ),
              title: Text('Share Current Look'),
              subtitle: Text('Share the currently visible outfit'),
              onTap: () {
                Navigator.pop(context);
                _shareCurrentLook();
              },
            ),

            // Share all looks
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedThreeCircle,
                  color: AppColors.textPrimary,
                ),
              ),
              title: Text('Share All Looks'),
              subtitle: Text('Share all ${_totalItems} generated outfits'),
              onTap: () {
                Navigator.pop(context);
                _shareAllLooks();
              },
            ),

            // Share as collage
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedGrid,
                  color: AppColors.textPrimary,
                ),
              ),
              title: Text('Share as Collage'),
              subtitle: Text('Combine all looks into one image'),
              onTap: () {
                Navigator.pop(context);
                _shareAsCollage();
              },
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;
    if (_isLoading) {
      return LoadingPage();
    }
    return SafeArea(
      child: Column(
        children: [
          // Fixed Header Section
          Container(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.goNamed('myWardrobe');
                      },
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        color: AppColors.titleTextColor,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Curated  ",
                            style: GoogleFonts.libreFranklin(
                              color: AppColors.titleTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(18),
                            ),
                          ),
                          TextSpan(
                            text: "Looks",
                            style: GoogleFonts.libreFranklin(
                              color: AppColors.textPrimary,
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(18),
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _showShareOptions,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEB),
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFFD34169), width: 0.63),
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedShare08,
                        color: AppColors.textPrimary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            child: !_hasData
                ? _buildErrorState()
                : SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Dynamic Header based on current page
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Column(
                            //   children: [
                            //     Text(
                            //       "Your Curated Looks (${_currentIndex + 1}/$_totalItems)",
                            //       style: GoogleFonts.libreFranklin(
                            //         color: AppColors.titleTextColor,
                            //         fontSize: MediaQuery.of(context).textScaler.scale(16),
                            //         fontWeight: FontWeight.w600,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            Row(
                              children: [
                                Text(
                                  "for ",
                                  style: GoogleFonts.libreFranklin(
                                    color: AppColors.titleTextColor,
                                    fontSize: MediaQuery.of(
                                      context,
                                    ).textScaler.scale(16),
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                Text(
                                  "${widget.occasion ?? "casual"}  (${_currentIndex + 1}/$_totalItems)",
                                  style: GoogleFonts.libreFranklin(
                                    color: AppColors.titleTextColor,
                                    fontSize: MediaQuery.of(
                                      context,
                                    ).textScaler.scale(16),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.textPrimary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getSourceText(),
                                style: GoogleFonts.libreFranklin(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height:
                              MediaQuery.of(context).size.height * 0.018306636,
                        ),

                        // PageView for sliding images
                        Screenshot(
                          controller: _screenshotController,
                          child: Container(
                            height: dh * 0.55,
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                              itemCount: _totalItems,
                              itemBuilder: (context, index) {
                                String imageData = _getImageUrl(index);
                                // _styledImageUrls.add(imageData);
                                return Column(
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              color: Colors.white,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: _buildBase64Image(
                                                imageData,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                          // Saved button at top right
                                          Positioned(
                                            top: 12,
                                            right: 12,
                                            child: GestureDetector(
                                              onTap:
                                                  (loadingStates[index] ??
                                                      false)
                                                  ? null
                                                  : () => _toggleSave(index),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      (savedStates[index] ??
                                                          false)
                                                      ? AppColors.textPrimary
                                                      : Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                child:
                                                    (loadingStates[index] ??
                                                        false)
                                                    ? CircularProgressIndicator(
                                                        strokeWidth:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width *
                                                            0.004975124,
                                                        color:
                                                            (savedStates[index] ??
                                                                false)
                                                            ? Colors.white
                                                            : Colors.pink,
                                                      )
                                                    : HugeIcon(
                                                        icon: HugeIcons
                                                            .strokeRoundedBookmark02,
                                                        color:
                                                            (savedStates[index] ??
                                                                false)
                                                            ? Colors.white
                                                            : Colors.pink,
                                                        size: 28,
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.018306636,
                                    ),
                                    Text(
                                      _getDescription(index),
                                      style: GoogleFonts.libreFranklin(
                                        color: Colors.black,
                                        fontSize: MediaQuery.of(
                                          context,
                                        ).textScaler.scale(16),
                                        // fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.018306636,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),

                        // Dot Indicator
                        if (_totalItems > 1)
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _totalItems,
                                (index) =>
                                    _buildDotIndicator(index == _currentIndex),
                              ),
                            ),
                          ),

                        //Personalized recommendations
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Personalized recommendations",
                                    style: GoogleFonts.libreFranklin(
                                      color: AppColors.titleTextColor,
                                      fontSize: MediaQuery.of(
                                        context,
                                      ).textScaler.scale(18),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // View all action
                                    },
                                    child: Text(
                                      "View All",
                                      style: GoogleFonts.libreFranklin(
                                        color: Color(0xFF2563EB),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height *
                                    0.009153318,
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          "Based on what complements your closet and you ",
                                      style: GoogleFonts.libreFranklin(
                                        color: Color(0xFF6D717F),
                                        fontSize: 12,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "❤",
                                      style: GoogleFonts.libreFranklin(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 24),

                              _isProductLoading
                                  ? Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.03432490,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(
                                              height:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.018306636,
                                            ),
                                            Text(
                                              "Finding matching products...",
                                              style: GoogleFonts.libreFranklin(
                                                color: Colors.grey[600],
                                                fontSize: MediaQuery.of(
                                                  context,
                                                ).textScaler.scale(14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : _products.isEmpty
                                  ? Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.03432490,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.shopping_bag_outlined,
                                              size: 48,
                                              color: Colors.grey[400],
                                            ),
                                            SizedBox(
                                              height:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.018306636,
                                            ),
                                            Text(
                                              "No products found",
                                              style: GoogleFonts.libreFranklin(
                                                color: Colors.grey[600],
                                                fontSize: MediaQuery.of(
                                                  context,
                                                ).textScaler.scale(16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.3432490,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _products.length,
                                        itemBuilder: (context, index) {
                                          var product = _products[index];
                                          return Container(
                                            width: dw * 0.35,
                                            margin: EdgeInsets.only(right: 16),
                                            child: ProductCard(
                                              link: product['link'] ?? '',
                                              imageUrl: product['image'] ?? '',
                                              title: product['title'] ?? '',
                                              discountedPrice:
                                                  product['price'] ?? '',
                                              store: product['platform'] ?? '',
                                              dh: dh,
                                              initialFavorite: false,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height *
                                    0.0274599,
                              ),
                              GlobalPinkButton(
                                text: (widget.eventId != null)
                                    ? "Lock this Look"
                                    : "Plan in Calender",
                                // In your GlobalPinkButton onPressed method, change this:
                                onPressed: () async {
                                  if ((widget.eventId ?? '').isEmpty)
                                    context.goNamed('eventmainscreen');
                                  else {
                                    // Instead of sending all images, send only the current one
                                    // String currentImageUrl = _getImageUrl(
                                    //   _currentIndex,
                                    // );
                                    await _lockingForEvent(
                                      widget.eventId!,
                                      widget.dayEventId,
                                      _styledImageUrls,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            SizedBox(height: MediaQuery.of(context).size.height * 0.018306636),
            Text(
              _errorMessage ?? 'Failed to generate looks',
              style: GoogleFonts.libreFranklin(
                color: Colors.red,
                fontSize: MediaQuery.of(context).textScaler.scale(16),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.0274599),
            ElevatedButton(
              onPressed: () {
                _initializeData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.libreFranklin(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // String _getSourceText() {
  //   if (_generatedResponse != null &&
  //       _currentIndex < _generatedResponse!.results.length) {
  //     return _generatedResponse!.results[_currentIndex]?.type?.toLowerCase() ==
  //             'wardrobe'
  //         ? "From your Closet"
  //         : "From Ask Zuri";
  //   } else if (_recommendationResponse != null &&
  //       _currentIndex < _recommendationResponse!.results.length) {
  //     String? type = _recommendationResponse!.results[_currentIndex]?.type
  //         ?.toLowerCase();
  //     switch (type) {
  //       case 'wardrobe':
  //         return "From your Closet";
  //       case 'uploaded_image':
  //         return "Your Upload";
  //       case 'ai_suggestion':
  //         return "AI Suggestion";
  //       default:
  //         return "From your Closet";
  //     }
  //   }
  //   return "From your Closet";
  // }

  // String _getImageData(int index) {
  //   if (_generatedResponse != null &&
  //       index < _generatedResponse!.results.length) {
  //     return _generatedResponse!.results[index]?.image ?? '';
  //   } else if (_recommendationResponse != null &&
  //       index < _recommendationResponse!.results.length) {
  //     return _recommendationResponse!.results[index]?.imageB64 ?? '';
  //   }
  //   return '';
  // }

  Widget _buildDotIndicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4),
      height: MediaQuery.of(context).size.height * 0.009153318,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.textPrimary : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildBase64Image(
    String imageUrl, {
    BoxFit fit = BoxFit.contain,
    double? width,
    double? height,
  }) {
    if (imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Color(0xFFFFD6D5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 60, color: Color(0xFF8D6E63)),
            SizedBox(height: MediaQuery.of(context).size.height * 0.013729977),
            Text(
              'No image available',
              style: GoogleFonts.libreFranklin(
                color: Color(0xFF5D4037),
                fontSize: MediaQuery.of(context).textScaler.scale(14),
              ),
            ),
          ],
        ),
      );
    }

    try {
      // // Remove data:image/jpeg;base64, prefix if present
      // String cleanBase64 = base64String;
      // if (base64String.contains(',')) {
      //   cleanBase64 = base64String.split(',')[1];
      // }

      // Uint8List bytes = base64Decode(cleanBase64);
      return Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Color(0xFFFFD6D5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 60, color: Color(0xFF8D6E63)),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.013729977,
                ),
                Text(
                  'Failed to load image',
                  style: GoogleFonts.libreFranklin(
                    color: Color(0xFF5D4037),
                    fontSize: MediaQuery.of(context).textScaler.scale(14),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        width: width,
        height: height,
        color: Color(0xFFFFD6D5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 60, color: Color(0xFF8D6E63)),
            SizedBox(height: MediaQuery.of(context).size.height * 0.013729977),
            Text(
              'Invalid image data',
              style: GoogleFonts.libreFranklin(
                color: Color(0xFF5D4037),
                fontSize: MediaQuery.of(context).textScaler.scale(14),
              ),
            ),
          ],
        ),
      );
    }
  }

  // Widget _buildProductCard(
  //   String link,
  //   String imageUrl,
  //   String title,
  //   String discountedPrice,
  //   String store,
  //   double dh,
  // ) {
  //   return GestureDetector(
  //     onTap: () async {
  //       Developer.log('ProductCard - onTap: Opening product link: ${link}');
  //       try {
  //         await launchUrl(
  //           Uri.parse(link),
  //           mode: LaunchMode.externalApplication,
  //         );
  //       } catch (e) {}
  //     },
  //     child: Container(
  //       color: Colors.white,
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Expanded(
  //             child: Container(
  //               width: double.infinity,
  //               decoration: BoxDecoration(
  //                 borderRadius: const BorderRadius.all(Radius.circular(32)),
  //                 color: const Color(0xFFF5F5F5),
  //                 image: DecorationImage(
  //                   image: NetworkImage(imageUrl),
  //                   fit: BoxFit.cover,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.only(top: 8),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   title,
  //                   style: GoogleFonts.libreFranklin(
  //                     fontSize: MediaQuery.of(context).textScaler.scale(16),
  //                     fontWeight: FontWeight.w600,
  //                     color: Color(0xFFE91E63),
  //                   ),
  //                   maxLines: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //                 SizedBox(height: 4),
  //                 Row(
  //                   children: [
  //                     // if (originalPrice.isNotEmpty) ...[
  //                     //   Text(
  //                     //     originalPrice,
  //                     //     style: GoogleFonts.libreFranklin(
  //                     //       fontSize: MediaQuery.of(context).textScaler.scale(14),
  //                     //       color: AppColors.subTitleTextColor,
  //                     //       decoration: TextDecoration.lineThrough,
  //                     //     ),
  //                     //   ),
  //                     //   SizedBox(width: 4),
  //                     // ],
  //                     Text(
  //                       discountedPrice,
  //                       style: GoogleFonts.libreFranklin(
  //                         fontSize: MediaQuery.of(context).textScaler.scale(16),
  //                         fontWeight: FontWeight.bold,
  //                         color: AppColors.titleTextColor,
  //                       ),
  //                     ),
  //                     // if (discount.isNotEmpty) ...[
  //                     //   SizedBox(width: 4),
  //                     //   Text(
  //                     //     "(${discount} OFF)",
  //                     //     style: GoogleFonts.libreFranklin(
  //                     //       fontSize: 12,
  //                     //       color: AppColors.textPrimary,
  //                     //       fontWeight: FontWeight.w500,
  //                     //     ),
  //                     //   ),
  //                     // ],
  //                     Spacer(),
  //                     GestureDetector(
  //                       onTap: () {
  //                         _addWishList(
  //                           link,
  //                           imageUrl,
  //                           title,
  //                           discountedPrice,
  //                           store,
  //                         );
  //                       },
  //                       child: const HugeIcon(
  //                         icon: HugeIcons.strokeRoundedFavourite,
  //                         color: Colors.black,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(height: 4),
  //                 Text(
  //                   store,
  //                   style: GoogleFonts.libreFranklin(
  //                     fontSize: 12,
  //                     color: Colors.grey,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

class SaveButtonWidget extends StatefulWidget {
  final String? occasion;
  final String? tag;
  final String? description;
  final String? imageBase64;

  const SaveButtonWidget({
    super.key,
    required this.occasion,
    required this.description,
    required this.imageBase64,
    required this.tag,
  });

  @override
  State<SaveButtonWidget> createState() => _SaveButtonWidgetState();
}

class _SaveButtonWidgetState extends State<SaveButtonWidget> {
  bool isSaved = false;
  bool _isLoading = false;
  String? savedFavouriteId; // to store _id from API response

  void _toggleSave() async {
    setState(() {
      isSaved = !isSaved;
    });

    if (isSaved) {
      await _addToSavedFavourites(
        widget.imageBase64!,
        widget.tag ?? "From Zuri",
        widget.occasion ?? "Casual",
        widget.description ?? "",
      );
    } else {
      if (savedFavouriteId != null) {
        await _deleteFromSavedFavourites(savedFavouriteId!);
      } else {
        showErrorSnackBar(context, "No ID to delete");
      }
    }
  }

  Future<void> _addToSavedFavourites(
    String imageUrl,
    String tag,
    String occasion,
    String description,
  ) async {
    setState(() => _isLoading = true);

    try {
      final result = await SavedFavouritesService.addToSavedFavourites(
        imageUrl: imageUrl,
        tag: tag,
        occasion: occasion,
        description: description,
      );

      if (result != null) {
        savedFavouriteId = result.data.id;
        Developer.log("Saved ID: $savedFavouriteId");
        showSuccessSnackBar(context, result.msg);
      } else {
        showErrorSnackBar(context, "Failed to save");
        setState(() => isSaved = false); // Revert UI toggle
      }
    } catch (e) {
      Developer.log("Error saving: $e");
      showErrorSnackBar(context, "Error saving: $e");
      setState(() => isSaved = false); // Revert UI toggle
    }

    setState(() => _isLoading = false);
  }

  Future<void> _deleteFromSavedFavourites(String id) async {
    setState(() => _isLoading = true);

    try {
      final result = await SavedFavouritesService.deleteSavedFavourite(id);

      if (result['success']) {
        Developer.log("Deleted successfully");
        showSuccessSnackBar(context, result['msg']);
        savedFavouriteId = null;
      } else {
        showErrorSnackBar(context, result['msg']);
        setState(() => isSaved = true); // Revert UI toggle
      }
    } catch (e) {
      Developer.log("Error deleting: $e");
      showErrorSnackBar(context, "Error deleting: $e");
      setState(() => isSaved = true); // Revert UI toggle
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      right: 12,
      child: GestureDetector(
        onTap: _isLoading ? null : _toggleSave,
        child: Container(
          decoration: BoxDecoration(
            color: isSaved ? Colors.pink : Colors.white,
            shape: BoxShape.circle,
            border: isSaved
                ? null
                : Border.all(
                    color: Colors.pink,
                    width: MediaQuery.of(context).size.width * 0.004975124,
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: _isLoading
              ? CircularProgressIndicator(
                  strokeWidth: MediaQuery.of(context).size.width * 0.004975124,
                )
              : HugeIcon(
                  icon: HugeIcons.strokeRoundedBookmark02,
                  color: isSaved ? Colors.white : Colors.pink,
                  size: 28,
                ),
        ),
      ),
    );
  }
}
