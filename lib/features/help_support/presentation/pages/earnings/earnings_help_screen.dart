import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/help_support/presentation/cubit/earnings_help_detail_cubit.dart';
import 'package:goapp/features/help_support/presentation/cubit/earnings_help_cubit.dart';
import 'package:goapp/features/help_support/presentation/cubit/earnings_help_state.dart';
import 'package:goapp/features/help_support/presentation/pages/earnings/earnings_help_detail_screen.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';
import 'package:goapp/core/di/injection.dart';
import 'package:goapp/features/help_support/domain/usecases/get_earnings_help_faqs_usecase.dart';

class EarningsHelpScreen extends StatefulWidget {
  const EarningsHelpScreen({super.key});

  @override
  State<EarningsHelpScreen> createState() => _EarningsHelpScreenState();
}

class _EarningsHelpScreenState extends State<EarningsHelpScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EarningsHelpCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EarningsHelpCubit, EarningsHelpState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppAppBar(
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            title: const Text('Earnings', style: TextStyle(fontSize: 18)),
            backgroundColor: AppColors.white,
            elevation: 0,
            bottom: const HelpSupportAppBarBottomDivider(),
          ),
          bottomNavigationBar: const HelpTicketTrackingFooter(),
          body: ListView(
            padding: const EdgeInsets.only(top: 8),
            children: [
              HelpRoundedListSection(
                itemCount: state.links.length,
                contentPadding: EdgeInsets.zero,
                borderRadius: 0,
                itemBuilder: (context, index) {
                  final item = state.links[index];
                  return Material(
                    color: AppColors.transparent,
                    child: InkWell(
                      onTap: () {
                        final String detailTitle = switch (item.id) {
                          'learn_about_incentives' =>
                            'Learn More About Incentives',
                          'transfer_earnings_to_bank' =>
                            'Transfer Earnings to Bank',
                          _ => item.title,
                        };
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => BlocProvider(
                              create: (_) => EarningsHelpDetailCubit(
                                getFaqs: sl<GetEarningsHelpFaqsUseCase>(),
                                linkId: item.id,
                              ),
                              child: EarningsHelpDetailScreen(
                                title: detailTitle,
                                linkId: item.id,
                              ),
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
