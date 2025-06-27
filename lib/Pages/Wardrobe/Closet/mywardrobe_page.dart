import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';

class MywardrobePage extends StatefulWidget {
  @override
  _MywardrobePageState createState() => _MywardrobePageState();
}

class _MywardrobePageState extends State<MywardrobePage> {
  final TextEditingController _occasionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Column(
        children: [
          // Fixed Header Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 12),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Zuri',
                                style: GoogleFonts.libreFranklin(
                                  color: AppColors.titleTextColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: " Closet",
                                style: GoogleFonts.libreFranklin(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
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
                        border: Border.all(
                          color: Color(0xFFD34169),
                          width: 0.63,
                        ),
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedNotification01,
                              color: AppColors.textPrimary,
                              size: 28,
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: AppColors.titleTextColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '4',
                                  style: GoogleFonts.libreFranklin(
                                    color: Colors.white,
                                    fontSize: 8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Action Buttons Row
                Row(
                  children: [
                    GlobalPinkButton(
                      text: "Closet",
                      onPressed: () {},
                      width: dw * 0.4328,
                      height: 42,
                      fontSize: 13.45,
                      leftIcon: true,
                      leftIconData: HugeIcons.strokeRoundedHanger,
                    ),
                    SizedBox(width: 12),
                    GlobalTextButton(
                      text: "Create outfits",
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => _buildCustomPopup1(context),
                        );
                      },
                      width: dw * 0.4328,
                      height: 42,
                      fontSize: 13.45,
                      leftIcon: true,
                      leftIconData: HugeIcons.strokeRoundedAdd01,
                      borderWidth: 1,
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  // Category Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    // childAspectRatio: 1.1,
                    children: [
                      _buildCategoryCard(
                        'Tops',
                        dh,
                        dw,
                        '(10 Items)',
                        Icons.checkroom,
                        () {
                          context.goNamed('allItemsWardrobe', extra: 2);
                        },
                      ),
                      _buildCategoryCard(
                        'Bottoms',
                        dh,
                        dw,
                        '(11 Items)',
                        Icons.ac_unit_sharp,
                        () {
                          context.goNamed('allItemsWardrobe', extra: 3);
                        },
                      ),
                      _buildCategoryCard(
                        'Ethnic',
                        dh,
                        dw,
                        '(19 Items)',
                        Icons.accessibility,
                        () {
                          context.goNamed('allItemsWardrobe', extra: 4);
                        },
                      ),
                      _buildCategoryCard(
                        'Footwear',
                        dh,
                        dw,
                        '(5 Items)',
                        Icons.shopping_bag,
                        () {
                          context.goNamed('allItemsWardrobe', extra: 8);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Browse All Items Button
                  GlobalTextButton(
                    text: "Browse All Item(s)",
                    onPressed: () {
                      context.goNamed('allItemsWardrobe', extra: 0);
                    },
                  ),
                  SizedBox(height: 16),

                  // Add New Item Button
                  GlobalPinkButton(
                    text: "Add New Item",
                    onPressed: () {
                      context.goNamed(
                        'uploadImageWardrobe',
                        extra: 'fromMyWardrobe',
                      );
                    },
                    leftIcon: true,
                    leftIconData: HugeIcons.strokeRoundedAdd01,
                  ),
                  SizedBox(height: 32),

                  // Personalized Recommendations Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Personalized recommendations',
                        style: GoogleFonts.libreFranklin(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF000000),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'View All',
                          style: GoogleFonts.libreFranklin(
                            color: Color(0xFF2563EB),
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        text:
                            'Based on what complements your closet and you ❤️',
                        style: GoogleFonts.libreFranklin(
                          color: Color(0xFF6D717F),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Recommendation Cards
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                  SizedBox(height: dh * 0.0366),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    double dh,
    double dw,
    String itemCount,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: dh * 0.20366,
        width: dw * 0.42288557,
        decoration: BoxDecoration(
          color: Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.textPrimary),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.grey[600]),
              SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.libreFranklin(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.titleTextColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                itemCount,
                style: GoogleFonts.libreFranklin(
                  fontSize: 12,
                  color: AppColors.subTitleTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for product cards
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
                    Text(
                      title,
                      style: GoogleFonts.libreFranklin(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedFavourite,
                      color: AppColors.titleTextColor,
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
                      Text(
                        "(${discount} OFF)",
                        style: GoogleFonts.libreFranklin(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomPopup1(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
        side: BorderSide(color: Color(0xFFFBC8CF), width: 2),
      ),
      surfaceTintColor: Color(0xFFFAFAFA),
      shadowColor: Color(0xFFFBC8CF),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Do you have anything\nspecific in mind?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.libreFranklin(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.titleTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                GlobalTextButton(
                  text: "Upload to create",
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.goNamed('uploadOutfit');
                  },
                  rightIcon: true,
                ),
                const SizedBox(height: 16),
                GlobalTextButton(
                  text: "Generate Fresh Ideas",
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the first dialog
                    showDialog(
                      context: context,
                      builder: (context) => _buildCustomPopup2(context),
                    );
                  },
                  rightIcon: true,
                ),
              ],
            ),
          ),
          // Close Button
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedCancelCircle,
                color: AppColors.error,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomPopup2(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
        side: BorderSide(color: Color(0xFFFBC8CF), width: 2),
      ),
      surfaceTintColor: Color(0xFFFAFAFA),
      shadowColor: Color(0xFFFBC8CF),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Please Enter your Occasion",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.libreFranklin(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD34169),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _occasionController,
                  decoration: InputDecoration(
                    hintText: 'Girls night out...',
                    hintStyle: GoogleFonts.libreFranklin(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: const BorderSide(
                        color: Color(0xFFD87A9B),
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GlobalPinkButton(
                  text: "Let’s style Babe",
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.goNamed(
                      'createOutfit',
                      queryParameters: {"occasion": _occasionController.text},
                    );
                  },
                  rightIcon: true,
                ),
              ],
            ),
          ),
          // Close Button
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedCancelCircle,
                color: AppColors.error,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
