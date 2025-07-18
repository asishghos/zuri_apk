import 'dart:developer' as Developer;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Function/global_function.dart';
import 'package:testing2/Global/Widget/global_dialogbox.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/Pages/Magazine/magazine_detail_screen.dart';
import 'package:testing2/services/Class/zuri_magqazine_model.dart';
import 'package:testing2/services/DataSource/auth_api.dart';
import 'package:testing2/services/DataSource/zuri_magazine_api.dart';
import 'filter_overlay.dart';

class MagazineScreen extends StatefulWidget {
  const MagazineScreen({Key? key}) : super(key: key);

  @override
  State<MagazineScreen> createState() => _MagazineScreenState();
}

class _MagazineScreenState extends State<MagazineScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _modalScrollController = ScrollController();

  List<ZuriMagazine> _magzines = [];
  List<ZuriMagazine> _savedmagzine = [];
  List<ZuriMagazine> filteredmagzines = [];
  List<String> _categories = [];
  String selectedTab = 'All';
  int notificationCount = 3;
  bool _isSaving = false;
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

  // Add this method to your class
  // bool _isMagazineSaved(String magazineId) {
  //   return _savedMagazineIds.contains(magazineId);
  // }

  // In the MagazineCard widget, replace:
  // (magzine.isSaved ?? false)
  // with:
  // _isMagazineSaved(magzine.id)

  // Combined future for loading both categories and magzines
  Future<Map<String, dynamic>> _loadMagazineData() async {
    try {
      // Load categories
      final allMagazine = await ZuriMagazineApiService.allMagazine();
      _magzines = allMagazine;
      final categoriesResponse =
          await ZuriMagazineApiService.getAllCategories();
      Developer.log('Categories response: ${categoriesResponse.toString()}');
      _categories = categoriesResponse.data;

      return {'categories': categoriesResponse.data, 'magzines': _magzines};
    } catch (e) {
      Developer.log('Error loading magazine data: ${e.toString()}');
      return {'categories': <String>[], 'magzines': <ZuriMagazine>[]};
    }
  }

  Future<void> _fetchSavedMagazine() async {
    final responce = await ZuriMagazineApiService.getAllBookmarkedArticles();
    _savedmagzine = responce;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _modalScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    selectedTab = 'All'; // Set default tab
    _fetchSavedMagazine(); // Fetch saved magazines on init
  }

  void _filtermagzines(String query) {
    setState(() {
      if (query.isEmpty) {
        // If search is empty, apply category filter
        _filterByCategory(selectedTab);
      } else {
        // Apply search filter on the currently selected category
        List<ZuriMagazine> baseList = selectedTab == 'All'
            ? _magzines
            : _magzines
                  .where(
                    (magzine) =>
                        magzine.category.toLowerCase() ==
                        selectedTab.toLowerCase(),
                  )
                  .toList();

        filteredmagzines = baseList.where((magzine) {
          final title = magzine.title.toLowerCase();
          final content = magzine.content.toLowerCase();
          final category = magzine.category.toLowerCase();
          final author = magzine.authorName.toLowerCase();
          final searchQuery = query.toLowerCase();

          return title.contains(searchQuery) ||
              content.contains(searchQuery) ||
              category.contains(searchQuery) ||
              author.contains(searchQuery);
        }).toList();
      }
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      selectedTab = category;
      if (category == 'All' || category.isEmpty) {
        filteredmagzines = _magzines;
      } else {
        filteredmagzines = _magzines.where((magzine) {
          return magzine.category.toLowerCase() == category.toLowerCase();
        }).toList();
      }

      // Apply search filter on top of category filter if search is active
      if (_searchController.text.isNotEmpty) {
        _filtermagzines(_searchController.text);
      }
    });
  }

  Future<void> _toggleToSaveMagazine(String magazineId) async {
    setState(() {
      _isSaving = true;
    });
    try {
      await ZuriMagazineApiService.toggleBookmark(magazineId);
      await _fetchSavedMagazine();
      setState(() {}); // Refresh UI
    } catch (e) {
      Developer.log(e.toString());
      if (mounted) {
        showErrorSnackBar(context, "Failed to save/ remove magazine");
      }
      // Optionally show error
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _sharemagzine(ZuriMagazine magzine) {
    Share.share('Check out this magzine: ${magzine.title}');
  }

  void _showFilterOverlay(List<String> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (context) => FilterOverlay(
        scrollController: _modalScrollController,
        categories: categories,
        onApplyFilter: (selectedCategories) {
          Navigator.pop(context);
          // Add your filter logic here if needed
        },
      ),
    );
  }

  Widget _buildSearchBar(List<String> categories) {
    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: GlobalSearchBar(
              hintText: 'Search magazines...',
              onChanged: _filtermagzines,
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showFilterOverlay(categories),
            child: Container(
              width: 62,
              height: MediaQuery.of(context).size.height * 0.0572082,
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(32),
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedFilterHorizontal,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildCategoriesSection(List<String> categories) {
  //   // Add "All" category at the beginning
  //   final allCategories = ['All', ...categories];

  //   return SizedBox(
  //     height: 42,
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       padding: const EdgeInsets.symmetric(horizontal: 20),
  //       itemCount: allCategories.length,
  //       itemBuilder: (context, index) {
  //         final category = allCategories[index];
  //         final isSelected = selectedTab == category;
  //         return Padding(
  //           padding: const EdgeInsets.only(right: 8),
  //           child: GestureDetector(
  //             onTap: () => _filterByCategory(category),
  //             child: Container(
  //               padding: const EdgeInsets.symmetric(
  //                 horizontal: 16,
  //                 vertical: 12,
  //               ),
  //               decoration: BoxDecoration(
  //                 color: isSelected
  //                     ? AppColors.textPrimary
  //                     : const Color(0xFFFFF7F8),
  //                 borderRadius: BorderRadius.circular(32),
  //                 border: Border.all(
  //                   color: isSelected
  //                       ? Colors.transparent
  //                       : AppColors.textPrimary,
  //                   width: 0.5,
  //                 ),
  //               ),
  //               child: Text(
  //                 category,
  //                 style: GoogleFonts.libreFranklin(
  //                   color: isSelected ? Colors.white : AppColors.textPrimary,
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<Map<String, dynamic>>(
        future: _loadMagazineData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingPage();
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.018306636,
                  ),
                  Text(
                    'Failed to load magazine data',
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(16),
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.009153318,
                  ),
                  Text(
                    'Please check your connection and try again',
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(14),
                      color: Colors.grey[500],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.018306636,
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() {}), // Rebuild to retry
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final categories = data['categories'] as List<String>;
          final magzines = data['magzines'] as List<ZuriMagazine>;

          // Initialize magazines and filtered magazines if not already done
          if (_magzines.isEmpty && magzines.isNotEmpty) {
            _magzines = magzines;
            filteredmagzines = magzines;
          }

          // Tab bar: All, Saved, Categories
          final List<String> tabs = ['All', 'Saved', ...categories];

          List<ZuriMagazine> displayMagazines;
          if (selectedTab == 'All') {
            displayMagazines = _magzines;
          } else if (selectedTab == 'Saved') {
            displayMagazines = _savedmagzine;
          } else {
            displayMagazines = _magzines
                .where(
                  (magzine) =>
                      magzine.category.toLowerCase() ==
                      selectedTab.toLowerCase(),
                )
                .toList();
          }

          // Apply search filter if needed
          if (_searchController.text.isNotEmpty) {
            final searchQuery = _searchController.text.toLowerCase();
            displayMagazines = displayMagazines.where((magzine) {
              final title = magzine.title.toLowerCase();
              final content = magzine.content.toLowerCase();
              final category = magzine.category.toLowerCase();
              final author = magzine.authorName.toLowerCase();
              return title.contains(searchQuery) ||
                  content.contains(searchQuery) ||
                  category.contains(searchQuery) ||
                  author.contains(searchQuery);
            }).toList();
          }

          return Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  // Search Bar
                  _buildSearchBar(categories),
                  // Tab Bar
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.0549199,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: tabs.length,
                      itemBuilder: (context, index) {
                        final tab = tabs[index];
                        final isSelected = selectedTab == tab;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTab = tab;
                                _searchController.clear();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.textPrimary
                                    : const Color(0xFFFFF7F8),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : AppColors.textPrimary,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                tab,
                                style: GoogleFonts.libreFranklin(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontSize: MediaQuery.of(
                                    context,
                                  ).textScaler.scale(14),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Magazines List
                  Expanded(
                    child: displayMagazines.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.article_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.018306636,
                                ),
                                Text(
                                  selectedTab == 'Saved'
                                      ? 'No saved magazines found'
                                      : 'No magazines found',
                                  style: GoogleFonts.libreFranklin(
                                    fontSize: MediaQuery.of(
                                      context,
                                    ).textScaler.scale(16),
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.009153318,
                                ),
                                Text(
                                  'Try adjusting your search or filters',
                                  style: GoogleFonts.libreFranklin(
                                    fontSize: MediaQuery.of(
                                      context,
                                    ).textScaler.scale(14),
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: displayMagazines.length,
                            itemBuilder: (context, index) {
                              final magzine = displayMagazines[index];
                              return MagazineCard(
                                savedmagzine: _savedmagzine,
                                magzine: magzine,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MagazineDetailScreen(
                                            magazineid: magzine.id,
                                          ),
                                    ),
                                  );
                                },
                                onSave: () async {
                                  final isLoggedIn =
                                      await AuthApiService.isLoggedIn();
                                  if (isLoggedIn) {
                                    _toggleToSaveMagazine(magzine.id);
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) => GlobalDialogBox(
                                        title: "Please Sign Up to Continue",
                                        description:
                                            "Babe, I can't save your closet—or decode \nyour best colors and fits—unless you sign up. \nLet's make this official? Pretty please!",
                                        buttonNeed: true,
                                        buttonText:
                                            "OK, make me next-level stylish",
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          context.goNamed('scan&discover');
                                        },
                                      ),
                                    );
                                  }
                                },
                                onShare: () => _sharemagzine(magzine),
                              );
                            },
                          ),
                  ),
                ],
              ),
              // if (!_isLoggedIn)
              //   Container(
              //     color: Colors.black.withOpacity(0.5),
              //     child: Center(
              //       child: GlobalDialogBox(
              //         title: "Please Sign Up to Continue",
              //         description:
              //             "Babe, I can't save your closet—or decode \nyour best colors and fits—unless you sign up. \nLet's make this official? Pretty please!",
              //         buttonNeed: true,
              //         buttonText: "OK, make me next-level stylish",
              //         onTap: () {
              //           context.goNamed('scan&discover');
              //         },
              //       ),
              //     ),
              //   ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset('assets/images/Zuri/zm.svg'),
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEB),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD34169),
                    width: 0.63,
                  ),
                ),
                child: const Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedBookmark02,
                    color: AppColors.textPrimary,
                    size: 28,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEB),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD34169),
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
                            MediaQuery.of(context).size.height * 0.018306636,
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
        ],
      ),
    );
  }
}

class MagazineCard extends StatelessWidget {
  final List<ZuriMagazine> savedmagzine;
  final ZuriMagazine magzine;
  final VoidCallback onTap;
  final VoidCallback onSave;
  final VoidCallback onShare;

  const MagazineCard({
    Key? key,
    required this.savedmagzine,
    required this.magzine,
    required this.onTap,
    required this.onSave,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Magazine Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Category Badge with "by Author"
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          magzine.authorProfilePic,
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
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: GlobalFunction.capitalizeFirstLetter(
                                  magzine.category,
                                ),
                                style: GoogleFonts.libreFranklin(
                                  color: Color(0xFF1E1E1E),
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: " by ",
                                style: GoogleFonts.libreFranklin(
                                  color: AppColors.subTitleTextColor,
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: magzine.authorName,
                                style: GoogleFonts.libreFranklin(
                                  color: Color(0xFF1E1E1E),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.009153318,
                  ),

                  // Title
                  Text(
                    magzine.title,
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(20),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),

                  // Description
                  Text(
                    magzine.content,
                    style: GoogleFonts.libreFranklin(
                      fontSize: MediaQuery.of(context).textScaler.scale(14),
                      color: AppColors.titleTextColor,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.018306636,
                  ),

                  // Bottom Row
                  Row(
                    children: [
                      Text(
                        '5 min read',
                        style: GoogleFonts.libreFranklin(
                          fontSize: MediaQuery.of(context).textScaler.scale(10),
                          color: Color(0xFF131927),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 8),
            // Magazine Image and Action Buttons
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.network(
                    magzine.bannerImage,
                    width: MediaQuery.of(context).size.width * 0.248756,
                    height: 155,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage(context);
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.018306636,
                ),
                // Action Buttons below image
                Row(
                  children: [
                    GestureDetector(
                      onTap: onSave,
                      child: HugeIcon(
                        icon: (savedmagzine.any((m) => m.id == magzine.id))
                            ? HugeIcons.strokeRoundedBookmark02
                            : HugeIcons.strokeRoundedBookmark02,
                        size: 24,
                        color: (savedmagzine.any((m) => m.id == magzine.id))
                            ? AppColors.textPrimary
                            : Color(0xFF394050),
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: onShare,
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedShare08,
                        size: 24,
                        color: Color(0xFF394050),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.248756,
      height: 155,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey[400],
            size: 32,
          ),
          SizedBox(height: 4),
          Text(
            'Image\nUnavailable',
            textAlign: TextAlign.center,
            style: GoogleFonts.libreFranklin(
              color: Colors.grey[500],
              fontSize: MediaQuery.of(context).textScaler.scale(10),
            ),
          ),
        ],
      ),
    );
  }
}
