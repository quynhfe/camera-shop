import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentSlide = 0;
  final _pageController = PageController();

  static const _slides = [
    _SlideData(
      title: 'Discover Amazing Cameras',
      subtitle: 'Explore our curated collection of digital cameras from top brands worldwide.',
      color: AppColors.primary,
      bgColor: AppColors.primaryXLight,
      icon: Icons.camera_alt_outlined,
      emoji: '📸',
    ),
    _SlideData(
      title: 'Shop With Ease',
      subtitle: 'Fast checkout, secure payments, and exclusive deals just for you.',
      color: AppColors.peach,
      bgColor: Color(0xFFFFF5EE),
      icon: Icons.shopping_bag_outlined,
      emoji: '🛍️',
    ),
    _SlideData(
      title: 'Track Your Orders',
      subtitle: 'Real-time order tracking from purchase to your doorstep.',
      color: AppColors.teal,
      bgColor: Color(0xFFEFFFFE),
      icon: Icons.local_shipping_outlined,
      emoji: '🚀',
    ),
  ];

  void _next() {
    if (_currentSlide < _slides.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentSlide = i),
            itemCount: _slides.length,
            itemBuilder: (context, i) => _buildSlide(_slides[i]),
          ),
          Positioned(
            bottom: 56, left: 0, right: 0,
            child: Column(
              children: [
                // Dot indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (i) {
                    final isActive = i == _currentSlide;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? _slides[_currentSlide].color : AppColors.inactive,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      if (_currentSlide > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: _slides[_currentSlide].color, width: 1.5),
                              foregroundColor: _slides[_currentSlide].color,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      if (_currentSlide > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_slides[_currentSlide].color, _slides[_currentSlide].color.withValues(alpha: 0.75)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _slides[_currentSlide].color.withValues(alpha: 0.4),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(
                              _currentSlide == _slides.length - 1 ? 'Get Started ✨' : 'Next →',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(color: AppColors.textMid, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(_SlideData slide) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 210, height: 210,
            decoration: BoxDecoration(color: slide.bgColor, shape: BoxShape.circle),
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 140,
                height: 140,
                errorBuilder: (_, __, ___) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(slide.emoji, style: const TextStyle(fontSize: 56)),
                    const SizedBox(height: 4),
                    Icon(slide.icon, size: 40, color: slide.color),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 42),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.dark, letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  slide.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15.5, color: AppColors.textMid, height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideData {
  final String title;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final IconData icon;
  final String emoji;
  const _SlideData({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.icon,
    required this.emoji,
  });
}
