import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/di/injection.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/help_support/domain/entities/help_article_content.dart';
import 'package:goapp/features/help_support/domain/entities/help_content_block.dart';
import 'package:goapp/features/help_support/domain/entities/help_text_run.dart';
import 'package:goapp/features/help_support/presentation/cubit/earnings_help_article_cubit.dart';
import 'package:goapp/features/help_support/presentation/cubit/earnings_help_article_state.dart';
import 'package:goapp/features/help_support/presentation/cubit/support_chat_cubit.dart';
import 'package:goapp/features/help_support/presentation/pages/support_chat_screen.dart';
import 'package:goapp/features/help_support/presentation/routes/help_support_routes.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';

class EarningsHelpArticleScreen extends StatefulWidget {
  const EarningsHelpArticleScreen({super.key, required this.title});

  final String title;

  @override
  State<EarningsHelpArticleScreen> createState() =>
      _EarningsHelpArticleScreenState();
}

class _EarningsHelpArticleScreenState extends State<EarningsHelpArticleScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EarningsHelpArticleCubit>().init();
  }

  void _openSupportChat() {
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
    return BlocBuilder<EarningsHelpArticleCubit, EarningsHelpArticleState>(
      builder: (context, state) {
        final HelpArticleContent? content = state.content;
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppAppBar(
            automaticallyImplyLeading: false,
            backEnabled: false,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            title: Text(widget.title, style: const TextStyle(fontSize: 18)),
            actions: const [],
            backgroundColor: AppColors.white,
            elevation: 0,
            bottom: const HelpSupportAppBarBottomDivider(),
          ),
          bottomNavigationBar: content?.showBottomActions == true
              ? HelpCustomerCareSupportChatBar(onSupportChat: _openSupportChat)
              : null,
          body: content == null
              ? const SizedBox.shrink()
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                  child: _HelpContentRenderer(content: content),
                ),
        );
      },
    );
  }
}

class _HelpContentRenderer extends StatelessWidget {
  const _HelpContentRenderer({required this.content});

  final HelpArticleContent content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in content.blocks) ...[
          switch (block) {
            HelpSpacerBlock(:final height) => SizedBox(height: height),
            HelpHeadingBlock(:final text) => Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textBody,
              ),
            ),
            HelpParagraphBlock(:final runs) => _HelpRichText(runs: runs),
            HelpBulletsBlock(:final items) => _HelpBullets(items: items),
          },
        ],
      ],
    );
  }
}

class _HelpRichText extends StatelessWidget {
  const _HelpRichText({required this.runs});

  final List<HelpTextRun> runs;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontSize: 13,
          height: 1.45,
          color: AppColors.textSecondary,
        ),
        children: runs
            .map(
              (run) => TextSpan(
                text: run.text,
                style: run.bold
                    ? const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textBody,
                      )
                    : null,
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _HelpBullets extends StatelessWidget {
  const _HelpBullets({required this.items});

  final List<List<HelpTextRun>> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text(
                    '•',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _HelpRichText(runs: item)),
              ],
            ),
          ),
      ],
    );
  }
}
