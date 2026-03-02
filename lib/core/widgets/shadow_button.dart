import 'package:flutter/material.dart';

class ShadowButton extends StatelessWidget {
  const ShadowButton({
    super.key,
    this.onPressed,
    this.onLongPress,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.statesController,
    this.child,
    this.icon,
    this.label,
    this.loading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
  });

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;
  final WidgetStatesController? statesController;
  final Widget? child;
  final Widget? icon;
  final Widget? label;
  final bool loading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final BorderRadiusGeometry resolvedBorderRadius =
        borderRadius ?? _resolveBorderRadius();
    final Widget content = _buildContent();

    return Container(
      decoration: BoxDecoration(
        borderRadius: resolvedBorderRadius,
        boxShadow: enabled
            ? <BoxShadow>[
                BoxShadow(
                  offset: const Offset(0, 8),
                  blurRadius: 10,
                  spreadRadius: -6,
                  color: Colors.black.withValues(alpha: 0.1),
                ),
                BoxShadow(
                  offset: const Offset(0, 20),
                  blurRadius: 25,
                  spreadRadius: -5,
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ]
            : <BoxShadow>[],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        focusNode: focusNode,
        autofocus: autofocus,
        clipBehavior: clipBehavior,
        statesController: statesController,
        style: _buildStyle(resolvedBorderRadius),
        child: content,
      ),
    );
  }

  Widget _buildContent() {
    if (loading) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      );
    }
    if (child != null) {
      return child!;
    }
    if (icon != null && label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          icon!,
          const SizedBox(width: 8),
          Flexible(child: label!),
        ],
      );
    }
    if (label != null) {
      return label!;
    }
    return const SizedBox.shrink();
  }

  ButtonStyle _buildStyle(BorderRadiusGeometry resolvedBorderRadius) {
    final ButtonStyle normalized = (style ?? const ButtonStyle()).copyWith(
      elevation: const WidgetStatePropertyAll<double>(0),
      shadowColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
      surfaceTintColor:
          const WidgetStatePropertyAll<Color>(Colors.transparent),
      backgroundColor: backgroundColor != null
          ? WidgetStatePropertyAll<Color>(backgroundColor!)
          : null,
      foregroundColor: foregroundColor != null
          ? WidgetStatePropertyAll<Color>(foregroundColor!)
          : null,
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: resolvedBorderRadius),
      ),
    );
    return normalized;
  }

  BorderRadiusGeometry _resolveBorderRadius() {
    final OutlinedBorder? shape = style?.shape?.resolve(<WidgetState>{});
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius;
    }
    if (shape is StadiumBorder) {
      return BorderRadius.circular(999);
    }
    return BorderRadius.circular(12);
  }
}

