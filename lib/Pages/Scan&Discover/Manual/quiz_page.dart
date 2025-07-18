import 'dart:developer' as Developer;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/services/DataSource/auth_api.dart';
import 'package:testing2/services/Temp/TempUserDataStore.dart';

class QuizPage extends StatefulWidget {
  final String body_shape;
  // final String quiz1;

  const QuizPage({
    super.key,
    required this.body_shape,
    // required this.quiz1
  });
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int? selectedIndex; // No pre-selection

  final List<VeinColor> veinColors = [
    VeinColor(
      title: 'Green',
      description: 'Suggests warm undertones.',
      color: Color(0xFF90C695),
    ),
    VeinColor(
      title: 'Blue',
      description: 'Suggests cool undertones.',
      color: Color(0xFF8B9DC3),
    ),
    VeinColor(
      title: 'Mix of it',
      description: 'Likely neutral undertones.',
      color: Color(0xFF88B5B5),
    ),
  ];
  bool _isLoading = false;
  late String tone;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<bool?> _checkLoginStatus() async {
    try {
      Developer.log("=== Starting Full Login + First Time Check ===");
      final prefs = await SharedPreferences.getInstance();
      // Not first time, check login tokens
      final accessToken = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');

      Developer.log(
        "Stored access token: ${accessToken?.substring(0, 20) ?? 'null'}...",
      );
      Developer.log(
        "Stored refresh token: ${refreshToken?.substring(0, 20) ?? 'null'}...",
      );

      final token = await AuthApiService.getCurrentToken();
      final isLoggedIn = await AuthApiService.isLoggedIn();

      Developer.log(
        "AuthApiService.getCurrentToken(): ${token?.substring(0, 20) ?? 'null'}...",
      );
      Developer.log("AuthApiService.isLoggedIn(): $isLoggedIn");

      if (!mounted) return false;

      if (isLoggedIn && token != null && token.isNotEmpty) {
        Developer.log(
          "✅ Token found and user is logged in. Validating with backend...",
        );
        final isValid = await AuthApiService.validateToken();

        if (isValid) {
          Developer.log("✅ Token is valid, navigating to home2");
          return true;
        } else {
          Developer.log("❌ Token invalid. Clearing tokens and going to home");
          await prefs.remove('access_token');
          await prefs.remove('refresh_token');
          return false;
        }
      } else {
        Developer.log("🚫 Not logged in or token empty. Navigating to home");
        return false;
      }
    } catch (e) {
      Developer.log("❌ Error checking login status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: Text(
                "Flip your wrist and carefully observe the color \nof the veins on the underside of your arms. \nFor best results, do it in natural light.",
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(14),
                  fontWeight: FontWeight.w500,
                  color: AppColors.titleTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.036613272),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: veinColors.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: VeinColorCard(
                      veinColor: veinColors[index],
                      isSelected: selectedIndex == index,
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.06407322,
              child: ElevatedButton(
                onPressed: selectedIndex != null
                    ? () async {
                        await TempUserDataStore().save(
                          bodyShape: widget.body_shape,
                          skinTone: selectedIndex == 0
                              ? "warm"
                              : selectedIndex == 1
                              ? "cool"
                              : "neutral",
                        );
                        context.goNamed('signup');
                      }
                    : null,

                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedIndex != null
                      ? AppColors.textPrimary
                      : Color(0xFFE5E7EA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  elevation: 0,
                ),
                child: (_isLoading)
                    ? CircularProgressIndicator(color: AppColors.textPrimary)
                    : Text(
                        'Submit',
                        style: GoogleFonts.libreFranklin(
                          color: selectedIndex != null
                              ? Colors.white
                              : Color(0xFF9EA2AE),
                          fontSize: MediaQuery.of(context).textScaler.scale(18),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.022883295),
          ],
        ),
      ),
    );
  }
}

class VeinColor {
  final String title;
  final String description;
  final Color color;

  VeinColor({
    required this.title,
    required this.description,
    required this.color,
  });
}

class VeinColorCard extends StatelessWidget {
  final VeinColor veinColor;
  final bool isSelected;
  final VoidCallback onTap;

  const VeinColorCard({
    Key? key,
    required this.veinColor,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isSelected ? const Color(0xFFFBD1D4) : const Color(0xFFFAFAFA),
          border: Border.all(
            color: isSelected ? AppColors.textPrimary : veinColor.color,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 101,
              height: 80,
              decoration: BoxDecoration(
                color: veinColor.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.textPrimary : veinColor.color,
                  width: 1,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    veinColor.title,
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(18),
                      fontWeight: FontWeight.w600,
                      color: AppColors.titleTextColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    veinColor.description,
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(14),
                      color: Color(0xFF9EA2AE),
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
