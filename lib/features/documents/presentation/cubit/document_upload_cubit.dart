import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:goapp/core/storage/registration_progress_store.dart';

import '../model/document_upload_model.dart';
import '../../../document_verify/presentation/model/document_model.dart';
import '../../../document_verify/presentation/model/document_progress_store.dart';

class DocumentUploadCubit extends Cubit<DocumentUploadState> {
  DocumentUploadCubit({int initialStepIndex = 0})
      : super(_buildInitialState(initialStepIndex)) {
    unawaited(
      RegistrationProgressStore.setStep(
        RegistrationStep.documentUpload,
        documentStepIndex: initialStepIndex,
      ),
    );
  }

  final ImagePicker _picker = ImagePicker();
  final bool _isTest = const bool.fromEnvironment('FLUTTER_TEST');
  bool _isPicking = false;

  static DocumentUploadState _buildInitialState(int initialStepIndex) {
    final steps = [
      DocumentStep.drivingLicense,
      DocumentStep.vehicleRC,
      DocumentStep.identityAadhaar,
      DocumentStep.identityPan,
    ].map((step) {
      final type = _mapStepToDocTypeStatic(step);
      final front = DocumentProgressStore.frontImagePath(type) != null;
      final back = DocumentProgressStore.backImagePath(type) != null;
      final number = DocumentProgressStore.documentNumber(type) ?? '';
      return StepData(
        step: step,
        frontCaptured: front,
        backCaptured: back,
        documentNumber: number,
      );
    }).toList();

    return DocumentUploadState(
      currentStepIndex: initialStepIndex,
      steps: steps,
      bankData: const BankAccountData(),
    );
  }

  static DocumentType _mapStepToDocTypeStatic(DocumentStep step) {
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
      emit(state.copyWithDocStep(state.currentDocStep.copyWith(clearImageError: true)));
    }
    if (_isTest) {
      final updated = state.currentDocStep.copyWith(frontCaptured: true);
      emit(state.copyWithDocStep(updated));
      return;
    }
    if (!await _ensurePermission(source)) return;

    _isPicking = true;
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );
      if (picked == null) return;

      final sizeBytes = await _readFileSize(picked);
      const maxBytes = 5 * 1024 * 1024;
      if (sizeBytes <= 0 || sizeBytes > maxBytes) {
        emit(
          state.copyWithDocStep(
            state.currentDocStep.copyWith(
              imageError:
                  'Image size should not exceed 5MB. Please select an image under 5MB.',
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
      emit(state.copyWithDocStep(state.currentDocStep.copyWith(clearImageError: true)));
    }
    if (_isTest) {
      final updated = state.currentDocStep.copyWith(backCaptured: true);
      emit(state.copyWithDocStep(updated));
      return;
    }
    if (!await _ensurePermission(source)) return;

    _isPicking = true;
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );
      if (picked == null) return;

      final sizeBytes = await _readFileSize(picked);
      const maxBytes = 5 * 1024 * 1024;
      if (sizeBytes <= 0 || sizeBytes > maxBytes) {
        emit(
          state.copyWithDocStep(
            state.currentDocStep.copyWith(
              imageError:
                  'Image size should not exceed 5MB. Please select an image under 5MB.',
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
    final updated =
        state.currentDocStep.copyWith(frontCaptured: false, clearImageError: true);
    emit(state.copyWithDocStep(updated));
  }

  void removeBack() {
    if (state.isCurrentStepBank) return;
    DocumentProgressStore.setBackImagePath(
      _mapStepToDocType(state.currentDocStep.step),
      null,
    );
    final updated =
        state.currentDocStep.copyWith(backCaptured: false, clearImageError: true);
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

  Future<int> _readFileSize(XFile file) async {
    try {
      final len = await file.length();
      if (len > 0) return len;
    } catch (_) {}
    try {
      final stat = await File(file.path).stat();
      return stat.size;
    } catch (_) {
      return 0;
    }
  }

  void updateDocumentNumber(String value) {
    if (state.isCurrentStepBank) return;
    final updated = state.currentDocStep.copyWith(
      documentNumber: value,
      clearError: value.trim().isNotEmpty,
    );
    DocumentProgressStore.setDocumentNumber(
      _mapStepToDocType(updated.step),
      value,
    );
    DocumentProgressStore.setCompleted(
      _mapStepToDocType(updated.step),
      updated.isNumberValid,
    );
    emit(state.copyWithDocStep(updated));
  }

  void updateAccountHolderName(String value) {
    final updated = state.bankData.copyWith(
      accountHolderName: value,
      clearNameError: value.trim().isNotEmpty,
    );
    DocumentProgressStore.setCompleted(
      DocumentType.bankDetails,
      updated.isComplete && !updated.hasErrors,
    );
    emit(state.copyWith(bankData: updated));
  }

  void updateAccountNumber(String value) {
    final updated = state.bankData.copyWith(
      accountNumber: value,
      clearAccountNumberError: value.trim().isNotEmpty,
    );
    DocumentProgressStore.setCompleted(
      DocumentType.bankDetails,
      updated.isComplete && !updated.hasErrors,
    );
    emit(state.copyWith(bankData: updated));
  }

  void updateConfirmAccountNumber(String value) {
    final updated = state.bankData.copyWith(
      confirmAccountNumber: value,
      clearConfirmError: value.trim().isNotEmpty,
    );
    DocumentProgressStore.setCompleted(
      DocumentType.bankDetails,
      updated.isComplete && !updated.hasErrors,
    );
    emit(state.copyWith(bankData: updated));
  }

  void updateIfscCode(String value) {
    final updated = state.bankData.copyWith(
      ifscCode: value,
      clearIfscError: value.trim().isNotEmpty,
    );
    DocumentProgressStore.setCompleted(
      DocumentType.bankDetails,
      updated.isComplete && !updated.hasErrors,
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
        return value.toUpperCase().trim();
      case DocumentStep.identityAadhaar:
        return value.trim();
      case DocumentStep.identityPan:
        return value.toUpperCase().trim();
      case DocumentStep.bankAccount:
        return value.trim();
    }
  }

  String? _validateDocumentNumber(DocumentStep step, String value) {
    switch (step) {
      case DocumentStep.drivingLicense:
        if (value.length != 15 ||
            !RegExp(r'^[A-Z]{2}\d{2}\d{4}\d{7}$').hasMatch(value)) {
          return 'Enter valid license number (e.g. MH1220180012345)';
        }
        return null;
      case DocumentStep.vehicleRC:
        if (value.length < 6 ||
            value.length > 13 ||
            !RegExp(r'^[A-Z]{2}\d{1,2}[A-Z]{0,3}\d{4}$').hasMatch(
              value.replaceAll(' ', ''),
            )) {
          return 'Enter valid vehicle number (e.g. TN01AB1234)';
        }
        return null;
      case DocumentStep.identityAadhaar:
        if (!RegExp(r'^\d{12}$').hasMatch(value)) {
          return 'Aadhaar Number must be 12 digits.';
        }
        return null;
      case DocumentStep.identityPan:
        if (value.length != 10 ||
            !RegExp(r'^[A-Z]{5}\d{4}[A-Z]$').hasMatch(value)) {
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
    }
    if (b.accountNumber.trim().isEmpty) {
      updated = updated.copyWith(accountNumberError: 'Account number is required');
      valid = false;
    }
    if (b.confirmAccountNumber.trim().isEmpty) {
      updated = updated.copyWith(confirmAccountNumberError: 'Please confirm account number');
      valid = false;
    } else if (b.confirmAccountNumber != b.accountNumber) {
      updated = updated.copyWith(confirmAccountNumberError: 'Account numbers do not match');
      valid = false;
    }
    if (b.ifscCode.trim().isEmpty) {
      updated = updated.copyWith(ifscError: 'IFSC code is required');
      valid = false;
    } else if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(b.ifscCode.trim().toUpperCase())) {
      updated = updated.copyWith(ifscError: 'Enter a valid IFSC code');
      valid = false;
    }

    if (!valid) {
      emit(state.copyWith(bankData: updated));
    }
    return valid;
  }

  Future<void> saveAndNext() async {
    if (state.isSubmitting) return;
    if (state.isCurrentStepBank) {
      if (!_validateBankStep()) return;
      DocumentProgressStore.setCompleted(
        DocumentType.bankDetails,
        state.bankData.isComplete,
      );
      emit(state.copyWith(isSubmitting: true));
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(isSubmitting: false, isAllDone: true));
      unawaited(
        RegistrationProgressStore.setStep(
          RegistrationStep.verificationSubmitted,
          clearDocumentStep: true,
        ),
      );
    } else {
      if (!_validateDocStep()) return;
      DocumentProgressStore.setCompleted(
        _mapStepToDocType(state.currentDocStep.step),
        state.currentDocStep.isNumberValid,
      );
      final nextIndex = state.currentStepIndex + 1;
      emit(state.copyWith(currentStepIndex: nextIndex));
      unawaited(
        RegistrationProgressStore.setStep(
          RegistrationStep.documentUpload,
          documentStepIndex: nextIndex,
        ),
      );
    }
  }

  void goBack() {
    if (state.canGoBack) {
      final nextIndex = state.currentStepIndex - 1;
      emit(state.copyWith(currentStepIndex: nextIndex));
      unawaited(
        RegistrationProgressStore.setStep(
          RegistrationStep.documentUpload,
          documentStepIndex: nextIndex,
        ),
      );
    }
  }

  void jumpToStep(int index) {
    if (index >= 0 && index < state.totalSteps) {
      emit(state.copyWith(currentStepIndex: index));
      unawaited(
        RegistrationProgressStore.setStep(
          RegistrationStep.documentUpload,
          documentStepIndex: index,
        ),
      );
    }
  }

  void reset() {
    if (isClosed) return;
    emit(DocumentUploadState.initial());
  }
}
