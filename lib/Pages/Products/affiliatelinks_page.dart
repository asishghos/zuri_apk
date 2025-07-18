import 'dart:developer' as Developer;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Function/global_function.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';

class AffiliateLinksPage extends StatefulWidget {
  final List<String> keywords;
  final bool? needToOpenAskZuri;
  AffiliateLinksPage({Key? key, required this.keywords, this.needToOpenAskZuri})
    : super(key: key);

  @override
  State<AffiliateLinksPage> createState() => AffiliateLinksPageState();
}

class AffiliateLinksPageState extends State<AffiliateLinksPage> {
  // Public class
  List<String> _currentKeywords = [];
  String selectedSortOption = 'Discount: High to Low';
  int selectedFilterIndex = 0;
  final List<String> filterOptions = ['Price', 'Category', 'Brands', 'Website'];

  final List<String> sortOptions = [
    'Popularity',
    'Discount: High to Low',
    'Price: High to Low',
    'Price: Low to High',
  ];
  // Add these variables to your State class
  List<String> selectedCategories = [];
  List<String> selectedBrands = [];
  List<String> selectedWebsites = [];
  RangeValues priceRange = const RangeValues(0, 5000);
  TextEditingController categorySearchController = TextEditingController();

  // Categories data
  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'count': 588},
    {'name': 'Top wear', 'count': 80},
    {'name': 'Bottom wear', 'count': 97},
    {'name': 'Shoes', 'count': 100},
    {'name': 'Accessories', 'count': 304},
  ];

  final List<String> brands = ['Nike', 'Adidas', 'Puma', 'Reebok', 'H&M'];
  final List<String> websites = [
    'Amazon.in',
    'Myntra.com',
    'Nykaa.com',
    'Flipkart.com',
  ];
  @override
  void initState() {
    super.initState();
    _currentKeywords = widget.keywords;
    _loadAffiliateLinks();
    Developer.log(widget.keywords.toString());
  }

  List<Map<String, String>> _products = [];
  bool _isLoading = true;

  void updateKeywords(List<String> newKeywords) {
    setState(() {
      _currentKeywords = newKeywords;
    });
    _loadAffiliateLinks();
  }

  void _loadAffiliateLinks() async {
    setState(() {
      _isLoading = true;
    });
    Developer.log('Loading affiliate links for keywords: $_currentKeywords');

    final result = await GlobalFunction.searchProductsByKeywords(
      _currentKeywords,
    );
    Developer.log(result.toString());
    setState(() {
      _products = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    if (_isLoading) {
      return LoadingPage();
    }

    return Column(
      children: [
        // Filter and Sort buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showFilterBottomSheet(context);
                  },
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedFilterHorizontal,
                    color: Colors.white,
                    size: 17,
                  ),
                  label: Text(
                    'Apply Filters',
                    style: GoogleFonts.libreFranklin(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showSortBottomSheet(context),
                  icon: SvgPicture.asset(
                    "assets/images/affiliate/sort-by-down-01.svg",
                  ),
                  label: Text(
                    'Sort by',
                    style: GoogleFonts.libreFranklin(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),

        // optional
        // if (_currentKeywords.isNotEmpty)
        //   Container(
        //     padding: EdgeInsets.all(16),
        //     child: Wrap(
        //       spacing: 8,
        //       runSpacing: 8,
        //       children: _currentKeywords.map((keyword) {
        //         return Chip(
        //           label: Text(keyword),
        //           backgroundColor: AppColors.textPrimary.withOpacity(0.1),
        //         );
        //       }).toList(),
        //     ),
        //   ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              itemCount: _products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
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
          ),
        ),
      ],
    );
  }

  // Widget _buildProductCard(
  //   String link,
  //   String imageUrl,
  //   String title,
  //   String discountedPrice,
  //   String store,
  //   double dh,
  // ) {
  //   return GestureDetector(
  //     onTap: () async {
  //       Developer.log('ProductCard - onTap: Opening product link: ${link}');
  //       try {
  //         await launchUrl(
  //           Uri.parse(link),
  //           mode: LaunchMode.externalApplication,
  //         );
  //       } catch (e) {}
  //     },
  //     child: Container(
  //       color: Colors.white,
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Expanded(
  //             child: Container(
  //               width: double.infinity,
  //               decoration: BoxDecoration(
  //                 borderRadius: const BorderRadius.all(Radius.circular(32)),
  //                 color: const Color(0xFFF5F5F5),
  //                 image: DecorationImage(
  //                   image: NetworkImage(imageUrl),
  //                   fit: BoxFit.cover,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.only(top: 8),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   title,
  //                   style: GoogleFonts.libreFranklin(
  //                     fontSize: MediaQuery.of(context).textScaler.scale(16),
  //                     fontWeight: FontWeight.w600,
  //                     color: Color(0xFFE91E63),
  //                   ),
  //                   maxLines: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //                 SizedBox(height: 4),
  //                 Row(
  //                   children: [
  //                     // if (originalPrice.isNotEmpty) ...[
  //                     //   Text(
  //                     //     originalPrice,
  //                     //     style: GoogleFonts.libreFranklin(
  //                     //       fontSize: MediaQuery.of(context).textScaler.scale(14),
  //                     //       color: AppColors.subTitleTextColor,
  //                     //       decoration: TextDecoration.lineThrough,
  //                     //     ),
  //                     //   ),
  //                     //   SizedBox(width: 4),
  //                     // ],
  //                     Text(
  //                       discountedPrice,
  //                       style: GoogleFonts.libreFranklin(
  //                         fontSize: MediaQuery.of(context).textScaler.scale(16),
  //                         fontWeight: FontWeight.bold,
  //                         color: AppColors.titleTextColor,
  //                       ),
  //                     ),
  //                     // if (discount.isNotEmpty) ...[
  //                     //   SizedBox(width: 4),
  //                     //   Text(
  //                     //     "(${discount} OFF)",
  //                     //     style: GoogleFonts.libreFranklin(
  //                     //       fontSize: 12,
  //                     //       color: AppColors.textPrimary,
  //                     //       fontWeight: FontWeight.w500,
  //                     //     ),
  //                     //   ),
  //                     // ],
  //                     Spacer(),
  //                     GestureDetector(
  //                       onTap: () {},
  //                       child: const HugeIcon(
  //                         icon: HugeIcons.strokeRoundedFavourite,
  //                         color: Colors.black,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(height: 4),
  //                 Text(
  //                   store,
  //                   style: GoogleFonts.libreFranklin(
  //                     fontSize: 12,
  //                     color: Colors.grey,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(
                    color: Color(0xFFD9D9D9),
                    indent: 150,
                    endIndent: 150,
                  ),
                  // Header with title and close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sort by',
                        style: GoogleFonts.libreFranklin(
                          fontSize: MediaQuery.of(context).textScaler.scale(18),
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
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

                  // Divider line
                  SizedBox(height: 15),
                  Divider(),
                  SizedBox(height: 10),
                  // Sort options
                  ...sortOptions.map((option) {
                    bool isSelected = selectedSortOption == option;
                    return Container(
                      child: ListTile(
                        // selectedTileColor: Color(0xFFFDE7E9),
                        // selectedColor: Color(0xFFFDE7E9),
                        // splashColor: Color(0xFFFDE7E9),
                        title: Text(
                          option,
                          style: GoogleFonts.libreFranklin(
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(16),
                            color: AppColors.titleTextColor,
                          ),
                        ),
                        trailing: Container(
                          width:
                              MediaQuery.of(context).size.width * 0.049751243,
                          height:
                              MediaQuery.of(context).size.height * 0.022883295,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.textPrimary),
                            color: isSelected
                                ? AppColors.textPrimary
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                )
                              : null,
                        ),
                        onTap: () {
                          setState(() {
                            selectedSortOption = option;
                          });
                          // Auto close after selection
                          Future.delayed(const Duration(milliseconds: 200), () {
                            Navigator.pop(context);
                          });
                        },
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 4,
                        ),
                      ),
                    );
                  }).toList(),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.022883295,
                  ),
                ],
              ),
            );
          },
        );
      },
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
                          'Filters',
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
                                      color: isSelected
                                          ? Colors.black
                                          : AppColors.titleTextColor,
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
                                selectedBrands.clear();
                                selectedWebsites.clear();
                                priceRange = const RangeValues(0, 5000);
                              });
                              setState(() {
                                selectedCategories.clear();
                                selectedBrands.clear();
                                selectedWebsites.clear();
                                priceRange = const RangeValues(0, 5000);
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
                              Navigator.pop(context);
                              _applyFilters();
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
        return _buildPriceFilter(setModalState);
      case 1:
        return _buildCategoryFilter(setModalState);
      case 2:
        return _buildBrandsFilter(setModalState);
      case 3:
        return _buildWebsiteFilter(setModalState);
      default:
        return Container();
    }
  }

  // Price Filter Widget
  Widget _buildPriceFilter(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Price range',
          style: GoogleFonts.libreFranklin(
            fontSize: 12,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
        SizedBox(height: 5),
        Text(
          '₹0 - ₹5000',
          style: GoogleFonts.libreFranklin(
            fontSize: MediaQuery.of(context).textScaler.scale(14),
            color: AppColors.titleTextColor,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.022883295),
        RangeSlider(
          values: priceRange,
          min: 0,
          max: 5000,
          divisions: 50,
          activeColor: AppColors.titleTextColor,
          inactiveColor: Colors.grey[300],
          onChanged: (RangeValues values) {
            setModalState(() {
              priceRange = values;
            });
          },
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.022883295),
        Text(
          '5000 Products found',
          style: GoogleFonts.libreFranklin(
            fontSize: 12,
            color: Color(0xFF9EA2AE),
          ),
        ),
      ],
    );
  }

  // Category Filter Widget
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
        SizedBox(height: MediaQuery.of(context).size.height * 0.022883295),

        // Top Picks
        Row(
          children: [
            Text(
              'Top Picks',
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(14),
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.02487562),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
        SizedBox(height: 15),

        // Category List
        Expanded(
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              bool isSelected = selectedCategories.contains(category['name']);

              return ListTile(
                title: Row(
                  children: [
                    Text(
                      category['name'],
                      style: GoogleFonts.libreFranklin(
                        fontSize: MediaQuery.of(context).textScaler.scale(14),
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      '(${category['count']})',
                      style: GoogleFonts.libreFranklin(
                        fontSize: MediaQuery.of(context).textScaler.scale(14),
                        color: Colors.grey[500],
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
                        selectedCategories.remove(category['name']);
                      } else {
                        selectedCategories.add(category['name']);
                      }
                    });
                  },
                  activeColor: AppColors.textPrimary,
                ),
                onTap: () {
                  setModalState(() {
                    if (isSelected) {
                      selectedCategories.remove(category['name']);
                    } else {
                      selectedCategories.add(category['name']);
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

  // Brands Filter Widget
  Widget _buildBrandsFilter(StateSetter setModalState) {
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
              hintText: 'Search Brands',
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
        SizedBox(height: MediaQuery.of(context).size.height * 0.022883295),
        Divider(color: Colors.grey[300]),
        Expanded(
          child: ListView.builder(
            itemCount: brands.length,
            itemBuilder: (context, index) {
              final brand = brands[index];
              bool isSelected = selectedBrands.contains(brand);

              return ListTile(
                title: Text(
                  brand,
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
                        selectedBrands.add(brand);
                      } else {
                        selectedBrands.remove(brand);
                      }
                    });
                  },
                  activeColor: AppColors.textPrimary,
                ),
                onTap: () {
                  setModalState(() {
                    if (isSelected) {
                      selectedBrands.remove(brand);
                    } else {
                      selectedBrands.add(brand);
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
  Widget _buildWebsiteFilter(StateSetter setModalState) {
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
              hintText: 'Search Website',
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
        SizedBox(height: MediaQuery.of(context).size.height * 0.022883295),
        Divider(color: Colors.grey[300]),
        Expanded(
          child: ListView.builder(
            itemCount: websites.length,
            itemBuilder: (context, index) {
              final website = websites[index];
              bool isSelected = selectedWebsites.contains(website);

              return ListTile(
                title: Text(
                  website,
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
                        selectedWebsites.add(website);
                      } else {
                        selectedWebsites.remove(website);
                      }
                    });
                  },
                  activeColor: AppColors.textPrimary,
                ),
                onTap: () {
                  setModalState(() {
                    if (isSelected) {
                      selectedWebsites.remove(website);
                    } else {
                      selectedWebsites.add(website);
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

  // Apply Filters Function
  void _applyFilters() {
    print('Selected Categories: $selectedCategories');
    print('Selected Brands: $selectedBrands');
    print('Selected Websites: $selectedWebsites');
    print('Price Range: ${priceRange.start} - ${priceRange.end}');
  }
}
