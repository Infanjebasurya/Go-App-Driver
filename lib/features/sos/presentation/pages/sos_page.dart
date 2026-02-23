import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/sos/presentation/cubit/sos_cubit.dart';
import 'package:goapp/features/sos/presentation/cubit/sos_state.dart';
import 'package:goapp/features/sos/presentation/widgets/sos_bottom_sheet.dart';

class SOSPage extends StatelessWidget {
  const SOSPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.neutral333),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'SOS Security',
          style: TextStyle(
            color: AppColors.neutral333,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<SosCubit, SosState>(
          builder: (context, state) {
            return Column(
              children: <Widget>[
                const SizedBox(height: 40),
                Center(
                  child: GestureDetector(
                    onTap: () => SOSBottomSheet.show(context),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.earningsAccentSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: AppColors.emerald,
                        size: 36,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Trusted Contacts Notified',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral333,
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Driver contact and details have been shared with your emergency circle.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.neutral888,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: state.contacts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (_, index) {
                      final contact = state.contacts[index];
                      return _ContactCard(
                        name: contact.name,
                        status: contact.status,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => context.read<SosCubit>().markSafe(),
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(
                            state.isSafe ? 'Alert Ended' : 'I am Safe',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald,
                            foregroundColor: AppColors.white,
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Ending the alert will notify all contacts',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.neutral888,
                          letterSpacing: 0.5,
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
  const _ContactCard({required this.name, required this.status});

  final String name;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.strokeLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: AppColors.neutralDDD,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral333,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.neutral888,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.neutral888,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.earningsAccentSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Send',
              style: TextStyle(
                color: AppColors.emerald,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
