import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/services/DataSource/auth_api.dart';
// import 'package:flutter_svg/flutter_svg.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  final String? appBarTitleGrey;
  final String? appBarTitlePink;
  final bool showBackButton;
  final bool showAppBar;
  final bool showBottomNavBar;
  final String? loc;
  final Object? extraData;
  final Widget? drawer;

  const MainShell({
    super.key,
    required this.child,
    this.appBarTitleGrey,
    this.appBarTitlePink,
    this.showBackButton = false,
    this.showAppBar = true,
    this.showBottomNavBar = true,
    this.loc,
    this.extraData,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    final location = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.fullPath;
    print("MainShell location: $location | back loc: $loc");

    int getCurrentIndex() {
      if (location.startsWith('/home2')) return 0;
      if (location.startsWith('/chatbot')) return 1;
      if (location.startsWith('/myWardrobe')) return 2;
      if (location.startsWith('/magazine')) return 3;
      if (location.startsWith('/eventmainscreen')) return 4;
      return 0;
    }

    void handleBackNavigation() {
      print("Back pressed, navigating to: $loc");
      try {
        if (loc != null) {
          context.goNamed(loc!, extra: extraData);
        } else if (GoRouter.of(context).canPop()) {
          context.pop();
        } else {
          context.goNamed('home');
        }
      } catch (e) {
        print("Back navigation failed: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Navigation failed')));
        }
      }
    }

    void handleNavTap(int index) async {
      print("Nav tapped: $index");
      try {
        switch (index) {
          case 0:
            final isLoggedIn = await AuthApiService.isLoggedIn();
            if (isLoggedIn) {
              context.goNamed('home2');
            } else {
              context.goNamed('home');
            }
            break;

          case 1:
            context.goNamed('chatbot');
            break;
          case 2:
            context.goNamed('myWardrobe');
            break;
          case 3:
            context.goNamed('magazine');
            break;
          case 4:
            context.goNamed('eventmainscreen');
            break;
        }
      } catch (e) {
        print("Navigation failed: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Navigation failed')));
        }
      }
    }

    final currentIndex = getCurrentIndex();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              automaticallyImplyLeading: showBackButton,
              leadingWidth: 56,
              leading: showBackButton
                  ? GestureDetector(
                      onTap: handleBackNavigation,
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        size: 24,
                        color: AppColors.titleTextColor,
                      ),
                    )
                  : null,
              title: RichText(
                text: TextSpan(
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(16),
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    // First half (grey)
                    TextSpan(
                      text: appBarTitleGrey,
                      style: GoogleFonts.libreFranklin(
                        color: AppColors.titleTextColor,
                      ),
                    ),
                    // Second half (pink)
                    TextSpan(
                      text: appBarTitlePink,
                      style: GoogleFonts.libreFranklin(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              centerTitle: true,
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: MediaQuery.of(context).size.width * 0.1094527,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            )
          : null,
      extendBody: false,
      drawer: drawer,
      body: SafeArea(bottom: !showBottomNavBar, child: child),
      bottomNavigationBar: showBottomNavBar
          ? Container(
              padding: const EdgeInsets.only(
                bottom: 16,
                left: 8,
                right: 8,
                top: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFA4949475),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    "assets/images/navbar/home-10 (3).svg",
                    'Home',
                    0,
                    currentIndex,
                    context,
                    handleNavTap,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => handleNavTap(1),
                      child: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width:
                                  MediaQuery.of(context).size.width * 0.0746268,
                              height:
                                  MediaQuery.of(context).size.height *
                                  0.0343249,
                              child: Lottie.asset(
                                'assets/images/chatbot/animation.json',
                              ),
                            ),
                            // SizedBox(height: MediaQuery.of(context).size.height * 0.009153318),
                            Text(
                              "Ask Zuri",
                              style: GoogleFonts.libreFranklin(
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(10),
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                                letterSpacing: -0.2,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildNavItem(
                    "assets/images/navbar/wardrobe-01.svg",
                    'Zuri Closet',

                    2,
                    currentIndex,
                    context,
                    handleNavTap,
                  ),
                  _buildNavItem(
                    "assets/images/navbar/mastodon.svg",
                    null,
                    3,
                    currentIndex,
                    context,
                    handleNavTap,
                  ),
                  _buildNavItem(
                    "assets/images/navbar/calendar-03.svg",
                    'Events',
                    4,
                    currentIndex,
                    context,
                    handleNavTap,
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildNavItem(
    String svgpath,
    String? labelText,
    int index,
    int currentIndex,
    BuildContext context,
    Function(int) onTap,
  ) {
    final isSelected = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.049751243,
                height: MediaQuery.of(context).size.height * 0.022883295,
                child: SvgPicture.asset(
                  svgpath,
                  colorFilter: ColorFilter.mode(
                    isSelected ? AppColors.textPrimary : Colors.grey.shade600,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.009153318,
              ),
              (labelText != null)
                  ? Text(
                      labelText,
                      style: GoogleFonts.libreFranklin(
                        fontSize: MediaQuery.of(context).textScaler.scale(10),
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppColors.textPrimary
                            : Colors.grey.shade600,
                        // letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : isSelected
                  ? SvgPicture.asset('assets/images/navbar/Frame 1634.svg')
                  : SvgPicture.asset('assets/images/navbar/Frame 1634 (1).svg'),
            ],
          ),
        ),
      ),
    );
  }
}
