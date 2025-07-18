import 'dart:developer' as Developer;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Function/global_function.dart';
import 'package:testing2/Global/Widget/global_dialogbox.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/services/Class/zuri_magqazine_model.dart';
import 'package:testing2/services/DataSource/auth_api.dart';
import 'package:testing2/services/DataSource/zuri_magazine_api.dart';

class MagazineDetailScreen extends StatefulWidget {
  final String magazineid;

  const MagazineDetailScreen({Key? key, required this.magazineid})
    : super(key: key);

  @override
  State<MagazineDetailScreen> createState() => _MagazineDetailScreenState();
}

class _MagazineDetailScreenState extends State<MagazineDetailScreen> {
  bool isSaved = false;
  bool _isLoading = false;
  bool _isSaving = false;
  ZuriMagazine? _article;
  String? _errorMessage;
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

  @override
  void initState() {
    super.initState();
    _loadMagazineData();
  }

  void _toggleSave() {
    _checkLoginStatus();
    if (_isLoggedIn) {
      _toggleToSaveMagazine();
      setState(() {
        isSaved = !isSaved;
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => GlobalDialogBox(
          title: "Please Sign Up to Continue",
          description:
              "Babe, I can't save your closet—or decode \nyour best colors and fits—unless you sign up. \nLet's make this official? Pretty please!",
          buttonNeed: true,
          buttonText: "OK, make me next-level stylish",
          onTap: () {
            Navigator.of(context).pop();
            context.goNamed('scan&discover');
          },
        ),
      );
    }
  }

  void _shareArticle() {
    if (_article != null) {
      SharePlus.instance.share(
        '''Check out this article: ${_article!.title}''' as ShareParams,
      );
    }
  }

  Future<void> _toggleToSaveMagazine() async {
    setState(() {
      _isSaving = true;
    });
    try {
      await ZuriMagazineApiService.toggleBookmark(widget.magazineid);
      // Update the saved state in the article model if it has that property
      if (_article != null) {
        // Assuming ZuriMagazine has an isSaved property
        // _article!.isSaved = !_article!.isSaved;
      }
      setState(() {}); // Refresh UI
    } catch (e) {
      Developer.log('Error toggling bookmark: ${e.toString()}');
      // Revert the UI state if API call failed
      setState(() {
        isSaved = !isSaved;
      });
      // Show error message to user
      if (mounted) {
        // showErrorSnackBar(
        //   context,
        //   ('Failed to ${isSaved ? 'remove' : 'save'} article'),
        // );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _loadMagazineData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ZuriMagazineApiService.getByIdMagazine(
        widget.magazineid,
      );

      Developer.log('Magazine response: ${response.toString()}');

      _article = response;
      // Initialize saved state from article data
      // Assuming ZuriMagazine has an isSaved property
      // isSaved = _article!.isSaved ?? false;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading magazine data: ${e.toString()}';
      });
      Developer.log('Error loading magazine data: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle loading state
    if (_isLoading) {
      return Scaffold(backgroundColor: Colors.white, body: LoadingPage());
    }

    // Handle error state
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.titleTextColor,
              size: 20,
            ),
          ),
          title: Text(
            'Error',
            style: GoogleFonts.libreFranklin(
              color: AppColors.textPrimary,
              fontSize: MediaQuery.of(context).textScaler.scale(20),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.018306636,
              ),
              Text(
                _errorMessage!,
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.0274599),
              ElevatedButton(
                onPressed: _loadMagazineData,
                child: Text('Retry', style: GoogleFonts.libreFranklin()),
              ),
            ],
          ),
        ),
      );
    }

    // Handle case where article is null but not loading
    if (_article == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.titleTextColor,
              size: 20,
            ),
          ),
          title: Text(
            'Article Not Found',
            style: GoogleFonts.libreFranklin(
              color: AppColors.textPrimary,
              fontSize: MediaQuery.of(context).textScaler.scale(20),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(child: Text('Article not found')),
      );
    }

    // Main content - article is loaded
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: const Color(0xFFFFFFFF),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: AppColors.titleTextColor,
              size: 28,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          GlobalFunction.capitalizeFirstLetter(_article!.category),
          style: GoogleFonts.libreFranklin(
            color: AppColors.textPrimary,
            fontSize: MediaQuery.of(context).textScaler.scale(20),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    GlobalFunction.capitalizeFirstLetter(_article!.title),
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(24),
                      fontWeight: FontWeight.w600,
                      color: AppColors.titleTextColor,
                      height: 1.2,
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.018306636,
                  ),

                  // Main content
                  Text(
                    _article!.subTitle,
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(16),
                      color: const Color(0xFF4D5461),
                      height: 1.2,
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.018306636,
                  ),

                  // Read time
                  Text(
                    "5 min Read",
                    style: GoogleFonts.libreFranklin(
                      fontSize: 12,
                      color: const Color(0xFF6C757D),
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.013729977,
                  ),

                  // Author section
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _article!.authorProfilePic,
                          width:
                              MediaQuery.of(context).size.width * 0.0049751244,
                          height:
                              MediaQuery.of(context).size.height * 0.0274599,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width:
                                  MediaQuery.of(context).size.width *
                                  0.0049751244,
                              height:
                                  MediaQuery.of(context).size.height *
                                  0.0274599,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Surabhi',
                        style: GoogleFonts.libreFranklin(
                          fontSize: MediaQuery.of(context).textScaler.scale(14),
                          color: const Color(0xFF6C757D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Article Image
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.width * 0.6,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[300],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  _article!.bannerImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image, size: 48, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Article Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.018306636,
                  ),

                  // Extended content
                  Text(
                    _article!.content,
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(16),
                      color: const Color(0xFF212529),
                      height: 1.6,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.0274599,
                  ),

                  // Tags section
                  if (_article!.tags.isNotEmpty) ...[
                    Text(
                      'Related Tags',
                      style: GoogleFonts.libreFranklin(
                        fontSize: MediaQuery.of(context).textScaler.scale(18),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF212529),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.013729977,
                    ),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _article!.tags.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return _buildTag(_article!.tags[index]);
                        },
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.0274599,
                    ),
                  ],

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _shareArticle,
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedShare08,
                            color: AppColors.titleTextColor,
                          ),
                          label: Text(
                            'Share Article',
                            style: GoogleFonts.libreFranklin(
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(16),
                              color: AppColors.titleTextColor,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6C757D),
                            side: const BorderSide(
                              color: AppColors.textPrimary,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _toggleSave,
                          icon: _isSaving
                              ? SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width *
                                      0.049751243,
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.022883295,
                                  child: CircularProgressIndicator(
                                    strokeWidth:
                                        MediaQuery.of(context).size.width *
                                        0.004975124,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : HugeIcon(
                                  icon: HugeIcons.strokeRoundedBookmark02,
                                  color: isSaved
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  size: 24,
                                ),
                          label: Text(
                            _isSaving
                                ? 'Saving...'
                                : (isSaved ? 'Saved' : 'Save Article'),
                            style: GoogleFonts.libreFranklin(
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(16),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !isSaved
                                ? Colors.white
                                : AppColors.textPrimary,
                            foregroundColor: !isSaved
                                ? AppColors.textPrimary
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: isSaved
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            elevation: 0,
                          ),
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
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.2)),
      ),
      child: Text(
        tag,
        style: GoogleFonts.libreFranklin(
          color: const Color(0xFFE91E63),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
