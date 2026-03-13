import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/di/injection.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/help_support/presentation/cubit/support_chat_cubit.dart';
import 'package:goapp/features/help_support/presentation/pages/support_chat_screen.dart';
import 'package:goapp/features/help_support/presentation/routes/help_support_routes.dart';

class NearbyDemandLocationDetailScreen extends StatelessWidget {
  const NearbyDemandLocationDetailScreen({super.key});

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
        title: const Text(
          'Nearby Demand Location',
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: SizedBox(
            height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ensureSupportChatDependenciesRegistered();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      settings: const RouteSettings(
                        name: HelpSupportRoutes.supportChat,
                      ),
                      builder: (_) => BlocProvider(
                        create: (_) => sl<SupportChatCubit>(),
                        child: const SupportChatScreen(),
                      ),
                    ),
                  );
                },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Get Help'),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    TextSpan(text: 'If you can see '),
                    TextSpan(
                      text: '"Demand planner"',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBody,
                      ),
                    ),
                    TextSpan(text: ' in the menu,\n'),
                    TextSpan(
                      text:
                          'tap on it to check the city areas where demand\nwill be high at different times during the day.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.emerald, width: 1.5),
              ),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Demand Planner',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(text: 'In '),
                        TextSpan(
                          text: 'Demand Planner',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        TextSpan(text: ', you can view all the '),
                        TextSpan(
                          text: 'High\nDemand Areas',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        TextSpan(text: ' across the city throughout the\nday.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/image/Nothing Phone 1.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  height: 1.35,
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  const TextSpan(text: 'Select '),
                                  const TextSpan(
                                    text: 'Demand\nPlanner',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' from the left-\nside menu ',
                                  ),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 2),
                                      child: Icon(
                                        Icons.menu,
                                        size: 16,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.35,
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  TextSpan(text: 'Zoom in or out on the\nmap, or tap on any\n'),
                                  TextSpan(
                                    text: 'highlighted area',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  TextSpan(text: ' to see\ndemand levels.'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.35,
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  TextSpan(text: 'Select the '),
                                  TextSpan(
                                    text: 'time slot',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '\nwhen demand is\nhighest and plan your\ntrips accordingly.',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
