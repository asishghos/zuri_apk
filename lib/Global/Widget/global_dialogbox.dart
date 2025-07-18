import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testing2/Global/Colors/app_colors.dart';

class GlobalDialogBox extends StatelessWidget {
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onTap;
  final bool buttonNeed;
  final bool? needCancleButton;
  GlobalDialogBox({
    Key? key,
    required this.title,
    required this.description,
    this.buttonText,
    this.onTap,
    required this.buttonNeed,
    this.needCancleButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.0),
        border: Border.all(color: const Color(0xFFFBC8CF), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (needCancleButton == true)
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop(); // Dismiss the dialog when tapped
                },
                child: Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    shape:
                        BoxShape.circle, // Circular shape for the close button
                    border: Border.all(
                      color: const Color(
                        0xFFE91E63,
                      ), // Pink border for the circle
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.close, // The 'X' icon
                    color: Color(0xFFD34169), // Pink color for the icon
                    size: 14,
                  ),
                ),
              ),
            ),

          SizedBox(height: 15), // Vertical space
          // "Uh Oh!" title
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.libreFranklin(
              fontSize: MediaQuery.of(context).textScaler.scale(20),
              fontWeight: FontWeight.w600,
              color: const Color(0xFFD34169), // Pink color for the title
            ),
          ),
          SizedBox(height: 15),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.libreFranklin(
              fontSize: MediaQuery.of(context).textScaler.scale(16),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF979797),
            ),
          ),
          SizedBox(height: 25),
          if (buttonNeed)
            ElevatedButton(
              onPressed: () {
                onTap!();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor:
                    Colors.white, // White text color for the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    32.0,
                  ), // Rounded corners for the button
                ),
                padding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the text and icon
                children: [
                  Text(
                    buttonText!,
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8), // Space between text and icon
                  const Icon(
                    Icons.arrow_forward, // Forward arrow icon
                    size: 20,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
