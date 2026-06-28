import 'package:flutter/material.dart';
import '../../database/database_service.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  Map<String, dynamic> _stats = {'revenue': 0.0, 'orders': 0, 'products': 0, 'customers': 0};
  List<Order> _recentOrders = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final stats = await DatabaseService.instance.getRevenueStats();
    final orders = await DatabaseService.instance.getAllOrders();
    if (mounted) setState(() {
      _stats = stats;
      _recentOrders = orders.take(10).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Revenue', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _statCard('Total Revenue', '\$${(_stats['revenue'] as double).toStringAsFixed(2)}', Icons.attach_money, AppColors.adminPrimary, const Color(0xFFEFF6FF)),
                  _statCard('Total Orders', '${_stats['orders']}', Icons.shopping_bag_outlined, AppColors.success, const Color(0xFFE8F5E9)),
                  _statCard('Products', '${_stats['products']}', Icons.inventory_2_outlined, AppColors.purple, const Color(0xFFF3E8FF)),
                  _statCard('Customers', '${_stats['customers']}', Icons.people_outline, AppColors.amber, const Color(0xFFFEF3C7)),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              const SizedBox(height: 12),
              ..._recentOrders.map((o) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppColors.adminPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.receipt_long_outlined, color: AppColors.adminPrimary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(o.orderId, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(o.createdAt.split('T').first, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                  ])),
                  Text('\$${o.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.adminPrimary)),
                ]),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 22),
        ),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      ]),
    );
  }
}
