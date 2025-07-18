import 'dart:developer' as Developer;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/services/Class/digital_wardrobe_model.dart';
import 'package:testing2/services/DataSource/digital_wardrobe_api.dart';

class EditTagsPage extends StatefulWidget {
  final String? fromPage;
  final String? garmentId;
  final String? garmentName;
  const EditTagsPage({
    required this.garmentName,
    required this.garmentId,
    this.fromPage,
    super.key,
  });

  @override
  State<EditTagsPage> createState() => _EditTagsPageState();
}

class _EditTagsPageState extends State<EditTagsPage> {
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
    'Georgette'
        'Net',
    'Satin',
    'Tulle',
  ];
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
  List<String> selectedColorName = [];
  List<String> selectedColorHex = [];
  List<String> selectedFabrics = [];
  List<String> selectedSeasons = [];
  List<String> selectedOcassions = [];
  TextEditingController categorySearchController = TextEditingController();
  late final String garmentName;

  Future<GarmentDetails?> _getSingleGarmentDetails({
    required String garmentId,
  }) async {
    final garment = await WardrobeApiService.fetchGarmentDetails(garmentId);
    if (garment != null) {
      Developer.log("✅ Garment Details fetched successfully");
      return garment;
    } else {
      Developer.log("❌ Garment not found");
      return null;
    }
  }

  void _applyUpdate() async {
    // Use the actual garment ID from widget
    final garmentId = widget.garmentId ?? '';

    // Build the updated fields from selected tags
    final updatedFields = <String, dynamic>{};

    // Add selected values to update fields
    if (selectedCategories.isNotEmpty) {
      updatedFields['category'] =
          selectedCategories.first; // Assuming single category
    }

    if (selectedColorName.isNotEmpty && selectedColorHex.isNotEmpty) {
      updatedFields['color'] = {
        if (selectedColorName.isNotEmpty) 'name': selectedColorName.first,
        if (selectedColorHex.isNotEmpty) 'hex': selectedColorHex.first,
      };
    }

    if (selectedFabrics.isNotEmpty) {
      updatedFields['fabric'] = selectedFabrics.first; // Assuming single fabric
    }

    if (selectedOcassions.isNotEmpty) {
      updatedFields['occasion'] = selectedOcassions; // Array of occasions
    }

    if (selectedSeasons.isNotEmpty) {
      updatedFields['season'] = selectedSeasons; // Array of seasons
    }

    // Only proceed if there are changes to save
    if (updatedFields.isEmpty) {
      Developer.log("No changes to save");
      return;
    }

    final updatedGarment = await WardrobeApiService.updateGarment(
      garmentId: garmentId,
      updatedFields: updatedFields,
    );

    if (updatedGarment != null) {
      Developer.log("✅ Garment updated successfully");
      // Navigate back or show success message
      if (mounted) {
        showSuccessSnackBar(context, 'Tags updated successfully!');
        setState(() {});
      }
    } else {
      Developer.log("❌ Failed to update garment");
      if (mounted) {
        showErrorSnackBar(context, 'Failed to update tags');
      }
    }
  }

  void _initializeSelectedTags(GarmentDetails garment) {
    selectedColorName = [garment.color.name];
    selectedColorHex = [garment.color.hex];
    selectedCategories = [garment.category];
    selectedFabrics = [garment.fabric];
    selectedOcassions = List.from(garment.occasion);
    selectedSeasons = List.from(garment.season);
  }

  void _addNewItemsToLists(GarmentDetails garment) {
    // Add new color if not exists
    bool colorExists = colors.any(
      (color) => color['name'] == garment.color.name,
    );
    if (!colorExists) {
      colors.add({
        'name': garment.color.name,
        'hexCode': '0xFF808080', // Default gray color for new items
      });
      Developer.log("Added new color: ${garment.color.name}");
    }

    // Add new category if not exists
    if (!categories.contains(garment.category)) {
      categories.add(garment.category);
      Developer.log("Added new category: ${garment.category}");
    }

    // Only add valid fabrics
    if (!fabrics.contains(garment.fabric)) {
      fabrics.add(garment.fabric);
      Developer.log("Added new fabric: ${garment.fabric}");
    }

    // Add new occasions if not exist
    // for (String occasion in garment.occasion) {
    //   if (!_getAllOccasions().contains(occasion)) {
    //     _addNewOccasion(occasion);
    //     Developer.log("Added new occasion: $occasion");
    //   }
    // }

    // Add new seasons if not exist
    for (String season in garment.season) {
      if (!seasons.contains(season)) {
        seasons.add(season);
        Developer.log("Added new season: $season");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(right: 20, left: 20),
        child: Column(
          children: [
            // Fixed Header Section
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (widget.fromPage == 'fromAllItems') {
                      context.goNamed('allItemsWardrobe', extra: 0);
                    } else if (widget.fromPage == 'fromrecentCategory') {
                      context.goNamed('allItemsWardrobe', extra: 1);
                    } else if (widget.fromPage == 'fromtopsCategory') {
                      context.goNamed('allItemsWardrobe', extra: 2);
                    } else if (widget.fromPage == 'frombottomsCategory') {
                      context.goNamed('allItemsWardrobe', extra: 3);
                    } else if (widget.fromPage == 'fromethnicCategory') {
                      context.goNamed('allItemsWardrobe', extra: 4);
                    } else if (widget.fromPage == 'fromdressesCategory') {
                      context.goNamed('allItemsWardrobe', extra: 5);
                    } else if (widget.fromPage == 'fromcoordsetCategory') {
                      context.goNamed('allItemsWardrobe', extra: 6);
                    } else if (widget.fromPage == 'fromswimwearCategory') {
                      context.goNamed('allItemsWardrobe', extra: 7);
                    } else if (widget.fromPage == 'fromfootwearCategory') {
                      context.goNamed('allItemsWardrobe', extra: 8);
                    } else if (widget.fromPage == 'fromaccessoriesCategory') {
                      context.goNamed('allItemsWardrobe', extra: 9);
                    } else {
                      context.goNamed('myWardrobe');
                    }
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
                        text: widget.garmentName ?? 'Edit Tags',
                        style: GoogleFonts.libreFranklin(
                          color: AppColors.titleTextColor,
                          fontSize: MediaQuery.of(context).textScaler.scale(18),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Spacer(),
                TextButton(
                  onPressed: () {
                    if (widget.fromPage == 'fromAllItems') {
                      context.goNamed('allItemsWardrobe', extra: 0);
                    } else if (widget.fromPage == 'fromrecentCategory') {
                      context.goNamed('allItemsWardrobe', extra: 1);
                    } else if (widget.fromPage == 'fromtopsCategory') {
                      context.goNamed('allItemsWardrobe', extra: 2);
                    } else if (widget.fromPage == 'frombottomsCategory') {
                      context.goNamed('allItemsWardrobe', extra: 3);
                    } else if (widget.fromPage == 'fromethnicCategory') {
                      context.goNamed('allItemsWardrobe', extra: 4);
                    } else if (widget.fromPage == 'fromdressesCategory') {
                      context.goNamed('allItemsWardrobe', extra: 5);
                    } else if (widget.fromPage == 'fromcoordsetCategory') {
                      context.goNamed('allItemsWardrobe', extra: 6);
                    } else if (widget.fromPage == 'fromswimwearCategory') {
                      context.goNamed('allItemsWardrobe', extra: 7);
                    } else if (widget.fromPage == 'fromfootwearCategory') {
                      context.goNamed('allItemsWardrobe', extra: 8);
                    } else if (widget.fromPage == 'fromaccessoriesCategory') {
                      context.goNamed('allItemsWardrobe', extra: 9);
                    } else {
                      context.goNamed('myWardrobe');
                    }
                  },

                  child: Text(
                    'Save',
                    style: GoogleFonts.libreFranklin(
                      color: AppColors.textPrimary,
                      fontSize: MediaQuery.of(context).textScaler.scale(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: FutureBuilder<GarmentDetails?>(
                  future: _getSingleGarmentDetails(
                    garmentId: widget.garmentId ?? '',
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.textPrimary,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height *
                                  0.018306636,
                            ),
                            Text(
                              'Error loading items',
                              style: GoogleFonts.libreFranklin(
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(16),
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height *
                                  0.009153318,
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
                    } else if (!snapshot.hasData ||
                        snapshot.data!.imageId.isEmpty) {
                      return Center(
                        child: Text(
                          'No items found',
                          style: GoogleFonts.libreFranklin(
                            fontSize: MediaQuery.of(
                              context,
                            ).textScaler.scale(16),
                            color: Colors.grey,
                          ),
                        ),
                      );
                    } else {
                      final garment = snapshot.data!;
                      _initializeSelectedTags(garment);
                      final List<String> tags = [
                        garment.color.name,
                        garment.category,
                        garment.fabric,
                        garment.occasion.join(', '),
                        garment.season.join(', '),
                      ];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: dh * 0.7,
                            width: dw,
                            child: Image.network(garment.imageUrl),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height *
                                0.018306636,
                          ),
                          Text(
                            "We've tagged it for you! Feel free to tweak if something's off. ",
                            style: GoogleFonts.libreFranklin(
                              color: AppColors.titleTextColor,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height *
                                0.018306636,
                          ),
                          Container(
                            height:
                                MediaQuery.of(context).size.height *
                                0.036613272,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,

                              itemCount: tags.length,
                              itemBuilder: (context, index) {
                                String tag = tags[index];
                                return Container(
                                  margin: EdgeInsets.only(right: 8),
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Color(0xFFE25C7E),
                                      elevation: 0,
                                      side: BorderSide(
                                        color: Color(0xFFE25C7E),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                    ),
                                    child: Text(
                                      tag,
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
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 0.0274599,
                          ),
                          GlobalPinkButton(
                            text: "Edit tags",
                            onPressed: () {
                              _showFilterBottomSheet(context);
                            },
                            height: 48,
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ],
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
                          'Edit tags',
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
                                selectedColorName.clear();
                                selectedColorHex.clear();
                                selectedOcassions.clear();
                                selectedSeasons.clear();
                              });
                              setState(() {
                                selectedCategories.clear();
                                selectedFabrics.clear();
                                selectedColorName.clear();
                                selectedColorHex.clear();
                                selectedOcassions.clear();
                                selectedSeasons.clear();
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
                              _applyUpdate();
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
                              'Save',
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
              bool isSelected = selectedColorName.contains(color['name']);

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
                        selectedColorName.remove(color['name']);
                        selectedColorHex.remove(color['hex']);
                      } else {
                        selectedColorName.remove(color['name']);
                        selectedColorHex.remove(color['hex']);
                      }
                    });
                  },
                  activeColor: AppColors.textPrimary,
                ),
                onTap: () {
                  setModalState(() {
                    if (isSelected) {
                      selectedColorName.remove(color['name']);
                      selectedColorHex.remove(color['hex']);
                    } else {
                      selectedColorName.add(color['name']);
                      selectedColorHex.add(color['hex']);
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

  // Fabrics Filter Widget
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

  // Season Filter Widget
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
        Expanded(
          child: ListView.builder(
            itemCount: categories.length,
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
