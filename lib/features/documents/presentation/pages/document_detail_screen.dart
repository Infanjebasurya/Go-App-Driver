import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/documents/presentation/model/document_model.dart';

class DocumentDetailScreen extends StatelessWidget {
  final DocumentModel document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _buildContent(),
            ),
          ),
          _EncryptionFooter(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Icon(
            Icons.arrow_back_ios,
            color: AppColors.headingDark,
            size: 14,
          ),
        ),
      ),
      title: Text(
        document.title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.headingDark,
          letterSpacing: -0.3,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.strokeLight, height: 1),
      ),
    );
  }

  Widget _buildContent() {
    switch (document.iconAsset) {
      case 'driving_license':
        return const _DrivingLicenseDetail();
      case 'vehicle_rc':
        return const _VehicleRCDetail();
      case 'aadhaar_card':
        return const _AadhaarCardDetail();
      case 'pan_card':
        return const _PanCardDetail();
      case 'bank_account':
      case 'add bank account':
        return const _PanCardDetail();
      default:
        return const _DrivingLicenseDetail();
    }
  }
}

class _DrivingLicenseDetail extends StatelessWidget {
  const _DrivingLicenseDetail();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SubHeader(text: 'Government of India • Digital Copy'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _CardImageBox(
                label: 'FRONT VIEW',
                color: const Color(0xFF8A9BAE),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CardImageBox(
                label: 'BACK VIEW',
                color: const Color(0xFF2C3A4A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _InfoCard(
          children: [
            _InfoRow(
              label: 'LICENSE NUMBER',
              value: 'MH12 20180012345',
              valueLarge: true,
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: _InfoField(label: 'HOLDER NAME', value: 'Sam Yogi'),
                ),
                Expanded(
                  child: _InfoField(label: 'VALIDITY', value: '12 Oct 2028'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.surfaceF0),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceF0,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                const _InfoField(
                  label: 'CLASS OF VEHICLE',
                  value: 'LMV-NT, MCWG',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _VehicleRCDetail extends StatelessWidget {
  const _VehicleRCDetail();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SubHeader(text: 'Registration Document'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _CardImageBox(
                label: 'FRONT VIEW',
                color: const Color(0xFF8A9BAE),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CardImageBox(
                label: 'BACK VIEW',
                color: const Color(0xFF2C3A4A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _InfoCard(
          children: [
            _InfoRow(
              label: 'VEHICLE NUMBER',
              value: 'TN02 BY2026',
              valueLarge: true,
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: _InfoField(label: 'OWNERSHIP', value: 'Owner'),
                ),
                Expanded(
                  child: _InfoField(
                    label: 'YEAR OF MANUFACTURE',
                    value: '2022',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.surfaceF0),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceF0,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                const _InfoField(
                  label: 'CLASS OF VEHICLE',
                  value: 'LMV-NT, MCWG',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _AadhaarCardDetail extends StatefulWidget {
  const _AadhaarCardDetail();

  @override
  State<_AadhaarCardDetail> createState() => _AadhaarCardDetailState();
}

class _AadhaarCardDetailState extends State<_AadhaarCardDetail> {
  bool _masked = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CardImageBox(
          label: 'FRONT VIEW',
          color: Color(0xFF9EC8B0),
          showVerified: true,
          fullWidth: true,
        ),
        const SizedBox(height: 14),
        const _CardImageBox(
          label: 'BACK VIEW',
          color: Color(0xFFA8C4B8),
          showVerified: true,
          fullWidth: true,
        ),
        const SizedBox(height: 20),
        _VerifiedSection(
          children: [
            const Text(
              'Aadhaar Number:',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.neutral888,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _masked ? '**** **** 1425' : '2345 6789 1425',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: AppColors.headingDark,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => setState(() => _masked = !_masked),
                  child: Icon(
                    _masked
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.neutral888,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _PanCardDetail extends StatefulWidget {
  const _PanCardDetail();

  @override
  State<_PanCardDetail> createState() => _PanCardDetailState();
}

class _PanCardDetailState extends State<_PanCardDetail> {
  bool _masked = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CardImageBox(
          label: 'FRONT VIEW',
          color: Color(0xFF7FB5C8),
          showVerified: true,
          fullWidth: true,
        ),
        const SizedBox(height: 20),
        _VerifiedSection(
          children: [
            const Text(
              'Pan Number:',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.neutral888,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _masked ? '******142F' : 'ABCDE1142F',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.headingDark,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => setState(() => _masked = !_masked),
                  child: Icon(
                    _masked
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.neutral888,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'This PAN card has been successfully verified with the issuing authority and linked to your profile.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.neutralAAA,
                height: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SubHeader extends StatelessWidget {
  final String text;

  const _SubHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.neutral888,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _CardImageBox extends StatelessWidget {
  final String label;
  final Color color;
  final bool showVerified;
  final bool fullWidth;

  const _CardImageBox({
    required this.label,
    required this.color,
    this.showVerified = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral888,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              width: fullWidth ? double.infinity : null,
              height: fullWidth ? 160 : 90,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  Icons.credit_card,
                  color: Colors.white.withValues(alpha: 0.3),
                  size: 36,
                ),
              ),
            ),
            if (showVerified)
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: AppColors.verifiedMint,
                        size: 13,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'VERIFIED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.verifiedMint,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.strokeLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool valueLarge;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.neutralAAA,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: valueLarge ? 32 : 22,
            fontWeight: FontWeight.w800,
            color: AppColors.headingDark,
            letterSpacing: valueLarge ? 1.2 : 0,
          ),
        ),
      ],
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;

  const _InfoField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.neutralAAA,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.headingDark,
          ),
        ),
      ],
    );
  }
}

class _VerifiedSection extends StatelessWidget {
  final List<Widget> children;

  const _VerifiedSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.strokeLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'VERIFIED IDENTIFICATION',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.headingDark,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.surfaceF0),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _EncryptionFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.surfaceF0)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, color: AppColors.gold, size: 14),
          SizedBox(width: 6),
          Text(
            'SECURE ENCRYPTION ACTIVE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.neutralAAA,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
