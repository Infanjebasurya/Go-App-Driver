import 'package:flutter/material.dart';

import 'home_drawer.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.onReopenDrawer});

  final VoidCallback onReopenDrawer;

  @override
  Widget build(BuildContext context) {
    return HomeDrawer(onReopenDrawer: onReopenDrawer);
  }
}
