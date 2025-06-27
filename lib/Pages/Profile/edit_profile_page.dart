import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_dialogbox.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Global/Widget/image_pick_global_logic.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late SharedPreferences prefs;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _footHeightController = TextEditingController();
  final TextEditingController _inchHeightController = TextEditingController();
  final TextEditingController _locationController = TextEditingController(
    text: 'Malda',
  );

  // Global imge picker widget
  final _imagePickerService = ImagePickerService();
  File? _imageFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  void _handlePickImage() {
    _imagePickerService.showImageSourcePicker(
      context: context,
      onStartLoading: () {
        setState(() => _isLoading = true);
      },
      onStopLoading: () {
        setState(() => _isLoading = false);
      },
      onValidImagePicked: (imageFile) {
        _imageFile = imageFile;
        context.goNamed('autoUpload');
      },
      onInvalidImage: () {},
    );
  }

  String selectedBodyShape = 'Hourglass';
  String selectedSkinUndertone = 'Warm';
  String selectedLocation = 'Malda';
  bool isBodyShapeExpanded = false;
  bool isSkinToneExpanded = false;
  bool isLocationExpanded = false;

  final List<String> bodyShapeOptions = [
    'Hourglass',
    'Pear',
    'Apple',
    'Rectangle',
    'Inverted Triangle',
  ];

  final List<String> skinUndertoneOptions = ['Warm', 'Cool', 'Neutral'];

  final List<String> _indianLocations = [
    'Malda, West Bengal, India',
    'Kolkata, West Bengal, India',
    'Mumbai, Maharashtra, India',
    'Delhi, India',
    'Bengaluru, Karnataka, India',
    'Chennai, Tamil Nadu, India',
    'Hyderabad, Telangana, India',
    // Add more as needed
  ];

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userFullName') ?? '';
      _emailController.text = prefs.getString('userEmail') ?? '';
    });
  }

  bool showLocationSuggestions = false;

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            // Fixed Header Section
            Container(
              color: AppColors.textPrimary,
              height: dh * 0.23,
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(IconlyLight.arrowLeft2, size: 24),
                          color: Colors.white,
                          onPressed: () {
                            context.goNamed('profileAfterLogin');
                          },
                        ),
                        Text(
                          'Edit Profile',
                          style: GoogleFonts.libreFranklin(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Profile Image
                    Expanded(
                      child: Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 46,
                              backgroundImage: NetworkImage(
                                'http://placebeard.it/250/250',
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    // Handle image edit
                                    _handlePickImage();
                                  },
                                  child: Icon(
                                    IconlyLight.edit,
                                    color: Colors.grey[700],
                                    size: 18,
                                  ),
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

            // Scrollable Form Section
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Name Field
                        Text(
                          'Full Name',
                          style: GoogleFonts.libreFranklin(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212936),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          label: 'Full Name',
                          keyboardType: TextInputType.name,
                          controller: _nameController,
                          showClearButton: true,
                          showChangeButton: false,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Email',
                          style: GoogleFonts.libreFranklin(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212936),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Email Field
                        _buildInputField(
                          label: 'Email',
                          controller: _emailController,
                          showClearButton: true,
                          showChangeButton: false,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Location',
                          style: GoogleFonts.libreFranklin(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212936),
                          ),
                        ),
                        SizedBox(height: 12),
                        // Location Field
                        _buildLocationField(),

                        SizedBox(height: 12),
                        Text(
                          'Body Shape',
                          style: GoogleFonts.libreFranklin(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212936),
                          ),
                        ),
                        SizedBox(height: 12),
                        // Body Shape Dropdown
                        _buildDropDown(
                          listOptions: bodyShapeOptions,
                          selectedOption: selectedBodyShape,
                          isExpanded: isBodyShapeExpanded,
                          onTap: () {
                            setState(() {
                              isBodyShapeExpanded = !isBodyShapeExpanded;
                              // Close other dropdowns
                              isSkinToneExpanded = false;
                            });
                          },
                          onOptionSelected: (option) {
                            setState(() {
                              selectedBodyShape = option;
                              isBodyShapeExpanded = false;
                            });
                          },
                        ),

                        const SizedBox(height: 12),
                        Text(
                          'Skin Undertone',
                          style: GoogleFonts.libreFranklin(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212936),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Skin Undertone Dropdown
                        _buildDropDown(
                          listOptions: skinUndertoneOptions,
                          selectedOption: selectedSkinUndertone,
                          isExpanded: isSkinToneExpanded,
                          onTap: () {
                            setState(() {
                              isSkinToneExpanded = !isSkinToneExpanded;
                              // Close other dropdowns
                              isBodyShapeExpanded = false;
                            });
                          },
                          onOptionSelected: (option) {
                            setState(() {
                              selectedSkinUndertone = option;
                              isSkinToneExpanded = false;
                            });
                          },
                        ),

                        const SizedBox(height: 12),
                        Text(
                          'Height',
                          style: GoogleFonts.libreFranklin(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212936),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Height Field
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100, // Reduced width
                              child: _buildInputField(
                                label: 'Height in ft',
                                keyboardType: TextInputType.number,
                                controller: _footHeightController,
                                showClearButton: true,
                                showChangeButton: false,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "'ft",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 16),
                            SizedBox(
                              width: 100, // Reduced width
                              child: _buildInputField(
                                label: 'Height in ft',
                                keyboardType: TextInputType.number,
                                controller: _inchHeightController,
                                showClearButton: true,
                                showChangeButton: false,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "'inch",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Update Button
                        GlobalPinkButton(
                          text: "Update Profile",
                          onPressed: () {},
                        ),

                        // Add some bottom spacing
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required bool showClearButton,
    required bool showChangeButton,
    required TextInputType keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.words,
      // Add style for input text
      style: GoogleFonts.libreFranklin(
        fontSize: 14,
        color: AppColors.titleTextColor,
      ),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: GoogleFonts.libreFranklin(
          color: AppColors.titleTextColor,
          fontSize: 14,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Color(0xFFD87A9B), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        suffixIcon: (showClearButton || showChangeButton)
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showClearButton)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () => controller.clear(),
                    ),
                  if (showChangeButton)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLocationExpanded = !isLocationExpanded;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "CHANGE",
                        style: GoogleFonts.libreFranklin(
                          color: Color(0xFFC8270D),
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildLocationField() {
    // Filter locations based on user input
    List<String> filteredLocations = _locationController.text.isEmpty
        ? []
        : _indianLocations
              .where(
                (location) => location.toLowerCase().contains(
                  _locationController.text.toLowerCase(),
                ),
              )
              .take(5) // Limit to 5 suggestions
              .toList();

    // Show suggestions only if user is typing and there are matches
    bool showSuggestions =
        _locationController.text.isNotEmpty &&
        filteredLocations.isNotEmpty &&
        showLocationSuggestions; // ✅ Now uses your flag

    return Column(
      children: [
        TextFormField(
          controller: _locationController,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.words,
          onChanged: (value) {
            setState(() {
              showLocationSuggestions = true;
            });
          },
          style: GoogleFonts.libreFranklin(
            fontSize: 14,
            color: AppColors.titleTextColor,
          ),

          decoration: InputDecoration(
            hintText: 'Type location (e.g., Kolkata, Mumbai)',
            hintStyle: GoogleFonts.libreFranklin(
              color: AppColors.titleTextColor,
              fontSize: 14,
            ),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: const BorderSide(color: Color(0xFFD87A9B), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_locationController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      setState(() {
                        _locationController.clear();
                      });
                    },
                  ),
              ],
            ),
          ),
        ),

        // Auto-suggestions while typing
        if (showSuggestions)
          Container(
            margin: EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: Colors.white,
              border: Border.all(color: Color(0xFFE0E0E0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: filteredLocations.asMap().entries.map((entry) {
                int index = entry.key;
                String location = entry.value;
                bool isFirst = index == 0;
                bool isLast = index == filteredLocations.length - 1;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _locationController.text = location;
                      selectedLocation = location;
                      showLocationSuggestions = false; // ✅ Hide suggestion box
                      FocusScope.of(
                        context,
                      ).unfocus(); // Optional: hide keyboard
                    });
                  },

                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: isFirst && isLast
                          ? BorderRadius.circular(16)
                          : isFirst
                          ? BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            )
                          : isLast
                          ? BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            )
                          : BorderRadius.zero,
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.libreFranklin(
                                fontSize: 14,
                                color: AppColors.titleTextColor,
                              ),
                              children: _highlightMatchedText(
                                location,
                                _locationController.text,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        // Browse all locations (expanded view)
        //   if (isLocationExpanded)
        //     Container(
        //       margin: EdgeInsets.only(top: 8),
        //       decoration: BoxDecoration(
        //         borderRadius: BorderRadius.circular(16),
        //         color: Colors.white,
        //         border: Border.all(color: Color(0xFF9EA2AE)),
        //       ),
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           Padding(
        //             padding: EdgeInsets.all(16),
        //             child: Text(
        //               'All Locations',
        //               style: GoogleFonts.libreFranklin(
        //                 fontSize: 14,
        //                 fontWeight: FontWeight.w600,
        //                 color: Color(0xFF212936),
        //               ),
        //             ),
        //           ),
        //           ...(_indianLocations.map((location) {
        //             return GestureDetector(
        //               onTap: () {
        //                 setState(() {
        //                   _locationController.text = location;
        //                   selectedLocation = location;
        //                   isLocationExpanded = false;
        //                 });
        //               },
        //               child: Container(
        //                 width: double.infinity,
        //                 padding: EdgeInsets.symmetric(
        //                   horizontal: 16,
        //                   vertical: 12,
        //                 ),
        //                 decoration: BoxDecoration(
        //                   color:
        //                       selectedLocation == location
        //                           ? Colors.grey[100]
        //                           : Colors.transparent,
        //                 ),
        //                 child: Row(
        //                   children: [
        //                     Icon(
        //                       Icons.location_on_outlined,
        //                       size: 16,
        //                       color:
        //                           selectedLocation == location
        //                               ? Colors.black
        //                               : Color(0xFF9EA2AE),
        //                     ),
        //                     SizedBox(width: 8),
        //                     Expanded(
        //                       child: Text(
        //                         location,
        //                         style: GoogleFonts.libreFranklin(
        //                           fontSize: 14,
        //                           color:
        //                               selectedLocation == location
        //                                   ? AppColors.textPrimary
        //                                   : AppColors.titleTextColor,
        //                         ),
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //             );
        //           }).toList()),
        //         ],
        //       ),
        //     ),
        // ],
      ],
    );
  }

  // Helper method to highlight matched text in suggestions
  List<TextSpan> _highlightMatchedText(String text, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }

    List<TextSpan> spans = [];
    String lowerText = text.toLowerCase();
    String lowerQuery = query.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      // Add text before match
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      // Add highlighted match
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: GoogleFonts.libreFranklin(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      );

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  Widget _buildDropDown({
    required List<String> listOptions,
    required String selectedOption,
    required bool isExpanded,
    required VoidCallback onTap,
    required Function(String) onOptionSelected,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: const Color(0xFFF5F5F5),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedOption,
                      style: GoogleFonts.libreFranklin(
                        color: AppColors.titleTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Color(0xFF141B34),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF9EA2AE))),
              ),
              child: Column(
                children: listOptions.map((option) {
                  return GestureDetector(
                    onTap: () => onOptionSelected(option),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: selectedOption == option
                            ? Colors.grey[100]
                            : Colors.transparent,
                      ),
                      child: Text(
                        option,
                        style: GoogleFonts.libreFranklin(
                          fontSize: 14,
                          color: selectedOption == option
                              ? AppColors.textPrimary
                              : AppColors.titleTextColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
