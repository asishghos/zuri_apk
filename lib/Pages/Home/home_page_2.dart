import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';

class HomePage2 extends StatefulWidget {
  HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  SharedPreferences? prefs = null;

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

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
                // const SizedBox(height: 20),
                // Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Builder(
                          builder: (context) => GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: CircleAvatar(
                              radius: 32,
                              backgroundColor: Color(0xFFE5E7EA),
                              child:
                                  (prefs?.getString("userProfilePic") != null &&
                                      prefs!
                                          .getString("userProfilePic")!
                                          .isNotEmpty)
                                  ? ClipOval(
                                      child: Image.network(
                                        prefs!.getString("userProfilePic")!,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : HugeIcon(
                                      icon: HugeIcons.strokeRoundedUser,
                                      color: AppColors.titleTextColor,
                                      size: 32,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back!',
                              style: GoogleFonts.libreFranklin(
                                color: AppColors.titleTextColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              prefs?.getString("userFullName") ?? "User",
                              style: GoogleFonts.libreFranklin(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
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
                                  icon: HugeIcons.strokeRoundedFavourite,
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
                                      '9',
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
                        const SizedBox(width: 12),
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
                  ],
                ),
                const SizedBox(height: 24),
                // Search Bar
                Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEB),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFD34169)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      const Icon(
                        IconlyLight.search,
                        color: Color(0xFFE91E63),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Style me for a...',
                            hintStyle: GoogleFonts.libreFranklin(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: const Icon(
                          IconlyLight.camera,
                          color: AppColors.textPrimary,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Latest from Zuri Unzipped Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Latest from Zuri Unzipped',
                        style: GoogleFonts.libreFranklin(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.titleTextColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Handle "All Stories" tap
                        },
                        child: Text(
                          'All Stories',
                          style: GoogleFonts.libreFranklin(
                            fontSize: 14,
                            color: Color(0xFF2563EB),
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Featured Article Card
                  Container(
                    width: double.infinity,
                    height: dh * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/home2/h1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Look Hot, Stay Cool',
                    style: GoogleFonts.libreFranklin(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFDC4C72),
                    ),
                  ),

                  Text(
                    '5 Beachwear Trends to Pack Now for your upcoming Goa Getaway!',
                    style: GoogleFonts.libreFranklin(
                      fontSize: 16,
                      color: Color(0xFF9EA2AE),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Easy Styling Section
                  Text(
                    'Few clicks. Full closet. Easy.',
                    style: GoogleFonts.libreFranklin(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.titleTextColor,
                    ),
                  ),

                  const SizedBox(height: 16),
                  // get started
                  Container(
                    width: double.infinity,
                    height: dh * 0.19,
                    padding: const EdgeInsets.only(top: 16, left: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE7E9),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upload pic(s) of your closet faves. We\'ll auto-style them for any of your upcoming events.',
                                style: GoogleFonts.libreFranklin(
                                  fontSize: 14,
                                  color: AppColors.subTitleTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  // Handle get started tap
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.textPrimary,
                                  foregroundColor: Color(0xFFFDE7E9),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                ),
                                child: Text(
                                  'Get started',
                                  style: GoogleFonts.libreFranklin(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        ClipRRect(
                          child: Image.asset('assets/images/home2/h2.png'),
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Hot & Fresh Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hot & Fresh: Just-Dropped\nPicks Curated for You',
                        style: GoogleFonts.libreFranklin(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.titleTextColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Handle "View All" tap
                        },
                        child: Text(
                          'View All',
                          style: GoogleFonts.libreFranklin(
                            fontSize: 14,
                            color: Color(0xFF2563EB),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Product Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 20,
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
                      _buildProductCard(
                        'assets/images/home2/h4.png',
                        'Pendant',
                        '',
                        '₹478',
                        '',
                        'Nykaa.com',
                        dh,
                      ),
                      _buildProductCard(
                        'assets/images/home2/h5.png',
                        'Blue Jeans',
                        '',
                        '₹700',
                        '',
                        'Amazon.in',
                        dh,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Style SOS Section
                  Text(
                    'Style SOS',
                    style: GoogleFonts.libreFranklin(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.titleTextColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    height: dh * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/home2/h7.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                      height: 300,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Upload a full-length snap of your look',
                    style: GoogleFonts.libreFranklin(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'For a planned or current event—and we\'ll tell you what slays, what sways, and how to turn up the heat.',
                    style: GoogleFonts.libreFranklin(
                      fontSize: 16,
                      color: Color(0xFF9EA2AE),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 16),
                  GlobalPinkButton(text: "Upload Now", onPressed: () {}),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
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
                    const Icon(
                      Icons.favorite_border,
                      color: AppColors.titleTextColor,
                      size: 20,
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
}
