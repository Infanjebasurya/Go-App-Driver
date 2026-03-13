import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/help_support/presentation/cubit/help_cubit.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HelpCubit, HelpState>(
      builder: (context, state) {
        final cubit = context.read<HelpCubit>();
        final String query = state is HelpExploreState ? state.searchQuery : '';
        final items = _ExploreIssueItem.defaultItems;
        final filteredItems = query.trim().isEmpty
            ? items
            : items
                  .where(
                    (item) =>
                        item.title.toLowerCase().contains(query.toLowerCase()),
                  )
                  .toList(growable: false);
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppAppBar(
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            title: const Text(
              'Explore all Issues',
              style: TextStyle(fontSize: 18),
            ),
            backgroundColor: AppColors.white,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.borderSoft),
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 200,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textBody,
                        side: const BorderSide(color: AppColors.borderSoft),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Ticket Tracking'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Our support team typically responds within 15 minutes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              HelpSearchBar(onChanged: cubit.updateSearch),
              const SizedBox(height: 12),
              Expanded(
                child: filteredItems.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.fromLTRB(16, 18, 16, 18),
                        child: Text(
                          'No issues found. Try a different search.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: filteredItems.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox.shrink(),
                        itemBuilder: (context, i) {
                          final item = filteredItems[i];
                          return Material(
                            color: AppColors.transparent,
                            child: InkWell(
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      item.icon,
                                      size: 22,
                                      color: AppColors.textBody,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
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
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _ExploreIssueItem {
  const _ExploreIssueItem({required this.icon, required this.title});

  final IconData icon;
  final String title;

  static const List<_ExploreIssueItem> defaultItems = <_ExploreIssueItem>[
    _ExploreIssueItem(
      icon: Icons.location_on_outlined,
      title: 'Nearby Demand Locations',
    ),
    _ExploreIssueItem(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Earnings',
    ),
    _ExploreIssueItem(icon: Icons.settings_outlined, title: 'Account'),
    _ExploreIssueItem(icon: Icons.phone_android_outlined, title: 'App issues'),
    _ExploreIssueItem(icon: Icons.warning_amber_rounded, title: 'Emergency'),
    _ExploreIssueItem(
      icon: Icons.shield_outlined,
      title: 'Accidental Insurance',
    ),
    _ExploreIssueItem(icon: Icons.bolt_outlined, title: 'Getting Started'),
  ];
}
