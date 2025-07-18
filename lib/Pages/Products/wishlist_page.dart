import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Function/global_function.dart';
import 'dart:developer' as Developer;

import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/services/Class/saved_fav_model.dart';
import 'package:testing2/services/DataSource/product_api.dart';

class WishlistPage extends StatefulWidget {
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<dynamic> _wishListProducts = [];
  bool isLoading = true;
  // Map<int, bool> savedStates = {}; // To toggle icon state
  // Map<int, bool> loadingStates = {}; // To show loading spinner

  @override
  void initState() {
    super.initState();
    _loadWishListProducts();
  }

  SharedPreferences? prefs = null;
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
      // _loadProducts(result);
    } catch (e) {
      showErrorSnackBar(context, "failed to fetch User based keywords");
    }
  }

  Future<void> _loadWishListProducts() async {
    try {
      final result = await ProductApiServices.getWishlistItems();
      Developer.log(result.toString());
      if (result['success']) {
        setState(() {
          _wishListProducts = result['items'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Developer.log("Error loading favorites: $e");
      showErrorSnackBar(context, "Error loading favorites: $e");
    }
  }

  Future<void> _removeFromWishlist(int index) async {
    try {
      final product = _wishListProducts[index];
      Map<String, String> productData = {
        "productId":
            product['productId'] ??
            product['id'] ??
            '', // Use actual product ID
        "productImage": product['productImage'] ?? '',
        "link": product['productUrl'] ?? '',
        "productTitle": product['productTitle'] ?? '',
        "price": product['price'] ?? '',
        "platform": product['platform'] ?? '',
      };

      final result = await ProductApiServices.toggleWishlistItem(productData);

      if (result['success']) {
        setState(() {
          _wishListProducts.removeAt(index);
        });
        showSuccessSnackBar(
          context,
          result['message'] ?? 'Removed from wishlist',
        );
        // Remove the reload call as we already updated the local state
        // await _loadWishListProducts();
      } else {
        showErrorSnackBar(
          context,
          result['message'] ?? 'Failed to remove from wishlist',
        );
      }
    } catch (e) {
      Developer.log("Error removing from wishlist: $e");
      showErrorSnackBar(context, "Error removing from wishlist: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;

    if (isLoading) {
      return LoadingPage();
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header Section
            Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 10,
                top: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowLeft01,
                          color: AppColors.titleTextColor,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Zuri  ",
                              style: GoogleFonts.libreFranklin(
                                color: AppColors.titleTextColor,
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(16),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: "Wishlist",
                              style: GoogleFonts.libreFranklin(
                                color: AppColors.textPrimary,
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(16),
                                fontWeight: FontWeight.w600,

                                // fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_wishListProducts.isNotEmpty)
                    GestureDetector(
                      // onTap: _shareCurrentLook,
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
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedShare08,
                            color: AppColors.textPrimary,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Scrollable part
            Expanded(
              child: _wishListProducts.isEmpty
                  ? SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: _buildEmptyState(),
                    )
                  : Padding(
                      padding: EdgeInsets.all(20),
                      child: _buildFavoritesGrid(dh),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Text(
          "Your Wishlist is Empty",
          style: GoogleFonts.libreFranklin(
            color: AppColors.textPrimary,
            fontSize: MediaQuery.of(context).textScaler.scale(16),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.036613272),
        ClipRRect(child: Image.asset('assets/images/Zuri/g1.png')),
        SizedBox(height: MediaQuery.of(context).size.height * 0.036613272),
        Row(
          children: [
            Text(
              'Your wishlist is feeling a little lonely! 💔',
              style: GoogleFonts.libreFranklin(
                fontSize: 15,
                color: AppColors.titleTextColor,
              ),
            ),
            // Text('❤️', style: GoogleFonts.libreFranklin(fontSize: MediaQuery.of(context).textScaler.scale(16))),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.018306636),
        Text(
          'Add your fave pieces and let Zuri keep them safe ‘til you’re ready to slay.',
          style: GoogleFonts.libreFranklin(
            fontSize: 15,
            color: AppColors.titleTextColor,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.036613272),
        GlobalPinkButton(
          text: "Add Now",
          onPressed: () {
            initPrefs();
            _fetchKeywords();
            final stringKeywords = (_keywords as List).cast<String>().join(',');
            context.goNamed(
              'affiliate',
              queryParameters: {
                'keywords': stringKeywords,
                'needToOpenAskZuri': "false",
              },
            );
          },
          rightIcon: true,
        ),
      ],
    );
  }

  Widget _buildFavoritesGrid(double dh) {
    return GridView.builder(
      itemCount: _wishListProducts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.60,
      ),
      itemBuilder: (context, index) {
        final product = _wishListProducts[index];
        return ProductCard(
          link: product['productUrl'] ?? '',
          imageUrl: product['productImage'] ?? '',
          title: product['productTitle'] ?? '',
          discountedPrice: product['price'] ?? '',
          store: product['platform'] ?? '',
          dh: dh,
          initialFavorite: true, // Always true for wishlist items
          productId:
              product['productId'] ??
              product['id'], // Pass the actual product ID
          onFavoriteToggle: (isFavorite) {
            // If item is removed from wishlist, remove from local list
            if (!isFavorite) {
              setState(() {
                _wishListProducts.removeAt(index);
              });
            }
          },
        );
      },
    );
  } // Widget _buildProductCard(
  //   String imagePath,
  //   String tag,
  //   String occasion,
  //   String description,
  //   double dh,
  //   int index,
  //   bool isSaved,
  //   SavedFavouriteData item,
  // ) {
  //   return Container(
  //     color: Colors.white,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Expanded(
  //           child: Container(
  //             width: double.infinity,
  //             height: dh * 0.25,
  //             decoration: BoxDecoration(
  //               borderRadius: const BorderRadius.all(Radius.circular(32)),
  //               color: const Color(0xFFF5F5F5),
  //               image: DecorationImage(
  //                 image: NetworkImage(imagePath),
  //                 fit: BoxFit.contain,
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
  //                   Expanded(
  //                     child: Text(
  //                       (occasion.isNotEmpty
  //                               ? occasion[0].toUpperCase() +
  //                                     occasion.substring(1)
  //                               : '') +
  //                           " Outfit",
  //                       maxLines: 2,
  //                       overflow: TextOverflow.ellipsis,
  //                       style: GoogleFonts.libreFranklin(
  //                         fontSize: MediaQuery.of(context).textScaler.scale(18),
  //                         fontWeight: FontWeight.w600,
  //                         color: AppColors.textPrimary,
  //                       ),
  //                     ),
  //                   ),
  //                   GestureDetector(
  //                     onTap: () => _toggleSave(index),
  //                     child: isLoading
  //                         ? SizedBox(
  //                             width: 16,
  //                             height:
  //                                 MediaQuery.of(context).size.height *
  //                                 0.018306636,
  //                             child: CircularProgressIndicator(
  //                               strokeWidth:
  //                                   MediaQuery.of(context).size.width *
  //                                   0.004975124,
  //                               color: Colors.pink[400],
  //                             ),
  //                           )
  //                         : HugeIcon(
  //                             icon: isSaved
  //                                 ? Icons.bookmark
  //                                 : Icons.bookmark_border,
  //                             color: AppColors.textPrimary,
  //                             size: 20,
  //                           ),
  //                   ),
  //                 ],
  //               ),

  //               LayoutBuilder(
  //                 builder: (context, constraints) {
  //                   // Use TextPainter to check if text overflows 2 lines
  //                   final span = TextSpan(
  //                     text: description,
  //                     style: GoogleFonts.libreFranklin(
  //                       fontSize: 12,
  //                       color: AppColors.titleTextColor,
  //                     ),
  //                   );
  //                   final tp = TextPainter(
  //                     text: span,
  //                     maxLines: 2,
  //                     textDirection: TextDirection.ltr,
  //                   )..layout(maxWidth: constraints.maxWidth);

  //                   final isOverflow = tp.didExceedMaxLines;

  //                   return Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         description,
  //                         maxLines: 2,
  //                         overflow: TextOverflow.ellipsis,
  //                         style: GoogleFonts.libreFranklin(
  //                           fontSize: 12,
  //                           color: AppColors.titleTextColor,
  //                         ),
  //                       ),
  //                       if (isOverflow)
  //                         GestureDetector(
  //                           onTap: () {
  //                             _showExpandedView(item, index);
  //                             // showDialog(
  //                             // context: context,
  //                             // builder: (context) => AlertDialog(
  //                             //   content: Text(
  //                             //   description,
  //                             //   style: GoogleFonts.libreFranklin(
  //                             //     fontSize: MediaQuery.of(context).textScaler.scale(14),
  //                             //     color: AppColors.titleTextColor,
  //                             //   ),
  //                             //   ),
  //                             // ),
  //                             // );
  //                           },
  //                           child: Padding(
  //                             padding: const EdgeInsets.only(top: 2.0),
  //                             child: Text(
  //                               'see more',
  //                               style: GoogleFonts.libreFranklin(
  //                                 color: Colors.blue,
  //                                 fontSize: 12,
  //                                 decoration: TextDecoration.underline,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                     ],
  //                   );
  //                 },
  //               ),
  //               SizedBox(height: 4),
  //               Container(
  //                 decoration: BoxDecoration(
  //                   color: AppColors.textPrimary,
  //                   borderRadius: BorderRadius.circular(32),
  //                 ),
  //                 padding: EdgeInsets.only(left: 4, right: 4),
  //                 child: Text(
  //                   tag,
  //                   style: GoogleFonts.libreFranklin(
  //                     color: Color(0xFFF9FAFB),
  //                     fontSize: MediaQuery.of(context).textScaler.scale(10),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
