import 'dart:developer' as Developer;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'package:testing2/services/DataSource/auth_api.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToVideoScreen();
    });
  }

  void _navigateToVideoScreen() {
    Timer(const Duration(seconds: 2), () {
      if (mounted && Navigator.canPop(context) == false) {
        context.goNamed('splash2');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(
          image: AssetImage('assets/images/Zuri/Zuri.png'),
          width: 200,
        ),
      ),
    );
  }
}

class ZuriVideoScreen extends StatefulWidget {
  const ZuriVideoScreen({super.key});

  @override
  State<ZuriVideoScreen> createState() => _ZuriVideoScreenState();
}

class _ZuriVideoScreenState extends State<ZuriVideoScreen> {
  VideoPlayerController? _controller;
  bool _isVideoInitialized = false;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _navigationTimer = Timer(const Duration(seconds: 5), () {
      _checkLoginStatus();
    });
  }

  // Future<bool> isFirstTimeUser() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   bool? alreadyUsed = prefs.getBool('alreadyUsed');
  //   if (alreadyUsed == null || alreadyUsed == false) {
  //     await prefs.setBool('alreadyUsed', true);
  //     return true; // First time
  //   }
  //   return false; // Not first time
  // }

  void _checkLoginStatus() async {
    try {
      Developer.log("=== Starting Full Login + First Time Check ===");
      final prefs = await SharedPreferences.getInstance();
      // Check if first time
      final isFirstTime = prefs.getBool('alreadyUsed') ?? false;

      if (!isFirstTime) {
        Developer.log(
          "🎯 First-time user detected, setting flag and going to onboarding...",
        );
        await prefs.setBool('alreadyUsed', true);
        if (mounted) context.goNamed('onboarding');
        return;
      }

      // Not first time, check login tokens
      final accessToken = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');

      Developer.log(
        "Stored access token: ${accessToken?.substring(0, 20) ?? 'null'}...",
      );
      Developer.log(
        "Stored refresh token: ${refreshToken?.substring(0, 20) ?? 'null'}...",
      );

      final token = await AuthApiService.getCurrentToken();
      final isLoggedIn = await AuthApiService.isLoggedIn();

      Developer.log(
        "AuthApiService.getCurrentToken(): ${token?.substring(0, 20) ?? 'null'}...",
      );
      Developer.log("AuthApiService.isLoggedIn(): $isLoggedIn");

      if (!mounted) return;

      if (isLoggedIn && token != null && token.isNotEmpty) {
        Developer.log(
          "✅ Token found and user is logged in. Validating with backend...",
        );
        context.goNamed('home2');
        // final isValid = await AuthApiService.validateToken();

        // if (isValid) {
        //   Developer.log("✅ Token is valid, navigating to home2");
        //   context.goNamed('home2');
        // } else {
        //   Developer.log("❌ Token invalid. Clearing tokens and going to home");
        //   await prefs.remove('access_token');
        //   await prefs.remove('refresh_token');
        //   context.goNamed('home');
        // }
      } else {
        Developer.log("🚫 Not logged in or token empty. Navigating to home");
        context.goNamed('home');
      }

      Developer.log("=== Login + First Time Check Complete ===");
    } catch (e) {
      Developer.log("❌ Error checking login status: $e");
      if (mounted) {
        context.goNamed('home'); // fallback route
      }
    }
  }

  void _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(
        'assets/images/Zuri/svideo.mp4',
      );
      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });

        _controller!.setLooping(true);
        _controller!.setVolume(0.0);
        _controller!.play();
      }
    } catch (e) {
      Developer.log('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background - Video or fallback
          _isVideoInitialized && _controller != null
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                )
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1a1a1a), Color(0xFF000000)],
                    ),
                  ),
                ),

          // Black overlay mask for better text visibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/Zuri/Zuri2.png',
                  width: 250,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 250,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'ZURI',
                          style: GoogleFonts.libreFranklin(
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(32),
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: DefaultTextStyle(
                    style: GoogleFonts.libreFranklin(
                      fontSize: 24.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                    child: Text(
                      "Serve your best look. \nEvery single time.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
