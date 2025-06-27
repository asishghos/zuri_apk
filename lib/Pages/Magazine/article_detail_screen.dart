import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'magazine_screen.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({Key? key, required this.article})
    : super(key: key);

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    isSaved = widget.article.isSaved;
  }

  void _toggleSave() {
    setState(() {
      isSaved = !isSaved;
    });
  }

  void _shareArticle() {
    Share.share('Check out this article: ${widget.article.title}');
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
          widget.article.category,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
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
                    widget.article.title,
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
                    widget.article.description,
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
                        widget.article.readTime,
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
                        child: Image.asset(
                          'assets/images/Surabhi.jpg',
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
                  widget.article.imageUrl,
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
                  const SizedBox(height: 16),

                  // Extended content
                  const Text(
                    'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.\n\nContrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source.',
                    style: TextStyle(
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag('Fashion'),
                      _buildTag('Style'),
                      _buildTag('Budget'),
                      _buildTag('Luxury'),
                      _buildTag('Tips'),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Action buttons (made larger)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _shareArticle,
                          icon: const Icon(Icons.share_outlined, size: 20),
                          label: const Text(
                            'Share Article',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6C757D),
                            side: const BorderSide(
                              color: AppColors.textPrimary,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                            isSaved ? Icons.bookmark : Icons.bookmark_outline,
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
