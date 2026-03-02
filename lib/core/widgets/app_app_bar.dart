import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.titleStyle,
    this.backEnabled = true,
    this.onBack,
    this.leading,
    this.actions,
    this.bottom,
    this.backgroundColor,
    this.surfaceTintColor,
    this.elevation,
    this.shadowColor,
    this.toolbarHeight,
    this.centerTitle,
    this.titleSpacing,
    this.automaticallyImplyLeading,
    this.backIconSize = 14,
  });

  final Object? title;
  final Widget? titleWidget;
  final TextStyle? titleStyle;
  final bool backEnabled;
  final VoidCallback? onBack;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final Color? surfaceTintColor;
  final double? elevation;
  final Color? shadowColor;
  final double? toolbarHeight;
  final bool? centerTitle;
  final double? titleSpacing;
  final bool? automaticallyImplyLeading;
  final double? backIconSize;

  @override
  Size get preferredSize => Size.fromHeight(
        (toolbarHeight ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final Widget? resolvedTitle = titleWidget ??
        switch (title) {
          String text => Text(
              text,
              style: titleStyle ?? const TextStyle(fontSize: 24),
            ),
          Widget widget => widget,
          null => null,
          _ => Text(
              title.toString(),
              style: titleStyle ?? const TextStyle(fontSize: 24),
            ),
        };
    final bool resolvedAutoLeading = automaticallyImplyLeading ??
        (leading == null && backEnabled);
    final Widget? resolvedLeading = leading ??
        (resolvedAutoLeading
            ? IconButton(
                icon: Icon(
                  color: AppColors.black,
                  Icons.arrow_back_ios_new_rounded,
                  size: 14,
                ),
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              )
            : null);

    return AppBar(
      title: resolvedTitle,
      centerTitle: centerTitle ?? true,
      automaticallyImplyLeading: resolvedAutoLeading,
      leading: resolvedLeading,
      actions: actions,
      bottom: bottom,
      backgroundColor: backgroundColor,
      surfaceTintColor: surfaceTintColor,
      elevation: elevation,
      shadowColor: shadowColor,
      toolbarHeight: toolbarHeight,
      titleSpacing: titleSpacing,
    );
  }
}
