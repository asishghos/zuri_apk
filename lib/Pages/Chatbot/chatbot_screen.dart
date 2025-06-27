import 'dart:developer' as Developer;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:testing2/Global/Colors/app_colors.dart';

class ZuriChatScreen extends StatefulWidget {
  final String userName;

  const ZuriChatScreen({Key? key, required this.userName}) : super(key: key);

  @override
  State<ZuriChatScreen> createState() => _ZuriChatScreenState();
}

class _ZuriChatScreenState extends State<ZuriChatScreen> {
  final TextEditingController _textController = TextEditingController();
  // bool _hasText = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: IntrinsicHeight(
          child: Column(
            children: [
              // Top section with AskZuri and history icon
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // AskZuri text
                    Flexible(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Ask',
                              style: GoogleFonts.libreFranklin(
                                color: AppColors.titleTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                            TextSpan(
                              text: ' Zuri',
                              style: GoogleFonts.libreFranklin(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // History icon
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.textPrimary,
                          width: 0.63,
                        ),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: IconButton(
                        onPressed: () {
                          // Navigate to history screen
                        },
                        icon: const Icon(
                          Icons.history,
                          color: AppColors.textPrimary,
                          size: 24,
                          weight: 0.63,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Animated center icon with proper error handling
              Container(
                width: 150,
                height: 150,
                child: _buildLottieAnimation(),
              ),

              const SizedBox(height: 48),

              // Main text with proper constraints
              Container(
                constraints: const BoxConstraints(maxWidth: 650),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.libreFranklin(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      height: 28 / 24,
                      letterSpacing: -0.40,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(text: 'Hey, ${widget.userName} '),
                      TextSpan(
                        text: 'Style questions?\nHot takes? ',
                        style: GoogleFonts.libreFranklin(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                          height: 28 / 24,
                          letterSpacing: -0.40,
                        ),
                      ),
                      const TextSpan(text: 'Let\'s make it fashion.'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle text with proper constraints
              Container(
                child: Text(
                  "Ask in any language you're comfortable with — Zuri speaks them all",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.libreFranklin(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.subTitleTextColor,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Prompt buttons with overflow protection
              Row(
                children: [
                  Expanded(
                    child: _buildPromptButton(
                      'Help me plan my beach vacay wardrobe.',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPromptButton(
                      'Where can I find affordable versions of this look?',
                    ),
                  ),
                ],
              ),

              SizedBox(height: dh * 0.23),

              // Input field with attach icon
              Container(
                height: dh * 0.065,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  border: Border.all(color: AppColors.textPrimary),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // Attach icon
                    Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: GestureDetector(
                        onTap: () {
                          // Handle attachment action
                          print('Attach button tapped');
                        },
                        child: Container(
                          width: 22,
                          height: 22,
                          //png nhi hogaa
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedFileAttachment,
                            color: AppColors.titleTextColor,
                          ),
                        ),
                      ),
                    ),
                    // Text input field
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Ask Zuri...',
                            hintStyle: GoogleFonts.libreFranklin(
                              fontSize: 16,
                              color: AppColors.titleTextColor,
                            ),
                          ),
                          style: GoogleFonts.libreFranklin(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    // Send button (shows when text is entered)
                    if (_textController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: IconButton(
                          onPressed: () {
                            Developer.log(
                              'Send message: ${_textController.text}',
                            );
                            context.goNamed(
                              'affiliate',
                              extra: _textController.text,
                            );
                          },
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowRight01,
                            color: AppColors.titleTextColor,
                            size: 28,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLottieAnimation() {
    return FutureBuilder(
      future: _checkAssetExists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.textPrimary),
          );
        }

        if (snapshot.hasError || snapshot.data == false) {
          // Fallback icon if Lottie asset doesn't exist
          return Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: BorderRadius.circular(75),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: AppColors.textPrimary,
            ),
          );
        }
        return Lottie.asset('assets/images/chatbot/animation.json');
      },
    );
  }

  Future<bool> _checkAssetExists() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return true; // Assume asset exists for now
    } catch (e) {
      return false;
    }
  }

  Widget _buildPromptButton(String text) {
    return GestureDetector(
      onTap: () {
        _textController.text = text;
        setState(() {});
      },
      child: Container(
        padding: EdgeInsets.all(8),
        height: 76,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.libreFranklin(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColors.titleTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
