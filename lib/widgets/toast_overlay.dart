import 'package:flutter/material.dart';
import '../providers/toast_provider.dart';
import '../theme/app_theme.dart';



class ToastHost extends StatelessWidget {
  final Widget child;
  final ToastProvider provider;
  const ToastHost({super.key, required this.child, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        AnimatedBuilder(
          animation: provider,
          builder: (context, _) {
            final msg = provider.current;
            if (msg == null) return const SizedBox.shrink();
            return Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              child: _ToastCard(message: msg),
            );
          },
        ),
      ],
    );
  }
}

class _ToastCard extends StatelessWidget {
  final ToastMessage message;
  const _ToastCard({required this.message});

  Color get bgColor {
    switch (message.type) {
      case ToastType.success: return const Color(0xFFE8F5E9);
      case ToastType.warning: return const Color(0xFFFEF3C7);
      case ToastType.error: return const Color(0xFFFDE8E8);
    }
  }

  Color get iconColor {
    switch (message.type) {
      case ToastType.success: return AppColors.success;
      case ToastType.warning: return AppColors.amber;
      case ToastType.error: return AppColors.red;
    }
  }

  IconData get icon {
    switch (message.type) {
      case ToastType.success: return Icons.check_circle_outline;
      case ToastType.warning: return Icons.warning_amber_outlined;
      case ToastType.error: return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message.message, style: TextStyle(color: iconColor, fontSize: 14, fontWeight: FontWeight.w500))),
          ],
        ),
      ),
    );
  }
}
