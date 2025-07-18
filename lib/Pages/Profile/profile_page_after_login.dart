import 'dart:developer' as Developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Function/global_function.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/Pages/Products/wishlist_page.dart';
import 'package:testing2/Pages/Profile/support_page.dart';
import 'package:testing2/Pages/Saved/saved_fav_page.dart';
import 'package:testing2/Pages/uploaded_look_page.dart/uploaded_look_page.dart';
import 'package:testing2/services/Class/auth_model.dart';
import 'package:testing2/services/Class/result_class.dart';
import 'package:testing2/services/DataSource/auth_api.dart';

class ProfileDrawerAfterLogin extends StatefulWidget {
  const ProfileDrawerAfterLogin({Key? key}) : super(key: key);

  @override
  State<ProfileDrawerAfterLogin> createState() =>
      _ProfileDrawerAfterLoginState();
}

class _ProfileDrawerAfterLoginState extends State<ProfileDrawerAfterLogin> {
  late SharedPreferences prefs;
  UserProfileResponse? _profileResponse = null;
  bool _isLoading = false;
  bool _hasTriedLoading = false; // Track if we've attempted to load data
  int _retryCount = 0;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);
  List<File> images = [];
  @override
  void initState() {
    super.initState();
    initPrefs();
    _getUserProfile();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  Future<void> _getUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthApiService.getUserProfile();
      if (response != null) {
        _profileResponse = response;
        for (int i = 0; i < _profileResponse!.newAdditions.length; i++) {
          File temp = await GlobalFunction.urlToFile(
            _profileResponse!.newAdditions[i].imageUrl,
          );
          images.add(temp);
        }
        if (_profileResponse?.data.profilePicture != null &&
            _profileResponse!.data.profilePicture != "") {
          prefs.setString("userProfilePic", response.data.profilePicture);
        }
        prefs.setString("userFullName", _profileResponse!.data.fullName);
        Developer.log(response.msg.toString() + "✅✅");
        _retryCount = 0; // Reset retry count on success
      } else {
        Developer.log("_profileResponse is Null");
        // If response is null and we haven't exceeded max retries, try again
        if (_retryCount < _maxRetries) {
          _retryCount++;
          Developer.log("Retrying... Attempt $_retryCount/$_maxRetries");
          await Future.delayed(_retryDelay);
          if (mounted) {
            _getUserProfile(); // Recursive retry
            return; // Don't set loading to false yet
          }
        }
      }
    } catch (e) {
      Developer.log("Fetch user details fail: $e");
      // If error and we haven't exceeded max retries, try again
      if (_retryCount < _maxRetries) {
        _retryCount++;
        Developer.log(
          "Retrying after error... Attempt $_retryCount/$_maxRetries",
        );
        await Future.delayed(_retryDelay);
        if (mounted) {
          _getUserProfile(); // Recursive retry
          return; // Don't set loading to false yet
        }
      } else {
        // Only show error dialog after all retries are exhausted
        showErrorDialog(
          context,
          "Failed to fetch user details after $_maxRetries attempts",
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasTriedLoading = true;
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
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;

    // Show loading if we're currently loading OR if we haven't tried loading yet
    if (_isLoading || !_hasTriedLoading) {
      return LoadingPage();
    }

    // If we've tried loading but still have no data, show a retry option
    if (_profileResponse == null && _hasTriedLoading) {
      return Container(
        width: MediaQuery.of(context).size.width,
        child: Drawer(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Unable to load profile data',
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(16),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please check your connection and try again',
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(14),
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    _retryCount = 0; // Reset retry count
                    _hasTriedLoading = false; // Reset loading state
                    _getUserProfile(); // Retry loading
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.goNamed('home2'),
                  child: Text(
                    'Back to Home',
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(14),
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Drawer(
        child: Column(
          children: [
            Container(
              color: AppColors.textPrimary,
              height: dh * 0.23,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              // Navigator.pop(context);
                              context.goNamed(
                                'editProfile',
                                extra: _profileResponse,
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  'My Profile',
                                  style: GoogleFonts.libreFranklin(
                                    color: Colors.white,
                                    fontSize: MediaQuery.of(
                                      context,
                                    ).textScaler.scale(18),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: dw * 0.1),
                                const HugeIcon(
                                  icon: HugeIcons.strokeRoundedEdit02,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.goNamed('home2');
                              context.pop();
                            },
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.018306636,
                      ),
                      // Profile Info
                      Row(
                        children: [
                          // Profile Picture
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Color(0xFFE5E7EA),
                            child:
                                _profileResponse?.data.profilePicture != null &&
                                    _profileResponse!.data.profilePicture != ""
                                ? ClipOval(
                                    child: Image.network(
                                      _profileResponse!.data.profilePicture,
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
                          SizedBox(width: 16),
                          // Profile Details
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    IconlyLight.location,
                                    color: Color(0xFFFFFFFF),
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    ResultCache.loactiondata?[0] ?? "location",
                                    style: GoogleFonts.libreFranklin(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: MediaQuery.of(
                                        context,
                                      ).textScaler.scale(14),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                _profileResponse?.data.fullName ?? "User Name",
                                style: GoogleFonts.libreFranklin(
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(
                                    context,
                                  ).textScaler.scale(18),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    _getBodyShape(
                                      _profileResponse
                                              ?.data
                                              .userBodyInfo
                                              .bodyShape ??
                                          "Unknown",
                                    ),
                                    style: GoogleFonts.libreFranklin(
                                      color: Color(0xFFF3F4F6),
                                      fontSize: MediaQuery.of(
                                        context,
                                      ).textScaler.scale(14),
                                    ),
                                  ),
                                  Text(
                                    "  |  ",
                                    style: GoogleFonts.libreFranklin(
                                      color: Color(0xFFF3F4F6),
                                    ),
                                  ),
                                  Text(
                                    _getSkinUnderTone(
                                      _profileResponse
                                              ?.data
                                              .userBodyInfo
                                              .undertone ??
                                          "Unknown",
                                    ),
                                    style: GoogleFonts.libreFranklin(
                                      color: Color(0xFFF3F4F6),
                                      fontSize: MediaQuery.of(
                                        context,
                                      ).textScaler.scale(14),
                                    ),
                                  ),
                                  Text(
                                    "  |  ",
                                    style: GoogleFonts.libreFranklin(
                                      color: Color(0xFFF3F4F6),
                                    ),
                                  ),
                                  Text(
                                    "${_profileResponse?.data.userBodyInfo.height?.feet ?? '--'}'${_profileResponse?.data.userBodyInfo.height?.inches ?? '--'}",
                                    style: GoogleFonts.libreFranklin(
                                      color: Color(0xFFF3F4F6),
                                      fontSize: MediaQuery.of(
                                        context,
                                      ).textScaler.scale(14),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Content Section
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: HugeIcons.strokeRoundedHanger,
                        title: 'Closet Stats',
                        subtitle: '${_profileResponse?.closetStats ?? 0} item',
                        onTap: () {
                          context.goNamed('allItemsWardrobe', extra: 1);
                        },
                        pinkSubtitle: true,
                      ),
                      _buildDivider(width: dw * 0.05),
                      _buildMenuItem(
                        icon: HugeIcons.strokeRoundedUpload04,
                        title: 'Uploaded Looks',
                        subtitle:
                            "Your best angles you've uploaded - in one spot!",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return UploadedLookPage();
                              },
                            ),
                          );
                        },
                        pinkSubtitle: false,
                      ),
                      _buildDivider(width: dw * 0.05),
                      _buildMenuItem(
                        icon: HugeIcons.strokeRoundedBookmark02,
                        title: 'Saved Favorites',
                        subtitle: 'Our curations from your closet that you  💝',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return SavedFavoritesScreen();
                              },
                            ),
                          );
                        },
                        pinkSubtitle: false,
                      ),
                      _buildDivider(width: dw * 0.05),
                      _buildMenuItem(
                        icon: HugeIcons.strokeRoundedFavourite,
                        title: 'Zuri Wishlist',
                        subtitle: 'Your faves from our online finds!',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return WishlistPage();
                              },
                            ),
                          );
                        },
                        pinkSubtitle: false,
                      ),
                      _buildDivider(width: dw * 0.05),
                      _buildMenuItem(
                        icon: HugeIcons.strokeRoundedAddCircle,
                        title: 'New Additions',
                        subtitle: 'Latest closet uploads & fresh buys',
                        onTap: () {},
                        pinkSubtitle: false,
                      ),
                      Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (_profileResponse?.newAdditions != null &&
                                    _profileResponse!.newAdditions.length >=
                                        1 &&
                                    _profileResponse!
                                        .newAdditions[0]
                                        .imageUrl
                                        .isNotEmpty)
                                  _buildProductImage(
                                    _profileResponse!.newAdditions[0].imageUrl,
                                    context,
                                  ),
                                SizedBox(width: 8),
                                if (_profileResponse?.newAdditions != null &&
                                    _profileResponse!.newAdditions.length >=
                                        2 &&
                                    _profileResponse!
                                        .newAdditions[1]
                                        .imageUrl
                                        .isNotEmpty)
                                  _buildProductImage(
                                    _profileResponse!.newAdditions[1].imageUrl,
                                    context,
                                  ),
                                SizedBox(width: 8),
                                if (_profileResponse?.newAdditions != null &&
                                    _profileResponse!.newAdditions.length >=
                                        3 &&
                                    _profileResponse!
                                        .newAdditions[2]
                                        .imageUrl
                                        .isNotEmpty)
                                  _buildProductImage(
                                    _profileResponse!.newAdditions[2].imageUrl,
                                    context,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: dh * 0.02),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: dw * 0.7,
                            height: dh * 0.05,
                            child: GlobalPinkButton(
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(14),
                              text: "Create fab looks with these now! 💃🏻",
                              onPressed: () {
                                context.goNamed(
                                  'createOutfit',
                                  queryParameters: {
                                    "occasion": "Random occasion",
                                    "imagePaths": images
                                        .map((file) => file.path)
                                        .join(','),
                                  },
                                  extra: null,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: dh * 0.02),
                      _buildDivider(width: dw * 0.05),
                      _buildMenuItem(
                        icon: HugeIcons.strokeRoundedCustomerSupport,
                        title: "Support",
                        subtitle:
                            "We're just a call or text away, you Unstoppable Style Queen 👑",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return SupportPage();
                              },
                            ),
                          );
                        },
                        pinkSubtitle: false,
                      ),
                      _buildDivider(width: dw * 0.05),
                      SizedBox(height: dh * 0.02),
                      // Log out
                      GestureDetector(
                        onTap: () async {
                          showGlobalDeleteConfirmationDialog(
                            context: context,
                            buttonText: "Log out",
                            title: "confirm",
                            content: "Are you sure?",
                            onConfirm: () async {
                              final result = await AuthApiService.logoutUser();
                              if (result['success']) {
                                await prefs
                                    .clear(); // This removes all keys and values
                                context.goNamed('home');
                              } else {
                                // Show error message or still navigate to login
                                // since local tokens were cleared anyway
                                context.goNamed(
                                  'login',
                                  extra:
                                      "from profile page after logout -- from After Login Profile Page",
                                );
                              }
                              return;
                            },
                          );
                          // final result = await AuthApiService.logoutUser();
                          // if (result['success']) {
                          //   context.goNamed('home');
                          // } else {
                          //   // Show error message or still navigate to login
                          //   // since local tokens were cleared anyway
                          //   context.goNamed('login');
                          // }
                        },
                        child: Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedLogout03,
                              color: Color(0xFFFF5236),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Log out',
                              style: GoogleFonts.libreFranklin(
                                color: Colors.red,
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(16),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: dh * 0.04),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildDivider({required double width}) {
  return Divider(
    indent: width,
    endIndent: width,
    color: Color(0xFFE5E7EA),
    height: 5,
    thickness: 2,
  );
}

Widget _buildMenuItem({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
  required bool pinkSubtitle,
}) {
  return Container(
    // padding: EdgeInsets.all(8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: Row(
          children: [
            HugeIcon(icon: icon, color: AppColors.titleTextColor, size: 24),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.libreFranklin(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.titleTextColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.libreFranklin(
                      fontSize: 14,
                      color: pinkSubtitle
                          ? AppColors.textPrimary
                          : Color(0xFF9EA2AE),
                    ),
                  ),
                ],
              ),
            ),
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: AppColors.titleTextColor,
              size: 28,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildProductImage(String imageUrl, BuildContext context) {
  return Container(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Image(
        image: NetworkImage(imageUrl),
        fit: BoxFit.fill,
        height: MediaQuery.of(context).size.height * 0.17,
        width: MediaQuery.of(context).size.height * 0.13,
      ),
    ),
  );
}
