import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/di/injection.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/help_support/domain/entities/help_article_link.dart';
import 'package:goapp/features/help_support/presentation/cubit/account_help_cubit.dart';
import 'package:goapp/features/help_support/presentation/cubit/account_help_state.dart';
import 'package:goapp/features/help_support/presentation/pages/account/about_goapp_id_card_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/account/update_aadhaar_pan_details_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/account/update_driving_license_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/account/update_mobile_number_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/account/update_rc_details_screen.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';

class NewAccountScreen extends StatelessWidget {
  const NewAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountHelpCubit>(
      create: (_) => sl<AccountHelpCubit>(),
      child: BlocBuilder<AccountHelpCubit, AccountHelpState>(
        builder: (context, state) {
          final items = _AccountItem.fromLinks(state.links);
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppAppBar(
              leading: IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => Navigator.of(context).pop(),
              ),
              centerTitle: true,
              title: const Text('Account', style: TextStyle(fontSize: 18)),
              backgroundColor: AppColors.white,
              elevation: 0,
              bottom: const HelpSupportAppBarBottomDivider(),
            ),
            body: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: items.length,
              separatorBuilder: (context, index) => Divider(
                height: 0,
                thickness: 0.5,
                color: AppColors.handleGray.withValues(alpha: 0.2),
              ),
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

class _AccountItem {
  final String title;
  final Widget destination;
  final String chevronKey;

  const _AccountItem({
    required this.title,
    required this.destination,
    required this.chevronKey,
  });

  static List<_AccountItem> fromLinks(List<HelpArticleLink> links) {
    final items = <_AccountItem>[];
    for (final link in links) {
      final item = _AccountItem._fromLink(link);
      if (item != null) items.add(item);
    }
    return items;
  }

  static _AccountItem? _fromLink(HelpArticleLink link) {
    switch (link.id) {
      case 'update_rc_details':
        return _AccountItem(
          title: link.title,
          destination: const UpdateRcDetailsScreen(),
          chevronKey: 'account_item_update_rc_chevron',
        );
      case 'update_mobile_number':
        return _AccountItem(
          title: link.title,
          destination: const UpdateMobileNumberScreen(),
          chevronKey: 'account_item_update_mobile_chevron',
        );
      case 'update_driving_license':
        return _AccountItem(
          title: link.title,
          destination: const UpdateDrivingLicenseScreen(),
          chevronKey: 'account_item_update_dl_chevron',
        );
      case 'update_aadhaar_pan_details':
        return _AccountItem(
          title: link.title,
          destination: const UpdateAadhaarPanDetailsScreen(),
          chevronKey: 'account_item_update_aadhaar_pan_chevron',
        );
      case 'about_goapp_id_card':
        return _AccountItem(
          title: link.title,
          destination: const AboutGoAppIdCardScreen(),
          chevronKey: 'account_item_about_id_card_chevron',
        );
    }
    return null;
  }
}
