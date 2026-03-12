import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';

import '../bloc/internet_bloc.dart';
import '../bloc/internet_event.dart';
import '../bloc/internet_state.dart';

class GlobalNetworkDialogOverlay extends StatelessWidget {
  const GlobalNetworkDialogOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InternetBloc, InternetState>(
      builder: (context, state) {
        final bool visible =
            state.status != InternetStatus.initial && !state.isConnected;
        return IgnorePointer(
          ignoring: !visible,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 160),
            child: Scaffold(
              backgroundColor: AppColors.white,
              appBar: AppBar(
                backgroundColor: AppColors.white,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: const Text(
                  'Connection Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                centerTitle: true,
              ),
              // appBar: AppBar(
              //   backgroundColor: AppColors.white,
              //   elevation: 0,
              //   // leading: const Icon(
              //   //   Icons.arrow_back_ios_new_rounded,
              //   //   size: 18,
              //   //   color: AppColors.black87,
              //   // ),
              //   title: const Text(
              //     'Connection Status',
              //     style: TextStyle(
              //       fontSize: 16,
              //       fontWeight: FontWeight.w600,
              //       color: AppColors.black,
              //     ),
              //   ),
              //   centerTitle: true,
              // ),
              body: SafeArea(
                top: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: <Widget>[
                              const SizedBox(height: 30),
                              _StatusIcon(),
                              const SizedBox(height: 25),
                              const Text(
                                'No Internet Connection',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Oops! It seems you're offline. Please check your internet\nconnection and try again.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: AppColors.textMuted,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 25),
                              _TipsCard(),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.emerald,
                                    foregroundColor: AppColors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: () {
                                    context.read<InternetBloc>().add(
                                      const InternetCheckRequested(),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Try Again',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.surfaceF5,
            shape: BoxShape.circle,
          ),
        ),
        const Icon(Icons.wifi_rounded, size: 44, color: AppColors.neutralCCC),
        Positioned(
          bottom: 8,
          right: 1,
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.warningRed,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _TipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceF8,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text(
            'Quick Tips',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 12),
          _TipRow(
            icon: Icons.signal_cellular_alt_rounded,
            text: 'Check your mobile data or Wi-Fi connection',
          ),
          SizedBox(height: 10),
          _TipRow(
            icon: Icons.airplanemode_active_rounded,
            text: 'Make sure airplane mode is turned off',
          ),
          SizedBox(height: 10),
          _TipRow(
            icon: Icons.refresh_rounded,
            text: 'Try turning your connection off and on again',
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.amber,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: AppColors.orange),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
