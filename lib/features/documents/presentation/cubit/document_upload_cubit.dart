import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:goapp/core/storage/text_field_store.dart';

import '../model/document_upload_model.dart';
import '../../../document_verify/presentation/model/document_model.dart';
import '../../../document_verify/presentation/model/document_progress_store.dart';

class DocumentUploadCubit extends Cubit<DocumentUploadState> {
  DocumentUploadCubit({int initialStepIndex = 0})
      : super(
    DocumentUploadState.initial().copyWith(
      currentStepIndex: initialStepIndex,
    ),
  ) {
    _restoreDraft();
  }

  final ImagePicker _picker = ImagePicker();
  final bool _isTest = const bool.fromEnvironment('FLUTTER_TEST');
  bool _isPicking = false;

  static const String _docPrefix = 'documents';
  static const String _bankPrefix = 'bank_details';

  String _docNumberKey(DocumentStep step) {
    switch (step) {
      case DocumentStep.drivingLicense:
        return '$_docPrefix.driving_license.number';
      case DocumentStep.vehicleRC:
        return '$_docPrefix.vehicle_rc.number';
      case DocumentStep.identityAadhaar:
        return '$_docPrefix.aadhaar.number';
      case DocumentStep.identityPan:
        return '$_docPrefix.pan.number';
      case DocumentStep.bankAccount:
        return '$_docPrefix.bank.number';
    }
  }

  String _bankKey(String field) => '$_bankPrefix.$field';

  void _restoreDraft() {
    final updatedSteps = state.steps.map((step) {
      final stored = TextFieldStore.read(_docNumberKey(step.step)) ?? '';
      if (stored.isEmpty) return step;
      return step.copyWith(documentNumber: stored, clearError: true);
    }).toList();
    final bankData = state.bankData.copyWith(
      accountHolderName:
          TextFieldStore.read(_bankKey('account_holder')) ?? '',
      accountNumber: TextFieldStore.read(_bankKey('account_number')) ?? '',
      confirmAccountNumber:
          TextFieldStore.read(_bankKey('confirm_account_number')) ?? '',
      ifscCode: TextFieldStore.read(_bankKey('ifsc')) ?? '',
    );
    emit(state.copyWith(steps: updatedSteps, bankData: bankData));
  }

  DocumentType _mapStepToDocType(DocumentStep step) {
    switch (step) {
      case DocumentStep.drivingLicense:
        return DocumentType.drivingLicense;
      case DocumentStep.vehicleRC:
        return DocumentType.vehicleRC;
      case DocumentStep.identityAadhaar:
        return DocumentType.aadhaarCard;
      case DocumentStep.identityPan:
        return DocumentType.panCard;
      case DocumentStep.bankAccount:
        return DocumentType.bankDetails;
    }
  }

  Future<void> captureFront({required ImageSource source}) async {
    if (state.isCurrentStepBank) return;
    if (_isPicking) return;
    if (state.currentDocStep.imageError != null) {
      emit(
        state.copyWithDocStep(
          state.currentDocStep.copyWith(clearImageError: true),
        ),
      );
    }
    if (_isTest) {
      final updated = state.currentDocStep.copyWith(frontCaptured: true);
      emit(state.copyWithDocStep(updated));
      return;
    }
    if (!await _ensurePermission(source)) return;

    _isPicking = true;
    try {
      final picked = await _picker.pickImage(source: source);
      if (picked == null) return;

      final sizeBytes = await picked.length();
      const maxBytes = 1024 * 1024;
      if (sizeBytes > maxBytes) {
        emit(
          state.copyWithDocStep(
            state.currentDocStep.copyWith(
              imageError: 'Image must be less than 1 MB',
            ),
          ),
        );
        return;
      }

      DocumentProgressStore.setFrontImagePath(
        _mapStepToDocType(state.currentDocStep.step),
        picked.path,
      );
      final updated = state.currentDocStep.copyWith(frontCaptured: true);
      emit(state.copyWithDocStep(updated));
    } finally {
      _isPicking = false;
    }
  }

  Future<void> captureBack({required ImageSource source}) async {
    if (state.isCurrentStepBank) return;
    if (_isPicking) return;
    if (state.currentDocStep.imageError != null) {
      emit(
        state.copyWithDocStep(
          state.currentDocStep.copyWith(clearImageError: true),
        ),
      );
    }
    if (_isTest) {
      final updated = state.currentDocStep.copyWith(backCaptured: true);
      emit(state.copyWithDocStep(updated));
      return;
    }
    if (!await _ensurePermission(source)) return;

    _isPicking = true;
    try {
      final picked = await _picker.pickImage(source: source);
      if (picked == null) return;

      final sizeBytes = await picked.length();
      const maxBytes = 1024 * 1024;
      if (sizeBytes > maxBytes) {
        emit(
          state.copyWithDocStep(
            state.currentDocStep.copyWith(
              imageError: 'Image must be less than 1 MB',
            ),
          ),
        );
        return;
      }

      DocumentProgressStore.setBackImagePath(
        _mapStepToDocType(state.currentDocStep.step),
        picked.path,
      );
      final updated = state.currentDocStep.copyWith(backCaptured: true);
      emit(state.copyWithDocStep(updated));
    } finally {
      _isPicking = false;
    }
  }

  void removeFront() {
    if (state.isCurrentStepBank) return;
    DocumentProgressStore.setFrontImagePath(
      _mapStepToDocType(state.currentDocStep.step),
      null,
    );
    final updated = state.currentDocStep.copyWith(
      frontCaptured: false,
      clearImageError: true,
    );
    emit(state.copyWithDocStep(updated));
  }

  void removeBack() {
    if (state.isCurrentStepBank) return;
    DocumentProgressStore.setBackImagePath(
      _mapStepToDocType(state.currentDocStep.step),
      null,
    );
    final updated = state.currentDocStep.copyWith(
      backCaptured: false,
      clearImageError: true,
    );
    emit(state.copyWithDocStep(updated));
  }

  Future<bool> _ensurePermission(ImageSource source) async {
    if (source == ImageSource.gallery && Platform.isAndroid) {
      return true;
    }

    final Permission permission = source == ImageSource.camera
        ? Permission.camera
        : Permission.photos;

    final status = await permission.status;
    if (status.isGranted) return true;

    final result = await permission.request();
    return result.isGranted;
  }

  void updateDocumentNumber(String value) {
    if (state.isCurrentStepBank) return;
    unawaited(
      TextFieldStore.write(
        _docNumberKey(state.currentDocStep.step),
        value,
      ),
    );
    final updated = state.currentDocStep.copyWith(
      documentNumber: value,
      clearError: value.trim().isNotEmpty,
    );
    DocumentProgressStore.setDocumentNumber(
      _mapStepToDocType(updated.step),
      updated.documentNumber,
    );
    DocumentProgressStore.setCompleted(
      _mapStepToDocType(updated.step),
      updated.isNumberValid,
    );
    emit(state.copyWithDocStep(updated));
  }

  void updateAccountHolderName(String value) {
    final normalized = value.toUpperCase();
    unawaited(TextFieldStore.write(_bankKey('account_holder'), normalized));
    final updated = state.bankData.copyWith(
      accountHolderName: normalized,
      clearNameError: normalized.trim().isNotEmpty,
    );
    DocumentProgressStore.setCompleted(
      DocumentType.bankDetails,
      updated.isComplete,
    );
    emit(state.copyWith(bankData: updated));
  }

  void updateAccountNumber(String value) {
    final normalized = value.toUpperCase();
    unawaited(TextFieldStore.write(_bankKey('account_number'), normalized));
    final updated = state.bankData.copyWith(
      accountNumber: normalized,
      clearAccountNumberError: normalized.trim().isNotEmpty,
    );
    DocumentProgressStore.setCompleted(
      DocumentType.bankDetails,
      updated.isComplete,
    );
    emit(state.copyWith(bankData: updated));
  }

  void updateConfirmAccountNumber(String value) {
    final normalized = value.toUpperCase();
    unawaited(
      TextFieldStore.write(_bankKey('confirm_account_number'), normalized),
    );
    final updated = state.bankData.copyWith(
      confirmAccountNumber: normalized,
      clearConfirmError: normalized.trim().isNotEmpty,
    );
    DocumentProgressStore.setCompleted(
      DocumentType.bankDetails,
      updated.isComplete,
    );
    emit(state.copyWith(bankData: updated));
  }

  void updateIfscCode(String value) {
    final normalized = value.toUpperCase();
    unawaited(TextFieldStore.write(_bankKey('ifsc'), normalized));
    final updated = state.bankData.copyWith(
      ifscCode: normalized,
      clearIfscError: normalized.trim().isNotEmpty,
    );
    DocumentProgressStore.setCompleted(
      DocumentType.bankDetails,
      updated.isComplete,
    );
    emit(state.copyWith(bankData: updated));
  }

  bool _validateDocStep() {
    final step = state.currentDocStep;
    if (!step.frontCaptured || !step.backCaptured) {
      final updated = step.copyWith(
        numberError: 'Please upload both front and back document images',
      );
      emit(state.copyWithDocStep(updated));
      return false;
    }

    final rawValue = step.documentNumber.trim();
    if (rawValue.isEmpty) {
      final updated = step.copyWith(numberError: 'Document number is required');
      emit(state.copyWithDocStep(updated));
      return false;
    }

    final normalized = _normalizeDocumentNumber(step.step, rawValue);
    final error = _validateDocumentNumber(step.step, normalized);
    if (error != null) {
      final updated = step.copyWith(numberError: error);
      emit(state.copyWithDocStep(updated));
      return false;
    }

    if (normalized != step.documentNumber) {
      unawaited(TextFieldStore.write(_docNumberKey(step.step), normalized));
      final updated = step.copyWith(
        documentNumber: normalized,
        clearError: true,
      );
      emit(state.copyWithDocStep(updated));
    }

    return true;
  }

  String _normalizeDocumentNumber(DocumentStep step, String value) {
    switch (step) {
      case DocumentStep.drivingLicense:
      case DocumentStep.vehicleRC:
        return value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
      case DocumentStep.identityAadhaar:
        return value.replaceAll(RegExp(r'[^0-9]'), '');
      case DocumentStep.identityPan:
        return value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
      case DocumentStep.bankAccount:
        return value.trim();
    }
  }

  String? _validateDocumentNumber(DocumentStep step, String value) {
    switch (step) {
      case DocumentStep.drivingLicense:
        if (!RegExp(r'^[A-Z]{2}\d{2}\d{4}\d{7}$').hasMatch(value)) {
          return 'Enter valid license number (e.g. MH1220180012345)';
        }
        return null;
      case DocumentStep.vehicleRC:
        if (!RegExp(r'^[A-Z]{2}\d{1,2}[A-Z]{0,3}\d{4}$').hasMatch(value)) {
          return 'Enter valid vehicle number (e.g. TN01AB1234)';
        }
        return null;
      case DocumentStep.identityAadhaar:
        if (!RegExp(r'^\d{12}$').hasMatch(value)) {
          return 'Aadhaar number must be 12 digits';
        }
        return null;
      case DocumentStep.identityPan:
        if (!RegExp(r'^[A-Z]{5}\d{4}[A-Z]$').hasMatch(value)) {
          return 'Enter valid PAN (e.g. ABCDE1234F)';
        }
        return null;
      case DocumentStep.bankAccount:
        return null;
    }
  }

  bool _validateBankStep() {
    final b = state.bankData;
    BankAccountData updated = b;
    bool valid = true;

    if (b.accountHolderName.trim().isEmpty) {
      updated = updated.copyWith(nameError: 'Account holder name is required');
      valid = false;
    } else if (!RegExp(r'^[A-Z ]+$')
        .hasMatch(b.accountHolderName.trim().toUpperCase())) {
      updated = updated.copyWith(
        nameError: 'Only alphabets are allowed',
      );
      valid = false;
    }
    if (b.accountNumber.trim().isEmpty) {
      updated = updated.copyWith(
        accountNumberError: 'Account number is required',
      );
      valid = false;
    } else if (!RegExp(r'^[A-Z0-9]+$')
        .hasMatch(b.accountNumber.trim().toUpperCase())) {
      updated = updated.copyWith(
        accountNumberError: 'Only alphabets and numbers are allowed',
      );
      valid = false;
    }
    if (b.confirmAccountNumber.trim().isEmpty) {
      updated = updated.copyWith(
        confirmAccountNumberError: 'Please confirm account number',
      );
      valid = false;
    } else if (!RegExp(r'^[A-Z0-9]+$')
        .hasMatch(b.confirmAccountNumber.trim().toUpperCase())) {
      updated = updated.copyWith(
        confirmAccountNumberError: 'Only alphabets and numbers are allowed',
      );
      valid = false;
    } else if (b.confirmAccountNumber != b.accountNumber) {
      updated = updated.copyWith(
        confirmAccountNumberError: 'Account numbers do not match',
      );
      valid = false;
    }
    if (b.ifscCode.trim().isEmpty) {
      updated = updated.copyWith(ifscError: 'IFSC code is required');
      valid = false;
    } else if (!RegExp(
      r'^[A-Z]{4}0[A-Z0-9]{6}$',
    ).hasMatch(b.ifscCode.trim().toUpperCase())) {
      updated = updated.copyWith(ifscError: 'Enter a valid IFSC code');
      valid = false;
    }

    if (!valid) {
      emit(state.copyWith(bankData: updated));
    }
    return valid;
  }

  Future<void> saveAndNext() async {
    if (state.isCurrentStepBank) {
      if (!_validateBankStep()) return;
      DocumentProgressStore.setCompleted(
        DocumentType.bankDetails,
        state.bankData.isComplete,
      );
      emit(state.copyWith(isSubmitting: true));
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(isSubmitting: false, isAllDone: true));
    } else {
      if (!_validateDocStep()) return;
      DocumentProgressStore.setCompleted(
        _mapStepToDocType(state.currentDocStep.step),
        state.currentDocStep.isNumberValid,
      );
      emit(state.copyWith(currentStepIndex: state.currentStepIndex + 1));
    }
  }

  void goBack() {
    if (state.canGoBack) {
      emit(state.copyWith(currentStepIndex: state.currentStepIndex - 1));
    }
  }

  void jumpToStep(int index) {
    if (index >= 0 && index < state.totalSteps) {
      emit(state.copyWith(currentStepIndex: index));
    }
  }

  void reset() {
    if (isClosed) return;
    emit(DocumentUploadState.initial());
  }
}
