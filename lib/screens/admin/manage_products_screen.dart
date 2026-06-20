import 'package:flutter/material.dart';
import '../../database/database_service.dart';
import '../../models/product.dart';
import '../../theme/app_theme.dart';
import '../../utils/image_utils.dart';
import '../../widgets/confirm_dialog.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  List<Product> _products = [];
  final _searchCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    final products = await DatabaseService.instance.getAllProducts();
    if (mounted) setState(() => _products = products);
  }

  List<Product> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _products;
    return _products.where((p) => p.name.toLowerCase().contains(q) || p.brand.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Manage Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async { await Navigator.pushNamed(context, '/admin/product/new'); _load(); },
        backgroundColor: AppColors.adminPrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)), hintText: 'Search products...', isDense: true),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                itemCount: _filtered.length,
                itemBuilder: (context, i) => _productCard(_filtered[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(Product p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(width: 64, height: 64, child: ImageUtils.productImage(p.imageUrl, fit: BoxFit.cover)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(p.brand, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
            const SizedBox(height: 4),
            Row(children: [
              Text('\$${p.displayPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.adminPrimary, fontSize: 14)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(6)),
                child: Text('Stock: ${p.stock}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              ),
            ]),
          ])),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.adminPrimary, size: 20),
                onPressed: () async { await Navigator.pushNamed(context, '/admin/product/${p.id}'); _load(); },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.red, size: 20),
                onPressed: () async {
                  final confirm = await showConfirmDialog(context, title: 'Delete Product', message: 'Delete "${p.name}"?', destructive: true);
                  if (confirm == true) {
                    await DatabaseService.instance.deleteProduct(p.id);
                    _load();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
