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
  StyleRecommendationResponse? _recommendationResponse;

  @override
  void initState() {
    super.initState();
    _generateLook(widget.occation ?? "Casual");
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _generateLook(String occasion) async {
    setState(() {
      _isLoading = true;
    });

    final response = await GenerateLookService.generateLookForOccasion(
      occasion,
    );

    if (response != null) {
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
      Developer.log("❌ Failed to generate looks");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchStyleRecommender(
    String occasion,
    List<File> images,
  ) async {
    try {
      final response = await GenerateLookService.uploadAndGetRecommendation(
        imageFiles: images,
        occasion: occasion,
      );
      Developer.log(
        "🎉 Occasion: ${response?.aiGeneratedImages}, Images: ${response?.message}",
      );
      setState(() {
        _recommendationResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      Developer.log("❌ Failed to generate looks. Error is: ${e}");
      setState(() {
        _isLoading = false;
      });
    }
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
                    // folllow the main _shell app bar style------------------------------------------
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Create ",
                            style: GoogleFonts.libreFranklin(
                              color: AppColors.titleTextColor,
                              fontSize: 16,
                              // fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: "Outfit",
                            style: GoogleFonts.libreFranklin(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              // fontWeight: FontWeight.w600,
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
                ? Center(child: CircularProgressIndicator())
                : _generatedResponse == null
                ? Center(
                    child: Text(
                      'Failed to generate looks',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : _generatedResponse!.results.isEmpty
                ? Center(
                    child: Text(
                      'No outfit generated',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Dynamic Header based on current page
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Your Curated Look (${_currentIndex + 1}/${_generatedResponse!.results.length})",
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
                                _currentIndex <
                                        _generatedResponse!.results.length
                                    ? (_generatedResponse!
                                                  .results[_currentIndex]
                                                  .type
                                                  .toLowerCase() ==
                                              'wardrobe'
                                          ? "From your Closet"
                                          : "From Ask Zuri")
                                    : "From your Closet",
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
                          // need to adjust the height ... best 0.61
                          height: dh * 0.55,
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                            itemCount: _generatedResponse!.results.length,
                            itemBuilder: (context, index) {
                              final look = _generatedResponse!.results[index];
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
                                          look.image,
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
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _generatedResponse!.results.length,
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
                              // Recommendation Cards
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
      height: 300, // Fixed height instead of Expanded
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
