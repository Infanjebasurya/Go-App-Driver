import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/di/injection.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/help_support/domain/entities/help_article_link.dart';
import 'package:goapp/features/help_support/presentation/cubit/app_issues_help_cubit.dart';
import 'package:goapp/features/help_support/presentation/cubit/app_issues_help_state.dart';
import 'package:goapp/features/help_support/presentation/pages/app_issues/app_issue_detail_screens.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';

class NewAppIssueScreen extends StatelessWidget {
  const NewAppIssueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppIssuesHelpCubit>(
      create: (_) => sl<AppIssuesHelpCubit>(),
      child: BlocBuilder<AppIssuesHelpCubit, AppIssuesHelpState>(
        builder: (context, state) {
          final items = _AppIssueItem.fromLinks(state.links);
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppAppBar(
              leading: IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => Navigator.of(context).pop(),
              ),
              centerTitle: true,
              title: const Text('App issues', style: TextStyle(fontSize: 18)),
              backgroundColor: AppColors.white,
              elevation: 0,
              bottom: const HelpSupportAppBarBottomDivider(),
            ),
            bottomNavigationBar: const HelpTicketTrackingFooter(),
            body: ListView.separated(
              padding: const EdgeInsets.only(top: 8),
              itemCount: items.length,
              separatorBuilder: (_, _) => const HelpSupportThinDivider(),
              itemBuilder: (context, index) {
                final item = items[index];
                return HelpSupportChevronOnlyListItem(
                  title: item.title,
                  chevronKey: item.chevronKey,
                  onChevronTap: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => item.destination));
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AppIssueItem {
  final String title;
  final Widget destination;
  final String chevronKey;

  const _AppIssueItem({
    required this.title,
    required this.destination,
    required this.chevronKey,
  });

  static List<_AppIssueItem> fromLinks(List<HelpArticleLink> links) {
    final items = <_AppIssueItem>[];
    for (final link in links) {
      final item = _AppIssueItem._fromLink(link);
      if (item != null) items.add(item);
    }
    return items;
  }

  static _AppIssueItem? _fromLink(HelpArticleLink link) {
    switch (link.id) {
      case 'unable_to_go_on_duty':
        return _AppIssueItem(
          title: link.title,
          destination: const UnableToGoOnDutyScreen(),
          chevronKey: 'app_issue_unable_go_duty_chevron',
        );
      case 'not_receiving_orders':
        return _AppIssueItem(
          title: link.title,
          destination: const NotReceivingOrdersScreen(),
          chevronKey: 'app_issue_not_receiving_orders_chevron',
        );
      case 'service_suspended_on_my_account':
        return _AppIssueItem(
          title: link.title,
          destination: const ServiceSuspendedScreen(),
          chevronKey: 'app_issue_service_suspended_chevron',
        );
      case 'app_is_crashing':
        return _AppIssueItem(
          title: link.title,
          destination: const AppCrashingScreen(),
          chevronKey: 'app_issue_app_crashing_chevron',
        );
      case 'change_my_mobile_number':
        return _AppIssueItem(
          title: link.title,
          destination: const ChangeMobileNumberScreen(),
          chevronKey: 'app_issue_change_mobile_chevron',
        );
      case 'update_my_vehicle_details':
        return _AppIssueItem(
          title: link.title,
          destination: const UpdateVehicleDetailsScreen(),
          chevronKey: 'app_issue_update_vehicle_details_chevron',
        );
      case 'unable_to_upload_documents':
        return _AppIssueItem(
          title: link.title,
          destination: const UnableToUploadDocumentsScreen(),
          chevronKey: 'app_issue_unable_upload_documents_chevron',
        );
    }
    return null;
  }
}
