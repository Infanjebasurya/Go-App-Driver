import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:goapp/features/auth/presentation/theme/auth_ui_tokens.dart';
import '../cubit/driver_status_cubit.dart';
import '../cubit/driver_status_state.dart';


class DriverAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DriverAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverCubit, DriverState>(
      builder: (context, state) {
        return AppBar(
          backgroundColor: state.isOnline ? Colors.transparent : Colors.white,
          elevation: state.isOnline ? 6 : 6,
          shadowColor: Colors.black12,
          surfaceTintColor: Colors.transparent,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: _ToggleSwitch(isOnline: state.isOnline),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.black54),
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }
}

class _ToggleSwitch extends StatelessWidget {
  final bool isOnline;

  const _ToggleSwitch({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<DriverCubit>().toggleStatus(),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Tab(label: 'Offline', isSelected: !isOnline),
            _Tab(label: 'Online', isSelected: isOnline),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _Tab({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? (label == 'Online' ? AuthUiColors.brandGreen : Colors.grey)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? (label == 'Online' ? Colors.white : Colors.black87)
              : Colors.black54,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
