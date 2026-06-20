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
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          Positioned(top: -80, right: -60, child: _blurCircle(300, Colors.white.withOpacity(0.07))),
          Positioned(bottom: -100, left: -80, child: _blurCircle(350, Colors.white.withOpacity(0.05))),
          Center(
            child: FadeTransition(
              opacity: _opacity,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120, height: 120,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: AppColors.primary, size: 60),
                    ),
                    const SizedBox(height: 24),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                        children: [
                          TextSpan(text: 'Popi', style: TextStyle(color: Colors.white)),
                          TextSpan(text: 'Di', style: TextStyle(color: AppColors.coral)),
                          TextSpan(text: 'gi', style: TextStyle(color: AppColors.yellow)),
                          TextSpan(text: 'cam', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Your Camera Shop', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: 200,
                      child: AnimatedBuilder(
                        animation: _progressCtrl,
                        builder: (context, _) => ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _progressCtrl.value,
                            backgroundColor: Colors.white30,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.coral),
                            minHeight: 6,
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
    );
  }

  Widget _blurCircle(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
