import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/document_upload_model.dart';
import '../../../document_verify/presentation/model/document_model.dart';
import '../../../document_verify/presentation/model/document_progress_store.dart';

class DocumentUploadCubit extends Cubit<DocumentUploadState> {
  DocumentUploadCubit({int initialStepIndex = 0})
      : super(DocumentUploadState.initial().copyWith(
          currentStepIndex: initialStepIndex,
        ));

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

  void captureFront() {
    if (state.isCurrentStepBank) return;
    final updated = state.currentDocStep.copyWith(frontCaptured: true);
    emit(state.copyWithDocStep(updated));
  }

  void captureBack() {
    if (state.isCurrentStepBank) return;
    final updated = state.currentDocStep.copyWith(backCaptured: true);
    emit(state.copyWithDocStep(updated));
  }

  void removeFront() {
    if (state.isCurrentStepBank) return;
    final updated = state.currentDocStep.copyWith(frontCaptured: false);
    emit(state.copyWithDocStep(updated));
  }

  void removeBack() {
    if (state.isCurrentStepBank) return;
    final updated = state.currentDocStep.copyWith(backCaptured: false);
    emit(state.copyWithDocStep(updated));
  }

  void updateDocumentNumber(String value) {
    if (state.isCurrentStepBank) return;
    final updated = state.currentDocStep.copyWith(
      documentNumber: value,
      clearError: value.trim().isNotEmpty,
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
      updated.isComplete,
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
      updated.isComplete,
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
      updated.isComplete,
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
        return value
            .toUpperCase()
            .replaceAll(RegExp(r'[^A-Z0-9]'), '');
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
