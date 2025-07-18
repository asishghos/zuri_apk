import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testing2/Global/Colors/app_colors.dart';

class GuidelinesPage extends StatelessWidget {
  const GuidelinesPage({Key? key}) : super(key: key);

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
          'Dos & Don’ts for Snapping Items \ninto Your Zuri Closet',
          style: GoogleFonts.libreFranklin(
            fontSize: MediaQuery.of(context).textScaler.scale(16),
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
              'Closet Upload- Doing it Right 👍',
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(20),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.013729977),

            // Subtitle
            Text(
              'For Zuri to nail your look, upload clear flatlays, gallery shots, or order screenshots.',
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
                    title: 'Gallery Image',
                    green: true,
                    red: false,
                    context: context,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildPhotoExample(
                    imagePath: 'assets/images/guidelines/p7.png',
                    title: 'Flatlay Upload',
                    green: true,
                    red: false,
                    context: context,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildPhotoExample(
                    imagePath: 'assets/images/guidelines/p9.png',
                    title: 'Order Screenshot',
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
              'Closet Upload- Doing it Wrong 👎',
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
                        'For the most accurate analysis, please avoid the following.',
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
                    imagePath: 'assets/images/guidelines/p12.png',
                    title: 'Incomplete views',
                    green: false,
                    red: true,
                    context: context,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildPhotoExample(
                    imagePath: 'assets/images/guidelines/p11.png',
                    title: 'Multiple items',
                    green: false,
                    red: true,
                    context: context,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildPhotoExample(
                    imagePath: 'assets/images/guidelines/p10.png',
                    title: 'Low resolution image',
                    green: false,
                    red: true,
                    context: context,
                  ),
                ),
              ],
            ),

            SizedBox(height: 36),

            // Upload button
            // GlobalPinkButton(
            //   text: "Upload Pic(s)",
            //   onPressed: () => context.goNamed('scan&discover'),
            //   rightIcon: true,
            //   rightIconData: IconlyLight.upload,
            // ),

            // SizedBox(height: MediaQuery.of(context).size.height * 0.018306636),
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
                  height: MediaQuery.of(context).size.height * 0.02059490,
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
