import 'package:flutter/material.dart';


import '../../../cubit/profile_edit_state.dart';
import 'profile_logout_button.dart';

class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({
    super.key,
    required this.data,
    required this.onEditName,
    required this.onEditEmail,
    required this.onLogout,
    required this.onDelete,
  });

  final ProfileEditData data;
  final VoidCallback onEditName;
  final VoidCallback onEditEmail;
  final VoidCallback onLogout;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
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
                onEdit: onEditName,
              ),
              _rowDivider(),
              _InfoRow(
                icon: Icons.mail_outline,
                label: 'Email Address',
                value: data.email,
                editable: true,
                onEdit: onEditEmail,
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
              ProfileLogoutButton(onTap: onLogout),
              _rowDivider(),
              _ActionRow(
                icon: Icons.delete_outline,
                label: 'Delete Account',
                color: const Color(0xFFE53935),
                onTap: onDelete,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _rowDivider() =>
      const Divider(height: 1, color: Color(0xFFF5F5F5), indent: 54);
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
