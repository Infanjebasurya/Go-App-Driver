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
    this.backIconSize = 24,
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
  static const TextStyle _commonTitleStyle = TextStyle(
    fontSize: 18,
    color: AppColors.black,
    fontWeight: FontWeight.w700,
  );

  @override
  Size get preferredSize => Size.fromHeight(
        (toolbarHeight ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final Widget? resolvedTitle = _resolveTitle();
    final bool resolvedAutoLeading = automaticallyImplyLeading ??
        (leading == null && backEnabled);
    final Widget? resolvedLeading = leading ??
        (resolvedAutoLeading
            ? IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: AppColors.black,
                  size: backIconSize ?? 24,
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
      backgroundColor: backgroundColor ?? AppColors.white,
      surfaceTintColor: surfaceTintColor ?? AppColors.white,
      elevation: elevation ?? 0,
      shadowColor: shadowColor,
      toolbarHeight: toolbarHeight,
      titleSpacing: titleSpacing,
    );
  }

  Widget? _resolveTitle() {
    final Widget? candidate = titleWidget ??
        switch (title) {
          String text => Text(text),
          Widget widget => widget,
          null => null,
          _ => Text(title.toString()),
        };
    if (candidate is Text) {
      final String? plain = candidate.data;
      if (plain != null) {
        return Text(
          plain,
          style: titleStyle ?? _commonTitleStyle,
          maxLines: candidate.maxLines,
          overflow: candidate.overflow,
          textAlign: candidate.textAlign,
          textScaler: candidate.textScaler,
          softWrap: candidate.softWrap,
          strutStyle: candidate.strutStyle,
          textWidthBasis: candidate.textWidthBasis,
        );
      }
      final InlineSpan? span = candidate.textSpan;
      if (span != null) {
        return Text.rich(
          span,
          style: titleStyle ?? _commonTitleStyle,
          maxLines: candidate.maxLines,
          overflow: candidate.overflow,
          textAlign: candidate.textAlign,
          textScaler: candidate.textScaler,
          softWrap: candidate.softWrap,
          strutStyle: candidate.strutStyle,
          textWidthBasis: candidate.textWidthBasis,
        );
      }
    }
    return candidate;
  }
}



