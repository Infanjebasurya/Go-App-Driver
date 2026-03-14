import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/di/injection.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/help_support/presentation/cubit/support_chat_cubit.dart';
import 'package:goapp/features/help_support/presentation/pages/support_chat_screen.dart';
import 'package:goapp/features/help_support/presentation/routes/help_support_routes.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';

class AccountSupportArticleScreen extends StatelessWidget {
  const AccountSupportArticleScreen({
    super.key,
    required this.title,
    required this.content,
    this.showDefaultGetHelpLine = true,
  });

  final String title;
  final List<Widget> content;
  final bool showDefaultGetHelpLine;

  @override
  Widget build(BuildContext context) {
    void openSupportChat() {
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

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(title, style: const TextStyle(fontSize: 18)),
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
                  onPressed: openSupportChat,
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
                    style: ArticleText.body,
                    children: const [
                      TextSpan(text: 'If you need further help, tap '),
                      TextSpan(
                        text: 'Get Help',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.headingDark,
                        ),
                      ),
                      TextSpan(text: ' below'),
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

class ArticleText {
  ArticleText._();

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 2,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    color: AppColors.headingDark,
    height: 2,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.headingDark,
  );

  static const TextStyle bold = TextStyle(fontWeight: FontWeight.w700);
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.spans});

  final List<TextSpan> spans;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              '•',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(style: ArticleText.bodySmall, children: spans),
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleBulletList extends StatelessWidget {
  const ArticleBulletList({super.key, required this.items});

  final List<List<TextSpan>> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((spans) => _BulletLine(spans: spans)).toList(),
    );
  }
}
