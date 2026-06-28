import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../database/database_service.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_card.dart';
import '../../widgets/search_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _activeCategory = 'All';
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final products = await DatabaseService.instance.getAllProducts();
    if (mounted) setState(() => _products = products);
  }

  List<String> get _categories {
    final cats = _products.map((p) => p.category).toSet().toList();
    return ['All', ...cats];
  }

  List<Product> get _saleProducts => _products.where((p) => p.onSale).toList();
  List<Product> get _displayProducts {
    if (_activeCategory == 'All') return _products;
    return _products.where((p) => p.category == _activeCategory).toList();
  }

  // Per-category accent colors
  Color _catColor(String cat) {
    const map = {
      'All': AppColors.primary,
      'Instant Cameras': AppColors.teal,
      'DSLR': AppColors.peach,
      'Mirrorless': AppColors.lavender,
      'Accessories': AppColors.yellow,
    };
    return map[cat] ?? AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final unread = context.watch<NotificationProvider>().unreadCount;
    final ratio = AppResponsive.gridAspectRatio(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: RefreshIndicator(
          onRefresh: _loadProducts,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(user?.name ?? 'there', unread)),
              SliverToBoxAdapter(child: _buildBanner()),
              if (_saleProducts.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    '🔥 Flash Sale',
                    '${_saleProducts.length} items',
                    color: AppColors.coral,
                  ),
                ),
                SliverToBoxAdapter(child: _buildFlashSale()),
              ],
              SliverToBoxAdapter(child: _buildCategories()),
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  '✨ Featured',
                  '${_displayProducts.length} products',
                  color: AppColors.primary,
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppResponsive.hp(context),
                  0,
                  AppResponsive.hp(context),
                  AppResponsive.bottomInset(context),
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: AppResponsive.gridColumns(context),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: ratio,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => ProductCard(product: _displayProducts[i]),
                    childCount: _displayProducts.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────
  Widget _buildHeader(String name, int unread) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.hero,
      ),
      child: Stack(
        children: [
          // Background decorative circles
          Positioned(top: -50, right: -30, child: _softCircle(200, AppColors.primary.withValues(alpha: 0.06))),
          Positioned(bottom: 10, left: -60, child: _softCircle(160, AppColors.peach.withValues(alpha: 0.07))),
          Positioned(top: 80, right: 60, child: _softCircle(50, AppColors.yellow.withValues(alpha: 0.15))),
          // Dot pattern top right
          Positioned(top: 50, right: 20, child: _dotPattern(3, 4, AppColors.primary.withValues(alpha: 0.12))),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: logo + icon buttons
                  Row(
                    children: [
                      // Brand logo
                      Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              gradient: AppGradients.primary,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 19),
                          ),
                          const SizedBox(width: 8),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(fontFamily: 'Roboto', fontSize: 21, fontWeight: FontWeight.w900),
                              children: [
                                TextSpan(text: 'Popi', style: TextStyle(color: AppColors.dark)),
                                TextSpan(text: '.', style: TextStyle(color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Notification bell
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _iconButton(
                            Icons.notifications_outlined,
                            () => Navigator.pushNamed(context, '/notifications'),
                          ),
                          if (unread > 0)
                            Positioned(
                              top: -2, right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                child: Text(
                                  unread > 9 ? '9+' : '$unread',
                                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      _iconButton(Icons.person_rounded, () {}),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Greeting
                  Text(
                    'Hey $name! 👋',
                    style: const TextStyle(
                      fontSize: 23, fontWeight: FontWeight.w900, color: AppColors.dark, letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'What will you capture today?',
                    style: TextStyle(fontSize: 13.5, color: AppColors.textMid, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 18),
                  // Search bar
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/explore'),
                    child: AbsorbPointer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEED8E8), width: 1.5),
                          boxShadow: [
                            BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: SearchBarWidget(
                          controller: _searchCtrl,
                          onFilterPress: () => Navigator.pushNamed(context, '/explore', arguments: {'openFilter': true}),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Icon(icon, color: AppColors.dark, size: 20),
      ),
    );
  }

  // ── Banner ─────────────────────────────────────────────────────────────
  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      height: 164,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8FA3), Color(0xFFFFB347)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8FA3).withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(top: -30, right: -20, child: _softCircle(130, Colors.white.withValues(alpha: 0.12))),
          Positioned(bottom: -40, right: 55, child: _softCircle(110, Colors.white.withValues(alpha: 0.08))),
          Positioned(top: 18, right: 10, child: _softCircle(68, Colors.white.withValues(alpha: 0.1))),
          // Dot pattern
          Positioned(bottom: 16, left: 18, child: _dotPattern(3, 5, Colors.white.withValues(alpha: 0.25))),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 14, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '✨ NEW ARRIVALS',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Polaroid Now+',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Capture every moment',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: const Text(
                          'Shop Now →',
                          style: TextStyle(color: Color(0xFFFF6B9D), fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 82, height: 82,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_enhance_rounded, color: Colors.white, size: 46),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Flash Sale ──────────────────────────────────────────────────────────
  Widget _buildFlashSale() {
    return SizedBox(
      height: 224,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _saleProducts.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ProductCard(product: _saleProducts[i], isFlashSale: true),
        ),
      ),
    );
  }

  // ── Categories ──────────────────────────────────────────────────────────
  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categories.length,
          itemBuilder: (context, i) {
            final cat = _categories[i];
            final active = cat == _activeCategory;
            final color = _catColor(cat);
            return GestureDetector(
              onTap: () => setState(() => _activeCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                decoration: BoxDecoration(
                  color: active ? color : Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: active ? color : const Color(0xFFEED8E8),
                    width: 1.5,
                  ),
                  boxShadow: active
                      ? [BoxShadow(color: color.withValues(alpha: 0.32), blurRadius: 10, offset: const Offset(0, 4))]
                      : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: active ? Colors.white : AppColors.textMid,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Section Header ──────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, String subtitle, {required Color color}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.dark, letterSpacing: -0.3),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  Widget _softCircle(double size, Color color) => Container(
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
              width: 3.5, height: 3.5,
              margin: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }
}
