import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testing2/Global/Colors/app_colors.dart';

class GuidelinesPage extends StatelessWidget {
  const GuidelinesPage({Key? key}) : super(key: key);

  Widget _buildPhotoExample({
    required String imagePath,
    required String title,
    required bool red,
    required bool green,
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
                  height: 180,
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
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Zuri Closet Goals Start Here—Upload It All',
          style: GoogleFonts.libreFranklin(
            fontSize: 16,
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
            const SizedBox(height: 16),
            // Main title
            Text(
              'Closet Upload – Do it Right',
              style: GoogleFonts.libreFranklin(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            // Subtitle
            Text(
              'For Zuri to nail your look, upload clear pics flatlays, gallery shots, or order screenshots work best.',
              style: GoogleFonts.libreFranklin(
                fontSize: 16,
                color: AppColors.titleTextColor,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 32),

            // Good examples row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildPhotoExample(
                    imagePath: 'assets/images/guidelines/p5.png',
                    title: 'Gallery Image',
                    green: true,
                    red: false,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPhotoExample(
                    imagePath: 'assets/images/guidelines/p7.png',
                    title: 'Flatlay Upload',
                    green: true,
                    red: false,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPhotoExample(
                    imagePath: 'assets/images/guidelines/p8.png',
                    title: 'Order Screenshot',
                    green: true,
                    red: false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Second section title
            Text(
              'Avoid these for best results',
              style: GoogleFonts.libreFranklin(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            // Second subtitle with heart emoji
            RichText(
              text: TextSpan(
                style: GoogleFonts.libreFranklin(
                  fontSize: 16,
                  color: AppColors.titleTextColor,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text:
                        'For the most accurate analysis, please follow \nthese guidelines:',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

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
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPhotoExample(
                    imagePath: 'assets/images/guidelines/p2.png',
                    title: 'Obstructed View',
                    green: false,
                    red: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPhotoExample(
                    imagePath: 'assets/images/guidelines/p3.png',
                    title: 'Group Pics',
                    green: false,
                    red: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 36),

            // Upload button
            // GlobalPinkButton(
            //   text: "Upload Pic(s)",
            //   onPressed: () => context.goNamed('scan&discover'),
            //   rightIcon: true,
            //   rightIconData: IconlyLight.upload,
            // ),

            // const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
