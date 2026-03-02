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
        final categories = cubit.filteredIssueCategories;
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppAppBar(
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            title: const Text(
              'Explore all Issue',
              style: TextStyle(fontSize: 18),
            ),
            backgroundColor: AppColors.white,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.borderSoft),
            ),
          ),
          body: Column(
            children: [
              HelpSearchBar(onChanged: cubit.updateSearch),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    color: AppColors.borderSoft,
                    indent: 22,
                    endIndent: 22,
                  ),
                  itemBuilder: (context, i) {
                    final cat = categories[i];
                    return InkWell(
                      onTap: () {},
                      child: Container(
                        color: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Icon(cat.icon, size: 22, color: AppColors.textBody),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                cat.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
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
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: const HelpLiveChatBar(),
        );
      },
    );
  }
}

