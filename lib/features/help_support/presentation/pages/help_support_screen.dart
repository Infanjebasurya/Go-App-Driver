import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/help_support/presentation/cubit/complaint_cubit.dart';
import 'package:goapp/features/help_support/presentation/cubit/help_cubit.dart';
import 'package:goapp/features/help_support/presentation/pages/complaint_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/explore_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/safety.dart';
import 'package:goapp/features/help_support/presentation/pages/tickets_screen.dart';
import 'package:goapp/features/help_support/presentation/routes/help_support_routes.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/core/di/injection.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  bool _isComplaintExpanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HelpCubit>(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            Navigator.of(context).pop(true);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppAppBar(
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => Navigator.of(context).pop(true),
            ),
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
                  const SizedBox(height: 10),
                  _ExpandableComplaintTile(
                    expanded: _isComplaintExpanded,
                    onToggle: () {
                      setState(() {
                        _isComplaintExpanded = !_isComplaintExpanded;
                      });
                    },
                    onCreateNewComplaint: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => sl<ComplaintCubit>(),
                          child: const ComplaintScreen(),
                        ),
                      ),
                    ),
                    onRecentTickets: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TicketsScreen(
                          tickets: ComplaintCubit.recentTickets,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MenuTile(
                    icon: Icons.help_outline,
                    title: 'Explore all Issue',
                    onTap: () {
                      context.read<HelpCubit>().goToExplore();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(
                              name: HelpSupportRoutes.explore,
                            ),
                            builder: (_) => BlocProvider.value(
                              value: context.read<HelpCubit>(),
                              child: const ExploreScreen(),
                            ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
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
      ),
    );
  }
}

class _ExpandableComplaintTile extends StatelessWidget {
  const _ExpandableComplaintTile({
    required this.expanded,
    required this.onToggle,
    required this.onCreateNewComplaint,
    required this.onRecentTickets,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onCreateNewComplaint;
  final VoidCallback onRecentTickets;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: AppColors.hex14000000,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: AppColors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.report_outlined,
                      size: 22,
                      color: AppColors.textBody,
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Make Complaint',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.headingDark,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                      child: Icon(
                        expanded ? Icons.expand_less : Icons.chevron_right,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (expanded)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.hex14000000,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _SubMenuTile(
                  icon: Icons.add_circle_outline,
                  title: 'Create New Complaint',
                  onTap: onCreateNewComplaint,
                  grouped: true,
                ),
                const Divider(
                  height: 1,
                  color: AppColors.borderSoft,
                  indent: 16,
                  endIndent: 16,
                ),
                _SubMenuTile(
                  icon: Icons.confirmation_number_outlined,
                  title: 'Recent Support Tickets',
                  onTap: onRecentTickets,
                  grouped: true,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SubMenuTile extends StatelessWidget {
  const _SubMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.grouped = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool grouped;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: grouped ? BorderRadius.zero : BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textBody),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textBody,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ],
          ),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: AppColors.hex14000000,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
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
                      fontWeight: FontWeight.w700,
                      color: AppColors.headingDark,
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
      ),
    );
  }
}
