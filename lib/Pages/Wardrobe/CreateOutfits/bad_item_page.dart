import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testing2/Global/Colors/app_colors.dart';
import 'package:testing2/services/Class/styling_model.dart';

class BadItemsPage extends StatefulWidget {
  final List<ImageWithDescription?> badItems;

  const BadItemsPage({Key? key, required this.badItems}) : super(key: key);

  @override
  State<BadItemsPage> createState() => _BadItemsPageState();
}

class _BadItemsPageState extends State<BadItemsPage> {
  PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double dh = MediaQuery.of(context).size.height;
    double dw = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.close, color: Colors.grey[600], size: 28),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          children: [
            Text(
              "Oh, Babe! Cute, but not quite the mood",
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(20),
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.009153318),
            Text(
              "Let’s remix it into something more event-appropriate\n (and still very you!)",
              style: GoogleFonts.libreFranklin(
                fontSize: MediaQuery.of(context).textScaler.scale(14),
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.0274599),
            Container(
              height: dh * 0.65,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: widget.badItems.length,
                itemBuilder: (context, index) {
                  final badItem = widget.badItems[index]!;
                  return Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              badItem.image,
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.white,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        size: 60,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.013729977,
                                      ),
                                      Text(
                                        'Failed to load image',
                                        style: GoogleFonts.libreFranklin(
                                          color: Colors.grey[600],
                                          fontSize: MediaQuery.of(
                                            context,
                                          ).textScaler.scale(14),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height * 0.018306636,
                      ),
                      Text(
                        badItem.description,
                        style: GoogleFonts.libreFranklin(
                          fontSize: MediaQuery.of(context).textScaler.scale(14),
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
            if (widget.badItems.length > 1) ...[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.018306636,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.badItems.length,
                  (index) => _buildDotIndicator(index == _currentIndex),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4),
      height: MediaQuery.of(context).size.height * 0.009153318,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.textPrimary : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
