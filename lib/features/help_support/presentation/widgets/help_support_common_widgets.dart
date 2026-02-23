import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';

class HelpSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const HelpSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search for help topics...',
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20,
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderSoft),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderSoft),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.emerald, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class HelpLiveChatBar extends StatelessWidget {
  const HelpLiveChatBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.chat_bubble_outline, size: 18),
        label: const Text('START LIVE CHAT'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emerald,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
