import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/services/DataSource/auth_api.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  bool _isLoading = false;

  Future<void> _register() async {
    setState(() => _isLoading = true);
    final result = await AuthApiService.registerUser(
      fullName: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
    setState(() => _isLoading = false);

    if (result['success']) {
      // context.goNamed(
      //   'styleAnalyze',
      //   queryParameters: {
      //     "bodyShape": prefs.getString("bodyShape"),
      //     "skinTone": prefs.getString("skinTone"),
      //   },
      // );
      context.goNamed('login', extra: "success signup, came from SignUp page");
      showSuccessSnackBar(context, result['msg']);
    } else {
      showErrorSnackBar(context, result['msg']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? LoadingPage()
        : Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      // Header text
                      Column(
                        children: [
                          Text(
                            'But before the big revelation...',
                            style: GoogleFonts.libreFranklin(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.libreFranklin(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              children: [
                                TextSpan(text: "Let's make our "),
                                TextSpan(
                                  text: 'relationship official!',
                                  style: GoogleFonts.libreFranklin(
                                    color: Color(0xFFE91E63),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      Text(
                        'Name',
                        style: GoogleFonts.libreFranklin(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'styleQueen',
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
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

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
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Create a new password',
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
                            borderRadius: BorderRadius.circular(25),
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
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1,
                            ),
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

                      const SizedBox(height: 40),

                      GlobalPinkButton(
                        text: "Sign Up",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _register();
                          }
                        },
                      ),

                      const SizedBox(height: 32),

                      // Divider with text
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Color(0xFFF6A0AD),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Or continue with',
                              style: GoogleFonts.libreFranklin(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Color(0xFFF6A0AD),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

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

                      // Skip msg
                      Column(
                        children: [
                          Text(
                            'No Sign Up? No Sweat! Zuri will reveal',
                            style: GoogleFonts.libreFranklin(
                              color: AppColors.subTitleTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'your cut+ color analysis, anyway!',
                            style: GoogleFonts.libreFranklin(
                              color: AppColors.subTitleTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            onPressed: () {
                              // Handle maybe later
                              print('Maybe Later tapped');
                            },
                            child: Text(
                              'Maybe Later',
                              style: GoogleFonts.libreFranklin(
                                color: AppColors.subTitleTextColor,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already Have an Account? ',
                            style: GoogleFonts.libreFranklin(
                              color: Color(0xFF9EA2AE),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Handle login
                              context.goNamed(
                                'login',
                                extra: "without signup, came from SignUp page",
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Login Here',
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
