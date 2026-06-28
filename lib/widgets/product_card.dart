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
    final discountPct = product.onSale
        ? ((1 - product.salePrice! / product.price) * 100).round()
        : 0;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/product/${product.id}'),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ────────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    color: AppColors.surface,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ImageUtils.productImage(product.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                ),
                // Sale badge
                if (product.onSale)
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppGradients.sale,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.coral.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '-$discountPct%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                // Wishlist heart
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleWishlist(context),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 15,
                        color: isSaved ? AppColors.savedHeart : AppColors.inactive,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // ── Info ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppColors.dark, height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(children: [
                    const Icon(Icons.star_rounded, size: 13, color: AppColors.yellow),
                    const SizedBox(width: 3),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${product.reviews})',
                      style: const TextStyle(fontSize: 10, color: AppColors.inactive),
                    ),
                  ]),
                  const SizedBox(height: 9),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${product.displayPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primary,
                            ),
                          ),
                          if (product.onSale)
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 11, color: AppColors.inactive,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _addToCart(context),
                        child: Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            gradient: AppGradients.primary,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.38),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
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
    final discountPct = product.onSale
        ? ((1 - product.salePrice! / product.price) * 100).round()
        : 0;
    final screenW = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenW * 0.4).clamp(150.0, 220.0);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/product/${product.id}'),
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 14, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Container(
                    color: AppColors.surface,
                    height: 124,
                    width: double.infinity,
                    child: ImageUtils.productImage(product.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                if (product.onSale)
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: AppGradients.sale,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-$discountPct%',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.dark, height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '\$${product.displayPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary),
                  ),
                  if (product.onSale)
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 11, color: AppColors.inactive,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
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
