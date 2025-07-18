import 'dart:developer' as Developer;

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Function/global_function.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/Pages/Products/wishlist_page.dart';
import 'package:testing2/Pages/Weather/weather_logic.dart';
import 'package:testing2/services/Class/auth_model.dart';
import 'package:testing2/services/DataSource/auth_api.dart';
import 'package:testing2/services/DataSource/weather_api.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage2 extends StatefulWidget {
  HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  SharedPreferences? prefs = null;

  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initPrefs();
    _fetchKeywords();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  List<String>? _keywords;
  Future<void> _fetchKeywords() async {
    try {
      final result = await GlobalFunction.findKeywordsUserSpecific(
        prefs?.getString("bodyShape") ?? "Apple",
        prefs?.getString("underTone") ?? "Neutral",
      );
      _keywords = result;
      _loadProducts(result);
    } catch (e) {
      showErrorSnackBar(context, "failed to fetch User based keywords");
    }
  }

  List<Map<String, String>> _products = [];
  bool _isLoading = true;

  Future<void> _loadProducts(List<String> keywords) async {
    setState(() {
      _isLoading = true;
    });
    final result = await GlobalFunction.searchProductsByKeywords(keywords);
    // Developer.log(result.toString());
    setState(() {
      _products = result;
      _isLoading = false;
    });
  }

  final WeatherApiService _weatherService = WeatherApiService();

  WeatherLocationData? _weatherData;
  bool _isRefreshing = false;
  Future<void> loadWeatherData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Request permission first
      final hasPermission = await _weatherService.requestLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission denied');
      }

      // Check if location services are enabled
      final isServiceEnabled = await _weatherService.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      // Get complete weather data
      final weatherData = await _weatherService.getCompleteWeatherData();

      setState(() {
        _weatherData = weatherData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint("Error loading weather data: $e");
    }
  }

  Future<void> refreshWeatherData() async {
    if (_isRefreshing || _isLoading) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      final weatherData = await _weatherService.getCompleteWeatherData();

      setState(() {
        _weatherData = weatherData;
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        _isRefreshing = false;
      });

      debugPrint("Error refreshing weather data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Column(
        children: [
          // Fixed Header Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // SizedBox(height: MediaQuery.of(context).size.height * 0.022883295),
                // Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Builder(
                          builder: (context) => GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: CircleAvatar(
                              radius: 32,
                              backgroundColor: Color(0xFFE5E7EA),
                              child:
                                  (prefs?.getString("userProfilePic") != null &&
                                      prefs!
                                          .getString("userProfilePic")!
                                          .isNotEmpty)
                                  ? ClipOval(
                                      child: Image.network(
                                        prefs!.getString("userProfilePic")!,
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
                          ),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back,',
                              style: GoogleFonts.libreFranklin(
                                color: AppColors.titleTextColor,
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(16),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              prefs?.getString("userFullName") ?? "User",
                              style: GoogleFonts.libreFranklin(
                                color: AppColors.textPrimary,
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(16),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
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
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEB),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFFD34169),
                                width: 0.63,
                              ),
                            ),
                            child: Stack(
                              children: [
                                const Center(
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedFavourite,
                                    color: AppColors.textPrimary,
                                    size: 28,
                                  ),
                                ),
                                // Positioned(
                                //   top: 5,
                                //   right: 5,
                                //   child: Container(
                                //     width: 16,
                                //     height:
                                //         MediaQuery.of(context).size.height *
                                //         0.018306636,
                                //     decoration: const BoxDecoration(
                                //       color: AppColors.titleTextColor,
                                //       shape: BoxShape.circle,
                                //     ),
                                //     child: Center(
                                //       child: Text(
                                //         '9',
                                //         style: GoogleFonts.libreFranklin(
                                //           color: Colors.white,
                                //           fontSize: MediaQuery.of(context).textScaler.scale(8),
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        GestureDetector(
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEB),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFFD34169),
                                width: 0.63,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedNotification01,
                                    color: AppColors.textPrimary,
                                    size: 28,
                                  ),
                                ),
                                // Positioned(
                                //   top: 5,
                                //   right: 5,
                                //   child: Container(
                                //     width: 16,
                                //     height:
                                //         MediaQuery.of(context).size.height *
                                //         0.018306636,
                                //     decoration: const BoxDecoration(
                                //       color: AppColors.titleTextColor,
                                //       shape: BoxShape.circle,
                                //     ),
                                //     child: Center(
                                //       child: Text(
                                //         '4',
                                //         style: GoogleFonts.libreFranklin(
                                //           color: Colors.white,
                                //           fontSize: MediaQuery.of(context).textScaler.scale(8),
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.0274599,
                ),
                // Search Bar
                Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEB),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFD34169)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.049751243,
                      ),
                      const Icon(
                        IconlyLight.search,
                        color: Color(0xFFE91E63),
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: 'Style me for a...',
                            hintStyle: GoogleFonts.libreFranklin(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(16),
                            ),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (value) {
                            if (value.isEmpty) return;
                            context.goNamed(
                              'createOutfit',
                              queryParameters: {"occasion": value},
                              extra: null,
                            );
                          },
                        ),
                      ),

                      // Padding(
                      //   padding: EdgeInsets.only(right: 16),
                      //   child: const Icon(
                      //     IconlyLight.camera,
                      //     color: AppColors.textPrimary,
                      //     size: 32,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.009153318,
                ),
              ],
            ),
          ),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WeatherWidget(),
                  // Latest from Zuri Unzipped Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Latest from Zuri Unzipped',
                        style: GoogleFonts.libreFranklin(
                          fontSize: MediaQuery.of(context).textScaler.scale(20),
                          fontWeight: FontWeight.w600,
                          color: AppColors.titleTextColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.goNamed('magazine');
                        },
                        child: Text(
                          'All Stories',
                          style: GoogleFonts.libreFranklin(
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(14),
                            color: Color(0xFF2563EB),
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.022883295,
                  ),

                  // Featured Article Card
                  Container(
                    width: double.infinity,
                    height: dh * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/home2/h1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.009153318,
                  ),

                  Text(
                    'Look Hot, Stay Cool',
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(20),
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFDC4C72),
                    ),
                  ),

                  Text(
                    '5 Beachwear Trends to Pack Now for your upcoming Goa Getaway!',
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(16),
                      color: Color(0xFF9EA2AE),
                      height: 1.4,
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.0274599,
                  ),

                  // Easy Styling Section
                  Text(
                    'Few clicks. Full closet. Easy.',
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(20),
                      fontWeight: FontWeight.w600,
                      color: AppColors.titleTextColor,
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.018306636,
                  ),
                  // get started
                  Container(
                    width: double.infinity,
                    height: dh * 0.2,
                    padding: const EdgeInsets.only(top: 16, left: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE7E9),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upload pic(s) of your closet faves. We\'ll auto-style them for any of your upcoming events.',
                                style: GoogleFonts.libreFranklin(
                                  fontSize: MediaQuery.of(
                                    context,
                                  ).textScaler.scale(14),
                                  color: AppColors.subTitleTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              // SizedBox(
                              //   height:
                              //       MediaQuery.of(context).size.height *
                              //       0.018306636,
                              // ),
                              ElevatedButton(
                                onPressed: () {
                                  context.goNamed('uploadImageWardrobe');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.textPrimary,
                                  foregroundColor: Color(0xFFFDE7E9),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                ),
                                child: Text(
                                  'Get started',
                                  style: GoogleFonts.libreFranklin(
                                    fontSize: MediaQuery.of(
                                      context,
                                    ).textScaler.scale(14),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width:
                              MediaQuery.of(context).size.width * 0.049751243,
                        ),
                        ClipRRect(
                          child: Image.asset('assets/images/home2/h2.png'),
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.0274599,
                  ),

                  // Hot & Fresh Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hot & Fresh: Just-Dropped\nPicks Curated for You',
                        style: GoogleFonts.libreFranklin(
                          fontSize: MediaQuery.of(context).textScaler.scale(20),
                          fontWeight: FontWeight.w600,
                          color: AppColors.titleTextColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final stringKeywords = (_keywords as List)
                              .cast<String>()
                              .join(',');
                          context.goNamed(
                            'affiliate',
                            queryParameters: {
                              'keywords': stringKeywords,
                              'needToOpenAskZuri': "false",
                            },
                          );
                        },
                        child: Text(
                          'View All',
                          style: GoogleFonts.libreFranklin(
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(14),
                            color: Color(0xFF2563EB),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.018306636,
                  ),

                  // Product Grid
                  // Show only 4 products
                  _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.textPrimary,
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _products.length >= 4
                              ? 4
                              : _products.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 20,
                                childAspectRatio: 0.60,
                              ),
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return ProductCard(
                              link: product['link'] ?? '',
                              imageUrl: product['image'] ?? '',
                              title: product['title'] ?? '',
                              discountedPrice: product['price'] ?? '',
                              store: product['platform'] ?? '',
                              dh: dh,
                              initialFavorite: false,
                            );
                          },
                        ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.0274599,
                  ),

                  // Style SOS Section
                  Text(
                    'Style SOS',
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(20),
                      fontWeight: FontWeight.w600,
                      color: AppColors.titleTextColor,
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.022883295,
                  ),

                  Container(
                    width: double.infinity,
                    height: dh * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/home2/h7.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                      height: MediaQuery.of(context).size.height * 0.03432490,
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.009153318,
                  ),

                  Text(
                    'Upload a full-length snap of your look',
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(20),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.009153318,
                  ),

                  Text(
                    'For a planned or current event—and we\'ll tell you what slays, what sways, and how to turn up the heat.',
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(16),
                      color: Color(0xFF9EA2AE),
                      height: 1.4,
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.018306636,
                  ),
                  GlobalPinkButton(
                    text: "Upload Now",
                    onPressed: () {
                      context.goNamed("chatbot");
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.0343249,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//   Widget _buildProductCard(
//     String link,
//     String imageUrl,
//     String title,
//     String discountedPrice,
//     String store,
//     double dh,
//   ) {
//     return GestureDetector(
//       onTap: () async {
//         Developer.log('ProductCard - onTap: Opening product link: ${link}');
//         try {
//           await launchUrl(
//             Uri.parse(link),
//             mode: LaunchMode.externalApplication,
//           );
//         } catch (e) {}
//       },
//       child: Container(
//         color: Colors.white,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: const BorderRadius.all(Radius.circular(32)),
//                   color: const Color(0xFFF5F5F5),
//                   image: DecorationImage(
//                     image: NetworkImage(imageUrl),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 8),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: GoogleFonts.libreFranklin(
//                       fontSize: MediaQuery.of(context).textScaler.scale(16),
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFFE91E63),
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   SizedBox(height: 4),
//                   Row(
//                     children: [
//                       if (originalPrice.isNotEmpty) ...[
//                         Text(
//                           originalPrice,
//                           style: GoogleFonts.libreFranklin(
//                             fontSize: MediaQuery.of(context).textScaler.scale(14),
//                             color: AppColors.subTitleTextColor,
//                             decoration: TextDecoration.lineThrough,
//                           ),
//                         ),
//                         SizedBox(width: 4),
//                       ],
//                       Text(
//                         discountedPrice,
//                         style: GoogleFonts.libreFranklin(
//                           fontSize: MediaQuery.of(context).textScaler.scale(16),
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.titleTextColor,
//                         ),
//                       ),
//                       if (discount.isNotEmpty) ...[
//                         SizedBox(width: 4),
//                         Text(
//                           "(${discount} OFF)",
//                           style: GoogleFonts.libreFranklin(
//                             fontSize: 12,
//                             color: AppColors.textPrimary,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                       Spacer(),
//                       GestureDetector(
//                         onTap: () {},
//                         child: const HugeIcon(
//                           icon: HugeIcons.strokeRoundedFavourite,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     store,
//                     style: GoogleFonts.libreFranklin(
//                       fontSize: 12,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
