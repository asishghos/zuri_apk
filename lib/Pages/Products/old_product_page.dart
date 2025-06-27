import 'package:flutter/material.dart';
import 'package:testing2/services/Class/product_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as Developer;

// from this page to Home page if user LoggedIn and if not then sign up page
// void _checkLoginStatus() async {
//   final isLoggedIn = await AuthApiService.isLoggedIn();
//   if (!mounted) return;
//   if (isLoggedIn) {
//     context.goNamed('/home');
//   } else {
//     context.goNamed('/onboarding');
//   }
// }
class OldProductPage extends StatefulWidget {
  final List<ProductClass> result;
  const OldProductPage({Key? key, required this.result}) : super(key: key);

  @override
  State<OldProductPage> createState() => _OldProductPageState();
}

class _OldProductPageState extends State<OldProductPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    Developer.log(
      'ProductPage - initState: Initializing with ${widget.result.length} products',
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    // Load any saved favorites from local storage here
    // _loadFavorites();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels > 20 && !_isScrolling) {
      Developer.log('ProductPage - Scrolling: User scrolled down');
      setState(() {
        _isScrolling = true;
      });
    } else if (_scrollController.position.pixels <= 20 && _isScrolling) {
      Developer.log('ProductPage - Scrolling: User returned to top');
      setState(() {
        _isScrolling = false;
      });
    }
  }

  // Future<void> _loadFavorites() async {
  //   // Placeholder for loading favorites
  //   // Developer.log('ProductPage - _loadFavorites: Loading user favorites');
  //   // In a real app, you'd load from SharedPreferences or other storage
  // }

  Set<int> _favorites = {};

  void _toggleFavorite(int index) {
    // Developer.log(
    //     'ProductPage - _toggleFavorite: Toggling favorite for product at index $index');
    setState(() {
      if (_favorites.contains(index)) {
        _favorites.remove(index);
      } else {
        _favorites.add(index);
      }
    });
    // Here you would save favorites to persistent storage
  }

  @override
  void dispose() {
    // Developer.log('ProductPage - dispose: Cleaning up resources');
    _animationController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF1F1),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: _isScrolling
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(Icons.search, color: Color(0xFF999999), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search your perfect outfit...',
                          hintStyle: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: (value) {
                          Developer.log(
                            'ProductPage - Search: User typed "$value"',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Product count and view options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.result.length} Items Found',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Product Grid
            Expanded(
              child: widget.result.isEmpty
                  ? _buildEmptyState()
                  : _buildProductGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    Developer.log('ProductPage - EmptyState: No products available');
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Color(0xFFCCCCCC)),
          SizedBox(height: 16),
          Text(
            "No products found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF666666),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Try adjusting your search or filters",
            style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: widget.result.length,
      physics: BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final product = widget.result[index];
        // Developer.log(
        //     'ProductPage - Grid: Rendering product at index $index: ${product.title}');

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.8, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 50)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: ProductCard(
                imageUrl: product.thumbnail ?? "",
                title: product.title ?? "Untitled",
                brand: product.platform ?? "Unknown",
                originalLink: product.originalLink ?? "",
                isFavorite: _favorites.contains(index),
                onFavoriteToggle: () => _toggleFavorite(index),
              ),
            );
          },
        );
      },
    );
  }
}

class ProductCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String brand;
  final String originalLink;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const ProductCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.brand,
    required this.originalLink,
    required this.isFavorite,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Developer.log(
          'ProductCard - onTap: Opening product link: ${widget.originalLink}',
        );
        try {
          await launchUrl(
            Uri.parse(widget.originalLink),
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          Developer.log('ProductCard - Error: Failed to launch URL: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open product link'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.all(16),
            ),
          );
        }
      },
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Actions
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          frameBuilder:
                              (context, child, frame, wasSynchronouslyLoaded) {
                                if (frame != null) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  });
                                }
                                return child;
                              },
                          errorBuilder: (context, error, stackTrace) {
                            Developer.log(
                              'ProductCard - Error: Failed to load image: $error',
                            );
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            });
                            return Container(
                              color: Color(0xFFEEEEEE),
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 40,
                                  color: Color(0xFF999999),
                                ),
                              ),
                            );
                          },
                        ),
                        if (_isLoading)
                          Container(
                            color: Color(0xFFF5F5F5),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFB93957),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Favorite Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        widget.onFavoriteToggle();
                      },
                      customBorder: CircleBorder(),
                      child: Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          widget.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.isFavorite
                              ? Color(0xFFB93957)
                              : Color(0xFF666666),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Product details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand name
                  Text(
                    widget.brand,
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 3),

                  // Product title
                  Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
