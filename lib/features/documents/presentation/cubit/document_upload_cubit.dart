import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goapp/core/storage/text_field_store.dart';

import '../model/document_upload_model.dart';
import '../services/document_number_rules.dart';
import '../services/document_upload_file_service.dart';
import '../../../document_verify/presentation/model/document_model.dart';
import '../../../document_verify/presentation/model/document_progress_store.dart';

part 'document_upload_cubit_capture.dart';
part 'document_upload_cubit_validation.dart';

class DocumentUploadCubit extends Cubit<DocumentUploadState> {
  static const String _profilePhotoStorageKey = 'profile.photo.path';

  DocumentUploadCubit({int initialStepIndex = 0})
    : super(
        DocumentUploadState.initial().copyWith(
          currentStepIndex: initialStepIndex,
        ),
      ) {
    _restoreDraft();
  }

  final ImagePicker _picker = ImagePicker();
  final DocumentUploadFileService _fileService = const DocumentUploadFileService();
  final bool _isTest = const bool.fromEnvironment('FLUTTER_TEST');
  bool _isPicking = false;

  void _restoreDraft() {
    final updatedSteps = state.steps.map((step) {
      if (step.step == DocumentStep.profilePhoto) {
        final profilePath = DocumentProgressStore.profileImagePath();
        if (profilePath != null && profilePath.trim().isNotEmpty) {
          DocumentProgressStore.setProfileImagePath(profilePath);
        }
        return step.copyWith(
          frontCaptured: profilePath != null && profilePath.trim().isNotEmpty,
          frontPath: profilePath,
          frontType: profilePath == null ? null : DocumentUploadType.image,
          clearError: true,
          clearImageError: true,
        );
      }
      final docType = _mapStepToDocType(step.step);
      final frontPath = DocumentProgressStore.frontImagePath(docType);
      final backPath = DocumentProgressStore.backImagePath(docType);
      final storedNumber = DocumentProgressStore.documentNumber(docType);
      final frontType = _inferUploadType(frontPath);
      final backType = _inferUploadType(backPath);
      return step.copyWith(
        frontCaptured: frontPath != null,
        backCaptured: backPath != null,
        frontPath: frontPath,
        backPath: backPath,
        frontType: frontType,
        backType: backType,
        documentNumber: storedNumber ?? step.documentNumber,
        clearError: true,
        clearImageError: true,
      );
    }).toList();
    final restoredBankData = state.bankData.copyWith(
      accountHolderName: DocumentProgressStore.bankDraftValue('accountHolderName'),
      bankName: DocumentProgressStore.bankDraftValue('bankName'),
      accountNumber: DocumentProgressStore.bankDraftValue('accountNumber'),
      confirmAccountNumber: DocumentProgressStore.bankDraftValue('confirmAccountNumber'),
      ifscCode: DocumentProgressStore.bankDraftValue('ifscCode'),
      bankDocumentPath: DocumentProgressStore.frontImagePath(DocumentType.bankDetails),
      bankDocumentType: _inferUploadType(
        DocumentProgressStore.frontImagePath(DocumentType.bankDetails),
      ),
      clearNameError: true,
      clearBankNameError: true,
      clearAccountNumberError: true,
      clearConfirmError: true,
      clearIfscError: true,
      clearBankDocumentError: true,
    );
    emit(state.copyWith(steps: updatedSteps, bankData: restoredBankData));
  }

  DocumentType _mapStepToDocType(DocumentStep step) {
    switch (step) {
      case DocumentStep.profilePhoto:
        throw ArgumentError('Profile photo is not mapped to DocumentType');
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

  DocumentUploadType? _inferUploadType(String? path) {
    if (path == null || path.isEmpty) return null;
    final lower = path.toLowerCase();
    if (lower.endsWith('.pdf') ||
        lower.endsWith('.doc') ||
        lower.endsWith('.docx')) {
      return DocumentUploadType.document;
    }
    return DocumentUploadType.image;
  }

  Future<void> captureProfilePhoto({required ImageSource source}) {
    return _captureProfilePhoto(this, source: source);
  }

  Future<void> captureFront({required ImageSource source}) {
    return _captureFront(this, source: source);
  }

  Future<void> captureFrontDocument() {
    return _captureFrontDocument(this);
  }

  Future<void> captureBack({required ImageSource source}) {
    return _captureBack(this, source: source);
  }

  Future<void> captureBackDocument() {
    return _captureBackDocument(this);
  }

  Future<void> removeFront() {
    return _removeFront(this);
  }

  Future<void> removeBack() {
    return _removeBack(this);
  }

  void updateDocumentNumber(String value) {
    _updateDocumentNumber(this, value);
  }

  void updateAccountHolderName(String value) {
    final normalized = value.toUpperCase();
    DocumentProgressStore.setBankDraftValue('accountHolderName', normalized);
    final trimmed = normalized.trim();
    final valid = trimmed.isEmpty || RegExp(r'^[A-Z ]+$').hasMatch(trimmed);
    final updated = state.bankData.copyWith(
      accountHolderName: normalized,
      clearNameError: valid,
    );
    emit(state.copyWith(bankData: updated));
  }

  void updateBankName(String value) {
    final normalized = value.toUpperCase();
    DocumentProgressStore.setBankDraftValue('bankName', normalized);
    final updated = state.bankData.copyWith(
      bankName: normalized,
      clearBankNameError: normalized.trim().isNotEmpty,
    );
    emit(state.copyWith(bankData: updated));
  }

  void updateAccountNumber(String value) {
    final normalized = value.toUpperCase();
    DocumentProgressStore.setBankDraftValue('accountNumber', normalized);
    final updated = state.bankData.copyWith(
      accountNumber: normalized,
      clearAccountNumberError: normalized.trim().isNotEmpty,
    );
    emit(state.copyWith(bankData: updated));
  }

  void updateConfirmAccountNumber(String value) {
    final normalized = value.toUpperCase();
    DocumentProgressStore.setBankDraftValue('confirmAccountNumber', normalized);
    final updated = state.bankData.copyWith(
      confirmAccountNumber: normalized,
      clearConfirmError: normalized.trim().isNotEmpty,
    );
    emit(state.copyWith(bankData: updated));
  }

  void updateIfscCode(String value) {
    final normalized = value.toUpperCase();
    DocumentProgressStore.setBankDraftValue('ifscCode', normalized);
    final updated = state.bankData.copyWith(
      ifscCode: normalized,
      clearIfscError: normalized.trim().isNotEmpty,
    );
    emit(state.copyWith(bankData: updated));
  }

  Future<void> captureBankDocument({required ImageSource source}) {
    return _captureBankDocument(this, source: source);
  }

  Future<void> captureBankDocumentFile() {
    return _captureBankDocumentFile(this);
  }

  Future<void> removeBankDocument() {
    return _removeBankDocument(this);
  }

  Future<void> saveAndNext() {
    return _saveAndNext(this);
  }

  void _emitState(DocumentUploadState nextState) {
    if (isClosed) return;
    emit(nextState);
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
