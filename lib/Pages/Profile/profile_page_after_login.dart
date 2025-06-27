import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
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
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;
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
                              Navigator.pop(context);
                              context.goNamed('editProfile');
                            },
                            child: Row(
                              children: [
                                Text(
                                  'My Profile',
                                  style: GoogleFonts.libreFranklin(
                                    color: Colors.white,
                                    fontSize: 18,
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
                            onTap: () => context.goNamed('home2'),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Profile Info
                      Row(
                        children: [
                          // Profile Picture
                          const CircleAvatar(
                            radius: 32,
                            backgroundColor: Color(0xFFE5E7EA),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedUser,
                              color: AppColors.titleTextColor,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Profile Details
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    IconlyLight.location,
                                    color: Color(0xFFFFFFFF),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    ResultCache.loactiondata?[0] ?? "location",
                                    style: GoogleFonts.libreFranklin(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                prefs.getString('userFullName') ?? "User Name",
                                style: GoogleFonts.libreFranklin(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Hour Glass',
                                    style: GoogleFonts.libreFranklin(
                                      color: Color(0xFFF3F4F6),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "  |  ",
                                    style: TextStyle(color: Color(0xFFF3F4F6)),
                                  ),
                                  Text(
                                    'Warm, Medium',
                                    style: GoogleFonts.libreFranklin(
                                      color: Color(0xFFF3F4F6),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "  |  ",
                                    style: TextStyle(color: Color(0xFFF3F4F6)),
                                  ),
                                  Text(
                                    '5\'5',
                                    style: GoogleFonts.libreFranklin(
                                      color: Color(0xFFF3F4F6),
                                      fontSize: 14,
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
                        subtitle: '1 item',
                        onTap: () {},
                      ),
                      _buildDivider(width: dw * 0.05),
                      _buildMenuItem(
                        icon: HugeIcons.strokeRoundedUpload04,
                        title: 'Uploaded Looks',
                        subtitle:
                            "Your best angles you've uploaded - in one spot!",
                        onTap: () {},
                      ),
                      _buildDivider(width: dw * 0.05),
                      _buildMenuItem(
                        icon: HugeIcons.strokeRoundedBookmark02,
                        title: 'Saved Favorites',
                        subtitle: 'Our curations from your closet that you  💝',
                        onTap: () {},
                      ),
                      _buildDivider(width: dw * 0.05),
                      _buildMenuItem(
                        icon: HugeIcons.strokeRoundedFavourite,
                        title: 'Zuri Wishlist',
                        subtitle: 'Your faves from our online finds!',
                        onTap: () {},
                      ),
                      _buildDivider(width: dw * 0.05),
                      _buildMenuItem(
                        icon: HugeIcons.strokeRoundedAddCircle,
                        title: 'New Additions',
                        subtitle: 'Latest closet uploads & fresh buys',
                        onTap: () {},
                      ),
                      Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _buildProductImage('Blue Dress'),
                                const SizedBox(width: 8),
                                _buildProductImage('Black Heels'),
                                const SizedBox(width: 8),
                                _buildProductImage('Blue Pants'),
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
                              fontSize: 14,
                              text: "Create fab looks with these now! 💃🏻",
                              onPressed: () {},
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
                        onTap: () {},
                      ),
                      _buildDivider(width: dw * 0.05),
                      SizedBox(height: dh * 0.02),
                      // Log out
                      GestureDetector(
                        onTap: () async {
                          final result = await AuthApiService.logoutUser();
                          if (result['success']) {
                            context.goNamed('home');
                          } else {
                            // Show error message or still navigate to login
                            // since local tokens were cleared anyway
                            context.goNamed('login');
                          }
                        },
                        child: Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedLogout03,
                              color: Color(0xFFFF5236),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Log out',
                              style: GoogleFonts.libreFranklin(
                                color: Colors.red,
                                fontSize: 16,
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
              const SizedBox(width: 16),
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
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.libreFranklin(
                        fontSize: 14,
                        color: Color(0xFF9EA2AE),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.titleTextColor,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(String altText) {
    return Expanded(
      child: Container(
        height: 120,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Image(
            image: NetworkImage('http://placebeard.it/250/250'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
