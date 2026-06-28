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
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Icon(Icons.search_rounded, color: AppColors.primary, size: 21),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSubmit,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: const TextStyle(color: AppColors.inactive, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14, color: AppColors.dark),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () => controller.clear(),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.close_rounded, color: AppColors.inactive, size: 18),
              ),
            ),
          if (onFilterPress != null)
            GestureDetector(
              onTap: onFilterPress,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: hasActiveFilters ? AppColors.primaryXLight : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: hasActiveFilters ? AppColors.primary : AppColors.textMid,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
