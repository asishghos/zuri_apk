import 'dart:convert';
import 'dart:developer' as Developer;
import 'dart:io';
import 'package:screenshot/screenshot.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/Pages/Wardrobe/CreateOutfits/bad_item_page.dart';
import 'package:testing2/services/Class/product_model.dart';
import 'package:testing2/services/Class/styling_model.dart';
import 'package:testing2/services/DataSource/digital_wardrobe_api.dart';
import 'package:testing2/services/DataSource/event_api_service.dart';
import 'package:testing2/services/DataSource/product_api.dart';
import 'package:testing2/services/DataSource/saved_fav_api.dart';
import 'package:testing2/services/DataSource/styling_api.dart';

class CreateOutfitPage extends StatefulWidget {
  final String? occasion;
  final List<File>? images;
  final bool? isDialogBoxOpen;
  final String? description;
  final String? eventId;
  final String? loaction;

  CreateOutfitPage({
    Key? key,
    required this.occasion,
    this.images,
    this.isDialogBoxOpen,
    this.description,
    this.eventId,
    this.loaction,
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
  List<ProductItem> _products = [];

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
    // Remove this line: _fetchProductsWithKeywords();
  }

  void _fetchProductsWithKeywords() async {
    List<String> keywords = [];

    // Get keywords from the response
    if (_generatedResponse != null) {
      keywords = _generatedResponse!.imageAnalysis.goodImagesKeywords;
      Developer.log("Keywords from generated response: $keywords");
    } else if (_recommendationResponse != null) {
      keywords = _recommendationResponse!.imageAnalysis.goodImagesKeywords;
      Developer.log("Keywords from recommendation response: $keywords");
    }

    // Only fetch products if we have keywords
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
      final response = await ProductApiServices.fetchProducts(keywords);

      // Print each item nicely
      for (var item in response) {
        Developer.log(jsonEncode(item)); // prints whole product map
      }

      // Or just print the full list:
      Developer.log("Product Results: ${jsonEncode(response)}");

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
  Future<void> _lockingForEvent(
    String eventId,
    List<String> styledImageUrls,
  ) async {
    final response = await EventApiService.addStyledImageToEvent(
      eventId: eventId,
      styledImageUrls: styledImageUrls,
    );
    if (response != null) {
      showSuccessSnackBar(context, "Images add successfully in event.");
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

  // Replace the _getSourceText method with this:
  String _getSourceText() {
    List<dynamic> validItems = _validItems;
    if (_currentIndex < validItems.length) {
      var item = validItems[_currentIndex];
      String? type = item?.type?.toLowerCase();

      if (_generatedResponse != null) {
        return type == 'wardrobe' ? "From your Closet" : "From Ask Zuri";
      } else if (_recommendationResponse != null) {
        switch (type) {
          case 'wardrobe':
            return "From your Closet";
          case 'uploaded_image':
            return "From Your Upload";
          case 'ai_suggestion':
            return "From Zuri AI";
          default:
            return "From your Closet";
        }
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

  //   String _getItemDescription(int index) {
  //   List<dynamic> validItems = _validItems;
  //   if (index < validItems.length) {
  //     var item = validItems[index];
  //     if (item is ResultItem) {
  //       // If you add description field to ResultItem model
  //       return item.description ?? '';
  //     }
  //   }
  //   return '';
  // }

  ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _shareCurrentLook() async {
    // Capture screenshot
    final image = await _screenshotController.capture();
    // Save to temporary file
    final directory = await getTemporaryDirectory();
    final imagePath = await File('${directory.path}/zuri_outfit.png').create();
    await imagePath.writeAsBytes(image!);

    // Share with text
    await Share.shareXFiles([
      XFile(imagePath.path),
    ], text: 'Check out my curated look from Zuri! 👗✨ #ZuriStyle #OOTD');
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
                    const SizedBox(width: 16),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Curated  ",
                            style: GoogleFonts.libreFranklin(
                              color: AppColors.titleTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          TextSpan(
                            text: "Looks",
                            style: GoogleFonts.libreFranklin(
                              color: AppColors.textPrimary,
                              fontSize: 18,
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
                  onTap: _shareCurrentLook,
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
                            //         fontSize: 16,
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                Text(
                                  "${widget.occasion ?? "casual"}  (${_currentIndex + 1}/$_totalItems)",
                                  style: GoogleFonts.libreFranklin(
                                    color: AppColors.titleTextColor,
                                    fontSize: 16,
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
                                "From closet",
                                style: GoogleFonts.libreFranklin(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

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
                                _styledImageUrls.add(imageData);
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
                                                        strokeWidth: 2,
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
                                    Text(
                                      _getDescription(index),
                                      style: GoogleFonts.libreFranklin(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.left,
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
                                      fontSize: 18,
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
                              SizedBox(height: 8),
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

                              SizedBox(height: 16),

                              // Product Horizontal Scrollable List
                              // Container(
                              //   height: 300,
                              //   child: ListView.builder(
                              //     scrollDirection: Axis.horizontal,
                              //     itemCount: products
                              //         .length, // Number of product cards
                              //     itemBuilder: (context, index) {
                              //       var product =
                              //           products[index % products.length];

                              //       return Container(
                              //         width: dw * 0.35,
                              //         margin: EdgeInsets.only(right: 16),
                              //         child: _buildProductCard(
                              //           product['image']!,
                              //           product['title']!,
                              //           product['original']!,
                              //           product['discounted']!,
                              //           product['discount']!,
                              //           product['store']!,
                              //           dh,
                              //         ),
                              //       );
                              //     },
                              //   ),
                              // ),
                              // SizedBox(height: 16),
                              // // Product Horizontal Scrollable List
                              // Container(
                              //   height: 300,
                              //   child: ListView.builder(
                              //     scrollDirection: Axis.horizontal,
                              //     itemCount: products
                              //         .length, // Number of product cards
                              //     itemBuilder: (context, index) {
                              //       var product =
                              //           products[index % products.length];

                              //       return Container(
                              //         width: dw * 0.35,
                              //         margin: EdgeInsets.only(right: 16),
                              //         child: _buildProductCard(
                              //           product['image']!,
                              //           product['title']!,
                              //           product['original']!,
                              //           product['discounted']!,
                              //           product['discount']!,
                              //           product['store']!,
                              //           dh,
                              //         ),
                              //       );
                              //     },
                              //   ),
                              // ),
                              SizedBox(height: 16),
                              // Product Horizontal Scrollable List
                              // Improved version with better handling
                              _isProductLoading
                                  ? Container(
                                      height: 300,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(height: 16),
                                            Text(
                                              "Finding matching products...",
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : _products.isEmpty
                                  ? Container(
                                      height: 300,
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
                                            SizedBox(height: 16),
                                            Text(
                                              "No products found",
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 300,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _products.length,
                                        itemBuilder: (context, index) {
                                          var product = _products[index];
                                          return Container(
                                            width: dw * 0.35,
                                            margin: EdgeInsets.only(right: 16),
                                            child: _buildProductCard(
                                              product.source,
                                              product.title,
                                              product.price,
                                              product.keyword,
                                              product.rating,
                                              product.source,
                                              dh,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                              SizedBox(height: 24),

                              // // Save This Look Button
                              // GlobalTextButton(
                              //   text: "Save This Look",
                              //   leftIcon: true,
                              //   leftIconData: HugeIcons.strokeRoundedBookmark02,
                              //   onPressed: () {},
                              // ),
                              // SizedBox(height: 16),

                              // Plan in Calendar Button
                              GlobalPinkButton(
                                text: (widget.eventId != null)
                                    ? "Lock this Look"
                                    : "Plan in Calender",
                                onPressed: () async {
                                  if (widget.eventId == null &&
                                      widget.eventId!.isEmpty)
                                    context.goNamed('eventmainscreen');
                                  else {
                                    await _lockingForEvent(
                                      widget.eventId!,
                                      _styledImageUrls,
                                    );
                                  }
                                },
                                // leftIcon: true,
                                // leftIconData: HugeIcons.strokeRoundedAdd01,
                              ),
                              SizedBox(height: 20),
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
            SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Failed to generate looks',
              style: GoogleFonts.libreFranklin(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
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
      height: 8,
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
            SizedBox(height: 12),
            Text(
              'No image available',
              style: TextStyle(color: Color(0xFF5D4037), fontSize: 14),
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
                SizedBox(height: 12),
                Text(
                  'Failed to load image',
                  style: TextStyle(color: Color(0xFF5D4037), fontSize: 14),
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
            SizedBox(height: 12),
            Text(
              'Invalid image data',
              style: TextStyle(color: Color(0xFF5D4037), fontSize: 14),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildProductCard(
    String imagePath,
    String title,
    String originalPrice,
    String discountedPrice,
    String discount,
    String store,
    double dh,
  ) {
    return Container(
      height: 300,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(32)),
                color: const Color(0xFFF5F5F5),
                image: DecorationImage(
                  image: NetworkImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.libreFranklin(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE91E63),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedFavourite,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (originalPrice.isNotEmpty) ...[
                      Text(
                        originalPrice,
                        style: GoogleFonts.libreFranklin(
                          fontSize: 14,
                          color: AppColors.subTitleTextColor,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      discountedPrice,
                      style: GoogleFonts.libreFranklin(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.titleTextColor,
                      ),
                    ),
                    if (discount.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          "(${discount} OFF)",
                          style: GoogleFonts.libreFranklin(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  store,
                  style: GoogleFonts.libreFranklin(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
            border: isSaved ? null : Border.all(color: Colors.pink, width: 2),
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
              ? const CircularProgressIndicator(strokeWidth: 2)
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
