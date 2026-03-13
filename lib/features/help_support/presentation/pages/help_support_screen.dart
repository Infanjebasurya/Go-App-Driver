import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/navigation/last_route_observer.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/help_support/presentation/cubit/help_cubit.dart';
import 'package:goapp/features/help_support/presentation/cubit/earnings_help_cubit.dart';
import 'package:goapp/features/help_support/presentation/cubit/support_chat_cubit.dart';
import 'package:goapp/features/help_support/presentation/pages/explore_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/earnings/earnings_help_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/emergency/emergency_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/nearby_demand_location/nearby_demand_location_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/new_account_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/new_app_issue_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/safety.dart';
import 'package:goapp/features/help_support/presentation/pages/support_chat_screen.dart';
import 'package:goapp/features/help_support/presentation/pages/ticket_tracking_screen.dart';
import 'package:goapp/features/help_support/presentation/routes/help_support_routes.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/core/di/injection.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  bool _restoreAttempted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_restoreAttempted) return;
    _restoreAttempted = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final String? lastRoute = LastRouteStore.read();
      if (lastRoute == null || !lastRoute.startsWith('/help_support/')) return;

      if (lastRoute == HelpSupportRoutes.explore) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: HelpSupportRoutes.explore),
            builder: (_) => BlocProvider.value(
              value: context.read<HelpCubit>(),
              child: const ExploreScreen(),
            ),
          ),
        );
        return;
      }

      if (lastRoute == HelpSupportRoutes.nearbyDemandLocation) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(
              name: HelpSupportRoutes.nearbyDemandLocation,
            ),
            builder: (_) => const NearbyDemandLocationScreen(),
          ),
        );
        return;
      }

      if (lastRoute == HelpSupportRoutes.earnings) {
        ensureEarningsHelpDependenciesRegistered();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: HelpSupportRoutes.earnings),
            builder: (_) => BlocProvider(
              create: (_) => sl<EarningsHelpCubit>(),
              child: const EarningsHelpScreen(),
            ),
          ),
        );
        return;
      }

      if (lastRoute == HelpSupportRoutes.emergency) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: HelpSupportRoutes.emergency),
            builder: (_) => const EmergencyScreen(),
          ),
        );
        return;
      }

      if (lastRoute == HelpSupportRoutes.account) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: HelpSupportRoutes.account),
            builder: (_) => const NewAccountScreen(),
          ),
        );
        return;
      }

      if (lastRoute == HelpSupportRoutes.appIssues) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: HelpSupportRoutes.appIssues),
            builder: (_) => const NewAppIssueScreen(),
          ),
        );
        return;
      }

      if (lastRoute == HelpSupportRoutes.ticketTracking) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(
              name: HelpSupportRoutes.ticketTracking,
            ),
            builder: (_) => const TicketTrackingScreen(),
          ),
        );
        return;
      }

      if (lastRoute == HelpSupportRoutes.safety) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: HelpSupportRoutes.safety),
            builder: (_) => const SafetyPage(),
          ),
        );
        return;
      }

      if (lastRoute == HelpSupportRoutes.supportChat) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HelpCubit>(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            Navigator.of(context).pop(true);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppAppBar(
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            centerTitle: true,
            title: const Text('Help & Support', style: TextStyle(fontSize: 18)),
            backgroundColor: AppColors.white,
            elevation: 0,
          ),
          body: BlocBuilder<HelpCubit, HelpState>(
            builder: (context, state) {
              return Column(
                children: [
                  HelpSearchBar(
                    onChanged: context.read<HelpCubit>().updateSearch,
                  ),
                  const SizedBox(height: 10),
                  _MenuTile(
                    icon: Icons.help_outline,
                    title: 'Explore all Issue',
                    onTap: () {
                      context.read<HelpCubit>().goToExplore();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(
                            name: HelpSupportRoutes.explore,
                          ),
                          builder: (_) => BlocProvider.value(
                            value: context.read<HelpCubit>(),
                            child: const ExploreScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _MenuTile(
                    icon: Icons.shield_outlined,
                    title: 'Safety',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        settings: const RouteSettings(
                          name: HelpSupportRoutes.safety,
                        ),
                        builder: (_) => const SafetyPage(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: AppColors.hex14000000,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, size: 22, color: AppColors.textBody),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.headingDark,
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
        ),
      ),
    );
  }
}
