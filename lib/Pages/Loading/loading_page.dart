import 'dart:async';
import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  late AnimationController _waveController;

  int _timeLeft = 90;
  Timer? _timer;
  Timer? _animationTimer;

  int _currentAnimationIndex = 0;
  final List<String> _animationTypes = [
    'Rotating Dots',
    'Bouncing Balls',
    'Pulsing Circle',
    'Wave',
  ];

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animationTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!mounted) return;
      setState(() {
        _currentAnimationIndex =
            (_currentAnimationIndex + 1) % _animationTypes.length;
      });
    });

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          _timeLeft = 105;
          _startTimer();
        }
      });
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _bounceController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _timer?.cancel();
    _animationTimer?.cancel();
    super.dispose();
  }

  final Color _primaryTextColor = const Color(0xFF333333);
  final Color _primaryAccentColor = const Color(0xFF3D5AFE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF1F1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Loading your experience',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _primaryTextColor,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 200,
              width: 200,
              child: _buildPulsingCircleAnimation(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulsingCircleAnimation() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(4, (index) {
            double delayedValue = (_pulseController.value + index * 0.2) % 1.0;
            return Container(
              width: 120 * delayedValue,
              height: 120 * delayedValue,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _primaryAccentColor.withOpacity(1 - delayedValue),
                  width: 4,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
