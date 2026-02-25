import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/auth/presentation/theme/auth_ui_tokens.dart';
import 'package:goapp/features/auth/presentation/pages/r_login_page.dart';
import 'package:goapp/features/profile/presentation/cubit/profile_edit_cubit.dart';
import 'package:goapp/features/profile/presentation/cubit/profile_edit_state.dart';
import 'package:goapp/features/profile/domain/usecases/get_cached_profile_usecase.dart';

import '../../domain/repositories/profile_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileEditCubit>(
      create: (context) => ProfileEditCubit(
        getCachedProfileUseCase: GetCachedProfileUseCase(
          context.read<ProfileRepository>(),
        ),
      ),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF1A1A1A),
              size: 18,
            ),
          ),
        ),
        title: const Text(
          'Profile Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFEEEEEE), height: 1),
        ),
      ),
      body: BlocConsumer<ProfileEditCubit, ProfileEditState>(
        listener: (BuildContext context, ProfileEditState state) {
          if (state.status == ProfileEditStatus.loggedOut ||
              state.status == ProfileEditStatus.deleted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const RLoginPage()),
              (route) => false,
            );
          }
        },
        builder: (BuildContext context, ProfileEditState state) {
          if (state.status == ProfileEditStatus.loading ||
              state.status == ProfileEditStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(color: AuthUiColors.brandGreen),
            );
          }
          if (state.data == null) {
            return const Center(child: Text('Failed to load profile.'));
          }
          return _ProfileBody(data: state.data!);
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.data});

  final ProfileEditData data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AuthUiColors.brandGreen,
                          width: 2.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Container(
                          color: const Color(0xFF3A3A3A),
                          child: const Icon(
                            Icons.person,
                            size: 52,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 2,
                      right: 2,
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AuthUiColors.brandGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  data.fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Premium Member',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                _StatCell(
                  label: 'RATING',
                  value: '${data.rating}',
                  suffix: Icons.star,
                  suffixColor: const Color(0xFFFFB800),
                ),
                _divider(),
                _StatCell(label: 'TOTAL TRIPS', value: '${data.totalTrips}'),
                _divider(),
                _StatCell(label: 'TOTAL YEARS', value: '${data.totalYears}'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'Full Name',
                  value: data.fullName,
                  editable: true,
                  onEdit: () => _showEditNameSheet(context, data.fullName),
                ),
                _rowDivider(),
                _InfoRow(
                  icon: Icons.mail_outline,
                  label: 'Email Address',
                  value: data.email,
                  editable: true,
                  onEdit: () => _showEditEmailSheet(context, data.email),
                ),
                _rowDivider(),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: data.phone,
                ),
                _rowDivider(),
                _InfoRow(
                  icon: Icons.wc_outlined,
                  label: 'Gender',
                  value: data.gender,
                ),
                _rowDivider(),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Date of Birth',
                  value: data.dateOfBirth,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                _ActionRow(
                  icon: Icons.logout,
                  label: 'Logout',
                  color: const Color(0xFFE53935),
                  onTap: () => _showLogoutSheet(context),
                ),
                _rowDivider(),
                _ActionRow(
                  icon: Icons.delete_outline,
                  label: 'Delete Account',
                  color: const Color(0xFFE53935),
                  onTap: () => _showDeleteSheet(context),
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 40, color: const Color(0xFFF0F0F0));

  Widget _rowDivider() =>
      const Divider(height: 1, color: Color(0xFFF5F5F5), indent: 54);

  void _showEditNameSheet(BuildContext context, String current) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider<ProfileEditCubit>.value(
        value: context.read<ProfileEditCubit>(),
        child: _EditFieldSheet(
          title: 'Enter Your Full Name',
          icon: Icons.person_outline,
          initialValue: current,
          keyboardType: TextInputType.name,
          onSave: (String val) =>
              context.read<ProfileEditCubit>().updateFullName(val),
        ),
      ),
    );
  }

  void _showEditEmailSheet(BuildContext context, String current) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider<ProfileEditCubit>.value(
        value: context.read<ProfileEditCubit>(),
        child: _EditFieldSheet(
          title: 'Enter Your Email Address',
          icon: Icons.mail_outline,
          initialValue: current,
          keyboardType: TextInputType.emailAddress,
          onSave: (String val) =>
              context.read<ProfileEditCubit>().updateEmail(val),
        ),
      ),
    );
  }

  void _showLogoutSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider<ProfileEditCubit>.value(
        value: context.read<ProfileEditCubit>(),
        child: _ConfirmActionSheet(
          icon: Icons.logout,
          title: 'Logout',
          message: 'Are you sure you want to Logout your account?',
          actionLabel: 'Logout',
          actionColor: const Color(0xFFE53935),
          onConfirm: () => context.read<ProfileEditCubit>().logout(),
        ),
      ),
    );
  }

  void _showDeleteSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider<ProfileEditCubit>.value(
        value: context.read<ProfileEditCubit>(),
        child: _ConfirmActionSheet(
          icon: Icons.delete_outline,
          title: 'Delete Account',
          message: 'Are you sure you want to Delete your account?',
          actionLabel: 'Delete',
          actionColor: const Color(0xFFE53935),
          onConfirm: () => context.read<ProfileEditCubit>().deleteAccount(),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    this.suffix,
    this.suffixColor,
  });

  final String label;
  final String value;
  final IconData? suffix;
  final Color? suffixColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFFAAAAAA),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              if (suffix != null) ...<Widget>[
                const SizedBox(width: 3),
                Icon(suffix, color: suffixColor, size: 14),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.editable = false,
    this.isLast = false,
    this.onEdit,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool editable;
  final bool isLast;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 14, 16, isLast ? 14 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 20, color: const Color(0xFF888888)),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFAAAAAA),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          if (editable)
            GestureDetector(
              onTap: onEdit,
              child: const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: Color(0xFF888888),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isLast ? Radius.zero : const Radius.circular(14),
        bottom: isLast ? const Radius.circular(14) : Radius.zero,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, isLast ? 16 : 14),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 18),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: color.withValues(alpha: 0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _EditFieldSheet extends StatefulWidget {
  const _EditFieldSheet({
    required this.title,
    required this.icon,
    required this.initialValue,
    required this.keyboardType,
    required this.onSave,
  });

  final String title;
  final IconData icon;
  final String initialValue;
  final TextInputType keyboardType;
  final Future<void> Function(String) onSave;

  @override
  State<_EditFieldSheet> createState() => _EditFieldSheetState();
}

class _EditFieldSheetState extends State<_EditFieldSheet> {
  late TextEditingController _ctrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await widget.onSave(_ctrl.text);
    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: TextField(
              controller: _ctrl,
              keyboardType: widget.keyboardType,
              autofocus: true,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                fillColor: Colors.white,
                prefixIcon: Icon(
                  widget.icon,
                  color: const Color(0xFF888888),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F0ED),
                    foregroundColor: const Color(0xFF656565),
                    side: const BorderSide(color: Color(0xFFDDDDDD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 16),
                  label: Text(_saving ? 'Saving...' : 'Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuthUiColors.brandGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfirmActionSheet extends StatefulWidget {
  const _ConfirmActionSheet({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.actionColor,
    required this.onConfirm,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final Color actionColor;
  final Future<void> Function() onConfirm;

  @override
  State<_ConfirmActionSheet> createState() => _ConfirmActionSheetState();
}

class _ConfirmActionSheetState extends State<_ConfirmActionSheet> {
  bool _loading = false;

  Future<void> _confirm() async {
    setState(() => _loading = true);
    await widget.onConfirm();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(bottom: 28),
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: widget.actionColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, color: widget.actionColor, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton(
                  onPressed: _loading ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.actionColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.actionLabel,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF0F0F0),
                    foregroundColor: const Color(0xFF444444),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Not Now',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
