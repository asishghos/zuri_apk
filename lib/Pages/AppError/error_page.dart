import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorPage extends StatefulWidget {
  final String? errorTxt;
  const ErrorPage({Key? key, this.errorTxt}) : super(key: key);

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExpanded = false;
  final String _errorCode = "ERR-${math.Random().nextInt(9000) + 1000}";

  // Sample technical details for demonstration
  final String _technicalDetails = """
{• Connection timeout after 30 seconds
• Failed to connect to api.example.com
• Network request failed with status code 503
• Service unavailable - try again later}
  """;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDarkMode ? Colors.blueAccent : Colors.blue;
    final Color backgroundColor = isDarkMode
        ? const Color(0xFF121212)
        : Colors.white;
    final Color errorColor = isDarkMode ? Colors.redAccent : Colors.red;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated Error Icon
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animationController.value * 0.05 * math.pi,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 150,
                        height: 150,
                        child: CustomPaint(
                          painter: ErrorIconPainter(
                            color: errorColor,
                            animationValue: _animationController.value,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.04576659,
                ),

                // Error Code
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: errorColor,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Text(
                    _errorCode,
                    style: GoogleFonts.libreFranklin(
                      color: errorColor,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).textScaler.scale(16),
                    ),
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.0274599,
                ),

                // Error Title
                Text(
                  'Oops! Something went wrong',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(28),
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.018306636,
                ),

                // Error Message
                Text(
                  widget.errorTxt ?? 'An unexpected error occurred.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.libreFranklin(
                    fontSize: MediaQuery.of(context).textScaler.scale(16),
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.04576659,
                ),

                // Action Buttons
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // In a real app, you would implement retry logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Retrying...'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        minimumSize: const Size(250, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Try Again',
                        style: GoogleFonts.libreFranklin(
                          fontSize: MediaQuery.of(context).textScaler.scale(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.018306636,
                    ),

                    OutlinedButton(
                      onPressed: () {
                        context.goNamed("home");
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(250, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: primaryColor),
                      ),
                      child: Text(
                        'Go Back',
                        style: GoogleFonts.libreFranklin(
                          fontSize: MediaQuery.of(context).textScaler.scale(16),
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.0274599,
                    ),

                    // Technical Details Expansion
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Technical Details',
                            style: GoogleFonts.libreFranklin(
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          AnimatedRotation(
                            turns: _isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        height: _isExpanded ? null : 0,
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width *
                                      0.02487562,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: errorColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Error Details',
                                  style: GoogleFonts.libreFranklin(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.color,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height *
                                  0.013729977,
                            ),
                            Text(
                              _technicalDetails,
                              style: GoogleFonts.libreFranklin(
                                fontSize: MediaQuery.of(
                                  context,
                                ).textScaler.scale(14),
                                height: 1.5,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height *
                                  0.018306636,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // In a real app, this would copy the error details
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Error details copied to clipboard',
                                        ),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).cardColor,
                                    foregroundColor: primaryColor,
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.copy, size: 16),
                                  label: const Text('Copy'),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // In a real app, this would report the error
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Sending error report...',
                                        ),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: primaryColor,
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.send, size: 16),
                                  label: const Text('Report'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorIconPainter extends CustomPainter {
  final Color color;
  final double animationValue;

  ErrorIconPainter({required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        (size.width / 2) * (0.95 + 0.05 * math.sin(animationValue * math.pi));

    // Draw circle
    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, paint);

    // Draw exclamation mark
    final double exclamationHeight = size.height * 0.4;
    final double dotRadius = size.width * 0.05;
    final double lineStartY = center.dy - exclamationHeight / 2 + dotRadius;
    final double lineEndY = center.dy + exclamationHeight / 2 - dotRadius * 3;

    // Draw line
    canvas.drawLine(
      Offset(center.dx, lineStartY),
      Offset(center.dx, lineEndY),
      paint..strokeWidth = 10.0,
    );

    // Draw dot
    canvas.drawCircle(
      Offset(center.dx, center.dy + exclamationHeight / 2 - dotRadius),
      dotRadius,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(ErrorIconPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.color != color;
}

// Example of how to show the error page in a real app context
class ErrorPageExample extends StatelessWidget {
  const ErrorPageExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Error Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => const ErrorPage()));
          },
          child: const Text('Simulate Error'),
        ),
      ),
    );
  }
}
