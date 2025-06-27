import 'dart:developer' as Developer;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/services/Class/style_analyze_model.dart';
import 'package:testing2/services/DataSource/auth_api.dart';
import 'package:testing2/services/DataSource/style_analysis_api.dart';
import 'package:testing2/services/Temp/TempUserDataStore.dart';

class LoginPage extends StatefulWidget {
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

    final result = await AuthApiService.loginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );

    Developer.log("Result after Login $result");
    setState(() => _isLoading = false);

    if (result['success']) {
      final prefs = await SharedPreferences.getInstance();
      final user = result['user'];
      if (user == null || user['_id'] == null) {
        showErrorSnackBar(context, 'Invalid user data');
        return;
      }

      await prefs.setString('userID', user['_id']);
      await prefs.setString('userFullName', user['fullName']);
      await prefs.setString('userEmail', user['email']);

      // 1️⃣ First Time Check (still needs local flag)
      bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
      if (isFirstTime) {
        await prefs.setBool('isFirstTime', false);

        try {
          final loaded = await TempUserDataStore().load();
          if (loaded) {
            print(TempUserDataStore().bodyShape);
            print(TempUserDataStore().skinTone);
            print(TempUserDataStore().imageFile);
            final StyleAnalyzeClass? response;
            if (TempUserDataStore().imageFile == null) {
              response = await StyleAnalyzeApiService.manualAanalyzeservice(
                TempUserDataStore().bodyShape ?? '',
                TempUserDataStore().skinTone ?? '',
              );
            } else {
              response = await StyleAnalyzeApiService.autoAanalyzeservice(
                TempUserDataStore().imageFile!,
              );
            }
            await prefs.setString(
              "bodyShape",
              response!.bodyShapeResult?.bodyShape ?? '',
            );
            await prefs.setString(
              "skinTone",
              response.bodyShapeResult?.skinTone ?? '',
            );
            TempUserDataStore().clear();
            context.goNamed(
              'styleAnalyze',
              queryParameters: {
                "bodyShape": response.bodyShapeResult?.bodyShape,
                "skinTone": response.bodyShapeResult?.skinTone,
              },
            );
          } else {
            Developer.log("Data not coming from TempUserDataStore.dart");
            showErrorSnackBar(
              context,
              "Data not coming from TempUserDataStore.dart",
            );
          }
        } catch (e, stack) {
          Developer.log("StyleAnalyze error: $e\n$stack");
          showErrorSnackBar(context, "StyleAnalyze error: $e\n$stack");
        }

        return;
      }
      // 2️⃣ Location Permission & Service Check (Manual)
      final locationStatus = await Geolocator.isLocationServiceEnabled();
      if (!locationStatus) {
        final requestResult = await Geolocator.openLocationSettings();
        if (!requestResult) {
          context.goNamed('location'); // ask user to allow
          return;
        }
      }
      // final isServiceEnabled = await _weatherService.isLocationServiceEnabled();
      // if (!isServiceEnabled) {
      //   _showLocationSettingsDialog();
      //   return;
      // }

      // 3️⃣ Notification Permission Check
      // final notificationStatus = await Permission.notification.status;
      // if (!notificationStatus.isGranted) {
      //   final requestResult = await Permission.notification.request();
      //   if (!requestResult.isGranted) {
      //     context.goNamed('notification'); // ask user to allow
      //     return;
      //   }
      // }

      // ✅ All good
      showSuccessSnackBar(context, result['msg']);
      context.goNamed('home2');
    } else {
      showErrorSnackBar(context, result['msg']);
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
                const SizedBox(height: 40),
                // Header text
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.libreFranklin(
                      fontSize: 24,
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

                const SizedBox(height: 40),

                // Email field
                Text(
                  'Email',
                  style: GoogleFonts.libreFranklin(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
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
                      borderSide: const BorderSide(
                        color: Color(0xFFD87A9B),
                        width: 2,
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

                const SizedBox(height: 24),

                Text(
                  'Password',
                  style: GoogleFonts.libreFranklin(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
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
                      borderSide: const BorderSide(
                        color: Color(0xFFD87A9B),
                        width: 2,
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
                      onPressed: () {},
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

                const SizedBox(height: 40),

                _isLoading
                    ? CircularProgressIndicator()
                    : GlobalPinkButton(
                        text: "Let’s Talk Style, Babe!",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _login();
                          }
                        },
                      ),

                const SizedBox(height: 32),

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
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Color(0xFFF6A0AD), thickness: 1),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

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

                const SizedBox(height: 32),
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Do not have an Account? ',
                      style: GoogleFonts.libreFranklin(
                        color: Color(0xFF9EA2AE),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Handle login
                        context.goNamed('signup');
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Register Here',
                        style: GoogleFonts.libreFranklin(
                          color: Color(0xFF2563EB),
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
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
