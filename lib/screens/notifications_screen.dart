import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _notifications = [
    {'title': 'Order Shipped!', 'body': 'Your order ORD-0001 has been shipped.', 'time': '2h ago', 'type': 'order'},
    {'title': 'Flash Sale!', 'body': 'Up to 40% off on selected cameras today only!', 'time': '5h ago', 'type': 'promo'},
    {'title': 'New Arrivals', 'body': 'Check out the latest Fujifilm cameras in our store.', 'time': '1d ago', 'type': 'promo'},
    {'title': 'Order Delivered', 'body': 'Your order ORD-0002 has been delivered.', 'time': '2d ago', 'type': 'order'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final n = _notifications[i];
          final isOrder = n['type'] == 'order';
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: isOrder ? AppColors.primary.withOpacity(0.1) : AppColors.coral.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(isOrder ? Icons.receipt_long_outlined : Icons.local_offer_outlined, color: isOrder ? AppColors.primary : AppColors.coral, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(n['title']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 3),
                    Text(n['body']!, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(n['time']!, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
