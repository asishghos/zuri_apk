import 'dart:convert';
import 'dart:developer' as Developer;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/services/Class/styling_model.dart';
import 'package:testing2/services/DataSource/styling_api.dart';

class CreateOutfitPage extends StatefulWidget {
  final String? occation;
  final List<File>? images;
  CreateOutfitPage({Key? key, required this.occation, this.images})
    : super(key: key);
  @override
  State<CreateOutfitPage> createState() => _CreateOutfitPageState();
}

class _CreateOutfitPageState extends State<CreateOutfitPage> {
  PageController _pageController = PageController();
  int _currentIndex = 0;
  GeneratedOccasionResponse? _generatedResponse;
  StyledOutfitResponse? _recommendationResponse;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.images == null || widget.images!.isEmpty) {
      _generateLook(widget.occation ?? "Casual");
    } else {
      _fetchStyleRecommender("Casual", widget.images!);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _generateLook(String occasion) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await GenerateLookService.generateLookForOccasion(
        occasion,
      );
      Developer.log(response.toString());

      if (response != null && response.results.isNotEmpty) {
        Developer.log(
          "🎉 Occasion: ${response.occasion}, Images: ${response.message}",
        );
        for (var look in response.results) {
          Developer.log(
            "➡️ ${look.type} look${look.lookNumber != null ? ' #${look.lookNumber}' : ''}",
          );
        }
        setState(() {
          _generatedResponse = response;
          _isLoading = false;
        });
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

  Future<void> _fetchStyleRecommender(
    String occasion,
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
      );

      if (response!.results.isEmpty) {
        // Developer.log(response.toString());
        Developer.log(
          "🎉 Occasion: ${response.occasion}, Recommendations: ${response.recommendations}",
        );
        setState(() {
          _recommendationResponse = response;
          _isLoading = false;
        });
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

  bool get _hasData {
    return (_generatedResponse != null &&
            _generatedResponse!.results.isNotEmpty) ||
        (_recommendationResponse != null &&
            _recommendationResponse!.results.isNotEmpty);
  }

  int get _totalItems {
    if (_generatedResponse != null) {
      return _generatedResponse!.results.length;
    } else if (_recommendationResponse != null) {
      return _recommendationResponse!.results.length;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Column(
        children: [
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
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Create ",
                            style: GoogleFonts.libreFranklin(
                              color: AppColors.titleTextColor,
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text: "Outfit",
                            style: GoogleFonts.libreFranklin(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEB),
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFFD34169), width: 0.63),
                  ),
                  child: const Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedShare08,
                      color: AppColors.textPrimary,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            child: _isLoading
                ? LoadingPage()
                : !_hasData
                ? _buildErrorState()
                : SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Dynamic Header based on current page
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Your Curated Look (${_currentIndex + 1}/$_totalItems)",
                              style: GoogleFonts.libreFranklin(
                                color: AppColors.titleTextColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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

                        SizedBox(height: 16),

                        // PageView for sliding images
                        Container(
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
                              String imageData = _getImageData(index);
                              return Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.grey[200],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: _buildBase64Image(
                                          imageData,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "This is the space for AI gen image description lorem ipsum lorem ipsum lorem lorem",
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

                              // Product Grid
                              GridView.count(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.60,
                                children: [
                                  _buildProductCard(
                                    'assets/images/home2/h6.png',
                                    'Blue Kurta',
                                    '₹1,299',
                                    '₹363',
                                    '72%',
                                    'Amazon.in',
                                    dh,
                                  ),
                                  _buildProductCard(
                                    'assets/images/home2/h3.png',
                                    'Black Heels',
                                    '₹1,006',
                                    '₹503',
                                    '50%',
                                    'Myntra.com',
                                    dh,
                                  ),
                                ],
                              ),

                              SizedBox(height: 24),

                              // Save This Look Button
                              GlobalTextButton(
                                text: "Save This Look",
                                leftIcon: true,
                                leftIconData: HugeIcons.strokeRoundedBookmark02,
                                onPressed: () {},
                              ),
                              SizedBox(height: 16),

                              // Plan in Calendar Button
                              GlobalPinkButton(
                                text: "Plan in Calender",
                                onPressed: () {},
                                leftIcon: true,
                                leftIconData: HugeIcons.strokeRoundedAdd01,
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

  String _getSourceText() {
    if (_generatedResponse != null &&
        _currentIndex < _generatedResponse!.results.length) {
      return _generatedResponse!.results[_currentIndex].type.toLowerCase() ==
              'wardrobe'
          ? "From your Closet"
          : "From Ask Zuri";
    }
    return "From your Closet";
  }

  String _getImageData(int index) {
    if (_generatedResponse != null &&
        index < _generatedResponse!.results.length) {
      return _generatedResponse!.results[index].image;
    } else if (_recommendationResponse != null &&
        index < _recommendationResponse!.results.length) {
      return _recommendationResponse!.results[index].imageB64!;
    }
    return '';
  }

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
    String base64String, {
    BoxFit fit = BoxFit.contain,
    double? width,
    double? height,
  }) {
    if (base64String.isEmpty) {
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
      // Remove data:image/jpeg;base64, prefix if present
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',')[1];
      }

      Uint8List bytes = base64Decode(cleanBase64);
      return Image.memory(
        bytes,
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
                  image: AssetImage(imagePath),
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
