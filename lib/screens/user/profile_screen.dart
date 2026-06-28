import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.person, size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(user?.name ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                  const SizedBox(height: 4),
                  Text(user?.email ?? '', style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), foregroundColor: AppColors.primary),
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection('Account', [
              _MenuItem(Icons.receipt_long_outlined, 'My Orders', () => Navigator.pushNamed(context, '/orders')),
              _MenuItem(Icons.favorite_outline, 'Wishlist', () => Navigator.pushNamed(context, '/wishlist')),
              _MenuItem(Icons.credit_card_outlined, 'Payment Methods', () => Navigator.pushNamed(context, '/payment-methods')),
              _MenuItem(Icons.location_on_outlined, 'Shipping Addresses', () => Navigator.pushNamed(context, '/shipping-addresses')),
            ]),
            const SizedBox(height: 16),
            _buildSection('Support', [
              _MenuItem(Icons.map_outlined, 'Store Locations', () => Navigator.pushNamed(context, '/store-map')),
              _MenuItem(Icons.chat_bubble_outline, 'Chat Support', () => Navigator.pushNamed(context, '/chat')),
              _MenuItem(Icons.settings_outlined, 'Settings', () {}),
              _MenuItem(Icons.help_outline, 'Help Center', () {}),
            ]),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                  },
                  icon: const Icon(Icons.logout, color: AppColors.red),
                  label: const Text('Log Out', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w600, fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<_MenuItem> items) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF), letterSpacing: 0.5)),
          ),
          ...items.map((item) => ListTile(
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
              child: Icon(item.icon, color: AppColors.primary, size: 20),
            ),
            title: Text(item.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
            onTap: item.onTap,
          )),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.label, this.onTap);
}
