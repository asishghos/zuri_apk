import 'dart:developer' as Developer;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/services/DataSource/auth_api.dart';

class SetNewPasswordPage extends StatefulWidget {
  final String email;

  const SetNewPasswordPage({super.key, required this.email});
  @override
  _SetNewPasswordPageState createState() => _SetNewPasswordPageState();
}

class _SetNewPasswordPageState extends State<SetNewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  // Future<void> _login() async {
  //   setState(() => _isLoading = true);

  //   final result = await AuthApiService.loginUser(
  //     email: _emailController.text,
  //     password: _passwordController.text,
  //   );
  //   Developer.log("Result after Login $result");
  //   setState(() => _isLoading = false);

  //   if (result['success']) {
  //     // after login navigate to next page so change accordingly

  //     showSuccessSnackBar(context, result['msg']);
  //     context.goNamed('splash');
  //   } else {
  //     showErrorSnackBar(context, result['msg']);
  //   }
  // }

  Future<void> _setNewpassword(
    String newPassword,
    String confirmPassword,
  ) async {
    setState(() => _isLoading = true);
    try {
      final result = await AuthApiService.resetPassword(
        email: widget.email,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      Developer.log("Result after Login $result");
      setState(() => _isLoading = false);

      if (result['success']) {
        showSuccessSnackBar(context, result['msg']);
        context.goNamed('login', extra: "set new password page");
      } else {
        showErrorSnackBar(context, result['msg']);
      }
    } catch (e) {
      showErrorSnackBar(context, e.toString());
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
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(24),
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          children: [
                            TextSpan(
                              text: 'Set New Password',
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
                        'New Password',
                        style: GoogleFonts.libreFranklin(
                          fontSize: MediaQuery.of(context).textScaler.scale(16),
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.013729977,
                      ),
                      TextFormField(
                        controller: _newPasswordController,
                        keyboardType: TextInputType.emailAddress,
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
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(14),
                          ),
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: BorderSide(
                              color: Color(0xFFD87A9B),
                              width:
                                  MediaQuery.of(context).size.width *
                                  0.004975124,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: BorderSide(color: Colors.red, width: 1),
                          ),
                          contentPadding: EdgeInsets.symmetric(
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

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.0274599,
                      ),

                      Text(
                        'Confirm Password',
                        style: GoogleFonts.libreFranklin(
                          fontSize: MediaQuery.of(context).textScaler.scale(16),
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.013729977,
                      ),
                      TextFormField(
                        controller: _confirmPasswordController,
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
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(14),
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
                              width:
                                  MediaQuery.of(context).size.width *
                                  0.004975124,
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

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04576659,
                      ),
                      GlobalPinkButton(
                        text: "Reset Password",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _setNewpassword(
                              _newPasswordController.text,
                              _confirmPasswordController.text,
                            );
                          }
                        },
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
}
