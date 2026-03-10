import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/service/network_settings_service.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/di/injection.dart';

import 'network_status_cubit.dart';

class GlobalNetworkDialogOverlay extends StatelessWidget {
  const GlobalNetworkDialogOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkStatusCubit, NetworkStatusState>(
      builder: (context, state) {
        final bool visible = state.isOffline;
        return IgnorePointer(
          ignoring: !visible,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 160),
            child: Container(
              color: AppColors.overlayScrim,
              alignment: Alignment.center,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Material(
                      color: AppColors.white,
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.circle_outlined,
                                  size: 108,
                                  color: AppColors.warningRed,
                                ),
                                Icon(
                                  Icons.wifi_rounded,
                                  size: 52,
                                  color: AppColors.emerald,
                                ),
                                Icon(
                                  Icons.close_rounded,
                                  size: 100,
                                  color: AppColors.warningRed,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'NO INTERNET',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.dialogTitle,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Check your Internet connection and\ntry again.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.dialogBody,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'PLEASE TURN ON',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.dialogBody,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: _NetworkActionButton(
                                    icon: Icons.wifi_rounded,
                                    label: 'WIFI',
                                    onTap: () {
                                      sl<NetworkSettingsService>()
                                          .openWifiSettings();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _NetworkActionButton(
                                    icon: Icons.network_cell_rounded,
                                    label: 'MOBILE DATA',
                                    onTap: () {
                                      sl<NetworkSettingsService>()
                                          .openMobileDataSettings();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NetworkActionButton extends StatelessWidget {
  const _NetworkActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColors.darkRed,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(),
              Icon(icon, size: 16, color: AppColors.white),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
