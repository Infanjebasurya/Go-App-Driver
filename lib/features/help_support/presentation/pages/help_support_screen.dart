import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/help_support/presentation/cubit/complaint_cubit.dart';
import 'package:goapp/features/help_support/presentation/cubit/help_cubit.dart';
import 'package:goapp/features/help_support/presentation/pages/complaint_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/explore_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/safety.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HelpCubit(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          leading: const Icon(Icons.chevron_left),
          centerTitle: true,
          title: const Text('Help & Support', style: TextStyle(fontSize: 18)),
          backgroundColor: AppColors.white,
          elevation: 0,
        ),
        body: BlocBuilder<HelpCubit, HelpState>(
          builder: (context, state) {
            return Column(
              children: [
                HelpSearchBar(
                  onChanged: context.read<HelpCubit>().updateSearch,
                ),
                const SizedBox(height: 8),
                _MenuTile(
                  icon: Icons.report_outlined,
                  title: 'Make Complaint',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => ComplaintCubit(),
                        child: const ComplaintScreen(),
                      ),
                    ),
                  ),
                ),
                _MenuTile(
                  icon: Icons.help_outline,
                  title: 'Explore all Issue',
                  onTap: () {
                    context.read<HelpCubit>().goToExplore();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<HelpCubit>(),
                          child: const ExploreScreen(),
                        ),
                      ),
                    );
                  },
                ),
                _MenuTile(
                  icon: Icons.shield_outlined,
                  title: 'Safety',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SafetyPage()),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, size: 22, color: AppColors.textBody),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textBody,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const Divider(
          height: 1,
          color: AppColors.borderSoft,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }
}
