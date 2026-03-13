import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/sos/presentation/cubit/sos_cubit.dart';
import 'package:goapp/features/sos/presentation/cubit/sos_state.dart';
import 'package:goapp/features/sos/presentation/widgets/sos_bottom_sheet.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/core/widgets/shadow_button.dart';

class SOSPage extends StatelessWidget {
  const SOSPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F7),
      appBar: AppAppBar(
        backgroundColor: const Color(0xFFF9F9F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.neutral333),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'SOS Security',
          style: TextStyle(
            color: AppColors.neutral333,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<SosCubit, SosState>(
          builder: (context, state) {
            return Column(
              children: <Widget>[
                const SizedBox(height: 26),
                Center(
                  child: GestureDetector(
                    onTap: () => SOSBottomSheet.show(context),
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: AppColors.earningsAccentSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircleAvatar(
                          radius: 17,
                          backgroundColor: AppColors.emerald,
                          child: Icon(
                            Icons.share,
                            color: AppColors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Trusted Contacts Notified',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral333,
                  ),
                ),
                const SizedBox(height: 14),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 46),
                  child: Text(
                    'Your live location and status have been shared with your emergency circle.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.neutral666,
                      height: 1.55,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: state.contacts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (_, index) {
                      final contact = state.contacts[index];
                      return _ContactCard(
                        index: index,
                        name: contact.name,
                        status: contact.status,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 30),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ShadowButton(
                          onPressed: () =>
                              context.read<SosCubit>().sendAlertToAllContacts(),
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: const Text('Share Live to All'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Ending the alert will notify all contacts',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral888,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.index,
    required this.name,
    required this.status,
  });

  final int index;
  final String name;
  final String status;

  @override
  Widget build(BuildContext context) {
    final bool isDelivered = status == 'Sent' || status == 'Sended';
    final bool isPrimary = index == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD8D8D3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.neutralDDD,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral333,
                        ),
                      ),
                    ),
                    if (isPrimary) ...<Widget>[
                      const SizedBox(width: 4),
                      const Text(
                        'Primary',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: AppColors.neutral888,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDelivered
                            ? AppColors.emerald
                            : AppColors.neutral333,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isDelivered ? 'Live Location Received' : 'Not sent',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDelivered
                            ? AppColors.emerald
                            : AppColors.neutral666,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: isDelivered
                ? null
                : () => context.read<SosCubit>().sendAlertToContact(index),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDDF3E7),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                isDelivered ? 'sended' : 'Send',
                style: const TextStyle(
                  color: AppColors.emerald,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
