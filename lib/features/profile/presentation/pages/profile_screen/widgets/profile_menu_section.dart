import 'package:flutter/material.dart';

import '../../../cubit/profile_edit_state.dart';
import 'package:goapp/core/theme/app_colors.dart';

class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({
    super.key,
    required this.data,
    required this.onEditEmail,
    required this.onLogout,
    required this.onDelete,
  });

  final ProfileEditData data;
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dangerDeep,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: AppColors.surfaceF5,
                    ),
                    child: Text(
                      'Delete Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.dangerDeep,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

