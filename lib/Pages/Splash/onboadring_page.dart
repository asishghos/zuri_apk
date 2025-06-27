import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: "Scan & Discover",
      description:
          "Analyze your skin tone and body shape for dream fits, cuts, and color suggestions.",
      imagePath: "assets/images/onboarding/mirrorselfie.png",
      svgpath: 'assets/images/onboarding/s2.svg',
    ),
    OnboardingData(
      title: "Your Digital Wardrobe",
      description:
          "Get styled looks from your digital closet- automatically! Make every moment a runway moment.",
      imagePath: "assets/images/onboarding/wardribe_upload.png",
      svgpath: 'assets/images/onboarding/s1.svg',
    ),
    OnboardingData(
      title: "Style SOS?",
      description:
          "Get instant style feedback for an important event or occasion. Or just another day.",
      imagePath: "assets/images/onboarding/interview_image.png",
      svgpath: 'assets/images/onboarding/s3.svg',
    ),
  ];

  void _goToNextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      // Go to next page
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.goNamed('scan&discover');
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.80,
                  child: Stack(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.90,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            Image.asset(
                              _onboardingData[index].imagePath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.70,
                            ),
                            Positioned(
                              top: 50,
                              right: 36,
                              child: GestureDetector(
                                onTap: _goToNextPage,
                                child: SvgPicture.asset(
                                  'assets/images/onboarding/Frame1.svg',
                                  height: 50.0,
                                  width: 50.0,
                                  allowDrawingOutsideViewBox: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.60,
                          ),
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.30,
                            decoration: BoxDecoration(
                              color: Color(0xFFDC4C72),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: SvgPicture.asset(
                                      _onboardingData[index].svgpath,
                                      height: 50.0,
                                      width: 50.0,
                                      allowDrawingOutsideViewBox: true,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    _onboardingData[index].title,
                                    style: GoogleFonts.libreFranklin(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    _onboardingData[index].description,
                                    style: GoogleFonts.libreFranklin(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 32),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            color: Color(0xFFDC4C72),
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.10,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _onboardingData.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: Colors.white,
                    dotColor: Colors.white.withOpacity(0.4),
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "${_currentPage + 1} of ${_onboardingData.length}",
                  style: GoogleFonts.libreFranklin(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
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

class OnboardingData {
  final String title;
  final String description;
  final String imagePath;
  final String svgpath;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.svgpath,
  });
}
