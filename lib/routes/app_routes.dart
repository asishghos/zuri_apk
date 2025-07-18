import 'dart:developer' as Developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:testing2/Pages/AppError/error_page.dart';
import 'package:testing2/Pages/Auth/Login/login_page.dart';
import 'package:testing2/Pages/Auth/Password/check_mail_page.dart';
import 'package:testing2/Pages/Auth/Password/reset_password_page.dart';
import 'package:testing2/Pages/Auth/Password/set_new_password_page.dart';
import 'package:testing2/Pages/Auth/Signup/signup_page.dart';
import 'package:testing2/Pages/Chatbot/chat_popup_overlay.dart';
import 'package:testing2/Pages/Chatbot/chatbot_screen.dart';
import 'package:testing2/Pages/Chatbot/chathistory_screen.dart';
import 'package:testing2/Pages/Events/event_main_screen.dart';
import 'package:testing2/Pages/Home/home_page.dart';
import 'package:testing2/Pages/Home/home_page_2.dart';
import 'package:testing2/Pages/Profile/support_page.dart';
import 'package:testing2/Pages/Saved/saved_fav_page.dart';
import 'package:testing2/Pages/Scan&Discover/Auto/guidelines.dart';
import 'package:testing2/Pages/Scan&Discover/Manual/quiz_page.dart';
import 'package:testing2/Pages/Scan&Discover/Manual/body_shape_option.dart';
import 'package:testing2/Pages/Magazine/magazine_screen.dart';
import 'package:testing2/Pages/Profile/profile_page_before_login.dart';
import 'package:testing2/Pages/Products/affiliatelinks_page.dart';
import 'package:testing2/Pages/Profile/edit_profile_page.dart';
import 'package:testing2/Pages/Profile/profile_page_after_login.dart';
import 'package:testing2/Pages/Scan&Discover/StyleAnalyze/style_analyze_page.dart';
import 'package:testing2/Pages/Splash/onboadring_page.dart';
import 'package:testing2/Pages/Splash/splash_screen.dart';
import 'package:testing2/Pages/Scan&Discover/scan_discover_page.dart';
import 'package:testing2/Pages/Scan&Discover/Auto/image_upload_page.dart';
import 'package:testing2/Pages/Wardrobe/Closet/all_items_page.dart';
import 'package:testing2/Pages/Wardrobe/Closet/edit_tags_page.dart';
import 'package:testing2/Pages/Wardrobe/Closet/mywardrobe_page.dart';
import 'package:testing2/Pages/Wardrobe/Closet/upload_image_page.dart';
import 'package:testing2/Pages/Wardrobe/CreateOutfits/create_outfit_page.dart';
import 'package:testing2/Pages/Wardrobe/CreateOutfits/upload_outfit_page.dart';
import 'package:testing2/Pages/Weather/location_page.dart';
import 'package:testing2/routes/main_shell.dart';
import 'package:testing2/services/Class/auth_model.dart';
import 'package:testing2/services/DataSource/auth_api.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      /// Shell with BottomNav
      // ShellRoute(
      //   builder: (context, state, child) {
      //     Developer.log("Inside ShellRoute: ${state.fullPath}");
      //     return MainShell(
      //       child: child,
      //       showAppBar: true,
      //       showBottomNavBar: true,
      //       showBackButton: false,
      //     );
      //   },
      //   routes: [
      //     // GoRoute(
      //     //   path: '/home3',
      //     //   name: 'home3',
      //     //   builder: (context, state) => HomeScreen2(),
      //     // ),
      //   ],
      // ),
      GoRoute(
        path: '/eventmainscreen',
        name: 'eventmainscreen',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          return MainShell(
            child: CalendarEventsPage(
              eventId: extra?['eventId'],
              dayEventId: extra?['dayEventId'],
              openDayEventDetails: extra?['openDayEventDetails'] ?? false,
            ),
            showBottomNavBar: true,
            showAppBar: false,
            showBackButton: false,
          );
        },
      ),

      // 1st page for everytime user open this page
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) {
          Developer.log("Navigated to SplashScreen");
          return SplashScreen();
        },
      ),
      // -- 5sec video
      GoRoute(
        path: '/splash2',
        name: 'splash2',
        builder: (context, state) => ZuriVideoScreen(),
      ),
      // option page - 3 page is there
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) {
          Developer.log("Navigated to OptionPage");
          return OnboardingScreen();
        },
      ),

      // main home page --
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => MainShell(
          child: HomePage(),
          drawer: ProfileDrawerBeforeLogin(),
          showBottomNavBar: true,
          showAppBar: false,
          showBackButton: false,
        ),
      ),
      // main page after login
      GoRoute(
        path: '/home2',
        name: 'home2',
        builder: (context, state) => MainShell(
          child: HomePage2(),
          showBottomNavBar: true,
          showAppBar: false,
          showBackButton: false,
          drawer: const ProfileDrawerAfterLogin(),
        ),
      ),

      // <<<<<<<<<<<<<<<<< WARDROBE SECTION Start >>>>>>>>>>>>>>>>>>>>
      GoRoute(
        path: '/myWardrobe',
        name: 'myWardrobe',
        builder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>?;
          final isDialogBoxOpen = extraData?['isDialogBoxOpen'] ?? false;
          final occasion = extraData?['occasion'];
          final description = extraData?['description'];
          final eventId = extraData?['eventId'];
          final loaction = extraData?['location'];
          final dayEventId = extraData?['dayEventId'];

          return MainShell(
            child: MywardrobePage(
              isDialogBoxOpen: isDialogBoxOpen,
              occasion: occasion,
              description: description,
              eventId: eventId,
              loaction: loaction,
              dayEventId: dayEventId,
            ),
            showBottomNavBar: true,
            showAppBar: false,
            showBackButton: false,
          );
        },
      ),

      GoRoute(
        path: '/allItemsWardrobe',
        name: 'allItemsWardrobe',
        builder: (context, state) {
          final selectedTabIndex = state.extra as int;
          return MainShell(
            child: AllItemsWardrobePage(selectedTabIndex: selectedTabIndex),
            showAppBar: false,
            showBackButton: false,
            showBottomNavBar: false,
          );
        },
      ),
      GoRoute(
        path: '/editTags',
        name: 'editTags',
        builder: (context, state) {
          final fromPage = state.uri.queryParameters['fromPage'];
          final garmentId = state.uri.queryParameters['garmentId'];
          final garmentName = state.uri.queryParameters['garmentName'];
          return MainShell(
            child: EditTagsPage(
              fromPage: fromPage,
              garmentId: garmentId,
              garmentName: garmentName,
            ),
            showAppBar: false,
            showBackButton: false,
            showBottomNavBar: false,
          );
        },
      ),
      GoRoute(
        path: '/uploadImageWardrobe',
        name: 'uploadImageWardrobe',
        builder: (context, state) {
          final fromPage = state.extra as String?;
          return MainShell(
            child: UploadInwardrobePage(fromPage: fromPage),
            showAppBar: false,
            showBackButton: false,
            showBottomNavBar: false,
          );
        },
      ),
      // <<<<<<<<<<<<<<<<< WARDROBE SECTION End >>>>>>>>>>>>>>>>>>>>
      // Login page
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          final fromPage = state.extra as String;
          return LoginPage(fromPage: fromPage);
        },
      ),
      // profile drawer ---
      GoRoute(
        path: '/profileAfterLogin',
        name: 'profileAfterLogin',
        builder: (context, state) => const ProfileDrawerAfterLogin(),
      ),
      // profile drawer ---
      GoRoute(
        path: '/profileBeforeLogin',
        name: 'profileBeforeLogin',
        builder: (context, state) => const ProfileDrawerBeforeLogin(),
      ),
      //profile edit page
      GoRoute(
        path: '/editProfile',
        name: 'editProfile',
        builder: (context, state) {
          final profileResponse = state.extra as UserProfileResponse;
          return EditProfileScreen(profileResponse: profileResponse);
        },
      ),
      // Support Page
      GoRoute(
        path: '/support',
        name: 'support',
        builder: (context, state) {
          return SupportPage();
        },
      ),
      // Saved Favorites
      GoRoute(
        path: '/savedFav',
        name: 'savedFav',
        builder: (context, state) {
          return SavedFavoritesScreen();
        },
      ),
      //Sign Up page
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => SignUpPage(),
      ),
      // Reset Password Page --
      GoRoute(
        path: '/resetPassword',
        name: 'resetPassword',
        builder: (context, state) => MainShell(
          child: ResetPasswordPage(),
          showBackButton: true,
          showBottomNavBar: false,
          showAppBar: true,
          appBarTitleGrey: " ",
          appBarTitlePink: " ",
          loc: "login",
          extraData: "from Reset password page",
        ),
      ),
      // location page
      GoRoute(
        path: '/location',
        name: 'location',
        builder: (context, state) => MainShell(
          child: LocationPage(),
          showBackButton: false,
          showBottomNavBar: false,
          showAppBar: false,
        ),
      ),
      // Check Email Page --
      GoRoute(
        path: '/checkMail',
        name: 'checkMail',
        builder: (context, state) => MainShell(
          child: CheckEmailPage(),
          showBackButton: true,
          showBottomNavBar: false,
          showAppBar: true,
          appBarTitleGrey: " ",
          appBarTitlePink: " ",
          loc: "login",
        ),
      ),
      // Set New Password Page --
      GoRoute(
        path: '/setNewPassword',
        name: 'setNewPassword',
        builder: (context, state) {
          final String email = state.extra as String;
          return MainShell(
            child: SetNewPasswordPage(email: email),
            showBackButton: true,
            showBottomNavBar: false,
            showAppBar: true,
            appBarTitleGrey: " ",
            appBarTitlePink: " ",
            loc: "login",
          );
        },
      ),
      // Guidelines dos don'ts Page --
      GoRoute(
        path: '/guidelines',
        name: 'guidelines',
        builder: (context, state) => MainShell(
          child: PhotoUploadGuidelinesPage(),
          showBackButton: false,
          showBottomNavBar: false,
          showAppBar: false,
          appBarTitleGrey: " ",
          appBarTitlePink: " ",
          loc: "login",
        ),
      ),
      // auto upload home page -- Discover what makes you mirror blush!
      GoRoute(
        path: '/scan&discover',
        name: 'scan&discover',
        builder: (context, state) => const MainShell(
          child: ScanDiscoverPage(),
          appBarTitleGrey: 'Discover what makes your ',
          appBarTitlePink: 'mirror blush!',
          showBackButton: false,
          showBottomNavBar: false,
          showAppBar: true,
          loc: 'onboarding',
        ),
      ),

      /// Auto Analysis Flow
      GoRoute(
        path: '/autoUpload',
        name: 'autoUpload',
        builder: (context, state) {
          Developer.log("Navigated to AutoImageUploadPage");
          final File? file = state.extra as File?;
          return MainShell(
            child: file != null
                ? AutoImageUploadPage(file: file)
                : const ErrorPage(
                    errorTxt:
                        "error from image pass home_page_1 to auto_image_upload page",
                  ),
            appBarTitleGrey: "Can't wait to see your",
            appBarTitlePink: " gorg pix, hottie!",
            showBackButton: true,
            showBottomNavBar: false,
            showAppBar: true,
            loc: 'scan&discover',
          );
        },
      ),
      // new style analysis page
      GoRoute(
        path: '/styleAnalyze',
        name: 'styleAnalyze',
        builder: (context, state) {
          return MainShell(
            child: StyleAnalysisPage(),
            showAppBar: false,
            showBackButton: false,
            showBottomNavBar: true,
          );
        },
      ),

      /// Manual Flow
      GoRoute(
        path: '/body_shape_option',
        name: 'body_shape_option',
        builder: (context, state) {
          Developer.log("Navigated to BodyShapeSelector");
          return const MainShell(
            child: BodyShapeSelector(),
            appBarTitleGrey: 'Choose your ',
            appBarTitlePink: 'Body type!',
            showAppBar: true,
            showBottomNavBar: false,
            showBackButton: true,
            loc: 'scan&discover',
          );
        },
      ),
      //What is your vein color
      GoRoute(
        path: '/quiz',
        name: 'quiz',
        builder: (context, state) {
          final bodyShape = state.uri.queryParameters["body_shape"];
          Developer.log("SkinImageQuizPage Body Shape: $bodyShape");
          if (bodyShape == null) {
            return const MainShell(
              child: ErrorPage(
                errorTxt:
                    "You not select any Body shape. This error from Quiz 1 Page and Body shape option page",
              ),
              appBarTitleGrey: 'Error',
              showAppBar: true,
              showBackButton: true,
              loc: 'body_shape_option',
            );
          }
          return MainShell(
            child: QuizPage(body_shape: bodyShape),
            appBarTitleGrey: 'What is your ',
            appBarTitlePink: 'vein color',
            showAppBar: true,
            showBackButton: true,
            showBottomNavBar: false,
            loc: 'body_shape_option',
          );
        },
      ),

      //chat bot screem
      GoRoute(
        path: "/chatbot",
        name: "chatbot",
        builder: (context, state) {
          return MainShell(
            child: ZuriChatScreen(),
            appBarTitleGrey: "your ai assistant",
            loc: "home",
            showAppBar: false,
            showBackButton: true,
            showBottomNavBar: true,
          );
        },
      ),
      GoRoute(
        path: "/affiliate",
        name: "affiliate",
        builder: (context, state) {
          final extra = state.extra as Map<String, String?>? ?? {};
          final keywordsParam = state.uri.queryParameters['keywords'];
          final keywords = (keywordsParam != null && keywordsParam.isNotEmpty)
              ? keywordsParam
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList()
              : <String>[];

          final needToOpenAskZuriStr =
              state.uri.queryParameters['needToOpenAskZuri'];
          final needToOpenAskZuri = needToOpenAskZuriStr == 'true';

          return FutureBuilder<bool>(
            future: AuthApiService.isLoggedIn(),
            builder: (context, snapshot) {
              final isLoggedIn = snapshot.data ?? false;

              // Now we can use the public state class
              final affiliatePageKey = GlobalKey<AffiliateLinksPageState>();

              return ChatOverlayManager(
                firstQuery: extra,
                initiallyVisible: needToOpenAskZuri,
                // Pass the callback to update keywords
                onKeywordsUpdate: (newKeywords) {
                  // Replace the AffiliateLinksPage keywords with new ones
                  affiliatePageKey.currentState?.updateKeywords(newKeywords);
                },
                child: MainShell(
                  child: AffiliateLinksPage(
                    key: affiliatePageKey,
                    keywords: keywords,
                    needToOpenAskZuri: needToOpenAskZuri,
                  ),
                  appBarTitlePink:
                      'Customized items for you.\n Curated by us with ❤',
                  showBackButton: true,
                  showBottomNavBar: false,
                  showAppBar: true,
                  loc: isLoggedIn ? 'home2' : 'home',
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: "/chathistory",
        name: "chathistory",
        builder: (context, state) {
          return MainShell(child: ChatHistoryScreen());
        },
      ),
      GoRoute(
        path: "/magazine",
        name: "magazine",
        builder: (context, state) {
          return MainShell(
            child: MagazineScreen(),
            showBottomNavBar: true,
            showAppBar: false,
            showBackButton: false,
          );
        },
      ),
      GoRoute(
        path: "/error",
        name: "error",
        builder: (context, state) {
          return ErrorPage();
        },
      ),

      GoRoute(
        path: '/createOutfit',
        name: 'createOutfit',
        builder: (context, state) {
          final occasion = state.uri.queryParameters['occasion'];
          final imagePathsParam = state.uri.queryParameters['imagePaths'];

          List<File>? imagesList;
          if (imagePathsParam != null && imagePathsParam.isNotEmpty) {
            imagesList = imagePathsParam
                .split(',')
                .map((path) => File(path.trim()))
                .toList();
          }

          final extraData = state.extra as Map<String, dynamic>?;
          final isDialogBoxOpen = extraData?['isDialogBoxOpen'] ?? false;
          final description = extraData?['description'];
          final eventId = extraData?['eventId'];
          final loaction = extraData?['location'];
          final dayEventId = extraData?['dayEventId'];
          return MainShell(
            child: CreateOutfitPage(
              occasion: occasion,
              images: imagesList,
              description: description,
              eventId: eventId,
              isDialogBoxOpen: isDialogBoxOpen,
              loaction: loaction,
              dayEventId: dayEventId,
            ),
            showAppBar: false,
            showBackButton: false,
            showBottomNavBar: false,
          );
        },
      ),

      GoRoute(
        path: '/uploadOutfit',
        name: 'uploadOutfit',
        builder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>?;
          final isDialogBoxOpen = extraData?['isDialogBoxOpen'] ?? false;
          final occasion = extraData?['occasion'];
          final description = extraData?['description'];
          final eventId = extraData?['eventId'];
          final loaction = extraData?['location'];
          final dayEventId = extraData?['dayEventId'];
          return MainShell(
            child: UploadOutfitPage(
              isDialogBoxOpen: isDialogBoxOpen,
              occasion: occasion,
              description: description,
              eventId: eventId,
              loaction: loaction,
              dayEventId: dayEventId,
            ),
            showAppBar: false,
            showBackButton: false,
            showBottomNavBar: false,
          );
        },
      ),
    ],
    errorBuilder: (context, state) {
      Developer.log("Route Error: ${state.error}");
      return const ErrorPage();
    },
  );
}
