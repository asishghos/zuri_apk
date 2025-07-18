import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testing2/Global/Colors/app_colors.dart';

class CheckEmailPage extends StatelessWidget {
  const CheckEmailPage({Key? key}) : super(key: key);

  void _tryAnotherEmail(BuildContext context) {
    // Navigate back to the reset password page
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Email Icon
              const Icon(
                IconlyLight.message,
                size: 112,
                color: Color(0xFFD87A9B),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.04576659),

              // Main Title
              Text(
                'Babe, Check your Email',
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(28),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.018306636,
              ),

              // Subtitle
              Text(
                'We\'ve sent a password recovery link.',
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                  color: Colors.black54,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // Bottom Text with Link
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(14),
                    color: Colors.black54,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'Did not receive the email? Check your promotions or other tab or try another ',
                    ),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () => _tryAnotherEmail(context),
                        child: Text(
                          'email address',
                          style: GoogleFonts.libreFranklin(
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(14),
                            color: Color(0xFF4285F4),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF4285F4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.04576659),
            ],
          ),
        ),
      ),
    );
  }
}
