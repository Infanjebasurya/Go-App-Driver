import 'package:flutter/material.dart';

class HomeNoDeviceBack extends StatelessWidget {
  const HomeNoDeviceBack({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(canPop: false, child: child);
  }
}
