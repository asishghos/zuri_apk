import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/services/DataSource/auth_api.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Timer related variables
  bool _isTimerActive = false;
  int _timeRemaining = 0;
  Timer? _timer;

  // OTP related variables
  bool _isOtpSent = false;
  bool _isOtpValid = false;
  bool _isVerifying = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isTimerActive = true;
      _timeRemaining = 120; // 2 minutes in seconds
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _isTimerActive = false;
          timer.cancel();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _sendRecoveryLink() async {
    if (_formKey.currentState!.validate()) {
      try {
        final result = await AuthApiService.forgotPassword(
          email: _emailController.text,
        );

        if (result['success']) {
          setState(() {
            _isOtpSent = true;
          });
          _startTimer();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['msg'] ?? 'Recovery code sent to email'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Show error message
          showErrorSnackBar(
            context,
            result['msg'] ?? 'Failed to send recovery code',
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isNotEmpty) {
      setState(() {
        _isVerifying = true;
      });

      try {
        final result = await AuthApiService.verifyRecoveryCode(
          email: _emailController.text,
          code: _otpController.text,
        );

        if (result['success']) {
          setState(() {
            _isOtpValid = true;
          });

          showSuccessDialog(
            context,
            result['msg'] ?? 'OTP verified successfully',
          );

          context.goNamed('setNewPassword', extra: _emailController.text);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['msg'] ?? 'Invalid OTP'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.04576659),
              // Title
              Text(
                'Reset Password',
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(24),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.018306636,
              ),

              // Subtitle
              Text(
                'Enter the email associated with your account and we\'ll send a password reset link.',
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                  color: Colors.black54,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.04576659),

              // Email Label
              Text(
                'Email',
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.018306636,
              ),

              // Email Input Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isOtpValid, // Disable after OTP is verified
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  }
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return "Hmm. That doesn't look like a valid email. \nWanna double-check?";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Enter Your Email',
                  hintStyle: GoogleFonts.libreFranklin(
                    color: Colors.black38,
                    fontSize: MediaQuery.of(context).textScaler.scale(16),
                  ),
                  filled: true,
                  fillColor: _isOtpValid ? Colors.grey[200] : Color(0xFFF5F5F5),
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
                height: MediaQuery.of(context).size.height * 0.036613272,
              ),

              // Send Recovery Link Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isTimerActive || _isOtpValid
                      ? null
                      : _sendRecoveryLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTimerActive || _isOtpValid
                        ? Colors.grey[400]
                        : AppColors.textPrimary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isTimerActive
                        ? 'Resend in ${_formatTime(_timeRemaining)}'
                        : _isOtpValid
                        ? 'Code Verified ✓'
                        : 'Send recovery link',
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // OTP Section - Show only after email is sent
              if (_isOtpSent) ...[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.036613272,
                ),

                // OTP Label
                Text(
                  'Verification Code',
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(16),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.018306636,
                ),

                // OTP Input Field
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  enabled: !_isOtpValid,
                  maxLength: 6, // Assuming 6-digit OTP
                  onChanged: (value) {
                    setState(() {}); // Refresh to update button state
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter 6-digit code',
                    hintStyle: GoogleFonts.libreFranklin(
                      color: Colors.black38,
                      fontSize: MediaQuery.of(context).textScaler.scale(16),
                    ),
                    filled: true,
                    fillColor: _isOtpValid
                        ? Colors.grey[200]
                        : Color(0xFFF5F5F5),
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
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    counterText: '', // Hide character counter
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.0274599,
                ),

                // Submit OTP Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isOtpValid || _otpController.text.length < 6
                        ? null
                        : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isOtpValid
                          ? Colors.green
                          : _otpController.text.length < 6
                          ? Colors.grey[400]
                          : AppColors.textPrimary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 0,
                    ),
                    child: _isVerifying
                        ? SizedBox(
                            height:
                                MediaQuery.of(context).size.height *
                                0.022883295,
                            width:
                                MediaQuery.of(context).size.width * 0.049751243,
                            child: CircularProgressIndicator(
                              strokeWidth:
                                  MediaQuery.of(context).size.width *
                                  0.004975124,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            _isOtpValid ? 'Verified ✓' : 'Verify Code',
                            style: GoogleFonts.libreFranklin(
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(18),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
