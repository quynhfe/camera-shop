import 'package:flutter/material.dart';

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
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF111827), size: 20),
              onPressed: onBack ?? () => Navigator.pop(context),
            )
          : null,
      title: title != null
          ? Text(title!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827)))
          : null,
      actions: [
        if (showNotification)
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF374151)),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
              Positioned(
                top: 10, right: 10,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: Color(0xFFFF6B6B), shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        if (rightAction != null) rightAction!,
      ],
    );
  }
}
