import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'filter_overlay.dart';
import 'article_detail_screen.dart';

class MagazineScreen extends StatefulWidget {
  const MagazineScreen({Key? key}) : super(key: key);

  @override
  State<MagazineScreen> createState() => _MagazineScreenState();
}

class _MagazineScreenState extends State<MagazineScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _modalScrollController =
      ScrollController(); // Add this line

  final List<String> categories = [
    'Elegant Luxury on a Budget',
    'Strike a Pose',
    'Style Statement',
    'Fashion Trends',
    'Beauty Tips',
  ];

  final List<Article> articles = [
    Article(
      id: '1',
      title: 'Lorem Ipsum is simply dummy',
      description:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
      imageUrl:
          'https://images.unsplash.com/photo-1494790108755-2616b612b47c?w=150&h=150&fit=crop',
      readTime: '5 min read',
      author: 'Jane Doe',
      category: 'Elegant Luxury on a Budget',
      content: 'Full article content here...',
      isSaved: false,
    ),
    Article(
      id: '2',
      title: 'Lorem Ipsum is simply dummy',
      description:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
      imageUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop',
      readTime: '3 min read',
      author: 'John Smith',
      category: 'Strike a Pose',
      content: 'Full article content here...',
      isSaved: false,
    ),
    Article(
      id: '3',
      title: 'Lorem Ipsum is simply dummy',
      description:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
      imageUrl:
          'https://images.unsplash.com/photo-1534751516642-a1af1ef26a56?w=150&h=150&fit=crop',
      readTime: '7 min read',
      author: 'Sarah Johnson',
      category: 'Style Statement',
      content: 'Full article content here...',
      isSaved: true,
    ),
  ];

  List<Article> filteredArticles = [];
  String selectedCategory = 'Elegant Luxury on a Budget';
  int notificationCount = 3;

  // Helper method to get saved articles count
  int get savedArticlesCount =>
      articles.where((article) => article.isSaved).length;

  @override
  void initState() {
    super.initState();
    filteredArticles = articles;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _modalScrollController.dispose(); // Add this line
    super.dispose();
  }

  void _filterArticles(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredArticles = articles;
      } else {
        filteredArticles = articles
            .where(
              (article) =>
                  article.title.toLowerCase().contains(query.toLowerCase()) ||
                  article.description.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  article.category.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _toggleSaved(String articleId) {
    setState(() {
      final index = articles.indexWhere((article) => article.id == articleId);
      if (index != -1) {
        articles[index].isSaved = !articles[index].isSaved;
      }
    });
  }

  void _shareArticle(Article article) {
    Share.share('Check out this article: ${article.title}');
  }

  void _showFilterOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true, // Add this for better user interaction
      isDismissible: true, // Add this to allow dismissing by tapping outside
      useSafeArea: true, // Add this for better safe area handling
      builder: (context) => FilterOverlay(
        scrollController:
            _modalScrollController, // Use the proper scroll controller
        categories: categories,
        onApplyFilter: (selectedCategories) {
          Navigator.pop(context);
          // You can add your filter logic here if needed
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        scrolledUnderElevation: 0,
        surfaceTintColor: const Color(0xFFFFFFFF),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/svg/Z Magazine.svg',
              width: 98,
              height: 45,
              fit: BoxFit.fill,
            ),
          ],
        ),
        actions: [
          Container(
            width: 45,
            height: 45,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEB),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD34169), width: 0),
            ),
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/Icon/bookmark-02.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                ),
                if (savedArticlesCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD34169),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          savedArticlesCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: 45,
            height: 45,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEB),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD34169), width: 0),
            ),
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/Icon/notification-01.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                ),
                if (notificationCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD34169),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          notificationCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
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
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    width: 295,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEB),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: const Color(0xFFD34169),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterArticles,
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF9CA3AF),
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showFilterOverlay,
                  child: Container(
                    width: 62,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Image.asset(
                      'assets/images/Icon/filter-horizontal.png',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Categories
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
            child: ListView.builder(
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
                        builder: (context) =>
                            ArticleDetailScreen(article: article),
                      ),
                    );
                  },
                  onSave: () => _toggleSaved(article.id),
                  onShare: () => _shareArticle(article),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Article {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String readTime;
  final String author;
  final String category;
  final String content;
  bool isSaved;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.readTime,
    required this.author,
    required this.category,
    required this.content,
    required this.isSaved,
  });
}

class ArticleCard extends StatelessWidget {
  final Article article;
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
          color: Color(0xFFF3F4F6),
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
                  // Category Badge with "by Surabhi"
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
                          child: Image.asset(
                            'assets/images/Icon/Surabhi.jpg',
                            width: 8,
                            height: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      RichText(
                        text: TextSpan(
                          children: 'Elegant luxury on budget by Surabhi'
                              .split(' ')
                              .map(
                                (word) => TextSpan(
                                  text: '$word ',
                                  style: TextStyle(
                                    fontWeight: word == 'by'
                                        ? FontWeight.w400
                                        : FontWeight.w700,
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              )
                              .toList(),
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
                    article.description,
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
                        article.readTime,
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
                      article.imageUrl,
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
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
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        );
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
                          color: article.isSaved
                              ? const Color(0xFFE91E63)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          article.isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          size: 16,
                          color: article.isSaved
                              ? Colors.white
                              : const Color(0xFF6B7280),
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
}
