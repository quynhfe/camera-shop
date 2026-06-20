import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<String>? onSubmit;
  final VoidCallback? onFilterPress;
  final bool hasActiveFilters;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.placeholder = 'Search cameras...',
    this.onSubmit,
    this.onFilterPress,
    this.hasActiveFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSubmit,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () => controller.clear(),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.close, color: Color(0xFF9CA3AF), size: 18),
              ),
            ),
          if (onFilterPress != null)
            GestureDetector(
              onTap: onFilterPress,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: hasActiveFilters ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.tune, color: hasActiveFilters ? AppColors.primary : const Color(0xFF6B7280), size: 20),
              ),
            ),
        ],
      ),
    );
  }
}
