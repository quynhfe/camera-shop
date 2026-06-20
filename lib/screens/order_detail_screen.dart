import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_service.dart';
import '../models/order.dart';
import '../providers/toast_provider.dart';
import '../theme/app_theme.dart';
import '../utils/image_utils.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;

  static const _statusSteps = ['Order Placed', 'Processing', 'Shipped', 'Delivered', 'Completed'];
  static const _statusMap = {'Pending': 0, 'Processing': 1, 'Shipped': 2, 'Delivered': 3, 'Completed': 4};

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final order = await DatabaseService.instance.getOrderById(widget.orderId);
    if (mounted) setState(() => _order = order);
  }

  @override
  Widget build(BuildContext context) {
    if (_order == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final o = _order!;
    final stepIndex = _statusMap[o.status] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(o.orderId, style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statusCard(o, stepIndex),
            const SizedBox(height: 16),
            _infoCard('Items', Column(
              children: o.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(width: 56, height: 56, child: ImageUtils.productImage(item.productImage, fit: BoxFit.cover)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.productName ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text('Qty: ${item.quantity}', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                  ])),
                  Text('\$${(item.price * item.quantity).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                ]),
              )).toList(),
            )),
            const SizedBox(height: 12),
            _infoCard('Delivery Info', Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow(Icons.location_on_outlined, 'Address', o.address),
                const SizedBox(height: 8),
                _detailRow(Icons.credit_card_outlined, 'Payment', o.paymentMethod),
                const SizedBox(height: 8),
                _detailRow(Icons.calendar_today_outlined, 'Date', o.createdAt.split('T').first),
              ],
            )),
            const SizedBox(height: 12),
            _infoCard('Order Summary', Column(children: [
              _summaryRow('Subtotal', '\$${o.subtotal.toStringAsFixed(2)}'),
              const SizedBox(height: 4),
              _summaryRow('Shipping', '\$${o.shipping.toStringAsFixed(2)}'),
              const SizedBox(height: 4),
              _summaryRow('Tax', '\$${o.tax.toStringAsFixed(2)}'),
              const Divider(height: 16),
              _summaryRow('Total', '\$${o.total.toStringAsFixed(2)}', bold: true),
            ])),
            if (o.status == 'Delivered') ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await DatabaseService.instance.updateOrderStatus(o.id, 'Completed');
                    context.read<ToastProvider>().success('Order confirmed received');
                    _loadOrder();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                  child: const Text('Confirm Received', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(Order o, int stepIndex) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Order Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            _statusBadge(o.status),
          ]),
          const SizedBox(height: 20),
          if (o.status != 'Cancelled')
            Row(
              children: List.generate(_statusSteps.length * 2 - 1, (i) {
                if (i.isOdd) {
                  final lineActive = stepIndex > i ~/ 2;
                  return Expanded(child: Container(height: 3, color: lineActive ? AppColors.primary : const Color(0xFFE5E7EB)));
                }
                final idx = i ~/ 2;
                final done = stepIndex >= idx;
                return Column(children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: done ? AppColors.primary : const Color(0xFFE5E7EB),
                      shape: BoxShape.circle,
                    ),
                    child: done ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 56,
                    child: Text(_statusSteps[idx], textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: done ? AppColors.primary : const Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
                  ),
                ]);
              }),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFDE8E8), borderRadius: BorderRadius.circular(8)),
              child: const Row(children: [
                Icon(Icons.cancel_outlined, color: AppColors.red, size: 18),
                SizedBox(width: 8),
                Text('Order Cancelled', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w600)),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF111827))),
        const SizedBox(height: 12),
        content,
      ]),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 16, color: AppColors.primary),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ])),
    ]);
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 13, color: bold ? const Color(0xFF111827) : const Color(0xFF6B7280))),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
    ]);
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
