import 'package:flutter/material.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    super.key,
    required this.title,
    this.backEnabled = true,
    this.onBack,
    this.bottom,
    this.backIconSize = 14,
  });

  final String title;
  final bool backEnabled;
  final VoidCallback? onBack;
  final PreferredSizeWidget? bottom;
  final double? backIconSize;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontSize: 24),
      ),
      centerTitle: true,
      automaticallyImplyLeading: backEnabled,
      leading: backEnabled
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: backIconSize,
              ),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      bottom: bottom,
    );
  }
}
