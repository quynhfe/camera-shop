import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/toast_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/image_utils.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final double? width;
  final bool isFlashSale;
  final bool isWishlistScreen;
  final VoidCallback? onRemoveRequest;

  const ProductCard({
    super.key,
    required this.product,
    this.width,
    this.isFlashSale = false,
    this.isWishlistScreen = false,
    this.onRemoveRequest,
  });

  @override
  Widget build(BuildContext context) {
    if (isFlashSale) return _buildFlashSaleCard(context);
    return _buildNormalCard(context);
  }

  Widget _buildNormalCard(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final isSaved = wishlist.isSaved(product.id);
    final discountPct = product.onSale ? ((1 - product.salePrice! / product.price) * 100).round() : 0;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/product/${product.id}'),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ImageUtils.productImage(product.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                if (product.onSale)
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(6)),
                      child: Text('-$discountPct%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ),
                Positioned(
                  top: 6, right: 6,
                  child: GestureDetector(
                    onTap: () => _toggleWishlist(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]),
                      child: Icon(isSaved ? Icons.favorite : Icons.favorite_border, size: 16, color: isSaved ? AppColors.savedHeart : AppColors.inactive),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: AppColors.yellow),
                      const SizedBox(width: 2),
                      Text(product.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                      const SizedBox(width: 4),
                      Text('(${product.reviews})', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('\$${product.displayPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          if (product.onSale)
                            Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: AppColors.inactive, decoration: TextDecoration.lineThrough)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _addToCart(context),
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.add, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashSaleCard(BuildContext context) {
    final discountPct = product.onSale ? ((1 - product.salePrice! / product.price) * 100).round() : 0;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/product/${product.id}'),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: ImageUtils.productImage(product.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                if (product.onSale)
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(6)),
                      child: Text('-$discountPct%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('\$${product.displayPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.coral)),
                  Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: AppColors.inactive, decoration: TextDecoration.lineThrough)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleWishlist(BuildContext context) {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      context.read<ToastProvider>().warning('Please log in to save items');
      return;
    }
    context.read<WishlistProvider>().toggle(product.id);
  }

  void _addToCart(BuildContext context) {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      context.read<ToastProvider>().warning('Please log in to shop');
      return;
    }
    context.read<CartProvider>().addToCart(product.id);
    context.read<ToastProvider>().success('${product.name} added to cart');
  }
}
