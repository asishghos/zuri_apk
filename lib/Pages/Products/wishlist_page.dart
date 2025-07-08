import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'dart:developer' as Developer;

import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/services/Class/saved_fav_model.dart';
import 'package:testing2/services/DataSource/product_api.dart';
import 'package:testing2/services/DataSource/saved_fav_api.dart';

class WishlistPage extends StatefulWidget {
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<SavedFavouriteData> _favoriteItems = [];
  bool isLoading = true;
  Map<int, bool> savedStates = {}; // Track save state for each index
  Map<int, String?> savedItemIds = {}; // Track saved item IDs
  Map<int, bool> loadingStates = {};

  @override
  void initState() {
    super.initState();
    _loadSavedFavorites();
  }

  Future<void> _loadSavedFavorites() async {
    try {
      final result = await ProductApiServices.getWishlistItems();
      Developer.log(result.toString());
      if (result['success'] == "Favourites fetched successfully") {
        setState(() {
          _favoriteItems = result['data'];
          isLoading = false;
          // Initialize saved states
          for (int i = 0; i < _favoriteItems.length; i++) {
            savedStates[i] = true; // All items are saved initially
            savedItemIds[i] = _favoriteItems[i].id;
          }
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

  Future<void> _toggleSave(int index) async {
    // Get current state or default to false
    bool currentSaved = savedStates[index] ?? false;

    setState(() {
      savedStates[index] = !currentSaved;
      loadingStates[index] = true;
      _loadSavedFavorites();
    });

    if (savedStates[index]!) {
      await _addToSavedFavourites(index);
    } else {
      String? savedId = savedItemIds[index];
      if (savedId != null) {
        await _deleteFromSavedFavourites(index, savedId);
      } else {
        showErrorSnackBar(context, "No ID to delete");
      }
    }

    setState(() {
      loadingStates[index] = false;
    });
  }

  Future<void> _addToSavedFavourites(int index) async {
    try {
      await Future.delayed(Duration(milliseconds: 500)); // Simulate API call
      showSuccessSnackBar(context, "Added to favorites");
      savedItemIds[index] = "new_id_${index}"; // Set the new ID
    } catch (e) {
      Developer.log("Error adding: $e");
      showErrorSnackBar(context, "Error adding: $e");
      setState(() => savedStates[index] = false); // Revert
    }
  }

  Future<void> _deleteFromSavedFavourites(int index, String id) async {
    try {
      final result = await SavedFavouritesService.deleteSavedFavourite(id);

      if (result['success']) {
        Developer.log("Deleted successfully");
        showSuccessSnackBar(context, result['msg']);
        savedItemIds.remove(index);

        // Remove item from list if deleted
        setState(() {
          _favoriteItems.removeAt(index);
          // Reindex the maps
          _reindexMaps();
        });
      } else {
        showErrorSnackBar(context, result['msg']);
        setState(() => savedStates[index] = true); // Revert
      }
    } catch (e) {
      Developer.log("Error deleting: $e");
      showErrorSnackBar(context, "Error deleting: $e");
      setState(() => savedStates[index] = true); // Revert
    }
  }

  void _reindexMaps() {
    Map<int, bool> newSavedStates = {};
    Map<int, String?> newSavedItemIds = {};
    Map<int, bool> newLoadingStates = {};

    for (int i = 0; i < _favoriteItems.length; i++) {
      newSavedStates[i] = savedStates[i] ?? true;
      newSavedItemIds[i] = savedItemIds[i];
      newLoadingStates[i] = loadingStates[i] ?? false;
    }

    savedStates = newSavedStates;
    savedItemIds = newSavedItemIds;
    loadingStates = newLoadingStates;
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
                      const SizedBox(width: 16),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Saved ",
                              style: GoogleFonts.libreFranklin(
                                color: AppColors.titleTextColor,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: "Favorites",
                              style: GoogleFonts.libreFranklin(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_favoriteItems.isNotEmpty)
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
              child: _favoriteItems.isEmpty
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
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Love it? Favorite it!",
          style: GoogleFonts.libreFranklin(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: 32),
        ClipRRect(child: Image.asset('')),
        SizedBox(height: 32),
        Row(
          children: [
            Text(
              'If Zuri’s curations hit the mark, don’t let them slip away.',
              style: GoogleFonts.libreFranklin(
                fontSize: 15,
                color: AppColors.titleTextColor,
              ),
            ),
            Text('❤️', style: GoogleFonts.libreFranklin(fontSize: 16)),
          ],
        ),
        SizedBox(height: 16),
        Text(
          'Tap that bookmark to keep the magic before it’s gone for good.',
          style: GoogleFonts.libreFranklin(
            fontSize: 15,
            color: AppColors.titleTextColor,
          ),
        ),
        // SizedBox(height: 16),
        // Text(
        //   'Your closet, but smarter. Tap to favorite!',
        //   style: GoogleFonts.libreFranklin(
        //     fontSize: 15,
        //     color: AppColors.titleTextColor,
        //   ),
        // ),
        SizedBox(height: 32),
        GlobalPinkButton(
          text: "Curate a look you 🤍 now",
          onPressed: () {
            context.goNamed('uploadOutfit');
          },
          rightIcon: true,
        ),
      ],
    );
  }

  Widget _buildFavoritesGrid(double dh) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.70,
      ),
      itemCount: _favoriteItems.length,
      itemBuilder: (context, index) {
        final item = _favoriteItems[index];
        final isLoading = loadingStates[index] ?? false;
        final isSaved = savedStates[index] ?? true;

        return GestureDetector(
          onTap: () => _showExpandedView(item, index),
          child: Stack(
            children: [
              _buildProductCard(
                item.imageUrl,
                item.tag,
                item.occasion,
                item.description,
                dh,
                index,
                isSaved,
                item,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _toggleSave(index),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.pink[400],
                            ),
                          )
                        : Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: Colors.pink[400],
                            size: 20,
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(
    String imagePath,
    String tag,
    String occasion,
    String description,
    double dh,
    int index,
    bool isSaved,
    SavedFavouriteData item,
  ) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              height: dh * 0.25,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(32)),
                color: const Color(0xFFF5F5F5),
                image: DecorationImage(
                  image: NetworkImage(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        (occasion.isNotEmpty
                                ? occasion[0].toUpperCase() +
                                      occasion.substring(1)
                                : '') +
                            " Outfit",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.libreFranklin(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _toggleSave(index),
                      child: isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.pink[400],
                              ),
                            )
                          : HugeIcon(
                              icon: isSaved
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                    ),
                  ],
                ),

                LayoutBuilder(
                  builder: (context, constraints) {
                    // Use TextPainter to check if text overflows 2 lines
                    final span = TextSpan(
                      text: description,
                      style: GoogleFonts.libreFranklin(
                        fontSize: 12,
                        color: AppColors.titleTextColor,
                      ),
                    );
                    final tp = TextPainter(
                      text: span,
                      maxLines: 2,
                      textDirection: TextDirection.ltr,
                    )..layout(maxWidth: constraints.maxWidth);

                    final isOverflow = tp.didExceedMaxLines;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.libreFranklin(
                            fontSize: 12,
                            color: AppColors.titleTextColor,
                          ),
                        ),
                        if (isOverflow)
                          GestureDetector(
                            onTap: () {
                              _showExpandedView(item, index);
                              // showDialog(
                              // context: context,
                              // builder: (context) => AlertDialog(
                              //   content: Text(
                              //   description,
                              //   style: GoogleFonts.libreFranklin(
                              //     fontSize: 14,
                              //     color: AppColors.titleTextColor,
                              //   ),
                              //   ),
                              // ),
                              // );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                'see more',
                                style: GoogleFonts.libreFranklin(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: EdgeInsets.only(left: 4, right: 4),
                  child: Text(
                    tag,
                    style: GoogleFonts.libreFranklin(
                      color: Color(0xFFF9FAFB),
                      fontSize: 10,
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

  void _showExpandedView(SavedFavouriteData item, int index) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(color: Colors.transparent),
            child: Column(
              children: [
                // Header
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedCancelCircle,
                          color: Colors.red,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                ),
                // Expanded Image
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: Colors.grey[100],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
                // Bottom Section
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Text(
                            (item.occasion.isNotEmpty
                                    ? item.occasion[0].toUpperCase() +
                                          item.occasion.substring(1)
                                    : '') +
                                " Outfit",
                            style: GoogleFonts.libreFranklin(
                              color: Color(0xFFDC4C72),
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.description,
                        style: GoogleFonts.libreFranklin(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF9FAFB),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Text(
                          item.tag,
                          style: GoogleFonts.libreFranklin(
                            color: Color(0xFFF9FAFB),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
