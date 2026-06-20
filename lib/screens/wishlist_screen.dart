import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Wishlist (${wishlist.count})', style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: wishlist.items.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.favorite_border, size: 64, color: Color(0xFF9CA3AF)),
                const SizedBox(height: 16),
                const Text('Your wishlist is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
                const SizedBox(height: 8),
                const Text('Save items you love here', style: TextStyle(color: Color(0xFF6B7280))),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/explore'), child: const Text('Explore Products')),
              ]),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.67,
              ),
              itemCount: wishlist.items.length,
              itemBuilder: (context, i) => ProductCard(product: wishlist.items[i]),
            ),
    );
  }
}
