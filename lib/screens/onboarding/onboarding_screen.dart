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
      icon: Icons.camera_alt_outlined,
    ),
    _SlideData(
      title: 'Shop With Ease',
      subtitle: 'Fast checkout, secure payments, and exclusive deals just for you.',
      color: AppColors.coral,
      icon: Icons.shopping_bag_outlined,
    ),
    _SlideData(
      title: 'Track Your Orders',
      subtitle: 'Real-time order tracking from purchase to your doorstep.',
      color: AppColors.teal,
      icon: Icons.local_shipping_outlined,
    ),
  ];

  void _next() {
    if (_currentSlide < _slides.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentSlide = i),
            itemCount: _slides.length,
            itemBuilder: (context, i) => _buildSlide(_slides[i]),
          ),
          Positioned(
            bottom: 60, left: 0, right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (i) {
                    final isActive = i == _currentSlide;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? _slides[_currentSlide].color : const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      if (_currentSlide > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: _slides[_currentSlide].color),
                              foregroundColor: _slides[_currentSlide].color,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      if (_currentSlide > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _slides[_currentSlide].color,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            _currentSlide == _slides.length - 1 ? 'Get Started' : 'Next',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: Text('Skip', style: TextStyle(color: const Color(0xFF6B7280), fontSize: 14)),
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
            width: 200, height: 200,
            decoration: BoxDecoration(color: slide.color.withOpacity(0.1), shape: BoxShape.circle),
            child: Center(
              child: Image.asset('assets/images/logo.png', width: 140, height: 140, errorBuilder: (_, __, ___) => Icon(slide.icon, size: 80, color: slide.color)),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Text(slide.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                const SizedBox(height: 16),
                Text(slide.subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280), height: 1.6)),
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
  final IconData icon;
  const _SlideData({required this.title, required this.subtitle, required this.color, required this.icon});
}
