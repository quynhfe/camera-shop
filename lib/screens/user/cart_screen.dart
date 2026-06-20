import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/image_utils.dart';
import '../../widgets/confirm_dialog.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    const shipping = 10.0;
    final total = cart.subtotal + shipping;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Cart (${cart.totalItems})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.shopping_cart_outlined, size: 80, color: Color(0xFF9CA3AF)),
                const SizedBox(height: 16),
                const Text('Your cart is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
                const SizedBox(height: 8),
                const Text('Add some cameras to get started', style: TextStyle(color: Color(0xFF6B7280))),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/explore'),
                  child: const Text('Explore Products'),
                ),
              ]),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, i) {
                      final item = cart.items[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(width: 80, height: 80, child: ImageUtils.productImage(item.product?.imageUrl, fit: BoxFit.cover)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product?.name ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text('\$${item.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _qtyButton(Icons.remove, () async {
                                        if (item.quantity == 1) {
                                          final confirm = await showConfirmDialog(context, title: 'Remove item', message: 'Remove ${item.product?.name} from cart?', destructive: true);
                                          if (confirm == true) cart.removeFromCart(item.productId);
                                        } else {
                                          cart.updateQuantity(item.productId, item.quantity - 1);
                                        }
                                      }),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                      ),
                                      _qtyButton(Icons.add, () => cart.updateQuantity(item.productId, item.quantity + 1)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.red),
                                  onPressed: () async {
                                    final confirm = await showConfirmDialog(context, title: 'Remove item', message: 'Remove from cart?', destructive: true);
                                    if (confirm == true) cart.removeFromCart(item.productId);
                                  },
                                ),
                                Text('\$${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, -4))]),
                  child: Column(
                    children: [
                      _summaryRow('Subtotal', '\$${cart.subtotal.toStringAsFixed(2)}'),
                      const SizedBox(height: 6),
                      _summaryRow('Shipping', '\$${shipping.toStringAsFixed(2)}'),
                      const Divider(height: 20),
                      _summaryRow('Total', '\$${total.toStringAsFixed(2)}', bold: true),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/checkout'),
                          child: Text('Checkout • \$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: bold ? const Color(0xFF111827) : const Color(0xFF6B7280), fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: bold ? AppColors.primary : const Color(0xFF111827))),
      ],
    );
  }
}
