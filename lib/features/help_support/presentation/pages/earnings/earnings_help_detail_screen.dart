import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/di/injection.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/help_support/domain/usecases/get_earnings_help_article_usecase.dart';
import 'package:goapp/features/help_support/presentation/cubit/earnings_help_article_cubit.dart';
import 'package:goapp/features/help_support/presentation/cubit/earnings_help_detail_cubit.dart';
import 'package:goapp/features/help_support/presentation/cubit/earnings_help_detail_state.dart';
import 'package:goapp/features/help_support/presentation/pages/earnings/earnings_help_article_screen.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';

class EarningsHelpDetailScreen extends StatefulWidget {
  const EarningsHelpDetailScreen({
    super.key,
    required this.title,
    required this.linkId,
  });

  final String title;
  final String linkId;

  @override
  State<EarningsHelpDetailScreen> createState() => _EarningsHelpDetailScreenState();
}

class _EarningsHelpDetailScreenState extends State<EarningsHelpDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EarningsHelpDetailCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EarningsHelpDetailCubit, EarningsHelpDetailState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppAppBar(
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            title: Text(widget.title, style: const TextStyle(fontSize: 18)),
            backgroundColor: AppColors.white,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.borderSoft),
            ),
          ),
          bottomNavigationBar: const HelpTicketTrackingFooter(),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 10),
            children: [
              HelpRoundedListSection(
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return Material(
                    color: AppColors.transparent,
                    child: InkWell(
                      onTap: () {
                  final String displayTitle = switch (item.title) {
                    'Money was deducted after a cash payment' =>
                      'Money deducted after a cash payment',
                    'Customer asked to drop at a different location' =>
                      'Customer asked to drop different location',
                    'How do I transfer money to my bank account?' =>
                      'Transfer money to my bank account?',
                    'Transfer request is initiated but not\ncompleted' =>
                      'Transfer request is initiated',
                    'Money is credited but not showing in my\nbank account' =>
                      'Money not showing in my bank account',
                    "Why wasn't my incentive added after\nreaching the target?" =>
                      "Why wasn't my incentive added",
                    _ => item.title,
                  };
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => BlocProvider(
                              create: (_) => EarningsHelpArticleCubit(
                                getArticle: sl<GetEarningsHelpArticleUseCase>(),
                                linkId: widget.linkId,
                                faqTitle: item.title,
                              ),
                              child: EarningsHelpArticleScreen(title: displayTitle),
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textBody,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.textSecondary,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
