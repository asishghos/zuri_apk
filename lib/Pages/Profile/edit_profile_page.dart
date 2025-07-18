import 'dart:convert';
import 'dart:developer' as Developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Global/Widget/image_pick_global_logic.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/services/Class/auth_model.dart';
import 'package:testing2/services/Class/location_model.dart';
import 'package:testing2/services/DataSource/auth_api.dart';
// Add your API service import here
// import 'package:testing2/services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfileResponse profileResponse;

  EditProfileScreen({Key? key, required this.profileResponse})
    : super(key: key);
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late SharedPreferences prefs;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _footHeightController = TextEditingController();
  final TextEditingController _inchHeightController = TextEditingController();
  final TextEditingController _locationController = TextEditingController(
    text: 'Malda',
  );

  // Global image picker widget
  final _imagePickerService = ImagePickerService();
  File? _uploadedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  String _getBodyShape(String bodyShape) {
    switch (bodyShape) {
      case 'rectangle':
        return "Rectangle";
      case 'hourglass':
        return "HourGlass";
      case 'pear':
        return "Pear";
      case 'apple':
        return "Apple";
      case 'inverted triangle':
        return "Inverted Triangle";
      default:
        return "Unknown";
    }
  }

  String _getSkinUnderTone(String skinUnderTone) {
    switch (skinUnderTone) {
      case 'cool':
        return 'Cool';
      case 'warm':
        return 'Warm';
      case 'neutral':
        return 'Neutral';
      default:
        return "Unknown";
    }
  }

  // Convert display values back to API format
  String _getBodyShapeApiValue(String displayValue) {
    switch (displayValue) {
      case 'Rectangle':
        return 'rectangle';
      case 'HourGlass':
        return 'hourglass';
      case 'Pear':
        return 'pear';
      case 'Apple':
        return 'apple';
      case 'Inverted Triangle':
        return 'inverted triangle';
      default:
        return 'rectangle';
    }
  }

  String _getSkinUndertoneApiValue(String displayValue) {
    switch (displayValue) {
      case 'Cool':
        return 'cool';
      case 'Warm':
        return 'warm';
      case 'Neutral':
        return 'neutral';
      default:
        return 'neutral';
    }
  }

  late String selectedBodyShape;
  late String selectedSkinUndertone;
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
  LocationData? locationData;
  List<String> _allLocations = [];

  @override
  void initState() {
    super.initState();
    _initPrefs();
    selectedBodyShape = _getBodyShape(
      widget.profileResponse.data.userBodyInfo.bodyShape,
    );
    selectedSkinUndertone = _getSkinUnderTone(
      widget.profileResponse.data.userBodyInfo.undertone,
    );
    _nameController.text = widget.profileResponse.data.fullName;
    _emailController.text = widget.profileResponse.data.email;
    _footHeightController.text =
        widget.profileResponse.data.userBodyInfo.height?.feet.toString() ?? '';
    _inchHeightController.text =
        widget.profileResponse.data.userBodyInfo.height?.inches.toString() ??
        '';

    // Initialize height fields
    _initializeHeightFields();

    _loadLocationData();
  }

  void _initializeHeightFields() {
    // If you have height data in your profile response, initialize it here
    // This assumes you have height data in feet and inches format
    // Adjust according to your UserProfileResponse structure

    // Example initialization (adjust based on your data structure):
    // if (widget.profileResponse.data.userBodyInfo.heightFeet != null) {
    //   _footHeightController.text = widget.profileResponse.data.userBodyInfo.heightFeet.toString();
    // }
    // if (widget.profileResponse.data.userBodyInfo.heightInches != null) {
    //   _inchHeightController.text = widget.profileResponse.data.userBodyInfo.heightInches.toString();
    // }
  }

  Future<void> _loadLocationData() async {
    String jsonString = await rootBundle.loadString(
      'assets/json/india_locations.json',
    );
    Map<String, dynamic> jsonData = json.decode(jsonString);
    setState(() {
      locationData = LocationData.fromJson(jsonData);
      _allLocations = _generateLocationStrings();
    });
  }

  List<String> _generateLocationStrings() {
    List<String> locations = [];

    if (locationData != null) {
      for (StateData state in locationData!.states) {
        for (CityData city in state.cities) {
          locations.add(
            '${city.name}, ${state.name}, ${locationData!.country}',
          );
        }
      }
    }

    return locations;
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  // Update Profile Function
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse height values
      int? feet;
      int? inches;

      if (_footHeightController.text.isNotEmpty) {
        feet = int.tryParse(_footHeightController.text);
      }

      if (_inchHeightController.text.isNotEmpty) {
        inches = int.tryParse(_inchHeightController.text);
      }

      // Call the API service
      // Replace 'ApiService' with your actual API service class
      final result = await AuthApiService.updateUserProfile(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        bodyShape: _getBodyShapeApiValue(selectedBodyShape),
        undertone: _getSkinUndertoneApiValue(selectedSkinUndertone),
        feet: feet,
        inches: inches,
        location: _locationController.text.trim(),
        profilePicture: _uploadedImage,
      );

      if (result['success'] == true) {
        // Show success message
        Developer.log(result['msg'] ?? 'Profile updated successfully');
        showSuccessSnackBar(
          context,
          result['msg'] ?? 'Profile updated successfully',
        );

        // Navigate back to profile screen
        context.goNamed('profileAfterLogin');
      } else {
        // Show error message
        Developer.log(result['msg'] ?? 'Failed to update profile');
        showErrorSnackBar(context, result['msg'] ?? 'Failed to update profile');
      }
    } catch (e) {
      Developer.log('An error occurred: ${e.toString()}');
      showErrorSnackBar(context, 'An error occurred: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request permissions
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
      setState(() {});
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _uploadedImage = File(pickedFile.path);
          // selectedIndex = null;
        });
        setState(() {});
      } else {
        setState(() {});
      }
    } catch (e) {
      setState(() {});
      debugPrint('Error in _pickImage: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _scrollToFocusedField(FocusNode focusNode) {
    if (focusNode.hasFocus) {
      Future.delayed(Duration(milliseconds: 300), () {
        Scrollable.ensureVisible(
          focusNode.context!,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  bool showLocationSuggestions = false;

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;
    // Add debug prints
    Developer.log('Building EditProfileScreen');
    Developer.log('Loading state: $_isLoading');
    Developer.log('Profile data: ${widget.profileResponse.data.fullName}');

    return _isLoading
        ? LoadingPage()
        : Scaffold(
            backgroundColor: Colors.white, // Changed from Colors.transparent
            body: Container(
              width: dw,
              height: dh,
              color: Colors.white, // Add explicit color
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
                                icon: const Icon(
                                  IconlyLight.arrowLeft2,
                                  size: 24,
                                ),
                                color: Colors.white,
                                onPressed: () {
                                  context.goNamed('profileAfterLogin');
                                },
                              ),
                              Text(
                                'Edit Profile',
                                style: GoogleFonts.libreFranklin(
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(
                                    context,
                                  ).textScaler.scale(18),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height *
                                0.018306636,
                          ),
                          // Profile Image
                          Expanded(
                            child: Center(
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 32,
                                    backgroundColor: Color(0xFFE5E7EA),
                                    child: _uploadedImage != null
                                        ? ClipOval(
                                            child: Image.file(
                                              _uploadedImage!,
                                              width: 64,
                                              height: 64,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : widget
                                                  .profileResponse
                                                  .data
                                                  .profilePicture !=
                                              ""
                                        ? ClipOval(
                                            child: Image.network(
                                              widget
                                                  .profileResponse
                                                  .data
                                                  .profilePicture,
                                              width: 64,
                                              height: 64,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : HugeIcon(
                                            icon: HugeIcons.strokeRoundedUser,
                                            color: AppColors.titleTextColor,
                                            size: 32,
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
                                        onTap: _showPicker,
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
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Full Name Field
                                Text(
                                  'Full Name',
                                  style: GoogleFonts.libreFranklin(
                                    fontSize: MediaQuery.of(
                                      context,
                                    ).textScaler.scale(16),
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF212936),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.013729977,
                                ),
                                _buildInputField(
                                  label: 'Full Name',
                                  keyboardType: TextInputType.name,
                                  controller: _nameController,
                                  showClearButton: true,
                                  showChangeButton: false,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your full name';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.013729977,
                                ),
                                Text(
                                  'Email',
                                  style: GoogleFonts.libreFranklin(
                                    fontSize: MediaQuery.of(
                                      context,
                                    ).textScaler.scale(16),
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF212936),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.013729977,
                                ),
                                // Email Field
                                _buildInputField(
                                  label: 'Email',
                                  controller: _emailController,
                                  showClearButton: true,
                                  showChangeButton: false,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.013729977,
                                ),
                                Text(
                                  'Location',
                                  style: GoogleFonts.libreFranklin(
                                    fontSize: MediaQuery.of(
                                      context,
                                    ).textScaler.scale(16),
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF212936),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.013729977,
                                ),
                                // Location Field
                                _buildLocationField(),

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.013729977,
                                ),
                                Text(
                                  'Body Shape',
                                  style: GoogleFonts.libreFranklin(
                                    fontSize: MediaQuery.of(
                                      context,
                                    ).textScaler.scale(16),
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF212936),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.013729977,
                                ),
                                // Body Shape Dropdown
                                _buildDropDown(
                                  listOptions: bodyShapeOptions,
                                  selectedOption: selectedBodyShape,
                                  isExpanded: isBodyShapeExpanded,
                                  onTap: () {
                                    setState(() {
                                      isBodyShapeExpanded =
                                          !isBodyShapeExpanded;
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

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.013729977,
                                ),
                                Text(
                                  'Skin Undertone',
                                  style: GoogleFonts.libreFranklin(
                                    fontSize: MediaQuery.of(
                                      context,
                                    ).textScaler.scale(16),
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF212936),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.013729977,
                                ),
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

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.013729977,
                                ),
                                Text(
                                  'Height',
                                  style: GoogleFonts.libreFranklin(
                                    fontSize: MediaQuery.of(
                                      context,
                                    ).textScaler.scale(16),
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF212936),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.013729977,
                                ),

                                // Height Field
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      child: _buildInputField(
                                        label: 'Feet',
                                        keyboardType: TextInputType.number,
                                        controller: _footHeightController,
                                        showClearButton: true,
                                        showChangeButton: false,
                                        validator: (value) {
                                          if (value != null &&
                                              value.isNotEmpty) {
                                            final feet = int.tryParse(value);
                                            if (feet == null ||
                                                feet < 0 ||
                                                feet > 10) {
                                              return 'Invalid feet';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "ft",
                                      style: GoogleFonts.libreFranklin(
                                        color: Colors.black,
                                        fontSize: MediaQuery.of(
                                          context,
                                        ).textScaler.scale(16),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Spacer(),
                                    SizedBox(
                                      width: 150,
                                      child: _buildInputField(
                                        label: 'Inches',
                                        keyboardType: TextInputType.number,
                                        controller: _inchHeightController,
                                        showClearButton: true,
                                        showChangeButton: false,
                                        validator: (value) {
                                          if (value != null &&
                                              value.isNotEmpty) {
                                            final inches = int.tryParse(value);
                                            if (inches == null ||
                                                inches < 0 ||
                                                inches >= 12) {
                                              return 'Invalid inches';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "in",
                                      style: GoogleFonts.libreFranklin(
                                        color: Colors.black,
                                        fontSize: MediaQuery.of(
                                          context,
                                        ).textScaler.scale(16),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.0274599,
                                ),

                                GlobalPinkButton(
                                  text: "Update Profile",
                                  onPressed: _updateProfile,
                                ),

                                // Add some bottom spacing
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.0274599,
                                ),
                              ],
                            ),
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
    // required BuildContext context,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.words,
      validator: validator,
      style: GoogleFonts.libreFranklin(
        fontSize: MediaQuery.of(context).textScaler.scale(14),
        color: AppColors.titleTextColor,
      ),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: GoogleFonts.libreFranklin(
          color: AppColors.titleTextColor,
          fontSize: MediaQuery.of(context).textScaler.scale(14),
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(
            color: Color(0xFFD87A9B),
            width: MediaQuery.of(context).size.width * 0.004975124,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(
            color: Colors.red,
            width: MediaQuery.of(context).size.width * 0.004975124,
          ),
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
        : _allLocations
              .where(
                (location) => location.toLowerCase().contains(
                  _locationController.text.toLowerCase(),
                ),
              )
              .take(5)
              .toList();

    // Show suggestions only if user is typing and there are matches
    bool showSuggestions =
        _locationController.text.isNotEmpty &&
        filteredLocations.isNotEmpty &&
        showLocationSuggestions;

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
            fontSize: MediaQuery.of(context).textScaler.scale(14),
            color: AppColors.titleTextColor,
          ),
          decoration: InputDecoration(
            hintText: 'Type location (e.g., Kolkata, Mumbai)',
            hintStyle: GoogleFonts.libreFranklin(
              color: AppColors.titleTextColor,
              fontSize: MediaQuery.of(context).textScaler.scale(14),
            ),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide(
                color: Color(0xFFD87A9B),
                width: MediaQuery.of(context).size.width * 0.004975124,
              ),
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
                      showLocationSuggestions = false;
                      FocusScope.of(context).unfocus();
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
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(14),
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
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
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
                        fontSize: MediaQuery.of(context).textScaler.scale(14),
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
                          fontSize: MediaQuery.of(context).textScaler.scale(14),
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
}
