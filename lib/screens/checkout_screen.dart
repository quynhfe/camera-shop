import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_service.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/toast_provider.dart';
import '../theme/app_theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<Address> _addresses = [];
  List<PaymentMethod> _paymentMethods = [];
  Address? _selectedAddress;
  PaymentMethod? _selectedPayment;
  bool _isPlacing = false;

  static const _tax = 0.08;
  static const _shipping = 10.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final addresses = await DatabaseService.instance.getAddressesByUser(user.id);
    final payments = await DatabaseService.instance.getPaymentMethodsByUser(user.id);
    if (mounted) {
      setState(() {
        _addresses = addresses;
        _paymentMethods = payments;
        _selectedAddress = addresses.isNotEmpty ? (addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first)) : null;
        _selectedPayment = payments.isNotEmpty ? (payments.firstWhere((p) => p.isDefault, orElse: () => payments.first)) : null;
      });
    }
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) { context.read<ToastProvider>().error('Please select a shipping address'); return; }
    if (_selectedPayment == null) { context.read<ToastProvider>().error('Please select a payment method'); return; }
    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) return;
    final user = context.read<AuthProvider>().user!;
    setState(() => _isPlacing = true);

    final subtotal = cart.subtotal;
    final taxAmount = subtotal * _tax;
    final total = subtotal + _shipping + taxAmount;

    try {
      await DatabaseService.instance.createOrder(
        userId: user.id,
        subtotal: subtotal,
        shipping: _shipping,
        tax: taxAmount,
        total: total,
        address: '${_selectedAddress!.label}: ${_selectedAddress!.detail}',
        paymentMethod: '${_selectedPayment!.label}: ${_selectedPayment!.detail}',
        items: cart.items.map((item) => {'product_id': item.productId, 'quantity': item.quantity, 'price': item.price}).toList(),
      );
      await cart.clearCart();
      if (mounted) {
        context.read<ToastProvider>().success('Order placed successfully!');
        Navigator.pushReplacementNamed(context, '/order-success');
      }
    } catch (e) {
      if (mounted) context.read<ToastProvider>().error('Failed to place order');
    }
    if (mounted) setState(() => _isPlacing = false);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final subtotal = cart.subtotal;
    final taxAmount = subtotal * _tax;
    final total = subtotal + _shipping + taxAmount;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Shipping Address'),
            const SizedBox(height: 8),
            if (_addresses.isEmpty)
              _emptyCard('No addresses saved', Icons.location_on_outlined, () async {
                await _showAddAddress();
                _loadData();
              })
            else
              for (final a in _addresses) _addressCard(a),
            TextButton.icon(
              onPressed: () async { await _showAddAddress(); _loadData(); },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Address'),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Payment Method'),
            const SizedBox(height: 8),
            if (_paymentMethods.isEmpty)
              _emptyCard('No payment methods saved', Icons.credit_card_outlined, () async {
                await _showAddPayment();
                _loadData();
              })
            else
              for (final p in _paymentMethods) _paymentCard(p),
            TextButton.icon(
              onPressed: () async { await _showAddPayment(); _loadData(); },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Payment Method'),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Order Summary'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
              child: Column(children: [
                ...cart.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Text('${item.product?.name ?? ''} ×${item.quantity}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
                    Text('\$${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ]),
                )),
                const Divider(height: 20),
                _row('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
                const SizedBox(height: 4),
                _row('Shipping', '\$${_shipping.toStringAsFixed(2)}'),
                const SizedBox(height: 4),
                _row('Tax (8%)', '\$${taxAmount.toStringAsFixed(2)}'),
                const Divider(height: 16),
                _row('Total', '\$${total.toStringAsFixed(2)}', bold: true),
              ]),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, -4))]),
        child: ElevatedButton(
          onPressed: _isPlacing ? null : _placeOrder,
          child: _isPlacing
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('Place Order • \$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827)));

  Widget _addressCard(Address a) {
    final selected = _selectedAddress?.id == a.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedAddress = a),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.primary : const Color(0xFFE5E7EB), width: selected ? 2 : 1),
        ),
        child: Row(children: [
          Icon(Icons.location_on, color: selected ? AppColors.primary : const Color(0xFF9CA3AF), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Text(a.detail, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
          ])),
          if (selected) const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
        ]),
      ),
    );
  }

  Widget _paymentCard(PaymentMethod p) {
    final selected = _selectedPayment?.id == p.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = p),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.primary : const Color(0xFFE5E7EB), width: selected ? 2 : 1),
        ),
        child: Row(children: [
          Icon(Icons.credit_card, color: selected ? AppColors.primary : const Color(0xFF9CA3AF), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Text(p.detail, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
          ])),
          if (selected) const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
        ]),
      ),
    );
  }

  Widget _emptyCard(String msg, IconData icon, VoidCallback onAdd) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 12),
        Expanded(child: Text(msg, style: const TextStyle(color: Color(0xFF6B7280)))),
        TextButton(onPressed: onAdd, child: const Text('Add')),
      ]),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 13, color: bold ? const Color(0xFF111827) : const Color(0xFF6B7280))),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
    ]);
  }

  Future<void> _showAddAddress() async {
    final labelCtrl = TextEditingController();
    final detailCtrl = TextEditingController();
    final user = context.read<AuthProvider>().user!;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Address'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: labelCtrl, decoration: const InputDecoration(labelText: 'Label (e.g. Home)')),
          const SizedBox(height: 12),
          TextField(controller: detailCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Full address')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (labelCtrl.text.isNotEmpty && detailCtrl.text.isNotEmpty) {
                await DatabaseService.instance.addAddress(user.id, labelCtrl.text, detailCtrl.text);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPayment() async {
    final labelCtrl = TextEditingController();
    final detailCtrl = TextEditingController();
    final user = context.read<AuthProvider>().user!;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Payment Method'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: labelCtrl, decoration: const InputDecoration(labelText: 'Label (e.g. Visa Card)')),
          const SizedBox(height: 12),
          TextField(controller: detailCtrl, decoration: const InputDecoration(labelText: 'Card number / details')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (labelCtrl.text.isNotEmpty && detailCtrl.text.isNotEmpty) {
                await DatabaseService.instance.addPaymentMethod(user.id, labelCtrl.text, detailCtrl.text, 'card');
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
