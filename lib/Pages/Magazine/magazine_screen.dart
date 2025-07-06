import 'dart:developer' as Developer;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Global/Widget/global_widget.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/Pages/Magazine/article_detail_screen.dart';
import 'package:testing2/services/Class/zuri_magqazine_model.dart';
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

  List<ZuriArticle> _articles = [];
  List<ZuriArticle> filteredArticles = [];
  String selectedCategory = 'Elegant Luxury on a Budget';
  int notificationCount = 3;

  // // Helper method to get saved articles count
  // int get savedArticlesCount =>
  //     _articles.where((article) => article.isSaved ?? false).length;

  // Combined future for loading both categories and articles
  Future<Map<String, dynamic>> _loadMagazineData() async {
    try {
      // Load categories
      final categoriesResponse =
          await ZuriMagazineApiService.getAllCategoriesMagazine();
      Developer.log('Categories response: ${categoriesResponse.toString()}');

      // Load articles by category (using the first category or a default one)
      final articlesResponse =
          await ZuriMagazineApiService.getByCategoryMagazine("beauty");
      Developer.log('Articles response: ${articlesResponse.toString()}');
      Developer.log(articlesResponse[0].id.toString());

      return {
        'categories': categoriesResponse.data,
        'articles': articlesResponse,
      };
    } catch (e) {
      Developer.log('Error loading magazine data: ${e.toString()}');
      return {'categories': <String>[], 'articles': <ZuriArticle>[]};
    }
  }

  Future<void> _getByIdMagazine() async {
    try {
      final responce = await ZuriMagazineApiService.getByIdMagazine(
        "6864cd9b8200461d6f222b65",
      );
      Developer.log(responce.toString());
    } catch (e) {
      Developer.log(e.toString());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _modalScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _getByIdMagazine();
    super.initState();
  }

  void _filterArticles(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredArticles = _articles;
      } else {
        filteredArticles = _articles
            .where(
              (article) => (article.category.toLowerCase().contains(
                query.toLowerCase(),
              )),
            )
            .toList();
      }
    });
  }

  // void _toggleSaved(String articleId) {
  //   setState(() {
  //     final index = _articles.indexWhere((article) => article.id == articleId);
  //     if (index != -1) {
  //       _articles[index].isSaved = !(_articles[index].isSaved ?? false);
  //       // Also update filtered articles
  //       final filteredIndex = filteredArticles.indexWhere(
  //         (article) => article.id == articleId,
  //       );
  //       if (filteredIndex != -1) {
  //         filteredArticles[filteredIndex].isSaved = _articles[index].isSaved;
  //       }
  //     }
  //   });
  // }

  void _shareArticle(ZuriArticle article) {
    Share.share('Check out this article: ${article.title}');
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
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load magazine data',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please check your connection and try again',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
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
          final articles = data['articles'] as List<ZuriArticle>;

          // Initialize articles and filtered articles if not already done
          if (_articles.isEmpty && articles.isNotEmpty) {
            _articles = articles;
            filteredArticles = articles;
          }

          return Column(
            children: [
              _buildHeader(),
              // Search Bar
              Padding(
                padding: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
                child: Row(
                  children: [
                    Expanded(child: GlobalSearchBar()),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showFilterOverlay(categories),
                      child: Container(
                        width: 62,
                        height: 50,
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
              ),

              // Categories
              if (categories.isNotEmpty)
                SizedBox(
                  height: 42,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
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
                              category,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 24),
              // Articles List
              Expanded(
                child: filteredArticles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No articles found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filters',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredArticles.length,
                        itemBuilder: (context, index) {
                          final article = filteredArticles[index];
                          return ArticleCard(
                            article: article,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArticleDetailScreen(
                                    magazineid: article.id,
                                  ),
                                ),
                              );
                            },
                            onSave: () {},
                            // onSave: () => _toggleSaved(article.id ?? ''),
                            onShare: () => _shareArticle(article),
                          );
                        },
                      ),
              ),
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
          // Text(
          //   'Z-Magazine',
          //   style: GoogleFonts.libreFranklin(
          //     color: AppColors.titleTextColor,
          //     fontSize: 18,
          //     fontWeight: FontWeight.w600,
          //   ),
          // ),
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
              const SizedBox(width: 8),
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
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.titleTextColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '4',
                            style: GoogleFonts.libreFranklin(
                              color: Colors.white,
                              fontSize: 8,
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

class ArticleCard extends StatelessWidget {
  final ZuriArticle article;
  final VoidCallback onTap;
  final VoidCallback onSave;
  final VoidCallback onShare;

  const ArticleCard({
    Key? key,
    required this.article,
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
            // Article Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge with "by Author"
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Image.network(
                            article.authorProfilePic,
                            width: 8,
                            height: 8,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 8,
                                color: Colors.white,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children:
                                '${article.category} by ${article.authorName}'
                                    .split(' ')
                                    .map(
                                      (word) => TextSpan(
                                        text: '$word ',
                                        style: TextStyle(
                                          fontWeight: word == 'by'
                                              ? FontWeight.w400
                                              : FontWeight.w700,
                                          fontSize: 12,
                                          color: const Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    article.content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.titleTextColor,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Bottom Row
                  Row(
                    children: [
                      Text(
                        '5 min read',
                        style: const TextStyle(
                          fontSize: 10,
                          height: 2.2,
                          letterSpacing: -0.02 * 10,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF131927),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),
            // Article Image and Action Buttons
            Column(
              children: [
                // Article Image with graceful error handling
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 100,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Image.network(
                      article.bannerImage,
                      width: 100,
                      height: 120,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 100,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Action Buttons below image
                Row(
                  children: [
                    GestureDetector(
                      onTap: onShare,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.share_outlined,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onSave,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.bookmark,
                          size: 16,
                          color: const Color(0xFF6B7280),
                        ),
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

  Widget _buildPlaceholderImage() {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey[400],
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            'Image\nUnavailable',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 10),
          ),
        ],
      ),
    );
  }
}
