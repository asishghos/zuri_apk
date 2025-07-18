import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'package:google_fonts/google_fonts.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  Timer? _quoteTimer;
  int _currentQuoteIndex = 0;

  // Sample quotes with author information
  final List<Map<String, String>> quotes = [
    {
      "quote":
          "If you can’t be better than your competition, just dress better.",
      "authorName": "Anna Wintour",
      "authorBio":
          "British-American fashion editor who served as editor-in-chief of American Vogue from 1988 to 2025, shaping global fashion trends.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/3/3d/Anna_Wintour_2015.jpg",
    },
    {
      "quote": "Fashion is about dreaming and making other people dream.",
      "authorName": "Donatella Versace",
      "authorBio":
          "Italian fashion designer and sister of Gianni Versace; took over as creative director of Versace in 1997, infusing bold glamour into the brand.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/9/9e/Donatella_Versace_2010.jpg",
    },
    {
      "quote":
          "You have a more interesting life if you wear impressive clothes.",
      "authorName": "Vivienne Westwood",
      "authorBio":
          "British fashion designer who brought punk and new wave fashions into the mainstream. Known for her provocative designs and political activism.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/7/7d/Vivienne_Westwood_2014.jpg",
    },
    {
      "quote": "She can beat me, but she cannot beat my outfit.",
      "authorName": "Rihanna",
      "authorBio":
          "Barbadian singer, actress, and businesswoman. Founder of Fenty Beauty and known for her influence in music and fashion.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/8/8e/Rihanna_2018.png",
    },
    {
      "quote":
          "When you don’t dress like everybody else, you don’t have to think like everybody else.",
      "authorName": "Iris Apfel",
      "authorBio":
          "American businesswoman and fashion icon known for her eclectic style and oversized glasses. Worked on White House restoration projects for nine presidents.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/9/9d/Iris_Apfel_2015.jpg",
    },
    {
      "quote": "Elegance is the only beauty that never fades.",
      "authorName": "Audrey Hepburn",
      "authorBio":
          "British actress and humanitarian. Recognized as a film and fashion icon, known for roles in 'Breakfast at Tiffany's' and 'Roman Holiday'.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/3/3e/Audrey_Hepburn_1956.jpg",
    },
    {
      "quote":
          "One is never over-dressed or under-dressed with a little black dress.",
      "authorName": "Karl Lagerfeld",
      "authorBio":
          "German fashion designer and creative director of Chanel from 1983 until his death in 2019, known for revitalizing the brand.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/0/0e/Karl_Lagerfeld_2010.jpg",
    },
    {
      "quote":
          "I like my money right where I can see it… hanging in my closet.",
      "authorName": "Carrie Bradshaw",
      "authorBio":
          "Fictional character from 'Sex and the City', portrayed as a fashion-forward columnist navigating love and life in New York City.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/1/1e/Sarah_Jessica_Parker_2009.jpg",
    },
    {
      "quote": "Playing dress-up begins at age five and never truly ends.",
      "authorName": "Kate Spade",
      "authorBio":
          "American fashion designer and entrepreneur, co-founder of Kate Spade New York, known for her vibrant and playful designs.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/6/6d/Kate_Spade_2016.jpg",
    },
    {
      "quote": "Give a girl the right shoes and she can conquer the world.",
      "authorName": "Marilyn Monroe",
      "authorBio":
          "Iconic American actress and model of the 1950s, celebrated for her beauty, talent, and tragic life story.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/7/79/Marilyn_Monroe_1953.jpg",
    },
    {
      "quote": "You can have anything you want in life if you dress for it.",
      "authorName": "Edith Head",
      "authorBio":
          "Renowned American costume designer with a record eight Academy Awards, known for her work in classic Hollywood films.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/2/2c/Edith_Head_1976.jpg",
    },
    {
      "quote": "Some girls are just born with glitter in their veins.",
      "authorName": "Blair Waldorf",
      "authorBio":
          "Fictional character from 'Gossip Girl', depicted as a stylish and ambitious New York socialite.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/5/5f/Leighton_Meester_2010.jpg",
    },
    {
      "quote":
          "Fashion is self-expression. It’s like art you live your life in.",
      "authorName": "Blake Lively",
      "authorBio":
          "American actress known for her roles in 'Gossip Girl' and films, admired for her fashion sense and red carpet appearances.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/2/2f/Blake_Lively_2016.jpg",
    },
    {
      "quote":
          "There’s nothing sexier than a woman who is comfortable in her clothes.",
      "authorName": "Jennifer Aniston",
      "authorBio":
          "American actress and producer, rose to fame with 'Friends', known for her effortless style and charm.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/8/88/Jennifer_Aniston_2011.jpg",
    },
    {
      "quote": "Dressing well is a form of good manners.",
      "authorName": "Victoria Beckham",
      "authorBio":
          "British singer-turned-fashion designer, known for her sophisticated designs and personal style.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/3/3d/Victoria_Beckham_2010.jpg",
    },
    {
      "quote": "I love when my clothes make me feel like I’m telling a story.",
      "authorName": "Selena Gomez",
      "authorBio":
          "American singer and actress, recognized for her evolving fashion choices and influence on pop culture.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/4/4d/Selena_Gomez_2019.jpg",
    },
    {
      "quote": "Style is a way to say who you are without having to speak.",
      "authorName": "Kim Kardashian",
      "authorBio":
          "American media personality and entrepreneur, known for her impact on fashion and beauty industries.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/0/0f/Kim_Kardashian_2019.jpg",
    },
    {
      "quote":
          "Beauty and style should be inclusive. Every skin tone, every size, every body.",
      "authorName": "Kim Kardashian",
      "authorBio":
          "American media personality and entrepreneur, known for her impact on fashion and beauty industries.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/0/0f/Kim_Kardashian_2019.jpg",
    },
    {
      "quote":
          "Style is about being fearless and expressing yourself without apology.",
      "authorName": "Kylie Jenner",
      "authorBio":
          "American media personality and businesswoman, founder of Kylie Cosmetics, influential in beauty and fashion.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/1/1e/Kylie_Jenner_2018.jpg",
    },
    {
      "quote":
          "I’ve always loved fashion—it’s a way of creating a mood and showing who you are.",
      "authorName": "Kylie Jenner",
      "authorBio":
          "American media personality and businesswoman, founder of Kylie Cosmetics, influential in beauty and fashion.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/1/1e/Kylie_Jenner_2018.jpg",
    },
    {
      "quote": "The right outfit makes you feel unstoppable.",
      "authorName": "Kylie Jenner",
      "authorBio":
          "American media personality and businesswoman, founder of Kylie Cosmetics, influential in beauty and fashion.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/1/1e/Kylie_Jenner_2018.jpg",
    },
    {
      "quote":
          "Fashion is just another way to express how I’m feeling that day.",
      "authorName": "Kylie Jenner",
      "authorBio":
          "American media personality and businesswoman, founder of Kylie Cosmetics, influential in beauty and fashion.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/1/1e/Kylie_Jenner_2018.jpg",
    },
    {
      "quote": "I don’t speak fashion. I speak truth. Through clothes.",
      "authorName": "Jeremy Scott",
      "authorBio":
          "American fashion designer and creative director of Moschino, known for his bold and unconventional designs.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/9/9f/Jeremy_Scott_2011.jpg",
    },
    {
      "quote": "I don’t want to make garments. I want to create emotions.",
      "authorName": "Anamika Khanna",
      "authorBio":
          "Indian fashion designer renowned for blending traditional Indian textiles with modern silhouettes.",
      "authorPicUrl":
          "https://upload.wikimedia.org/wikipedia/commons/8/8e/Anamika_Khanna_2015.jpg",
    },
  ];
  @override
  void initState() {
    super.initState();

    // Rotation animation for the progress indicator
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationController.repeat();

    // Fade animation for quote transitions
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start with random quote
    _currentQuoteIndex = Random().nextInt(quotes.length);
    _fadeController.forward();

    // Set up timer for quote rotation
    _startQuoteTimer();
  }

  void _startQuoteTimer() {
    _quoteTimer = Timer.periodic(const Duration(seconds: 12), (timer) {
      _changeQuote();
    });
  }

  void _changeQuote() {
    _fadeController.reverse().then((_) {
      setState(() {
        int newIndex;
        do {
          newIndex = Random().nextInt(quotes.length);
        } while (newIndex == _currentQuoteIndex && quotes.length > 1);
        _currentQuoteIndex = newIndex;
      });
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _fadeController.dispose();
    _quoteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Custom Circular Progress Indicator
              Container(
                width: MediaQuery.of(context).size.width * 0.199,
                height: 80,
                child: Stack(
                  children: [
                    // Background circle
                    Container(
                      width: MediaQuery.of(context).size.width * 0.199,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 4,
                        ),
                      ),
                    ),
                    // Animated progress arc
                    RotationTransition(
                      turns: _rotationController,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.199,
                        height: 80,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFE91E63), // Pink color
                          ),
                          backgroundColor: Colors.transparent,
                          value: 0.25, // Shows quarter circle
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),

              // Quote section with fade animation
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 350),
                      child: Column(
                        children: [
                          // // Author profile picture
                          // Container(
                          //   width: MediaQuery.of(context).size.width * 0.199,
                          //   height: 80
                          //   decoration: BoxDecoration(
                          //     shape: BoxShape.circle,
                          //     border: Border.all(
                          //       color: Color(0xFFE91E63),
                          //       width: 3,
                          //     ),
                          //   ),
                          //   child: ClipOval(
                          //     child: Image.network(
                          //       quotes[_currentQuoteIndex]["authorPicUrl"]!,
                          //       width: MediaQuery.of(context).size.width * 0.199,
                          //       height: 80,
                          //       fit: BoxFit.cover,
                          //       errorBuilder: (context, error, stackTrace) {
                          //         return Container(
                          //           width: MediaQuery.of(context).size.width * 0.199,
                          //           height: 80,
                          //           decoration: BoxDecoration(
                          //             shape: BoxShape.circle,
                          //             color: Colors.grey.shade300,
                          //           ),
                          //           child: Icon(
                          //             Icons.person,
                          //             size: 40,
                          //             color: Colors.grey.shade600,
                          //           ),
                          //         );
                          //       },
                          //     ),
                          //   ),
                          // ),
                          // SizedBox(height: 20),

                          // Quote text
                          Text(
                            '"${quotes[_currentQuoteIndex]["quote"]}"',
                            style: GoogleFonts.libreFranklin(
                              color: Color(0xFFE91E63),
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(18),
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 15),

                          // Author name
                          Text(
                            "— ${quotes[_currentQuoteIndex]["authorName"]}",
                            style: GoogleFonts.libreFranklin(
                              color: Color(0xFFE91E63),
                              fontSize: MediaQuery.of(
                                context,
                              ).textScaler.scale(16),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),

                          // Author bio
                          // Text(
                          //   quotes[_currentQuoteIndex]["authorBio"]!,
                          //   style: GoogleFonts.libreFranklin(
                          //     color: Colors.grey.shade600,
                          //     fontSize: MediaQuery.of(
                          //       context,
                          //     ).textScaler.scale(14),
                          //     fontWeight: FontWeight.w300,
                          //     height: 1.3,
                          //   ),
                          //   textAlign: TextAlign.center,
                          //   maxLines: 3,
                          //   overflow: TextOverflow.ellipsis,
                          // ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 30),

              // // Progress dots indicator
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: List.generate(
              //     quotes.length,
              //     (index) => Container(
              //       margin: EdgeInsets.symmetric(horizontal: 4),
              //       width: 8,
              //       height: 8,
              //       decoration: BoxDecoration(
              //         shape: BoxShape.circle,
              //         color: index == _currentQuoteIndex
              //             ? Color(0xFFE91E63)
              //             : Colors.grey.shade300,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

// Alternative implementation with custom painter for more precise control
class CustomCircularProgress extends StatelessWidget {
  final Animation<double> animation;

  const CustomCircularProgress({Key? key, required this.animation})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(80, 80),
          painter: CircularProgressPainter(
            progress: 0.25,
            rotation: animation.value * 2 * 3.14159,
          ),
        );
      },
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final double rotation;

  CircularProgressPainter({required this.progress, required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = Color(0xFFE91E63)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      rotation - (3.14159 / 2), // Start from top
      2 * 3.14159 * progress, // Progress amount
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
