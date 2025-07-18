import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
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
                            child: const CircleAvatar(
                              radius: 24,
                              backgroundColor: Color(0xFFE5E7EA),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedUser,
                                color: AppColors.titleTextColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome!',
                              style: GoogleFonts.libreFranklin(
                                color: AppColors.titleTextColor,
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(16),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Guest",
                              style: GoogleFonts.libreFranklin(
                                color: AppColors.textPrimary,
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(16),
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
                          child: const Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedFavourite,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
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
                          child: const Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedNotification01,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // SizedBox(height: dh * 0.02746),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  Text(
                    "What's your 1st style move?",
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(24),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  SizedBox(height: dh * 0.02746),

                  // Section 1: Personalized Style
                  _buildStyleSection(
                    dh: dh,
                    title:
                        "1. Personalized style starts here. \nLet's scan and slay.",
                    description:
                        "Analyze my body type and skin tone to reveal my dream fits, cuts + colors!",
                    imageUrl:
                        'assets/images/home/WhatsApp Image 2025-06-06 at 15.55.23_eb1ae316.jpg',
                    buttonText: "Read me, Zuri!",
                    buttonColor: AppColors.textPrimary,
                    badgeText: "Recommended First",
                    onPressed: () {
                      context.goNamed('scan&discover');
                    },
                  ),

                  SizedBox(height: dh * 0.0366),

                  // Section 2: Upload Closet
                  _buildStyleSection(
                    dh: dh,
                    title: "2. Few clicks. Full closet. Easy.",
                    description:
                        "Upload pic(s) of your closet faves. We'll auto-style them for any of your upcoming events.",
                    imageUrl:
                        'assets/images/home/wardribe_upload-removebg-preview.png',
                    buttonText: "Get started",
                    buttonColor: AppColors.textPrimary,
                    onPressed: () {},
                  ),

                  SizedBox(height: dh * 0.0366),

                  // Section 3: Style SOS
                  _buildStyleSection(
                    dh: dh,
                    title: "3. Style SOS",
                    description:
                        "Upload a full-length snap of your look for a planned or current event—and we'll tell you what slays, what sways, and how to turn up the heat.",
                    imageUrl:
                        'assets/images/home/WhatsApp Image 2025-06-05 at 16.20.28_ba0d97bc.jpg',
                    buttonText: "Upload Now",
                    buttonColor: AppColors.textPrimary,
                    onPressed: () {},
                  ),

                  SizedBox(height: dh * 0.05),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSection({
    required double dh,
    required String title,
    required String description,
    required String imageUrl,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onPressed,
    String? badgeText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and subtitle
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            title,
            style: GoogleFonts.libreFranklin(
              fontSize: MediaQuery.of(context).textScaler.scale(20),
              fontWeight: FontWeight.w600,
              color: AppColors.titleTextColor,
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.018306636),

        // Image container with overlay
        Container(
          height: dh * 0.3,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // Background image
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imageUrl),
                      fit: BoxFit.cover,
                      alignment: Alignment
                          .topCenter, // Focus on top part where faces usually are
                    ),
                  ),
                ),

                // Badge (if provided)
                if (badgeText != null)
                  Positioned(
                    top: 15,
                    child: Container(
                      child: Stack(
                        children: [
                          SvgPicture.asset(
                            "assets/images/home/Rectangle 4397.svg",
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 8),
                            child: Text(
                              badgeText,
                              style: GoogleFonts.saira(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        SizedBox(height: MediaQuery.of(context).size.height * 0.018306636),

        // Description
        Text(
          description,
          style: GoogleFonts.libreFranklin(
            fontSize: MediaQuery.of(context).textScaler.scale(14),
            color: AppColors.titleTextColor,
          ),
        ),

        SizedBox(height: MediaQuery.of(context).size.height * 0.022883295),

        // Button
        GlobalPinkButton(text: buttonText, onPressed: onPressed),
      ],
    );
  }
}
