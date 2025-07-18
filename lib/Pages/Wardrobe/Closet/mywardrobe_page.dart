import 'dart:developer' as Developer;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Function/global_function.dart';
import 'package:testing2/Global/Widget/global_dialogbox.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/services/Class/auth_model.dart';
import 'package:testing2/services/Class/digital_wardrobe_model.dart';
import 'package:testing2/services/DataSource/auth_api.dart';
import 'package:testing2/services/DataSource/digital_wardrobe_api.dart';

class MywardrobePage extends StatefulWidget {
  final bool? isDialogBoxOpen;
  final String? occasion;
  final String? description;
  final String? eventId;
  final String? loaction;
  final String? dayEventId;

  const MywardrobePage({
    super.key,
    this.isDialogBoxOpen,
    this.occasion,
    this.description,
    this.eventId,
    this.loaction,
    this.dayEventId,
  });
  @override
  _MywardrobePageState createState() => _MywardrobePageState();
}

class _MywardrobePageState extends State<MywardrobePage> {
  final TextEditingController _occasionController = TextEditingController();
  SharedPreferences? prefs = null;
  bool _isLoggedIn = true;
  bool _isCheckingAuth = true;

  void _checkLoginStatus() async {
    try {
      final isLoggedIn = await AuthApiService.isLoggedIn();
      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
          _isCheckingAuth = false;
        });
      }
    } catch (e) {
      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isCheckingAuth = false;
        });
      }
    }
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
      // Developer.log(result.toString());
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

  CategoryCounts? _categoryCounts;
  Future<void> _getCategoryCounts() async {
    setState(() {
      _isLoading = true;
    });

    final result = await WardrobeApiService.fetchCategoryCounts();
    if (result != null) {
      Developer.log(result.counts.toString());
      setState(() {
        _categoryCounts = result;
      });
    } else {
      Developer.log("❌ Couldn't fetch category counts");
      setState(() {
        _categoryCounts = CategoryCounts(counts: {});
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _getCategoryCounts();
    // Use WidgetsBinding to ensure dialog shows after build completes
    if (widget.isDialogBoxOpen != null &&
        widget.isDialogBoxOpen! &&
        widget.isDialogBoxOpen == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => _buildCustomPopup1(context),
          );
        }
      });
      _occasionController.text = widget.occasion!;
    }
    initPrefs();
    _fetchKeywords();
  }

  @override
  void dispose() {
    _occasionController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;

    if (_isCheckingAuth || _isLoading) {
      return LoadingPage();
    }
    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              // Fixed Header Section
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 12),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Zuri',
                                    style: GoogleFonts.libreFranklin(
                                      color: AppColors.titleTextColor,
                                      fontSize: MediaQuery.of(
                                        context,
                                      ).textScaler.scale(18),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " Closet",
                                    style: GoogleFonts.libreFranklin(
                                      color: AppColors.textPrimary,
                                      fontSize: MediaQuery.of(
                                        context,
                                      ).textScaler.scale(18),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
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
                                  icon: HugeIcons.strokeRoundedNotification01,
                                  color: AppColors.textPrimary,
                                  size: 28,
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: Container(
                                  width: 16,
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.018306636,
                                  decoration: const BoxDecoration(
                                    color: AppColors.titleTextColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '4',
                                      style: GoogleFonts.libreFranklin(
                                        color: Colors.white,
                                        fontSize: MediaQuery.of(
                                          context,
                                        ).textScaler.scale(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.0274599,
                    ),
                    // Action Buttons Row
                    Row(
                      children: [
                        GlobalPinkButton(
                          text: "My Zuri Closet",
                          onPressed: () {},
                          width: dw * 0.4328,
                          height: 42,
                          fontSize: 13.45,
                          leftIcon: true,
                          leftIconData: HugeIcons.strokeRoundedHanger,
                        ),
                        SizedBox(width: 12),
                        GlobalTextButton(
                          text: "Create wow looks",
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => _buildCustomPopup1(context),
                            );
                          },
                          width: dw * 0.4328,
                          height: 42,
                          fontSize: 13.45,
                          leftIcon: true,
                          leftIconData: HugeIcons.strokeRoundedAdd01,
                          borderWidth: 1,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.018306636,
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
                    children: [
                      // Category Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        // childAspectRatio: 1.1,
                        children: [
                          _buildCategoryCard(
                            'Tops',
                            dh,
                            dw,
                            '(${_categoryCounts?.counts['Tops'] ?? 0} Items)',
                            'assets/images/wardrobe/s9.svg',
                            () {
                              context.goNamed('allItemsWardrobe', extra: 2);
                            },
                            80,
                            50,
                          ),
                          _buildCategoryCard(
                            'Bottoms',
                            dh,
                            dw,
                            '(${_categoryCounts?.counts['Bottoms'] ?? 0} Items)',
                            'assets/images/wardrobe/s3.svg',
                            () {
                              context.goNamed('allItemsWardrobe', extra: 3);
                            },
                            93,
                            40.5,
                          ),
                          _buildCategoryCard(
                            'Ethnic',
                            dh,
                            dw,
                            '(${_categoryCounts?.counts['Ethnic'] ?? 0} Items)',
                            'assets/images/wardrobe/s2.svg',
                            () {
                              context.goNamed('allItemsWardrobe', extra: 4);
                            },
                            118,
                            42,
                          ),
                          _buildCategoryCard(
                            'Dresses',
                            dh,
                            dw,
                            '(${_categoryCounts?.counts['Dresses'] ?? 0} Items)',
                            'assets/images/wardrobe/s5.svg',
                            () {
                              context.goNamed('allItemsWardrobe', extra: 5);
                            },
                            117,
                            62,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.0274599,
                      ),

                      // Browse All Items Button
                      GlobalTextButton(
                        text: "Browse All Item(s)",
                        onPressed: () {
                          context.goNamed('allItemsWardrobe', extra: 0);
                        },
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.018306636,
                      ),

                      // Add New Item Button
                      GlobalPinkButton(
                        text: "Add New Item",
                        onPressed: () {
                          context.goNamed(
                            'uploadImageWardrobe',
                            extra: 'fromMyWardrobe',
                          );
                        },
                        leftIcon: true,
                        leftIconData: HugeIcons.strokeRoundedAdd01,
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.036613272,
                      ),

                      // Personalized Recommendations Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Personalized recommendations',
                            style: GoogleFonts.libreFranklin(
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(18),
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF000000),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
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
                                color: Color(0xFF2563EB),
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(14),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.009153318,
                      ),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text.rich(
                          TextSpan(
                            text:
                                'Based on what complements your closet and you ❤️',
                            style: GoogleFonts.libreFranklin(
                              color: Color(0xFF6D717F),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.018306636,
                      ),

                      // Recommendation Cards
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
                      SizedBox(height: dh * 0.0366),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (!_isLoggedIn)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: GlobalDialogBox(
                  title: "Please Sign Up to Continue",
                  description:
                      "Babe, I can’t save your closet—or decode \nyour best colors and fits—unless you sign up. \nLet’s make this official? Pretty please!",
                  buttonNeed: true,
                  buttonText: "OK, make me next-level stylish",
                  onTap: () {
                    context.goNamed('scan&discover');
                  },
                ),
              ),
            ),
          // Interaction blocker when not logged in
          // if (!_isLoggedIn)
          //   Positioned.fill(
          //     child: AbsorbPointer(
          //       absorbing: true,
          //       child: Container(color: Colors.transparent),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    double dh,
    double dw,
    String itemCount,
    String svgPath,
    VoidCallback onTap,
    double height,
    double width,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: dh * 0.20366,
        width: dw * 0.42288557,
        decoration: BoxDecoration(
          color: Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.textPrimary),
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: height,
                width: width,
                child: SvgPicture.asset(svgPath),
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(20),
                  fontWeight: FontWeight.w600,
                  color: AppColors.titleTextColor,
                ),
              ),
              // SizedBox(height: 4),
              Text(
                itemCount,
                style: GoogleFonts.libreFranklin(
                  fontSize: 12,
                  color: AppColors.subTitleTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // // Helper method for product cards
  // Widget _buildProductCard(
  //   String imagePath,
  //   String title,
  //   String originalPrice,
  //   String discountedPrice,
  //   String discount,
  //   String store,
  //   double dh,
  // ) {
  //   return Container(
  //     color: Colors.white,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Expanded(
  //           child: Container(
  //             width: double.infinity,
  //             decoration: BoxDecoration(
  //               borderRadius: const BorderRadius.all(Radius.circular(32)),
  //               color: const Color(0xFFF5F5F5),
  //               image: DecorationImage(
  //                 image: AssetImage(imagePath),
  //                 fit: BoxFit.cover,
  //               ),
  //             ),
  //           ),
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.only(top: 8),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Text(
  //                     title,
  //                     style: GoogleFonts.libreFranklin(
  //                       fontSize: MediaQuery.of(context).textScaler.scale(18),
  //                       fontWeight: FontWeight.w600,
  //                       color: Color(0xFFE91E63),
  //                     ),
  //                   ),
  //                   HugeIcon(
  //                     icon: HugeIcons.strokeRoundedFavourite,
  //                     color: AppColors.titleTextColor,
  //                   ),
  //                 ],
  //               ),
  //               SizedBox(height: 4),
  //               Row(
  //                 children: [
  //                   if (originalPrice.isNotEmpty) ...[
  //                     Text(
  //                       originalPrice,
  //                       style: GoogleFonts.libreFranklin(
  //                         fontSize: MediaQuery.of(context).textScaler.scale(14),
  //                         color: AppColors.subTitleTextColor,
  //                         decoration: TextDecoration.lineThrough,
  //                       ),
  //                     ),
  //                     SizedBox(width: 4),
  //                   ],
  //                   Text(
  //                     discountedPrice,
  //                     style: GoogleFonts.libreFranklin(
  //                       fontSize: MediaQuery.of(context).textScaler.scale(16),
  //                       fontWeight: FontWeight.bold,
  //                       color: AppColors.titleTextColor,
  //                     ),
  //                   ),
  //                   if (discount.isNotEmpty) ...[
  //                     SizedBox(width: 4),
  //                     Text(
  //                       "(${discount} OFF)",
  //                       style: GoogleFonts.libreFranklin(
  //                         fontSize: 12,
  //                         color: AppColors.textPrimary,
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                   ],
  //                 ],
  //               ),
  //               SizedBox(height: 4),
  //               Text(
  //                 store,
  //                 style: GoogleFonts.libreFranklin(
  //                   fontSize: 12,
  //                   color: Colors.grey,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCustomPopup1(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
        side: BorderSide(
          color: Color(0xFFFBC8CF),
          width: MediaQuery.of(context).size.width * 0.004975124,
        ),
      ),
      surfaceTintColor: Color(0xFFFAFAFA),
      shadowColor: Color(0xFFFBC8CF),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Do you have anything\nspecific in mind?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(20),
                    fontWeight: FontWeight.w600,
                    color: AppColors.titleTextColor,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.0274599,
                ),
                GlobalTextButton(
                  text: "Upload to create",
                  onPressed: () {
                    Navigator.of(context).pop();
                    final extraData = <String, dynamic>{};
                    if (widget.occasion != null && widget.occasion!.isNotEmpty)
                      extraData["occasion"] = widget.occasion;
                    if (widget.description != null &&
                        widget.description!.isNotEmpty)
                      extraData["description"] = widget.description;
                    if (widget.eventId != null && widget.eventId!.isNotEmpty)
                      extraData["eventId"] = widget.eventId;
                    if (widget.loaction != null && widget.loaction!.isNotEmpty)
                      extraData["location"] = widget.loaction;
                    if (widget.dayEventId != null &&
                        widget.dayEventId!.isNotEmpty)
                      extraData["dayEventId"] = widget.dayEventId;
                    if (extraData.isNotEmpty) {
                      extraData["isDialogBoxOpen"] =
                          true; // add this only if other data exists
                    }
                    context.goNamed(
                      'uploadOutfit',
                      extra: extraData.isNotEmpty ? extraData : null,
                    );
                    // Log all incoming widget data
                    Developer.log("isDialogBoxOpen: ${widget.isDialogBoxOpen}");
                    Developer.log("occasion: ${widget.occasion}");
                    Developer.log("description: ${widget.description}");
                    Developer.log("eventId: ${widget.eventId}");
                    Developer.log("location: ${widget.loaction}");
                    Developer.log("dayEventId: ${widget.dayEventId}");
                  },
                  rightIcon: true,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.018306636,
                ),
                GlobalTextButton(
                  text: "Generate Fresh Ideas",
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the first dialog
                    showDialog(
                      context: context,
                      builder: (context) => _buildCustomPopup2(context),
                    );
                  },
                  rightIcon: true,
                ),
              ],
            ),
          ),
          // Close Button
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedCancelCircle,
                color: AppColors.error,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomPopup2(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
        side: BorderSide(
          color: Color(0xFFFBC8CF),
          width: MediaQuery.of(context).size.width * 0.004975124,
        ),
      ),
      surfaceTintColor: Color(0xFFFAFAFA),
      shadowColor: Color(0xFFFBC8CF),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Please Enter your Occasion",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(20),
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD34169),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.0274599,
                ),
                TextField(
                  controller: _occasionController,
                  decoration: InputDecoration(
                    hintText: "Girl's night out...",
                    hintStyle: GoogleFonts.libreFranklin(
                      color: Colors.grey[400],
                      fontSize: MediaQuery.of(context).textScaler.scale(14),
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
                  height: MediaQuery.of(context).size.height * 0.018306636,
                ),
                GlobalPinkButton(
                  text: "Let’s style, Babe",
                  onPressed: () {
                    Navigator.of(context).pop();
                    final extraData = <String, dynamic>{};

                    if (widget.occasion != null && widget.occasion!.isNotEmpty)
                      extraData["occasion"] = widget.occasion;
                    if (widget.description != null &&
                        widget.description!.isNotEmpty)
                      extraData["description"] = widget.description;
                    if (widget.eventId != null && widget.eventId!.isNotEmpty)
                      extraData["eventId"] = widget.eventId;
                    if (widget.loaction != null && widget.loaction!.isNotEmpty)
                      extraData["location"] = widget.loaction;
                    if (widget.dayEventId != null &&
                        widget.dayEventId!.isNotEmpty)
                      extraData["dayEventId"] = widget.dayEventId;
                    if (extraData.isNotEmpty) {
                      extraData["isDialogBoxOpen"] =
                          true; // add this only if other data exists
                    }
                    context.goNamed(
                      'createOutfit',
                      queryParameters: {"occasion": _occasionController.text},
                      extra: extraData.isNotEmpty ? extraData : null,
                    );
                    // Log all incoming widget data
                    Developer.log("isDialogBoxOpen: ${widget.isDialogBoxOpen}");
                    Developer.log("occasion: ${widget.occasion}");
                    Developer.log("description: ${widget.description}");
                    Developer.log("eventId: ${widget.eventId}");
                    Developer.log("location: ${widget.loaction}");
                    Developer.log("dayEventId: ${widget.dayEventId}");
                  },
                  rightIcon: true,
                ),
              ],
            ),
          ),
          // Close Button
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedCancelCircle,
                color: AppColors.error,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
