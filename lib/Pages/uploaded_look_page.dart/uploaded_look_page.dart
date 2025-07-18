import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'dart:developer' as Developer;

import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/services/Class/uploaded_look_model.dart';
import 'package:testing2/services/DataSource/uploaded_look_api.dart';

class UploadedLookPage extends StatefulWidget {
  @override
  _UploadedLookPageState createState() => _UploadedLookPageState();
}

class _UploadedLookPageState extends State<UploadedLookPage> {
  List<UploadedLook> _savedItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedFavorites();
  }

  Future<void> _loadSavedFavorites() async {
    try {
      final result = await UploadedLooksService.getUploadedLooks();
      Developer.log(result.toString());

      setState(() {
        _savedItems = result;
        isLoading = false;
      });
    } catch (e) {
      Developer.log("Error loading favorites: $e");
      showErrorSnackBar(context, "Error loading favorites: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteFromSavedFavourites(String id) async {
    try {
      setState(() {
        isLoading = true;
      });

      final result = await UploadedLooksService.deleteLook(id);
      Developer.log(result);

      if (result == "Look deleted successfully") {
        Developer.log("Look deleted successfully");
        showSuccessSnackBar(context, result);
        await _loadSavedFavorites();
      } else {
        showErrorSnackBar(context, result);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      Developer.log("Error deleting: $e");
      showErrorSnackBar(context, "Error deleting: $e");
      setState(() {
        isLoading = false;
      });
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
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Uploaded  ",
                              style: GoogleFonts.libreFranklin(
                                color: AppColors.titleTextColor,
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(18),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: "Looks",
                              style: GoogleFonts.libreFranklin(
                                color: AppColors.textPrimary,
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(18),
                                fontWeight: FontWeight.w600,
                                // fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_savedItems.isNotEmpty)
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
              child: _savedItems.isEmpty
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
          "Show us all of you—so we can serve looks made for you.",
          style: GoogleFonts.libreFranklin(
            color: AppColors.textPrimary,
            fontSize: MediaQuery.of(context).textScaler.scale(16),
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: MediaQuery.of(context).size.height * 0.036613272),
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.45,
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(32),
            child: Image.asset('assets/images/uploadLook/f2.png'),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.036613272),
        //         Row(
        //           children: [
        //             Text(
        //               '''Show us all of you—so we can serve looks made \nfor you.
        // Your shape and skin tone help us match you with \nthe styles that love you right''',
        //               style: GoogleFonts.libreFranklin(
        //                 fontSize: 15,
        //                 color: AppColors.titleTextColor,
        //               ),
        //             ),
        //             // Text('❤️', style: GoogleFonts.libreFranklin(fontSize: MediaQuery.of(context).textScaler.scale(16))),
        //           ],
        //         ),
        // SizedBox(height: MediaQuery.of(context).size.height * 0.018306636),
        // Text(
        //   'From boss-mode meetings to chill brunches, save the looks you love now and come back to them anytime you’re ready to dress to impress',
        //   style: GoogleFonts.libreFranklin(
        //     fontSize: 15,
        //     color: AppColors.titleTextColor,
        //   ),
        // ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.018306636),
        Text(
          '''Upload your head-to-toe pics so we can bring our A-game.\nThey help us analyze your shape and skin tone—so we can match you with the styles that love you most.''',
          style: GoogleFonts.libreFranklin(
            fontSize: 15,
            color: AppColors.titleTextColor,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.036613272),
        GlobalPinkButton(
          text: "Reveal my WOW Style!",
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
      itemCount: _savedItems.length,
      itemBuilder: (context, index) {
        final item = _savedItems[index];

        return GestureDetector(
          onTap: () => _showExpandedView(item, index),
          child: _buildProductCard(
            item.imageUrl,
            item.title,
            dh,
            index,
            item.createdAt,
            item,
          ),
        );
      },
    );
  }

  Widget _buildProductCard(
    String imagePath,
    String title,
    double dh,
    int index,
    DateTime dateTime,
    UploadedLook item,
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
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.libreFranklin(
                          fontSize: MediaQuery.of(context).textScaler.scale(18),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showGlobalDeleteConfirmationDialog(
                          context: context,
                          buttonText: "Delete",
                          title: "Delete Uploaded Look",
                          content:
                              'Are you sure you want to delete "${title}"? \nThis action cannot be undone.',
                          onConfirm: () => _deleteFromSavedFavourites(item.id),
                        );
                      },
                      // onTap: () => _deleteFromSavedFavourites(item.id),
                      child: isLoading
                          ? SizedBox(
                              width: 16,
                              height:
                                  MediaQuery.of(context).size.height *
                                  0.018306636,
                              child: CircularProgressIndicator(
                                strokeWidth:
                                    MediaQuery.of(context).size.width *
                                    0.004975124,
                                color: Colors.pink[400],
                              ),
                            )
                          : HugeIcon(
                              icon: HugeIcons.strokeRoundedDelete02,
                              color: AppColors.textPrimary,
                              size: 24,
                            ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedClock01,
                      color: Color(0xFF6D717F),
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      timeAgo(item.createdAt),
                      style: GoogleFonts.libreFranklin(
                        color: Color(0xFF6D717F),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExpandedView(UploadedLook item, int index) {
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
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.013729977,
                      ),

                      Row(
                        children: [
                          Text(
                            item.title,
                            style: GoogleFonts.libreFranklin(
                              color: Color(0xFFDC4C72),
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(24),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.013729977,
                      ),
                      Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedClock01,
                            color: Color(0xFFF9FAFB),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            timeAgo(item.createdAt),
                            style: GoogleFonts.libreFranklin(
                              color: Color(0xFFF9FAFB),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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

  String timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60)
      return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    if (diff.inHours < 24)
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays < 30)
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    if (diff.inDays < 365) {
      int months = (diff.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    }
    int years = (diff.inDays / 365).floor();
    return '$years year${years == 1 ? '' : 's'} ago';
  }
}
