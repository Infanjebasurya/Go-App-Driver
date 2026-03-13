import 'dart:math' as math;

import 'package:flutter/material.dart';

class KeyboardAwareBottom extends StatelessWidget {
  const KeyboardAwareBottom({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.duration = const Duration(milliseconds: 180),
    this.curve = Curves.easeOut,
    this.extraBottom = 0,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Duration duration;
  final Curve curve;
  final double extraBottom;

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final bottomInset = math.max(keyboardInset, safeBottom) + extraBottom;
    return AnimatedPadding(
      duration: duration,
      curve: curve,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
