import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/auth/presentation/theme/auth_ui_tokens.dart';
import 'package:goapp/features/refer_earn/presentation/cubit/invite_friends_cubit.dart';
import 'package:permission_handler/permission_handler.dart';

class InviteFriendsScreen extends StatelessWidget {
  const InviteFriendsScreen({super.key, required this.referralCode});

  final String referralCode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          InviteFriendsCubit(referralCode: referralCode)..initialize(),
      child: const _InviteFriendsView(),
    );
  }
}

class _InviteFriendsView extends StatelessWidget {
  const _InviteFriendsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.headingDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Invite Friends',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.headingDark,
          ),
        ),
      ),
      body: BlocBuilder<InviteFriendsCubit, InviteFriendsState>(
        builder: (context, state) {
          if (state is InviteFriendsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AuthUiColors.brandGreen),
            );
          }

          if (state is InviteFriendsPermissionDenied) {
            return _PermissionView(permanentlyDenied: state.permanentlyDenied);
          }

          if (state is InviteFriendsFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
            );
          }

          final InviteFriendsLoaded s = state as InviteFriendsLoaded;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: TextField(
                  onChanged: context.read<InviteFriendsCubit>().setQuery,
                  decoration: InputDecoration(
                    hintText: 'Search contacts...',
                    hintStyle: TextStyle(color: AppColors.gray.shade500),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.neutralAAA,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF6F6F6),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: s.contacts.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: Color(0xFFF1F1F1)),
                  itemBuilder: (_, i) {
                    final InviteContact c = s.contacts[i];
                    final bool isInviting = s.invitingContactId == c.id;
                    return _ContactRow(contact: c, isInviting: isInviting);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PermissionView extends StatelessWidget {
  const _PermissionView({required this.permanentlyDenied});

  final bool permanentlyDenied;

  @override
  Widget build(BuildContext context) {
    final String text = permanentlyDenied
        ? 'Contacts permission is permanently denied. Please enable it in Settings.'
        : 'Allow contacts permission to invite your friends.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () async {
                if (permanentlyDenied) {
                  await openAppSettings();
                } else {
                  await context.read<InviteFriendsCubit>().initialize();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AuthUiColors.brandGreen,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(permanentlyDenied ? 'Open Settings' : 'Allow'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.contact, required this.isInviting});

  final InviteContact contact;
  final bool isInviting;

  @override
  Widget build(BuildContext context) {
    final bool isMember = contact.isMember;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x1A00A86B),
              border: Border.all(color: AuthUiColors.brandGreen, width: 2.5),
            ),
            alignment: Alignment.center,
            child: Text(
              contact.initial,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.headingDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.headingDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.phone,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isMember)
            const Text(
              'MEMBER',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.neutralAAA,
                letterSpacing: 0.6,
              ),
            )
          else
            InkWell(
              onTap: isInviting
                  ? null
                  : () => context.read<InviteFriendsCubit>().invite(contact),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 16,
                      color: AuthUiColors.brandGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isInviting ? 'INVITING...' : 'INVITE',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AuthUiColors.brandGreen,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
