import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_service.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/toast_provider.dart';
import '../providers/wishlist_provider.dart';
import '../theme/app_theme.dart';
import '../utils/image_utils.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  String _selectedColor = 'Black';
  static const _colors = ['Black', 'Silver'];

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final p = await DatabaseService.instance.getProductById(widget.productId);
    if (mounted) setState(() => _product = p);
  }

  @override
  Widget build(BuildContext context) {
    if (_product == null) {
      return const Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    final p = _product!;
    final wishlist = context.watch<WishlistProvider>();
    final isSaved = wishlist.isSaved(p.id);
    final discountPct = p.onSale ? ((1 - p.salePrice! / p.price) * 100).round() : 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                backgroundColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.dark), onPressed: () => Navigator.pop(context)),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border, size: 20, color: isSaved ? AppColors.savedHeart : AppColors.textMid),
                        onPressed: () {
                          final auth = context.read<AuthProvider>();
                          if (!auth.isAuthenticated) { context.read<ToastProvider>().warning('Please log in'); return; }
                          context.read<WishlistProvider>().toggle(p.id);
                        },
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      SizedBox.expand(child: ImageUtils.productImage(p.imageUrl, fit: BoxFit.cover)),
                      if (p.onSale)
                        Positioned(
                          top: 100, left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(8)),
                            child: Text('-$discountPct%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(child: Text(p.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.dark, letterSpacing: -0.3))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
                          child: Text(p.brand, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.darkSecondary)),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.star, color: AppColors.yellow, size: 18),
                        const SizedBox(width: 4),
                        Text('${p.rating} (${p.reviews} reviews)', style: const TextStyle(color: AppColors.textMid, fontSize: 14)),
                        const SizedBox(width: 16),
                        const Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.inactive),
                        const SizedBox(width: 4),
                        Text('${p.stock} in stock', style: const TextStyle(color: AppColors.textMid, fontSize: 14)),
                      ]),
                      const SizedBox(height: 20),
                      const Text('Color', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Row(
                        children: _colors.map((color) {
                          final active = color == _selectedColor;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = color),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: active ? AppColors.primary : Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: active ? AppColors.primary : const Color(0xFFEED8E8), width: 1.5),
                              ),
                              child: Text(color, style: TextStyle(color: active ? Colors.white : AppColors.darkSecondary, fontWeight: FontWeight.w500)),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      const Text('Description', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(p.description, style: const TextStyle(fontSize: 14, color: AppColors.textMid, height: 1.7)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, -4))]),
              child: Row(
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('\$${p.displayPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    if (p.onSale)
                      Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, color: AppColors.inactive, decoration: TextDecoration.lineThrough)),
                  ]),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final auth = context.read<AuthProvider>();
                        if (!auth.isAuthenticated) { context.read<ToastProvider>().warning('Please log in to shop'); return; }
                        context.read<CartProvider>().addToCart(p.id);
                        context.read<ToastProvider>().success('${p.name} added to cart');
                      },
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
}
