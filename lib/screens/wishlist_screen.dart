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
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text('Wishlist (${wishlist.count})', style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: wishlist.items.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.favorite_border, size: 64, color: AppColors.inactive),
                const SizedBox(height: 16),
                const Text('Your wishlist is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.dark)),
                const SizedBox(height: 8),
                const Text('Save items you love here', style: TextStyle(color: AppColors.textMid)),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/explore'), child: const Text('Explore Products')),
              ]),
            )
          : GridView.builder(
              padding: EdgeInsets.fromLTRB(AppResponsive.hp(context), AppResponsive.hp(context), AppResponsive.hp(context), AppResponsive.bottomInset(context)),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: AppResponsive.gridColumns(context),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: AppResponsive.gridAspectRatio(context),
              ),
              itemCount: wishlist.items.length,
              itemBuilder: (context, i) => ProductCard(product: wishlist.items[i]),
            ),
    );
  }
}

