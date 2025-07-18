import 'dart:developer' as Developer;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/services/DataSource/zuri_magazine_api.dart';

class FilterOverlay extends StatefulWidget {
  final List<String> categories;
  final Function(List<String>) onApplyFilter;

  const FilterOverlay({
    Key? key,
    required this.categories,
    required this.onApplyFilter,
    required ScrollController scrollController,
  }) : super(key: key);

  @override
  State<FilterOverlay> createState() => _FilterOverlayState();
}

class _FilterOverlayState extends State<FilterOverlay> {
  int selectedFilterIndex = 0;
  final List<String> filterOptions = ['Category'];

  List<String> selectedCategories = [];
  TextEditingController categorySearchController = TextEditingController();

  List<String> _categories = [];
  Future<Map<String, dynamic>> _loadMagazineData() async {
    try {
      final categoriesResponse =
          await ZuriMagazineApiService.getAllCategories();
      Developer.log('Categories response: ${categoriesResponse.toString()}');
      _categories = categoriesResponse.data;
      return {'categories': categoriesResponse.data};
    } catch (e) {
      Developer.log('Error loading magazine data: ${e.toString()}');
      return {'categories': <String>[]};
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMagazineData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Top Handle
          Container(
            margin: EdgeInsets.only(top: 12),
            width: MediaQuery.of(context).size.width * 0.0995,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(18),
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: Colors.grey[600], size: 24),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey[200]),

          // Main Content with Column Layout
          Expanded(
            child: Row(
              children: [
                // Left Column - Filter Categories
                Container(
                  width: 120,
                  color: Colors.grey[50],
                  child: Column(
                    children: filterOptions.asMap().entries.map((entry) {
                      int index = entry.key;
                      String option = entry.value;
                      bool isSelected = selectedFilterIndex == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
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
                                      color: AppColors.textPrimary,
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
                                  : Colors.grey[600],
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
                    child: _buildFilterContent(selectedFilterIndex),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        selectedCategories.clear();
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      'Reset All',
                      style: GoogleFonts.libreFranklin(
                        fontSize: MediaQuery.of(context).textScaler.scale(16),
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.049751243,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApplyFilter(selectedCategories);
                      // Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                    ),
                    child: Text(
                      'Apply Filter',
                      style: GoogleFonts.libreFranklin(
                        fontSize: MediaQuery.of(context).textScaler.scale(16),
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
  }

  Widget _buildFilterContent(int index) {
    switch (index) {
      case 0:
        return _buildCategoryFilter();
      default:
        return Container();
    }
  }

  Widget _buildCategoryFilter() {
    // List<Map<String, dynamic>> filteredCategories = _categories.length;

    // // Filter categories based on search
    // if (categorySearchController.text.isNotEmpty) {
    //   filteredCategories = categoriesWithCounts
    //       .where(
    //         (category) => category['name'].toLowerCase().contains(
    //           categorySearchController.text.toLowerCase(),
    //         ),
    //       )
    //       .toList();
    // }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(25),
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
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.textPrimary,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                // Trigger rebuild to filter categories
              });
            },
          ),
        ),
        SizedBox(height: 25),

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
            SizedBox(width: 15),
            Expanded(child: Divider(color: Colors.grey[300], height: 1)),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.022883295),

        // Category List
        Expanded(
          child: ListView.builder(
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              bool isSelected = selectedCategories.contains(category);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedCategories.remove(category);
                      } else {
                        selectedCategories.add(category);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  category,
                                  style: GoogleFonts.libreFranklin(
                                    fontSize: MediaQuery.of(
                                      context,
                                    ).textScaler.scale(14),
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 5),
                              // Text(
                              //   '(${category['count']})',
                              //   style: GoogleFonts.libreFranklin(
                              //     fontSize: MediaQuery.of(
                              //       context,
                              //     ).textScaler.scale(14),
                              //     color: Colors.grey[500],
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        Container(
                          width:
                              MediaQuery.of(context).size.width * 0.049751243,
                          height:
                              MediaQuery.of(context).size.height * 0.022883295,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : Colors.grey[400]!,
                              width:
                                  MediaQuery.of(context).size.width *
                                  0.004975124,
                            ),
                            color: isSelected
                                ? AppColors.textPrimary
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    categorySearchController.dispose();
    super.dispose();
  }
}
