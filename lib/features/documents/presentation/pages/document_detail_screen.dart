import 'dart:io';

import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/document_verify/presentation/model/document_model.dart'
    show DocumentType;
import 'package:goapp/features/document_verify/presentation/model/document_progress_store.dart';
import 'package:goapp/features/documents/presentation/model/document_model.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';

class DocumentDetailScreen extends StatelessWidget {
  final DocumentModel document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
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
    return AppAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(document.title),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.strokeLight, height: 1),
      ),
    );
  }

  Widget _buildContent() {
    final frontImagePath = _resolvedFrontImagePath();
    final backImagePath = _resolvedBackImagePath();
    final documentNumber = _resolvedDocumentNumber();
    switch (document.iconAsset) {
      case 'driving_license':
        return _DrivingLicenseDetail(
          frontImagePath: frontImagePath,
          backImagePath: backImagePath,
          licenseNumber: documentNumber,
        );
      case 'vehicle_rc':
        return _VehicleRCDetail(
          frontImagePath: frontImagePath,
          backImagePath: backImagePath,
          vehicleNumber: documentNumber,
        );
      case 'aadhaar_card':
        return _AadhaarCardDetail(
          frontImagePath: frontImagePath,
          backImagePath: backImagePath,
          aadhaarNumber: documentNumber,
        );
      case 'pan_card':
        return _PanCardDetail(
          frontImagePath: frontImagePath,
          backImagePath: backImagePath,
          panNumber: documentNumber,
        );
      case 'bank_account':
      case 'add bank account':
        return _BankAccountDetail(frontImagePath: frontImagePath);
      default:
        return _DrivingLicenseDetail(
          frontImagePath: frontImagePath,
          backImagePath: backImagePath,
        );
    }
  }

  DocumentType? _documentTypeFromAsset() {
    switch (document.iconAsset) {
      case 'driving_license':
        return DocumentType.drivingLicense;
      case 'vehicle_rc':
        return DocumentType.vehicleRC;
      case 'aadhaar_card':
        return DocumentType.aadhaarCard;
      case 'pan_card':
        return DocumentType.panCard;
      case 'bank_account':
      case 'add bank account':
        return DocumentType.bankDetails;
      default:
        return null;
    }
  }

  String? _resolvedFrontImagePath() {
    final type = _documentTypeFromAsset();
    final latest = type == null
        ? null
        : DocumentProgressStore.frontImagePath(type);
    if (latest != null && latest.trim().isNotEmpty) return latest;
    return document.frontImagePath;
  }

  String? _resolvedBackImagePath() {
    final type = _documentTypeFromAsset();
    final latest = type == null
        ? null
        : DocumentProgressStore.backImagePath(type);
    if (latest != null && latest.trim().isNotEmpty) return latest;
    return document.backImagePath;
  }

  String? _resolvedDocumentNumber() {
    final type = _documentTypeFromAsset();
    final latest = type == null
        ? null
        : DocumentProgressStore.documentNumber(type);
    if (latest != null && latest.trim().isNotEmpty) return latest;
    return document.documentNumber;
  }
}

class _DrivingLicenseDetail extends StatelessWidget {
  final String? frontImagePath;
  final String? backImagePath;
  final String? licenseNumber;

  const _DrivingLicenseDetail({
    this.frontImagePath,
    this.backImagePath,
    this.licenseNumber,
  });

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
                color: AppColors.hexFF8A9BAE,
                imagePath: frontImagePath,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CardImageBox(
                label: 'BACK VIEW',
                color: AppColors.hexFF2C3A4A,
                imagePath: backImagePath,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _InfoCard(
          children: [
            _InfoRow(
              label: 'LICENSE NUMBER',
              value: licenseNumber?.isNotEmpty == true
                  ? licenseNumber!
                  : '—',
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
  final String? frontImagePath;
  final String? backImagePath;
  final String? vehicleNumber;

  const _VehicleRCDetail({
    this.frontImagePath,
    this.backImagePath,
    this.vehicleNumber,
  });

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
                color: AppColors.hexFF8A9BAE,
                imagePath: frontImagePath,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CardImageBox(
                label: 'BACK VIEW',
                color: AppColors.hexFF2C3A4A,
                imagePath: backImagePath,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _InfoCard(
          children: [
            _InfoRow(
              label: 'VEHICLE NUMBER',
              value: vehicleNumber?.isNotEmpty == true
                  ? vehicleNumber!
                  : '—',
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
  final String? frontImagePath;
  final String? backImagePath;
  final String? aadhaarNumber;

  const _AadhaarCardDetail({
    this.frontImagePath,
    this.backImagePath,
    this.aadhaarNumber,
  });

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
        _CardImageBox(
          label: 'FRONT VIEW',
          color: AppColors.hexFF9EC8B0,
          showVerified: true,
          fullWidth: true,
          imagePath: widget.frontImagePath,
        ),
        const SizedBox(height: 14),
        _CardImageBox(
          label: 'BACK VIEW',
          color: AppColors.hexFFA8C4B8,
          showVerified: true,
          fullWidth: true,
          imagePath: widget.backImagePath,
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
                  _masked
                      ? _maskLast4(widget.aadhaarNumber) ?? '—'
                      : (widget.aadhaarNumber?.isNotEmpty == true
                          ? widget.aadhaarNumber!
                          : '—'),
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

  String? _maskLast4(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.length <= 4) return trimmed;
    final last4 = trimmed.substring(trimmed.length - 4);
    return '****$last4';
  }
}

class _PanCardDetail extends StatefulWidget {
  final String? frontImagePath;
  final String? backImagePath;
  final String? panNumber;

  const _PanCardDetail({
    this.frontImagePath,
    this.backImagePath,
    this.panNumber,
  });

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
        _CardImageBox(
          label: 'FRONT VIEW',
          color: AppColors.hexFF7FB5C8,
          showVerified: true,
          fullWidth: true,
          imagePath: widget.frontImagePath,
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
                  _masked
                      ? _maskLast4(widget.panNumber) ?? '—'
                      : (widget.panNumber?.isNotEmpty == true
                          ? widget.panNumber!
                          : '—'),
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

  String? _maskLast4(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.length <= 4) return trimmed;
    final last4 = trimmed.substring(trimmed.length - 4);
    return '****$last4';
  }
}

class _BankAccountDetail extends StatelessWidget {
  final String? frontImagePath;

  const _BankAccountDetail({this.frontImagePath});

  @override
  Widget build(BuildContext context) {
    final name = _readDraft('accountHolderName');
    final ifsc = _readDraft('ifscCode');
    final account = _maskAccount(_readDraft('accountNumber'));
    final bankName = _readDraft('bankName');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _CardImageBox(
          label: 'BANK DOCUMENT',
          color: AppColors.hexFF8A9BAE,
          fullWidth: true,
          imagePath: frontImagePath,
        ),
        const SizedBox(height: 16),
        _LinkedBankSection(
          children: [
            const SizedBox(height: 12),
            _InfoField(label: 'ACCOUNT HOLDER', value: name ?? '—'),
            const SizedBox(height: 16),
            _InfoField(label: 'BANK NAME', value: bankName ?? '—'),
            const SizedBox(height: 16),
            _InfoField(label: 'IFSC CODE', value: ifsc ?? '—'),
            const SizedBox(height: 16),
            _InfoField(label: 'ACCOUNT NUMBER', value: account ?? '—'),
          ],
        ),
      ],
    );
  }

  String? _readDraft(String field) {
    final raw = DocumentProgressStore.bankDraftValue(field);
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _maskAccount(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length <= 4) return value;
    final last4 = value.substring(value.length - 4);
    return '****$last4';
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
  final String? imagePath;

  const _CardImageBox({
    required this.label,
    required this.color,
    this.showVerified = false,
    this.fullWidth = false,
    this.imagePath,
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
            _ImageBox(imagePath: imagePath, color: color, fullWidth: fullWidth),
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
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.08),
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

class _ImageBox extends StatelessWidget {
  final String? imagePath;
  final Color color;
  final bool fullWidth;

  const _ImageBox({
    required this.imagePath,
    required this.color,
    required this.fullWidth,
  });

  @override
  Widget build(BuildContext context) {
    final width = fullWidth ? double.infinity : null;
    final height = fullWidth ? 160.0 : 90.0;
    final isDocument = _isDocumentPath(imagePath);
    if (imagePath == null || imagePath!.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Icon(
            Icons.credit_card,
            color: AppColors.white.withValues(alpha: 0.3),
            size: 36,
          ),
        ),
      );
    }
    if (isDocument) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.description_rounded,
                color: AppColors.white,
                size: 36,
              ),
              const SizedBox(height: 6),
              Text(
                _basename(imagePath),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.file(
        File(imagePath!),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              Icons.credit_card,
              color: AppColors.white.withValues(alpha: 0.3),
              size: 36,
            ),
          ),
        ),
      ),
    );
  }

  bool _isDocumentPath(String? path) {
    if (path == null || path.isEmpty) return false;
    final lower = path.toLowerCase();
    return lower.endsWith('.pdf') ||
        lower.endsWith('.doc') ||
        lower.endsWith('.docx');
  }

  String _basename(String? path) {
    if (path == null || path.isEmpty) return '';
    final normalized = path.replaceAll('\\', '/');
    final idx = normalized.lastIndexOf('/');
    return idx >= 0 ? normalized.substring(idx + 1) : normalized;
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.strokeLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
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
      mainAxisAlignment: MainAxisAlignment.start,
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
        const SizedBox(height: 8),
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.strokeLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

class _LinkedBankSection extends StatelessWidget {
  final List<Widget> children;

  const _LinkedBankSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.strokeLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BANK DETAILS',
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





