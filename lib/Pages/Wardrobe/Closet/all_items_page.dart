import 'dart:developer' as Developer;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/services/Class/digital_wardrobe_model.dart';
import 'package:testing2/services/DataSource/digital_wardrobe_api.dart';

class AllItemsWardrobePage extends StatefulWidget {
  final int? selectedTabIndex;
  const AllItemsWardrobePage({required this.selectedTabIndex, super.key});

  @override
  State<AllItemsWardrobePage> createState() => _AllItemsWardrobePageState();
}

class _AllItemsWardrobePageState extends State<AllItemsWardrobePage> {
  bool showSearchResults = false;
  bool _isloading = false;
  late int _selectedTabIndex;
  int _refreshKey = 0;
  late ScrollController _scrollController;
  final List<String> categories = [
    'All',
    'Recent',
    'Tops',
    'Bottoms',
    'Ethnic',
    'Dresses',
    'co-ord set',
    'Swimwear',
    'Footwear',
    'Accessories',
    'Search',
  ];
  final List<String> tags = ['Pink', 'Casual', 'Cotton', 'Top', 'Winter'];
  final List<String> filterOptions = [
    'Color',
    'Occasion',
    'Fabric',
    'Category',
    'Season',
  ];
  final List<String> seasons = [
    'Summer',
    'Winter',
    'Monsoon',
    'Autumn',
    'Spring',
    'All Season',
  ];
  final List<String> fabrics = [
    'Cotton',
    'Linen',
    'Silk',
    'Wool',
    'Denim',
    'Polyester',
    'Rayon',
    'Velvet',
    'Chiffon',
    'Georgette',
    'Net',
    'Satin',
    'Tulle',
  ];
  final List<Map<String, dynamic>> colors = [
    {'name': 'Black', 'hexCode': '0xFF000000'},
    {'name': 'White', 'hexCode': '0xFFFFFFFF'},
    {'name': 'Gold', 'hexCode': '0xFFFFD700'},
    {'name': 'Pink', 'hexCode': '0xFFFFC0CB'},
    {'name': 'Navy Blue', 'hexCode': '0xFF000080'},
    {'name': 'Blue', 'hexCode': '0xFF0000FF'},
    {'name': 'Green', 'hexCode': '0xFF006400'},
    {'name': 'Cream', 'hexCode': '0xFFFFFDD0'},
    {'name': 'Beige', 'hexCode': '0xFFF5F5DC'},
    {'name': 'Brown', 'hexCode': '0xFF5C4033'},
    {'name': 'Red', 'hexCode': '0xFFFF0000'},
    {'name': 'Silver', 'hexCode': '0xFFC0C0C0'},
    {'name': 'Yellow', 'hexCode': '0xFFFFFF00'},
    {'name': 'Peach', 'hexCode': '0xFFFFE5B4'},
    {'name': 'Maroon', 'hexCode': '0xFF800000'},
    {'name': 'Grey', 'hexCode': '0xFF808080'},
    {'name': 'Off White', 'hexCode': '0xFFFAF9F6'},
    {'name': 'Rose Gold', 'hexCode': '0xFFB76E79'},
    {'name': 'Orange', 'hexCode': '0xFFFFA500'},
    {'name': 'Purple', 'hexCode': '0xFF4B0082'},
    {'name': 'Magenta', 'hexCode': '0xFFFF00FF'},
    {'name': 'Teal', 'hexCode': '0xFF008080'},
    {'name': 'Lavender', 'hexCode': '0xFFE6E6FA'},
    {'name': 'Olive', 'hexCode': '0xFF808000'},
    {'name': 'Turquoise', 'hexCode': '0xFF40E0D0'},
  ];
  int selectedFilterIndex = 0;
  // Add these variables to your State class
  List<String> selectedCategories = [];
  List<String> selectedColors = [];
  List<String> selectedFabrics = [];
  List<String> selectedSeasons = [];
  List<String> selectedOcassions = [];
  TextEditingController categorySearchController = TextEditingController();
  SharedPreferences? prefs;
  @override
  void initState() {
    super.initState();
    initPrefs();
    _selectedTabIndex = widget.selectedTabIndex ?? 0;
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedTab();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  Future<CategoryCounts> _getCategoryCounts() async {
    final result = await WardrobeApiService.fetchCategoryCounts();
    if (result != null) {
      Developer.log(result.counts.toString());
      return result;
    } else {
      Developer.log("❌ Couldn't fetch category counts");
      return CategoryCounts(counts: {});
    }
  }

  Future<List<GarmentItem>> _getGarments({required String category}) async {
    try {
      List<GarmentItem> garments =
          await WardrobeApiService.fetchGarmentsByCategory(category: category);
      for (var garment in garments) {
        Developer.log("🧥 ${garment.itemName} - ${garment.imageUrl}");
      }
      return garments;
    } catch (e) {
      Developer.log("❌ Failed to load garments: $e");
      return [];
    }
  }

  void _scrollToSelectedTab() {
    if (_scrollController.hasClients) {
      final double itemWidth = 100.0; // Approximate width of each tab
      final double screenWidth = MediaQuery.of(context).size.width;
      final double scrollPosition =
          (_selectedTabIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

      _scrollController.animateTo(
        scrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<List<GarmentItem>> _runFilter(
    List<String>? category,
    List<String>? color,
    List<String>? fabric,
    List<String>? occasion,
    List<String>? season,
  ) async {
    try {
      List<GarmentItem> garments = await WardrobeApiService.filterGarments(
        category: category,
        color: color,
        fabric: fabric,
        occasion: occasion,
        season: season,
      );
      for (var garment in garments) {
        Developer.log(
          "👕 ${garment.itemName} | ${garment.garmentId} | ${garment.imageId}",
        );
      }
      Developer.log(garments[0].toString());
      return garments;
    } catch (e) {
      Developer.log("❌ Exception during filter: $e");
      return [];
    }
  }

  // Apply Filters Function
  Future<List<GarmentItem>> _applyFilters() async {
    try {
      final filteredResults = await _runFilter(
        selectedCategories,
        selectedColors,
        selectedFabrics,
        selectedOcassions,
        selectedSeasons,
      );
      Developer.log('Selected Categories: $selectedCategories');
      Developer.log('Selected Brands: $selectedColors');
      Developer.log('Selected Websites: $selectedFabrics');
      return filteredResults;
    } catch (e) {
      Developer.log("❌ Exception during filter application: $e");
      return [];
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
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.goNamed('myWardrobe');
                      },
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        color: AppColors.titleTextColor,
                      ),
                    ),
                    SizedBox(width: dw * 0.02),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "My",
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

                SizedBox(height: dh * 0.02),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Global Search Bar
                    GlobalSearchBar(
                      height: MediaQuery.of(context).size.height * 0.0572082,
                      width: dw * 0.73,
                      hintText: '',
                    ),
                    SizedBox(width: dw * 0.01),
                    // Filter Option
                    Container(
                      height: MediaQuery.of(context).size.height * 0.0572082,
                      width: 62,
                      decoration: BoxDecoration(
                        color: Color(0xFFE25C7E),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: IconButton(
                        onPressed: () {
                          _showFilterBottomSheet(context);
                        },
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedFilterHorizontal,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.022883295,
                ),

                Container(
                  height: MediaQuery.of(context).size.height * 0.036613272,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      String category = categories[index];
                      bool isSelected = index == _selectedTabIndex;
                      return Container(
                        margin: EdgeInsets.only(right: 8),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedTabIndex = index;
                            });
                            _scrollToSelectedTab();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? Color(0xFFE25C7E)
                                : Colors.transparent,
                            foregroundColor: isSelected
                                ? Colors.white
                                : Color(0xFFE25C7E),
                            elevation: 0,
                            side: BorderSide(color: Color(0xFFE25C7E)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: Text(
                            category,
                            style: GoogleFonts.libreFranklin(
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(14),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Dynamic Content Area
          _buildContent(dh, dw),
        ],
      ),
    );
  }

  Widget _buildContent(double dh, double dw) {
    String selectedCategory = categories[_selectedTabIndex];
    if (selectedCategory == 'All') {
      // Show category cards for 'All' tab
      return Expanded(
        child: FutureBuilder<CategoryCounts>(
          key: ValueKey(_refreshKey), // Use key to force rebuild on refresh
          future: _getCategoryCounts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingPage();
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.018306636,
                    ),
                    Text(
                      'Error loading items',
                      style: GoogleFonts.libreFranklin(
                        fontSize: MediaQuery.of(context).textScaler.scale(16),
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.009153318,
                    ),
                    Text(
                      '${snapshot.error}',
                      style: GoogleFonts.libreFranklin(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.counts.isEmpty) {
              return Center(
                child: Text(
                  'No items found',
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(16),
                    color: AppColors.titleTextColor,
                  ),
                ),
              );
            } else {
              CategoryCounts counts = snapshot.data!;
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(20),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildCategoryCard(
                      'Tops',
                      dh,
                      dw,
                      '(${counts.counts['Tops']} Items)',
                      'assets/images/wardrobe/s9.svg',
                      2,
                      80,
                      50,
                    ),
                    _buildCategoryCard(
                      'Bottoms',
                      dh,
                      dw,
                      '(${counts.counts['Bottoms']} Items)',
                      'assets/images/wardrobe/s3.svg',
                      3,
                      93,
                      40.5,
                    ),
                    _buildCategoryCard(
                      'Ethnic',
                      dh,
                      dw,
                      '(${counts.counts['Ethnic']} Items)',
                      'assets/images/wardrobe/s2.svg',
                      4,
                      118,
                      42,
                    ),
                    _buildCategoryCard(
                      'Dresses',
                      dh,
                      dw,
                      '(${counts.counts['Dresses']} Items)',
                      'assets/images/wardrobe/s5.svg',
                      5,
                      117,
                      62,
                    ),
                    _buildCategoryCard(
                      'co-ord set',
                      dh,
                      dw,
                      '(${counts.counts['co-ord set']} Items)',
                      'assets/images/wardrobe/s10.svg',
                      6,
                      114,
                      38,
                    ),
                    _buildCategoryCard(
                      'Swimwear',
                      dh,
                      dw,
                      '(${counts.counts['Swimwear']} Items)',
                      'assets/images/wardrobe/s6.svg',
                      7,
                      94,
                      45.5,
                    ),
                    _buildCategoryCard(
                      'Footwear',
                      dh,
                      dw,
                      '(${counts.counts['Footwear']} Items)',
                      'assets/images/wardrobe/s4.svg',
                      8,
                      70,
                      69,
                    ),
                    _buildCategoryCard(
                      'Accessories',
                      dh,
                      dw,
                      '(${counts.counts['Accessories']} Items)',
                      'assets/images/wardrobe/s7.svg',
                      9,
                      73.5,
                      73.5,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      );
    } else if (selectedCategory == 'Search') {
      if (!showSearchResults) {
        // Return empty container or placeholder when no filters applied
        return Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 64, color: Colors.grey),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.018306636,
                ),
                Text(
                  'Apply filters to see results',
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(16),
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return Expanded(
        child: FutureBuilder<List<GarmentItem>>(
          key: ValueKey(_refreshKey), // Use key to force rebuild on refresh
          future: _applyFilters(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingPage();
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.018306636,
                    ),
                    Text(
                      'Error Filter items',
                      style: GoogleFonts.libreFranklin(
                        fontSize: MediaQuery.of(context).textScaler.scale(16),
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.009153318,
                    ),
                    Text(
                      '${snapshot.error}',
                      style: GoogleFonts.libreFranklin(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Container(height: dh * 0.15, color: Colors.transparent),
                  Container(
                    height: dh * 0.37757,
                    width: dw * 0.9,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppColors.textPrimary),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Hello, ${prefs?.getString("userFullName") ?? "User"}",
                          style: GoogleFonts.libreFranklin(
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(20),
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF131927),
                          ),
                        ),
                        Text(
                          "Snap, upload, and let Zuri turn your dresses into styled-to-perfection looks.",
                          style: GoogleFonts.libreFranklin(
                            color: Color(0xFF6D717F),
                            fontSize: 16,
                          ),
                        ),
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedUpload04,
                          color: AppColors.textPrimary,
                          size: dh * 0.13,
                        ),
                        GlobalPinkButton(
                          text: "Add Items",
                          onPressed: () {
                            _navigateToUploadPage();
                          },
                          height: 47,
                          width: 325,
                          fontSize: 13.45,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              List<GarmentItem> items = snapshot.data!;
              return Stack(
                children: [
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _buildClothingItemCard(items[index], dh);
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    right: 30,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1492537,
                      height: 60,
                      child: FloatingActionButton(
                        elevation: 1,
                        onPressed: () {
                          _navigateToUploadPage();
                        },
                        backgroundColor: Color(0xFFDC4C72),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedAdd01,
                          color: Colors.white,
                        ),
                        shape: CircleBorder(),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      );
    } else {
      // Use FutureBuilder to handle async data fetching
      return Expanded(
        child: FutureBuilder<List<GarmentItem>>(
          key: ValueKey(_refreshKey), // Use key to force rebuild on refresh
          future: _getGarments(category: selectedCategory),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingPage();
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.018306636,
                    ),
                    Text(
                      'Error loading items',
                      style: GoogleFonts.libreFranklin(
                        fontSize: MediaQuery.of(context).textScaler.scale(16),
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.009153318,
                    ),
                    Text(
                      '${snapshot.error}',
                      style: GoogleFonts.libreFranklin(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Container(height: dh * 0.15, color: Colors.transparent),
                  Container(
                    height: dh * 0.37757,
                    width: dw * 0.9,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppColors.textPrimary),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Hello, ${prefs?.getString("userFullName") ?? "User"}",
                          style: GoogleFonts.libreFranklin(
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(20),
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF131927),
                          ),
                        ),
                        Text(
                          "Snap, upload, and let Zuri turn your dresses into styled-to-perfection looks.",
                          style: GoogleFonts.libreFranklin(
                            color: Color(0xFF6D717F),
                            fontSize: 12,
                          ),
                        ),
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedUpload04,
                          color: AppColors.textPrimary,
                          size: dh * 0.13,
                        ),
                        GlobalPinkButton(
                          text: "Add Items",
                          onPressed: () {
                            _navigateToUploadPage();
                          },
                          height: 47,
                          width: 325,
                          fontSize: 13.45,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              List<GarmentItem> items = snapshot.data!;
              return Stack(
                children: [
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _buildClothingItemCard(items[index], dh);
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    right: 30,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1492537,
                      height: 60,
                      child: FloatingActionButton(
                        elevation: 1,
                        onPressed: () {
                          _navigateToUploadPage();
                        },
                        backgroundColor: Color(0xFFDC4C72),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedAdd01,
                          color: Colors.white,
                        ),
                        shape: CircleBorder(),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      );
    }
    // Fallback widget in case none of the above conditions match
  }

  void _navigateToUploadPage() {
    String route = 'uploadImageWardrobe';
    String extra;
    switch (_selectedTabIndex) {
      case 0:
        extra = 'fromAllItems';
        break;
      case 1:
        extra = 'fromrecentCategory';
        break;
      case 2:
        extra = 'fromtopsCategory';
        break;
      case 3:
        extra = 'frombottomsCategory';
        break;
      case 4:
        extra = 'fromethnicCategory';
        break;
      case 5:
        extra = 'fromdressesCategory';
        break;
      case 6:
        extra = 'fromcoordsetCategory';
        break;
      case 7:
        extra = 'fromswimwearCategory';
        break;
      case 8:
        extra = 'fromfootwearCategory';
        break;
      case 9:
        extra = 'fromaccessoriesCategory';
        break;
      case 10:
        extra = 'fromSearch';
        break;
      default:
        context.goNamed('myWardrobe');
        return;
    }
    context.goNamed(route, extra: extra);
  }

  void _navigateToEditPage({
    required String garmentId,
    required String garmentName,
  }) {
    String route = 'editTags';
    String fromPage;
    switch (_selectedTabIndex) {
      case 0:
        fromPage = 'fromAllItems';
        break;
      case 1:
        fromPage = 'fromrecentCategory';
        break;
      case 2:
        fromPage = 'fromtopsCategory';
        break;
      case 3:
        fromPage = 'frombottomsCategory';
        break;
      case 4:
        fromPage = 'fromethnicCategory';
        break;
      case 5:
        fromPage = 'fromdressesCategory';
        break;
      case 6:
        fromPage = 'fromcoordsetCategory';
        break;
      case 7:
        fromPage = 'fromswimwearCategory';
        break;
      case 8:
        fromPage = 'fromfootwearCategory';
        break;
      case 9:
        fromPage = 'fromaccessoriesCategory';
        break;
      case 10:
        fromPage = 'fromSearch';
        break;
      default:
        context.goNamed('myWardrobe');
        return;
    }
    context.goNamed(
      route,
      queryParameters: {
        'fromPage': fromPage,
        'garmentId': garmentId,
        'garmentName': garmentName,
      },
    );
  }

  Widget _buildClothingItemCard(GarmentItem item, double dh) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                _navigateToEditPage(
                  garmentId: item.garmentId,
                  garmentName: item.itemName,
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(32)),
                  color: const Color(0xFFF5F5F5),
                  image: DecorationImage(
                    image: NetworkImage(
                      (item.imageUrl.isEmpty || item.imageUrl == 'null')
                          ? 'https://images.pexels.com/photos/985635/pexels-photo-985635.jpeg'
                          : item.imageUrl,
                    ),
                    fit: BoxFit.fill,
                  ),
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
                      child: GestureDetector(
                        onTap: () {
                          _navigateToEditPage(
                            garmentId: item.garmentId,
                            garmentName: item.itemName,
                          );
                        },
                        child: Text(
                          (item.itemName.isEmpty || item.itemName == 'null')
                              ? 'Unknown Item'
                              : item.itemName,
                          style: GoogleFonts.libreFranklin(
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(16),
                            fontWeight: FontWeight.w600,
                            color: AppColors.titleTextColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _navigateToEditPage(
                              garmentId: item.garmentId,
                              garmentName: item.itemName,
                            );
                          },
                          child: const HugeIcon(
                            icon: HugeIcons.strokeRoundedEdit02,
                            color: Colors.black,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            _showDeleteConfirmation(item: item);
                          },
                          child: const HugeIcon(
                            icon: HugeIcons.strokeRoundedDelete01,
                            color: Colors.red,
                            size: 16,
                          ),
                        ),
                      ],
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

  void _showDeleteConfirmation({required GarmentItem item}) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          title: Text(
            'Delete Event',
            style: GoogleFonts.inter(
              fontSize: MediaQuery.of(context).textScaler.scale(18),
              fontWeight: FontWeight.w600,
              color: Color(0xFF131927),
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${item.itemName}"? This action cannot be undone.',
            style: GoogleFonts.libreFranklin(
              fontSize: MediaQuery.of(context).textScaler.scale(14),
              color: Color(0xFF394050),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(14),
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF394050),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final scaffoldContext = context; // Store parent context
                Navigator.of(dialogContext).pop(); // Close dialog
                final success = await WardrobeApiService.deleteGarmentImage(
                  item.garmentId,
                );
                if (success) {
                  Developer.log("🗑️ Garment deleted successfully!");
                  showSuccessSnackBar(
                    scaffoldContext,
                    "Garment deleted successfully!",
                  );
                  setState(() {
                    _refreshKey++; // Increment to force FutureBuilder refresh
                  });
                } else {
                  Developer.log("❌ Failed to delete garment");
                  showErrorSnackBar(
                    scaffoldContext,
                    "Failed to delete garment",
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF5236),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                elevation: 0,
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryCard(
    String title,
    double dh,
    double dw,
    String itemCount,
    String svgPath,
    int index,
    double height,
    double width,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
        _scrollToSelectedTab();
      },
      child: Container(
        // height: height,
        // width: width,
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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.009153318,
              ),
              Text(
                title,
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.titleTextColor,
                ),
              ),
              // SizedBox(height: 4),
              Text(
                itemCount,
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(10),
                  color: AppColors.subTitleTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Column-wise Filter Bottom Sheet Function
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              child: Column(
                children: [
                  Divider(
                    color: Color(0xFFD9D9D9),
                    indent: 150,
                    endIndent: 150,
                  ),
                  // Header
                  Container(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter',
                          style: GoogleFonts.libreFranklin(
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(18),
                            fontWeight: FontWeight.w600,
                            color: AppColors.titleTextColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCancelCircle,
                            color: Color(0xFF141B34),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(height: 15),
                  Divider(indent: 20, endIndent: 20, height: 0),
                  // Main Content with Column Layout
                  Expanded(
                    child: Row(
                      children: [
                        // Left Column - Filter Categories
                        Container(
                          width: 120,
                          color: Colors.grey[100],
                          child: Column(
                            children: filterOptions.asMap().entries.map((
                              entry,
                            ) {
                              int index = entry.key;
                              String option = entry.value;
                              bool isSelected = selectedFilterIndex == index;

                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    selectedFilterIndex = index;
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                    border: isSelected
                                        ? const Border(
                                            right: BorderSide(
                                              color: Color(0xFFE91E63),
                                              width: 3,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Text(
                                    option,
                                    style: GoogleFonts.libreFranklin(
                                      fontSize: MediaQuery.of(
                                        context,
                                      ).textScaler.scale(14),
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: Color(0xFF394050),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // Right Column - Filter Content
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            child: _buildFilterContent(
                              selectedFilterIndex,
                              setModalState,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Buttons
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setModalState(() {
                                selectedCategories.clear();
                                selectedFabrics.clear();
                                selectedColors.clear();
                                selectedOcassions.clear();
                                selectedSeasons.clear();
                              });
                              setState(() {
                                selectedCategories.clear();
                                selectedFabrics.clear();
                                selectedColors.clear();
                                selectedOcassions.clear();
                                selectedSeasons.clear();
                                showSearchResults = false; // Add this line
                              });
                            },
                            child: Text(
                              'Reset All',
                              style: GoogleFonts.libreFranklin(
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(16),
                                color: AppColors.titleTextColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width:
                              MediaQuery.of(context).size.width * 0.049751243,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                showSearchResults = true; // Add this line
                              });
                              Navigator.pop(context);
                              _applyFilters();
                              setState(() {
                                _selectedTabIndex = 10;
                              });
                              _scrollToSelectedTab();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.textPrimary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(
                              'Apply Filter',
                              style: GoogleFonts.libreFranklin(
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(14),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Build Filter Content based on selected index
  Widget _buildFilterContent(int index, StateSetter setModalState) {
    switch (index) {
      case 0:
        return _buildColorFilter(setModalState);
      case 1:
        return _buildOccasionFilter(setModalState);
      case 2:
        return _buildFabricsFilter(setModalState);
      case 4:
        return _buildseasonsFilter(setModalState);
      case 3:
        return _buildCategoryFilter(setModalState);
      default:
        return Container();
    }
  }

  // Color Filter Widget
  Widget _buildColorFilter(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(32),
          ),
          child: TextField(
            controller: categorySearchController,
            style: GoogleFonts.libreFranklin(
              fontSize: MediaQuery.of(context).textScaler.scale(14),
            ),
            decoration: InputDecoration(
              hintText: 'Search Color',
              hintStyle: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(14),
                color: Colors.grey[500],
              ),
              prefixIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: Color(0xFFD34169),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
            ),
          ),
        ),
        // SizedBox(height: MediaQuery.of(context).size.height * 0.022883295),

        // Category List
        Expanded(
          child: ListView.builder(
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              bool isSelected = selectedColors.contains(color['name']);

              return ListTile(
                title: Row(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.018306636,
                      width: 16,
                      // color: Color(int.parse(color['hexCode']!)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Color(int.parse(color['hexCode']!)),
                        border: Border.all(color: Color(0xFF6D717F)),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      color['name']!,
                      style: GoogleFonts.libreFranklin(
                        fontSize: MediaQuery.of(context).textScaler.scale(14),
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                trailing: Checkbox(
                  side: BorderSide(color: AppColors.textPrimary),
                  value: isSelected,
                  shape: CircleBorder(),
                  onChanged: (bool? value) {
                    setModalState(() {
                      if (isSelected) {
                        selectedColors.remove(color['name']);
                      } else {
                        selectedColors.add(color['name']);
                      }
                    });
                  },
                  activeColor: AppColors.textPrimary,
                ),
                onTap: () {
                  setModalState(() {
                    if (isSelected) {
                      selectedColors.remove(color['name']);
                    } else {
                      selectedColors.add(color['name']);
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
        ),
      ],
    );
  }

  // Add these state variables at the top of your class
  bool isSocialScenesExpanded = false;
  bool isCelebrationsExpanded = false;
  bool isWorkProfessionalExpanded = false;
  bool isChillCasualExpanded = false;

  // Occasion Filter Widget
  Widget _buildOccasionFilter(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(32),
          ),
          child: TextField(
            controller: categorySearchController,
            style: GoogleFonts.libreFranklin(
              fontSize: MediaQuery.of(context).textScaler.scale(14),
            ),
            decoration: InputDecoration(
              hintText: 'Search Occasion',
              hintStyle: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(14),
                color: Colors.grey[500],
              ),
              prefixIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: Color(0xFFD34169),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
            ),
          ),
        ),

        // Categories
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Social Scenes Section
                _buildOcationCategorySection(
                  title: 'Social Scenes',
                  isExpanded: isSocialScenesExpanded,
                  items: [
                    'Date Night',
                    'Girls\' Night Out',
                    'Brunch',
                    'Dinner',
                    'Clubbing',
                    'Concerts',
                  ],
                  setModalState: setModalState,
                  onToggle: () {
                    setModalState(() {
                      isSocialScenesExpanded = !isSocialScenesExpanded;
                    });
                  },
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.009153318,
                ),

                // Celebrations & Festivities Section
                _buildOcationCategorySection(
                  title: 'Celebrations & Festivities',
                  isExpanded: isCelebrationsExpanded,
                  items: [
                    'Birthday Parties',
                    'Weddings',
                    'Festivals',
                    'Pooja / Religious Functions',
                    'College Fests',
                  ],
                  setModalState: setModalState,
                  onToggle: () {
                    setModalState(() {
                      isCelebrationsExpanded = !isCelebrationsExpanded;
                    });
                  },
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.009153318,
                ),

                // Work & Professional Section
                _buildOcationCategorySection(
                  title: 'Work & Professional',
                  isExpanded: isWorkProfessionalExpanded,
                  items: [
                    'Office Meetings',
                    'Business Events',
                    'Conferences',
                    'Networking',
                  ],
                  setModalState: setModalState,
                  onToggle: () {
                    setModalState(() {
                      isWorkProfessionalExpanded = !isWorkProfessionalExpanded;
                    });
                  },
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.009153318,
                ),

                // Chill & Casual Section
                _buildOcationCategorySection(
                  title: 'Chill & Casual',
                  isExpanded: isChillCasualExpanded,
                  items: ['Shopping', 'Movie Night', 'Beach Day', 'Picnic'],
                  setModalState: setModalState,
                  onToggle: () {
                    setModalState(() {
                      isChillCasualExpanded = !isChillCasualExpanded;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build category sections
  Widget _buildOcationCategorySection({
    required String title,
    required bool isExpanded,
    required List<String> items,
    required StateSetter setModalState,
    required VoidCallback onToggle, // Add this parameter
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Section Header
          InkWell(
            onTap: onToggle, // Use the onToggle callback
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.libreFranklin(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF394050),
                    ),
                  ),
                  HugeIcon(
                    color: Color(0xFF394050),
                    size: 20,
                    icon: isExpanded
                        ? HugeIcons.strokeRoundedArrowUp01
                        : HugeIcons.strokeRoundedArrowDown01,
                  ),
                ],
              ),
            ),
          ),

          // Section Items (only show if expanded)
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            ...items
                .map((item) => _buildOccasionItem(item, setModalState))
                .toList(),
          ],
        ],
      ),
    );
  }

  // Helper method to build individual occasion items
  Widget _buildOccasionItem(String itemName, StateSetter setModalState) {
    bool isSelected = selectedOcassions.contains(itemName);

    return InkWell(
      onTap: () {
        setModalState(() {
          if (isSelected) {
            selectedOcassions.remove(itemName);
          } else {
            selectedOcassions.add(itemName);
          }
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(width: 16),
              Text(
                itemName,
                style: GoogleFonts.libreFranklin(
                  fontSize: MediaQuery.of(context).textScaler.scale(11),
                  color: Color(0xFF394050),
                ),
              ),
            ],
          ),
          Checkbox(
            side: BorderSide(color: AppColors.textPrimary),
            value: isSelected,
            shape: CircleBorder(),
            onChanged: (bool? value) {
              setModalState(() {
                if (isSelected) {
                  selectedOcassions.remove(itemName);
                } else {
                  selectedOcassions.add(itemName);
                }
              });
            },
            activeColor: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  // Brands Filter Widget
  Widget _buildFabricsFilter(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(32),
          ),
          child: TextField(
            controller: categorySearchController,
            style: GoogleFonts.libreFranklin(
              fontSize: MediaQuery.of(context).textScaler.scale(14),
            ),
            decoration: InputDecoration(
              hintText: 'Search Fabric',
              hintStyle: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(14),
                color: Colors.grey[500],
              ),
              prefixIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: Color(0xFFD34169),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: fabrics.length,
            itemBuilder: (context, index) {
              final fabric = fabrics[index];
              bool isSelected = selectedFabrics.contains(fabric);

              return ListTile(
                title: Text(
                  fabric,
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(14),
                    color: Colors.black,
                  ),
                ),
                trailing: Checkbox(
                  side: BorderSide(color: AppColors.textPrimary),
                  value: isSelected,
                  shape: CircleBorder(),
                  onChanged: (bool? value) {
                    setModalState(() {
                      if (value == true) {
                        selectedFabrics.add(fabric);
                      } else {
                        selectedFabrics.remove(fabric);
                      }
                    });
                  },
                  activeColor: AppColors.textPrimary,
                ),
                onTap: () {
                  setModalState(() {
                    if (isSelected) {
                      selectedFabrics.remove(fabric);
                    } else {
                      selectedFabrics.add(fabric);
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildseasonsFilter(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(32),
          ),
          child: TextField(
            controller: categorySearchController,
            style: GoogleFonts.libreFranklin(
              fontSize: MediaQuery.of(context).textScaler.scale(14),
            ),
            decoration: InputDecoration(
              hintText: 'Search Season',
              hintStyle: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(14),
                color: Colors.grey[500],
              ),
              prefixIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: Color(0xFFD34169),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: seasons.length,
            itemBuilder: (context, index) {
              final season = seasons[index];
              bool isSelected = selectedSeasons.contains(season);

              return ListTile(
                title: Text(
                  season,
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(14),
                    color: Colors.black,
                  ),
                ),
                trailing: Checkbox(
                  side: BorderSide(color: AppColors.textPrimary),
                  value: isSelected,
                  shape: CircleBorder(),
                  onChanged: (bool? value) {
                    setModalState(() {
                      if (value == true) {
                        selectedSeasons.add(season);
                      } else {
                        selectedSeasons.remove(season);
                      }
                    });
                  },
                  activeColor: AppColors.textPrimary,
                ),
                onTap: () {
                  setModalState(() {
                    if (isSelected) {
                      selectedSeasons.remove(season);
                    } else {
                      selectedSeasons.add(season);
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
        ),
      ],
    );
  }

  // Website Filter Widget
  Widget _buildCategoryFilter(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(32),
          ),
          child: TextField(
            controller: categorySearchController,
            style: GoogleFonts.libreFranklin(
              fontSize: MediaQuery.of(context).textScaler.scale(14),
            ),
            decoration: InputDecoration(
              hintText: 'Search Category',
              hintStyle: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(14),
                color: Colors.grey[500],
              ),
              prefixIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: Color(0xFFD34169),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: seasons.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              bool isSelected = selectedCategories.contains(category);

              return ListTile(
                title: Text(
                  category,
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(14),
                    color: Colors.black,
                  ),
                ),
                trailing: Checkbox(
                  side: BorderSide(color: AppColors.textPrimary),
                  value: isSelected,
                  shape: CircleBorder(),
                  onChanged: (bool? value) {
                    setModalState(() {
                      if (value == true) {
                        selectedCategories.add(category);
                      } else {
                        selectedCategories.remove(category);
                      }
                    });
                  },
                  activeColor: AppColors.textPrimary,
                ),
                onTap: () {
                  setModalState(() {
                    if (isSelected) {
                      selectedCategories.remove(category);
                    } else {
                      selectedCategories.add(category);
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
        ),
      ],
    );
  }
}
