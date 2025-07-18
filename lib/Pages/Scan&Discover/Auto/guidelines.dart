import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';

class PhotoUploadGuidelinesPage extends StatelessWidget {
  const PhotoUploadGuidelinesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24),
          onPressed: () => context.goNamed('scan&discover'),
        ),
        title: Text(
          '3 dos and don\'ts for pic(s) that \nwe can scan to the T.',
          style: GoogleFonts.libreFranklin(
            fontSize: MediaQuery.of(context).textScaler.scale(20),
            color: Color(0xFF121417),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.018306636),
            // Main title
            Text(
              'Your beautiful body\'s got range!',
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(20),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.013729977),

            // Subtitle
            Text(
              'Let\'s explore every nook, curve, and contour so you can look your hottest!',
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(16),
                color: AppColors.titleTextColor,
                height: 1.4,
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.036613272),

            // Good examples row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildPhotoExample(
                    imagePath: 'assets/images/guidelines/p5.png',
                    title: 'Full length pic(s)',
                    green: true,
                    red: false,
                    context: context,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildPhotoExample(
                    imagePath: 'assets/images/guidelines/p1.png',
                    title: 'Good lighting',
                    green: true,
                    red: false,
                    context: context,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildPhotoExample(
                    imagePath: 'assets/images/guidelines/p6.png',
                    title: 'Pro mirror selfie',
                    green: true,
                    red: false,
                    context: context,
                  ),
                ),
              ],
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.036613272),

            // Second section title
            Text(
              'Not all body scan pics are created equal.',
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(20),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.013729977),

            // Second subtitle with heart emoji
            RichText(
              text: TextSpan(
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                  color: AppColors.titleTextColor,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text:
                        'Adorable as these are, save them for your Insta or group chats 💕',
                  ),
                ],
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.0274599),

            // Bad examples row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildPhotoExample(
                    imagePath: 'assets/images/guidelines/p4.png',
                    title: 'Side or back view',
                    green: false,
                    red: true,
                    context: context,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildPhotoExample(
                    imagePath: 'assets/images/guidelines/p2.png',
                    title: 'Obstructed View',
                    green: false,
                    red: true,
                    context: context,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildPhotoExample(
                    imagePath: 'assets/images/guidelines/p3.png',
                    title: 'Group Pics',
                    green: false,
                    red: true,
                    context: context,
                  ),
                ),
              ],
            ),

            SizedBox(height: 36),

            // Upload button
            GlobalPinkButton(
              text: "Upload Pic(s)",
              onPressed: () => context.goNamed('scan&discover'),
              rightIcon: true,
              rightIconData: IconlyLight.upload,
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.018306636),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoExample({
    required String imagePath,
    required String title,
    required bool red,
    required bool green,
    required BuildContext context,
  }) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  width: 150,
                  height: MediaQuery.of(context).size.height * 0.2059490,
                  fit: BoxFit.cover,
                ),
              ),
              if (green)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.check,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (red)
                Positioned(
                  top: 8,
                  right: 8,
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
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.009153318),
          Text(
            title,
            style: GoogleFonts.libreFranklin(
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).textScaler.scale(14),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
