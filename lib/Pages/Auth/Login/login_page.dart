import 'dart:developer' as Developer;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/services/Class/auth_model.dart';
import 'package:testing2/services/DataSource/auth_api.dart';

class LoginPage extends StatefulWidget {
  final String fromPage;

  const LoginPage({super.key, required this.fromPage});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isLoading = false;
  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      final result = await AuthApiService.loginUser(
        email: _emailController.text,
        password: _passwordController.text,
      );

      Developer.log("Result after Login $result");
      setState(() => _isLoading = false);

      if (result['success'] != true ||
          result['user'] == null ||
          result['user']['_id'] == null) {
        showErrorSnackBar(context, result['msg'] ?? 'Login failed');
        return;
      }

      final user = result['user'];
      final prefs = await SharedPreferences.getInstance();

      // Save basic user data
      await prefs.setString('userID', user['_id']);
      await prefs.setString('userFullName', user['fullName'] ?? '');
      await prefs.setString('userEmail', user['email'] ?? '');

      // Fetch profile details
      await _getUserProfile();

      if (_profileResponse?.data.userBodyInfo != null) {
        final bodyInfo = _profileResponse!.data.userBodyInfo;
        await prefs.setString('bodyShape', _getBodyShape(bodyInfo.bodyShape));
        await prefs.setString(
          'underTone',
          _getSkinUnderTone(bodyInfo.undertone),
        );
      }

      // Redirect for "Before Login Profile Page"
      if (widget.fromPage == "from Before Login Profile Page") {
        context.goNamed('home2');
        return;
      }

      // First time login
      final isFirstTime = prefs.getBool('isFirstTime') ?? true;
      if (isFirstTime) {
        await prefs.setBool('isFirstTime', false);
        context.goNamed('styleAnalyze');
        return;
      }

      // Location permission check
      final locationStatus = await Geolocator.isLocationServiceEnabled();
      if (!locationStatus) {
        final opened = await Geolocator.openLocationSettings();
        if (!opened) {
          context.goNamed('location'); // ask user to enable location manually
          return;
        }
      }

      showSuccessSnackBar(context, result['msg']);
      context.goNamed('home2');
    } catch (e, stackTrace) {
      Developer.log("Login error: $e", error: e, stackTrace: stackTrace);
      showErrorSnackBar(context, 'Something went wrong. Please try again.');
      setState(() => _isLoading = false);
    }
  }

  UserProfileResponse? _profileResponse = null;
  Future<void> _getUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final responce = await AuthApiService.getUserProfile();
      if (responce != null) {
        _profileResponse = responce;
      } else {
        Developer.log("_profileResponse is Null");
      }
    } catch (e) {
      showErrorDialog(context, "Fetch user details fail");
      Developer.log("Fetch user details fail");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.04576659,
                ),
                // Header text
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(24),
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    children: [
                      TextSpan(
                        text: 'Welcome Back, User!',
                        style: GoogleFonts.libreFranklin(
                          color: Color(0xFFE91E63),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.04576659,
                ),

                // Email field
                Text(
                  'Email',
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(16),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.013729977,
                ),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email address';
                    }
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return 'Hmm. That doesn’t look like a valid email. \nWanna double-check?';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'styleQueen@gmail.com',
                    hintStyle: GoogleFonts.libreFranklin(
                      color: Colors.grey[400],
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
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.0274599,
                ),

                Text(
                  'Password',
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(16),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.013729977,
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an password';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '********',
                    hintStyle: GoogleFonts.libreFranklin(
                      color: Colors.grey[400],
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
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        context.goNamed('resetPassword');
                      },
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.libreFranklin(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4D5461),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.04576659,
                ),

                GlobalPinkButton(
                  text: "Let’s Talk Style, Babe!",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _login();
                    }
                  },
                  isLoading: _isLoading,
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.036613272,
                ),

                // Divider with text
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Color(0xFFF6A0AD), thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or Log in with',
                        style: GoogleFonts.libreFranklin(
                          color: Colors.grey[600],
                          fontSize: MediaQuery.of(context).textScaler.scale(14),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Color(0xFFF6A0AD), thickness: 1),
                    ),
                  ],
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.036613272,
                ),

                // Social login buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialButton(
                      svgPath: "assets/images/signup/g.svg",
                      borderColor: Color(0xFF4285F4),
                      onTap: () {
                        // Handle Google sign in
                        print('Google sign in tapped');
                      },
                    ),
                    _buildSocialButton(
                      svgPath: "assets/images/signup/f.svg",
                      borderColor: Color(0xFF3B5997),
                      onTap: () {
                        // Handle Facebook sign in
                        print('Facebook sign in tapped');
                      },
                    ),
                    _buildSocialButton(
                      svgPath: "assets/images/signup/a2.svg",
                      borderColor: AppColors.titleTextColor,
                      onTap: () {
                        // Handle Apple sign in
                        print('Apple sign in tapped');
                      },
                    ),
                  ],
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.036613272,
                ),
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Do not have an Account? ',
                      style: GoogleFonts.libreFranklin(
                        color: Color(0xFF9EA2AE),
                        fontSize: MediaQuery.of(context).textScaler.scale(14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Handle login
                        context.goNamed('scan&discover');
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Scan Here',
                        style: GoogleFonts.libreFranklin(
                          color: Color(0xFF2563EB),
                          fontSize: MediaQuery.of(context).textScaler.scale(14),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.04576659,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String svgPath,
    required VoidCallback onTap,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SvgPicture.asset(svgPath),
        ),
      ),
    );
  }
}
