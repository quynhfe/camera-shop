import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/database_service.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/toast_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/confirm_dialog.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _tabs = ['All', 'Pending', 'Processing', 'Shipped', 'Delivered', 'Completed', 'Cancelled'];
  int _tabIndex = 0;
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final orders = await DatabaseService.instance.getOrdersByUser(user.id);
    await _autoAdvanceOrders(orders);
    if (mounted) setState(() => _orders = orders);
  }

  Future<void> _autoAdvanceOrders(List<Order> orders) async {
    for (final order in orders) {
      if (order.status == 'Pending' || order.status == 'Processing') {
        try {
          final created = DateTime.parse(order.createdAt);
          if (DateTime.now().difference(created).inHours >= 24) {
            await DatabaseService.instance.updateOrderStatus(order.id, 'Shipped');
            order.status = 'Shipped';
          }
        } catch (_) {}
      }
    }
  }

  List<Order> get _filteredOrders {
    if (_tabIndex == 0) return _orders;
    return _orders.where((o) => o.status == _tabs[_tabIndex]).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      color: active ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: active ? AppColors.primary : const Color(0xFFE5E7EB)),
                    ),
                    child: Center(child: Text(_tabs[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: active ? Colors.white : const Color(0xFF374151)))),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _filteredOrders.isEmpty
                ? Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.receipt_long_outlined, size: 64, color: Color(0xFF9CA3AF)),
                      const SizedBox(height: 16),
                      const Text('No orders found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                    ]),
                  )
                : RefreshIndicator(
                    onRefresh: _loadOrders,
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, AppResponsive.bottomInset(context)),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, i) => _buildOrderCard(_filteredOrders[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(order.orderId, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            _statusBadge(order.status),
          ]),
          const SizedBox(height: 6),
          Text(order.createdAt.split('T').first, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
          const SizedBox(height: 10),
          Text('${order.items.length} item(s)', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
          const SizedBox(height: 4),
          Text('Total: \$${order.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.primary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/order/${order.id}'),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), foregroundColor: AppColors.primary),
                  child: const Text('Details', style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 8),
              if (order.status == 'Pending' || order.status == 'Processing')
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final confirm = await showConfirmDialog(context, title: 'Cancel Order', message: 'Cancel order ${order.orderId}?', destructive: true);
                      if (confirm == true) {
                        await DatabaseService.instance.updateOrderStatus(order.id, 'Cancelled');
                        if (!mounted) return;
                        context.read<NotificationProvider>().loadNotifications();
                        context.read<ToastProvider>().success('Order cancelled');
                        _loadOrders();
                      }
                    },
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.red), foregroundColor: AppColors.red),
                    child: const Text('Cancel', style: TextStyle(fontSize: 13)),
                  ),
                ),
              if (order.status == 'Delivered')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await DatabaseService.instance.updateOrderStatus(order.id, 'Completed');
                      if (!mounted) return;
                      context.read<NotificationProvider>().loadNotifications();
                      context.read<ToastProvider>().success('Order confirmed');
                      _loadOrders();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    child: const Text('Received', style: TextStyle(fontSize: 13)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg, fg;
    switch (status) {
      case 'Pending': bg = const Color(0xFFFEF3C7); fg = AppColors.amber; break;
      case 'Processing': bg = const Color(0xFFEFF6FF); fg = AppColors.primary; break;
      case 'Shipped': bg = const Color(0xFFECFDF5); fg = AppColors.teal; break;
      case 'Delivered': bg = const Color(0xFFE8F5E9); fg = AppColors.success; break;
      case 'Completed': bg = const Color(0xFFE8F5E9); fg = AppColors.paymentGreen; break;
      case 'Cancelled': bg = const Color(0xFFFDE8E8); fg = AppColors.red; break;
      default: bg = const Color(0xFFF3F4F6); fg = const Color(0xFF6B7280);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

