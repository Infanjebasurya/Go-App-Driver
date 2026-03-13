import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/di/injection.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/help_support/presentation/cubit/support_chat_cubit.dart';
import 'package:goapp/features/help_support/presentation/pages/support_chat_screen.dart';
import 'package:goapp/features/help_support/presentation/routes/help_support_routes.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = _EmergencyIssue.items;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text('Emergency', style: TextStyle(fontSize: 18)),
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderSoft),
        ),
      ),
      bottomNavigationBar: const HelpTicketTrackingFooter(),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: AppColors.borderSoft,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _EmergencyDetailScreen(issue: item),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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
        },
      ),
    );
  }
}

class _EmergencyDetailScreen extends StatelessWidget {
  const _EmergencyDetailScreen({required this.issue});

  final _EmergencyIssue issue;

  void _openSupportChat(BuildContext context) {
    ensureSupportChatDependenciesRegistered();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: HelpSupportRoutes.supportChat),
        builder: (_) => BlocProvider(
          create: (_) => sl<SupportChatCubit>(),
          child: const SupportChatScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(issue.title, style: const TextStyle(fontSize: 18)),
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderSoft),
        ),
      ),
      bottomNavigationBar: HelpCustomerCareSupportChatBar(
        onSupportChat: () => _openSupportChat(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Text.rich(
          issue.body,
          style: const TextStyle(
            fontSize: 13.5,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _EmergencyIssue {
  const _EmergencyIssue({required this.title, required this.body});

  final String title;
  final TextSpan body;

  static const List<_EmergencyIssue> items = [
    _EmergencyIssue(
      title: 'I had an accident',
      body: TextSpan(
        children: [
          TextSpan(
            text:
                'Your safety is our priority. We\'re sorry to hear about the accident and hope you are safe.\n\n',
          ),
          TextSpan(text: 'For immediate assistance, please contact '),
          TextSpan(
            text: 'Support Chat',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: ' or '),
          TextSpan(
            text: 'Customer Care',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: ' by tapping '),
          TextSpan(
            text: 'Get Help',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: ' below.'),
        ],
      ),
    ),
    _EmergencyIssue(
      title: 'I had an issue with a customer',
      body: TextSpan(
        children: [
          TextSpan(
            text: 'Please avoid getting into an argument with the customer.\n\n',
          ),
          TextSpan(
            text:
                'If a customer\'s behaviour made you feel unsafe or prevented you from starting or completing the ride, please contact ',
          ),
          TextSpan(
            text: 'Support Chat',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: ' or '),
          TextSpan(
            text: 'Customer Care',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: ' by tapping '),
          TextSpan(
            text: 'Get Help',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: ' below.\n\n'),
          TextSpan(
            text: 'If you need immediate emergency assistance, please contact ',
          ),
          TextSpan(
            text: 'local law enforcement',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: '.'),
        ],
      ),
    ),
    _EmergencyIssue(
      title: 'My vehicle was seized by authorities',
      body: TextSpan(
        children: [
          TextSpan(
            text: 'GoApp Drivers must always follow traffic regulations.\n\n',
          ),
          TextSpan(
            text:
                'If your vehicle was seized due to any traffic reason, please contact ',
          ),
          TextSpan(
            text: 'Support Chat',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: ' or '),
          TextSpan(
            text: 'Customer Care',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: ' by tapping '),
          TextSpan(
            text: 'Get Help',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: ' below.'),
        ],
      ),
    ),
    _EmergencyIssue(
      title: 'I received a traffic challan',
      body: TextSpan(
        children: [
          TextSpan(
            text: 'GoApp Drivers must always follow traffic regulations.\n\n',
          ),
          TextSpan(
            text:
                'If you received a traffic challan due to any other reason, please contact ',
          ),
          TextSpan(
            text: 'Support Chat',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: ' or '),
          TextSpan(
            text: 'Customer Care',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: ' by tapping '),
          TextSpan(
            text: 'Get Help',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: ' below.'),
        ],
      ),
    ),
  ];
}
