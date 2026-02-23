import 'package:flutter/material.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    super.key,
    required this.title,
    this.backEnabled = true,
    this.onBack,
    this.bottom,
  });

  final String title;
  final bool backEnabled;
  final VoidCallback? onBack;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      leading: backEnabled
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      bottom: bottom,
    );
  }
}
