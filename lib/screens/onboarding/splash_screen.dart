import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _opacityCtrl;
  late final AnimationController _progressCtrl;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _opacityCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _opacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _opacityCtrl, curve: Curves.easeOut));
    _scale = Tween(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _opacityCtrl, curve: Curves.easeOut));

    _opacityCtrl.forward();
    _progressCtrl.forward();

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  void dispose() {
    _opacityCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF6B9D), Color(0xFFFF9A5C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background circles
            Positioned(top: -80, right: -60, child: _blurCircle(300, Colors.white.withValues(alpha: 0.08))),
            Positioned(bottom: -100, left: -80, child: _blurCircle(350, Colors.white.withValues(alpha: 0.06))),
            Positioned(top: 120, left: 30, child: _blurCircle(80, Colors.white.withValues(alpha: 0.1))),
            Positioned(bottom: 200, right: 40, child: _blurCircle(60, Colors.white.withValues(alpha: 0.12))),
            // Dot patterns
            Positioned(top: 80, right: 40, child: _dotPattern(4, 4, Colors.white.withValues(alpha: 0.15))),
            Positioned(bottom: 100, left: 30, child: _dotPattern(3, 3, Colors.white.withValues(alpha: 0.12))),
            // Main content
            Center(
              child: FadeTransition(
                opacity: _opacity,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Camera icon in white circle
                      Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 58),
                      ),
                      const SizedBox(height: 28),
                      // Brand name
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontFamily: 'Roboto', fontSize: 36, fontWeight: FontWeight.w900),
                          children: [
                            TextSpan(text: 'Popi', style: TextStyle(color: Colors.white)),
                            TextSpan(text: 'Di', style: TextStyle(color: Color(0xFFFFF0A0))),
                            TextSpan(text: 'gi', style: TextStyle(color: Color(0xFFFFE0CC))),
                            TextSpan(text: 'cam', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your Camera Shop ✨',
                        style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 52),
                      // Progress bar
                      SizedBox(
                        width: 200,
                        child: AnimatedBuilder(
                          animation: _progressCtrl,
                          builder: (context, _) => ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: _progressCtrl.value,
                              backgroundColor: Colors.white30,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blurCircle(double size, Color color) => Container(
        width: size, height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _dotPattern(int rows, int cols, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        rows,
        (_) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            cols,
            (_) => Container(
              width: 4, height: 4,
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }
}
