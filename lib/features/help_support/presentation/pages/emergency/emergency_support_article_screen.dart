import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/di/injection.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/help_support/presentation/cubit/support_chat_cubit.dart';
import 'package:goapp/features/help_support/presentation/pages/support_chat_screen.dart';
import 'package:goapp/features/help_support/presentation/routes/help_support_routes.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';

class EmergencySupportArticleScreen extends StatelessWidget {
  const EmergencySupportArticleScreen({
    super.key,
    required this.title,
    required this.content,
    this.showDefaultGetHelpLine = true,
  });

  final String title;
  final List<Widget> content;
  final bool showDefaultGetHelpLine;

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
        title: Text(title, style: const TextStyle(fontSize: 16)),
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: const HelpSupportAppBarBottomDivider(),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: AppColors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call_outlined, size: 18),
                  label: const Text('Customer Care'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textBody,
                    side: const BorderSide(color: AppColors.borderSoft),
                    backgroundColor: const Color(0xFFEDEDED),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _openSupportChat(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Support Chat'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...content,
              if (showDefaultGetHelpLine) ...[
                const SizedBox(height: 18),
                Text.rich(
                  TextSpan(
                    style: EmergencyArticleText.body,
                    children: const [
                      TextSpan(text: 'If you need further help, tap '),
                      TextSpan(
                        text: 'Get Help',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.headingDark,
                        ),
                      ),
                      TextSpan(text: ' below.'),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 72),
            ],
          ),
        ),
      ),
    );
  }
}

class EmergencyArticleText {
  EmergencyArticleText._();

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 2,
  );
}
