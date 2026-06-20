import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/database_service.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _stats = {'revenue': 0.0, 'orders': 0, 'products': 0, 'customers': 0};
  List<Order> _recentOrders = [];

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final stats = await DatabaseService.instance.getRevenueStats();
    final orders = await DatabaseService.instance.getAllOrders();
    if (mounted) setState(() {
      _stats = stats;
      _recentOrders = orders.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hi, ${user?.name ?? 'Admin'}!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const Text('Admin Dashboard', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ]),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart_outlined), onPressed: () => Navigator.pushNamed(context, '/admin/revenue')),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
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
                  _statCard('Total Revenue', '\$${(_stats['revenue'] as double).toStringAsFixed(0)}', Icons.attach_money, const Color(0xFF3B82F6), const Color(0xFFEFF6FF)),
                  _statCard('Total Orders', '${_stats['orders']}', Icons.shopping_bag_outlined, const Color(0xFF22C55E), const Color(0xFFE8F5E9)),
                  _statCard('Products', '${_stats['products']}', Icons.inventory_2_outlined, const Color(0xFFA855F7), const Color(0xFFF3E8FF)),
                  _statCard('Customers', '${_stats['customers']}', Icons.people_outline, const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Recent Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              const SizedBox(height: 12),
              ..._recentOrders.map((o) => _orderCard(o)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 22),
        ),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      ]),
    );
  }

  Widget _orderCard(Order o) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(o.orderId, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text('\$${o.total.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.adminPrimary, fontWeight: FontWeight.w700)),
        ])),
        _statusBadge(o.status),
      ]),
    );
  }

  Widget _statusBadge(String status) {
    Color bg, fg;
    switch (status) {
      case 'Pending': bg = const Color(0xFFFEF3C7); fg = AppColors.amber; break;
      case 'Completed': bg = const Color(0xFFE8F5E9); fg = AppColors.success; break;
      case 'Cancelled': bg = const Color(0xFFFDE8E8); fg = AppColors.red; break;
      default: bg = const Color(0xFFEFF6FF); fg = AppColors.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
