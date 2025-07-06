import 'dart:developer' as Developer;

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/Pages/Loading/loading_page.dart';
import 'package:testing2/services/Class/zuri_magqazine_model.dart';
import 'package:testing2/services/DataSource/zuri_magazine_api.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String magazineid;

  const ArticleDetailScreen({Key? key, required this.magazineid})
    : super(key: key);

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool isSaved = false;
  bool _isLoading = false;
  late ZuriArticle _article;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });
    _loadMagazineData();
    // isSaved = _article!.isSaved;
  }

  void _toggleSave() {
    setState(() {
      isSaved = !isSaved;
    });
  }

  void _shareArticle() {
    SharePlus.instance.share(
      '''Check out this article: ${_article.title}''' as ShareParams,
    );
  }

  Future<ZuriArticle?> _loadMagazineData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      // Load categories
      final responce = await ZuriMagazineApiService.getByIdMagazine(
        widget.magazineid,
      );
      _article = responce;
      Developer.log('Categories response: ${responce.toString()}');
      setState(() {
        _isLoading = false;
      });
      return responce;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Developer.log('Error loading magazine data: ${e.toString()}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: const Color(0xFFFFFFFF),
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
          ), // Adjust this value as needed
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.titleTextColor,
              size: 20,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          _article.category,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? LoadingPage()
          : SingleChildScrollView(
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
                          _article.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColors.titleTextColor,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Main content
                        Text(
                          _article.subTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF4D5461),
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Read time
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Color(0xFF6C757D),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "5 min Read",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6C757D),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Author section (moved below read time)
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _article.authorProfilePic,
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Surabhi',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6C757D),
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
                        _article.bannerImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                size: 48,
                                color: Colors.grey,
                              ),
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
                        const SizedBox(height: 16),

                        // Extended content
                        Text(
                          _article.content,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF212529),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Author section
                        const SizedBox(height: 24),

                        // Tags section
                        const Text(
                          'Related Tags',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212529),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _article.tags.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              return _buildTag(_article.tags[index]);
                            },
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Action buttons (made larger)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _shareArticle,
                                icon: const Icon(
                                  Icons.share_outlined,
                                  size: 20,
                                ),
                                label: const Text(
                                  'Share Article',
                                  style: TextStyle(fontSize: 16),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF6C757D),
                                  side: const BorderSide(
                                    color: AppColors.textPrimary,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _toggleSave,
                                icon: Icon(
                                  isSaved
                                      ? Icons.bookmark
                                      : Icons.bookmark_outline,
                                  size: 20,
                                ),
                                label: Text(
                                  isSaved ? 'Saved' : 'Save Article',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSaved
                                      ? const Color(0xFFE91E63)
                                      : const Color(0xFF212529),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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
        style: const TextStyle(
          color: Color(0xFFE91E63),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
