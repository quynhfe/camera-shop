import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_service.dart';
import '../models/payment_method.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/confirm_dialog.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<PaymentMethod> _methods = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final list = await DatabaseService.instance.getPaymentMethodsByUser(user.id);
    if (mounted) setState(() => _methods = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Payment Methods', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _methods.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.credit_card_off_outlined, size: 64, color: Color(0xFF9CA3AF)),
                const SizedBox(height: 16),
                const Text('No payment methods saved', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
              ]),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _methods.length,
              itemBuilder: (context, i) {
                final m = _methods[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)]),
                  child: Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.paymentGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.credit_card_outlined, color: AppColors.paymentGreen, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(m.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        if (m.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                            child: const Text('Default', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ]),
                      const SizedBox(height: 4),
                      Text(m.detail, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                    ])),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.red),
                      onPressed: () async {
                        final confirm = await showConfirmDialog(context, title: 'Delete Payment Method', message: 'Delete "${m.label}"?', destructive: true);
                        if (confirm == true) {
                          await DatabaseService.instance.deletePaymentMethod(m.id);
                          _load();
                        }
                      },
                    ),
                  ]),
                );
              },
            ),
    );
  }

  Future<void> _showAddDialog() async {
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
                _load();
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

