import 'dart:developer' as Developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing2/Global/Colors/app_colors.dart';

class ZuriChatScreen extends StatefulWidget {
  const ZuriChatScreen({Key? key}) : super(key: key);

  @override
  State<ZuriChatScreen> createState() => _ZuriChatScreenState();
}

class _ZuriChatScreenState extends State<ZuriChatScreen> {
  final TextEditingController _textController = TextEditingController();

  // Add these new variables
  File? _uploadedImage;
  final ImagePicker _picker = ImagePicker();
  List<String> _quickPrompts = [
    "How does this outfit look on me? Any styling tips?",
    "What accessories would go well with this look?",
    "Is this appropriate for a formal event?",
  ];
  int? _selectedPromptIndex;
  SharedPreferences? prefs;

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
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Add image picker method
  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        var status = await Permission.camera.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Camera permission denied'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      } else if (source == ImageSource.gallery) {
        var status = await Permission.photos.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gallery permission denied'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _uploadedImage = File(pickedFile.path);
          _selectedPromptIndex = null;
        });
      }
    } catch (e) {
      debugPrint('Error in _pickImage: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Add image picker modal
  void _showPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Image Source',
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(18),
                    fontWeight: FontWeight.w600,
                    color: AppColors.titleTextColor,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.022883295,
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          _pickImage(ImageSource.gallery);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.photo_library,
                                size: 40,
                                color: AppColors.textPrimary,
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height *
                                    0.009153318,
                              ),
                              Text(
                                'Gallery',
                                style: GoogleFonts.libreFranklin(
                                  fontSize: MediaQuery.of(
                                    context,
                                  ).textScaler.scale(16),
                                  color: AppColors.titleTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          _pickImage(ImageSource.camera);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: AppColors.textPrimary,
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height *
                                    0.009153318,
                              ),
                              Text(
                                'Camera',
                                style: GoogleFonts.libreFranklin(
                                  fontSize: MediaQuery.of(
                                    context,
                                  ).textScaler.scale(16),
                                  color: AppColors.titleTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.022883295,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Add method to handle prompt selection
  void _selectPrompt(String prompt) {
    setState(() {
      _textController.text = prompt;
    });
  }

  // Add method to navigate with image
  void _navigateWithContent() {
    if (_uploadedImage != null || _textController.text.isNotEmpty) {
      // You can pass both text and image to the next screen
      // For now, just navigating with text as in original code
      context.goNamed(
        'affiliate',
        extra: {
          'text': _textController.text,
          'image': _uploadedImage?.path, // Pass image path if needed
        },
        queryParameters: {
          'keywords': [], // "Yoga pants,Wristlet"
          'needToOpenAskZuri': 'true', // "false"
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top section with AskZuri and history icon
              Row(
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
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(18),
                            ),
                          ),
                          TextSpan(
                            text: ' Zuri',
                            style: GoogleFonts.libreFranklin(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(18),
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

              // Flexible content area
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),

                      // Animated center icon with proper error handling
                      Container(
                        width: 150,
                        height: 150,
                        child: _buildLottieAnimation(),
                      ),

                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.022883295,
                      ),

                      // Main text with proper constraints
                      Container(
                        constraints: const BoxConstraints(maxWidth: 650),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.libreFranklin(
                              fontWeight: FontWeight.w600,
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(24),
                              letterSpacing: -0.40,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    'Hey, ${prefs?.getString("userFullName") ?? "User"} ',
                              ),
                              TextSpan(
                                text: 'Style questions?\nHot takes? ',
                                style: GoogleFonts.libreFranklin(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: MediaQuery.of(
                                    context,
                                  ).textScaler.scale(24),
                                  letterSpacing: -0.40,
                                ),
                              ),
                              const TextSpan(text: 'Let\'s make it fashion.'),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.009153318,
                      ),

                      // Subtitle text with proper constraints
                      Text(
                        "Ask in any language you're comfortable with — Zuri speaks them all",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.libreFranklin(
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).textScaler.scale(14),
                          color: AppColors.subTitleTextColor,
                        ),
                      ),

                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.009153318,
                      ),

                      // Prompt buttons with overflow protection
                      Row(
                        children: [
                          Expanded(
                            child: _buildPromptButton(
                              'Help me plan my beach vacay wardrobe.',
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildPromptButton(
                              'Where can I find affordable versions of this look?',
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                    ],
                  ),
                ),
              ),

              // Image preview and quick prompts section
              if (_uploadedImage != null) ...[
                Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _uploadedImage!,
                              width:
                                  MediaQuery.of(context).size.width * 0.1492537,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Choose a quick prompt or type your own:',
                              style: GoogleFonts.libreFranklin(
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(14),
                                fontWeight: FontWeight.w500,
                                color: AppColors.titleTextColor,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _uploadedImage = null;
                                _selectedPromptIndex = null;
                              });
                            },
                            icon: Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.013729977,
                      ),
                      // Quick prompts
                      ...List.generate(_quickPrompts.length, (index) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPromptIndex = index;
                                _textController.text = _quickPrompts[index];
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedPromptIndex == index
                                    ? AppColors.textPrimary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _selectedPromptIndex == index
                                      ? AppColors.textPrimary
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Text(
                                _quickPrompts[index],
                                style: GoogleFonts.libreFranklin(
                                  fontSize: 13,
                                  color: _selectedPromptIndex == index
                                      ? Colors.white
                                      : AppColors.titleTextColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],

              // Input field with attach icon - always at bottom
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
                          _showPicker();
                        },
                        child: Container(
                          width: 24,
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedFileAttachment,
                            color: AppColors.titleTextColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16), // Text input field
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: _uploadedImage != null
                                ? 'How can we help you with this gorg image?'
                                : 'Ask Zuri...',
                            hintStyle: GoogleFonts.libreFranklin(
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(16),
                              color: AppColors.titleTextColor,
                            ),
                          ),
                          style: GoogleFonts.libreFranklin(
                            fontWeight: FontWeight.w500,
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(16),
                            color: Colors.black,
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              _navigateWithContent();
                            }
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
                            _navigateWithContent();
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
              color: Colors.white,
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
