import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TopAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBack;
  final bool showNotification;
  final bool transparent;
  final VoidCallback? onBack;
  final Widget? rightAction;

  const TopAppBarWidget({
    super.key,
    this.title,
    this.showBack = false,
    this.showNotification = false,
    this.transparent = false,
    this.onBack,
    this.rightAction,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: transparent ? Colors.transparent : Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: showBack
          ? IconButton(
              icon: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: AppColors.dark, size: 16),
              ),
              onPressed: onBack ?? () => Navigator.pop(context),
            )
          : null,
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.dark,
                letterSpacing: -0.3,
              ),
            )
          : null,
      actions: [
        if (showNotification)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.dark),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
              Positioned(
                top: 10, right: 10,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ?rightAction,
      ],
    );
  }
}
