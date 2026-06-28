import 'package:flutter/material.dart';
import '../../database/database_service.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _tabs = ['All', 'Pending', 'Processing', 'Shipped', 'Delivered', 'Completed', 'Cancelled'];
  int _tabIndex = 0;
  List<Order> _orders = [];
  final _searchCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    final orders = await DatabaseService.instance.getAllOrders();
    if (mounted) setState(() => _orders = orders);
  }

  List<Order> get _filtered {
    var list = _tabIndex == 0 ? _orders : _orders.where((o) => o.status == _tabs[_tabIndex]).toList();
    final q = _searchCtrl.text.toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((o) => o.orderId.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Manage Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)), hintText: 'Search by order ID...', isDense: true),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tabs.length,
              itemBuilder: (context, i) {
                final active = i == _tabIndex;
                return GestureDetector(
                  onTap: () => setState(() => _tabIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: active ? AppColors.adminPrimary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: active ? AppColors.adminPrimary : const Color(0xFFE5E7EB)),
                    ),
                    child: Center(child: Text(_tabs[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: active ? Colors.white : const Color(0xFF374151)))),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filtered.length,
                itemBuilder: (context, i) => _orderCard(_filtered[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(Order o) {
    final statuses = ['Pending', 'Processing', 'Shipped', 'Delivered', 'Completed', 'Cancelled'];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(o.orderId, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            _statusBadge(o.status),
          ]),
          const SizedBox(height: 4),
          Text('\$${o.total.toStringAsFixed(2)} • ${o.items.length} items', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
          Text(o.createdAt.split('T').first, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/order/${o.id}'),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.adminPrimary), foregroundColor: AppColors.adminPrimary, padding: const EdgeInsets.symmetric(vertical: 8)),
                  child: const Text('View Details', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showStatusUpdate(o, statuses),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary, padding: const EdgeInsets.symmetric(vertical: 8)),
                  child: const Text('Update Status', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStatusUpdate(Order o, List<String> statuses) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Update Status — ${o.orderId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((s) => RadioListTile<String>(
            title: Text(s),
            value: s,
            groupValue: o.status,
            activeColor: AppColors.adminPrimary,
            onChanged: (v) async {
              if (v != null) {
                await DatabaseService.instance.updateOrderStatus(o.id, v);
                _load();
                if (mounted) Navigator.pop(context);
              }
            },
          )).toList(),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg, fg;
    switch (status) {
      case 'Pending': bg = const Color(0xFFFEF3C7); fg = AppColors.amber; break;
      case 'Completed': bg = const Color(0xFFE8F5E9); fg = AppColors.success; break;
      case 'Cancelled': bg = const Color(0xFFFDE8E8); fg = AppColors.red; break;
      default: bg = const Color(0xFFEFF6FF); fg = AppColors.adminPrimary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
