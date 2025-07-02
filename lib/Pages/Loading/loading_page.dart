import 'dart:math';

import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<String> quotes = [
    "Twirl into 2025 with a flared skirt & cinched waist! 🥻💫 Polka dots scream 50s diner diva.",
    "Audrey’s elegance lives on! 😎 Pearl studs + cat-eye liner for that iconic 50s glow-up.",
    "Pastel dresses are *it*! 🌸 Pair with ballet flats for a 50s vibe that slays today.",
    "Red lips, winged eyeliner 💋. Keep skin fresh & dewy for that modern 50s Insta look.",
    "Poodle skirts are poppin’! 🐩 Style with chunky sneakers for a Gen Z 50s remix.",
    "Leather jackets = Grease vibes ⚡. Tuck in a white tee & add high-waisted jeans for edge.",
    "Silk scarves are everything! 🧣 Knot one in your hair for that 50s starlet charm.",
    "Capri pants are back, babes! 👖 Bright colors + a fitted blouse = retro vacation slay.",
    "Saddle shoes for the win! 👟 Rock with ankle socks & a midi skirt for 50s TikTok vibes.",
    "Oversized bows = big 50s energy 🎀. Pop one in your ponytail for that vintage flex.",
    "Cardigans are cute & chic! 🧥 Button-up over a sundress for that 50s sweetheart look.",
    "High-waisted shorts are fire 🔥. Pair with a tucked-in blouse for 50s summer vibes.",
    "Floral headbands are trending! 🌼 Add to a low bun for that 50s garden-party glow.",
    "Swing dresses with petticoats? Yes, please! 💃 Layer with a denim jacket for 2025 cool.",
    "Classic pumps in bold colors 👠. Match with a pencil skirt for 50s office chic.",
    "Polka dot blouses are forever! 🟠 Tuck into high-waisted trousers for retro realness.",
    "Cat-eye glasses = instant 50s glam 😻. Pair with a sleek updo for maximum slay.",
    "Pleated skirts are a mood! 🩰 Add a fitted sweater for that 50s co-ed aesthetic.",
    "Bold lipstick shades are key 💄. Coral or cherry red for that 50s Hollywood vibe.",
    "T-strap heels are back! 👡 Style with a fit-and-flare dress for 50s-inspired elegance.",
    "Chiffon scarves for the win! 🧵 Tie around your neck for that 50s movie-star energy.",
    "Cropped jackets are *chef’s kiss* 🧶. Layer over a sundress for a 50s-modern mashup.",
    "Peter Pan collars are adorable! 👗 Add to a dress or blouse for 50s dainty vibes.",
    "Midi skirts with cinched belts 🎀. Pair with a crisp white shirt for retro perfection.",
    "Retro swimsuits are hot! 🏖️ High-waisted bikinis channel 50s pin-up realness.",
    "Statement brooches are back! 📌 Pin on a cardigan for that 50s vintage sparkle.",
    "Flared jeans with a fitted top 👖. Add a scarf for that 50s rockabilly edge.",
    "Wingtip shoes for a bold look! 👞 Pair with cuffed trousers for 50s-inspired swagger.",
    "Circle skirts with bold prints 🌈. Spin into 2025 with a modern 50s twirl.",
    "Gloves are serving elegance! 🧤 Short white gloves for that 50s tea-party vibe.",
    "Belted dresses are timeless! 🎗️ Cinch at the waist for that 50s hourglass silhouette.",
    "Retro sunglasses are a must 😎. Oversized frames for that 50s Hollywood diva look.",
    "Polka dot scarves are iconic! 🟡 Tie one on your bag for a 50s-inspired pop.",
    "Fit-and-flare dresses = romance 💕. Add a cardigan for that 50s sweetheart style.",
    "Chunky knit sweaters are cozy! 🧶 Pair with a skirt for 50s campus queen vibes.",
    "High ponytails with scrunchies 🦋. Channel 50s cheerleader energy with a modern twist.",
    "A-line dresses are always in! 👗 Go for bold colors to nail that 50s aesthetic.",
    "Berets are chic AF! 🧢 Tilt one to the side for that 50s Parisian-inspired look.",
    "Pencil dresses for the win! 🖤 Hug those curves for 50s bombshell energy.",
    "Retro handbags are everything! 👜 Structured purses for that 50s ladylike slay.",
    "Rock that retro vibe with high-waisted skirts & cinched waists! 🥻✨ Pair with bold polka dots for that 50s diner chic.",
    "Channel Audrey Hepburn with a sleek updo & cat-eye sunglasses 😎. Add a pearl choker for timeless glam!",
    "Swing into 2025 with full-circle dresses 🌸. Floral prints + pastel hues = modern 50s slay!",
    "Bold red lips 💋 & winged eyeliner are *the* 50s comeback. Keep it fresh with dewy skin for that Insta glow.",
    "Poodle skirts are back, babes! 🐩 Style with chunky sneakers for a Gen Z twist on 50s swagger.",
    "Grab a leather jacket for that Grease lightning vibe ⚡. Pair with slim-fit jeans for a 50s rebel refresh.",
    "Scarves are your BFF! 🧣 Tie one around your neck or hair for that 50s starlet sparkle.",
    "Capri pants are poppin’! 👖 Go for bright colors & tuck in a fitted blouse for that 50s vacay mood.",
    "Saddle shoes are serving looks! 👟 Mix with ankle socks & a pleated skirt for a 50s-inspired TikTok moment.",
    "Big bows, bigger energy 🎀. Add oversized hair bows to elevate your 50s-inspired ponytail.",
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
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
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    // Background circle
                    Container(
                      width: 80,
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
                      turns: _controller,
                      child: Container(
                        width: 80,
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
              SizedBox(height: 40),
              // Fashion tips/ Quotes text
              Center(
                child: Text(
                  quotes[Random().nextInt(quotes.length)],
                  style: TextStyle(
                    color: Color(
                      0xFFE91E63,
                    ), // Pink color matching the progress
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
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
