import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:goapp/core/storage/text_field_store.dart';
import 'package:goapp/core/storage/user_cache_store.dart';

import '../model/document_upload_model.dart';
import '../../../document_verify/presentation/model/document_model.dart';
import '../../../document_verify/presentation/model/document_progress_store.dart';

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
      accountHolderName: DocumentProgressStore.bankDraftValue(
        'accountHolderName',
      ),
      bankName: DocumentProgressStore.bankDraftValue('bankName'),
      accountNumber: DocumentProgressStore.bankDraftValue('accountNumber'),
      confirmAccountNumber: DocumentProgressStore.bankDraftValue(
        'confirmAccountNumber',
      ),
      ifscCode: DocumentProgressStore.bankDraftValue('ifscCode'),
      bankDocumentPath: DocumentProgressStore.frontImagePath(
        DocumentType.bankDetails,
      ),
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

  static const int _maxBytes = 5 * 1024 * 1024;

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

  bool _validateFileSize(int sizeBytes) {
    return sizeBytes > 0 && sizeBytes <= _maxBytes;
  }

  bool _isValidImageFormat(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png');
  }

  Future<void> captureProfilePhoto({required ImageSource source}) async {
    if (state.isCurrentStepBank || !state.isCurrentStepProfile) return;
    if (_isPicking) return;
    if (state.currentDocStep.imageError != null) {
      emit(
        state.copyWithDocStep(
          state.currentDocStep.copyWith(clearImageError: true),
        ),
      );
    }
    if (_isTest) {
      const testPath = 'test_profile.jpg';
      DocumentProgressStore.setProfileImagePath(testPath);
      await TextFieldStore.write(_profilePhotoStorageKey, testPath);
      final updated = state.currentDocStep.copyWith(
        frontCaptured: true,
        frontPath: testPath,
        frontType: DocumentUploadType.image,
        clearImageError: true,
      );
      emit(state.copyWithDocStep(updated));
      return;
    }
    if (!await _ensurePermission(source)) return;

    _isPicking = true;
    emit(state.copyWith(isProfileImageProcessing: true));
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 100);
      if (picked == null) return;

      if (!_isValidImageFormat(picked.path)) {
        emit(
          state.copyWithDocStep(
            state.currentDocStep.copyWith(
              imageError: 'Only JPG and PNG images are allowed.',
            ),
          ),
        );
        return;
      }

      final fileSize = await File(picked.path).length();
      final pickedSize = await picked.length();
      final bytes = await picked.readAsBytes();
      final sizeBytes = [
        fileSize,
        pickedSize,
        bytes.length,
      ].reduce((a, b) => a > b ? a : b);
      if (!_validateFileSize(sizeBytes)) {
        emit(
          state.copyWithDocStep(
            state.currentDocStep.copyWith(
              imageError: 'File size must be under 5 MB',
            ),
          ),
        );
        return;
      }

      DocumentProgressStore.setProfileImagePath(picked.path);
      await TextFieldStore.write(_profilePhotoStorageKey, picked.path);
      final updated = state.currentDocStep.copyWith(
        frontCaptured: true,
        frontPath: picked.path,
        frontType: DocumentUploadType.image,
        clearImageError: true,
      );
      emit(state.copyWithDocStep(updated));
    } finally {
      _isPicking = false;
      emit(state.copyWith(isProfileImageProcessing: false));
    }
  }

  Future<void> captureFront({required ImageSource source}) async {
    if (state.isCurrentStepBank || state.isCurrentStepProfile) return;
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
      final picked = await _picker.pickImage(source: source, imageQuality: 100);
      if (picked == null) return;

      final fileSize = await File(picked.path).length();
      final pickedSize = await picked.length();
      final bytes = await picked.readAsBytes();
      final sizeBytes = [
        fileSize,
        pickedSize,
        bytes.length,
      ].reduce((a, b) => a > b ? a : b);
      if (!_validateFileSize(sizeBytes)) {
        emit(
          state.copyWithDocStep(
            state.currentDocStep.copyWith(
              imageError: 'File size must be under 5 MB',
            ),
          ),
        );
        return;
      }

      DocumentProgressStore.setFrontImagePath(
        _mapStepToDocType(state.currentDocStep.step),
        picked.path,
      );
      final updated = state.currentDocStep.copyWith(
        frontCaptured: true,
        frontPath: picked.path,
        frontType: DocumentUploadType.image,
      );
      emit(state.copyWithDocStep(updated));
    } finally {
      _isPicking = false;
    }
  }

  Future<void> captureFrontDocument() async {
    if (state.isCurrentStepBank || state.isCurrentStepProfile) return;
    if (_isPicking) return;
    if (state.currentDocStep.imageError != null) {
      emit(
        state.copyWithDocStep(
          state.currentDocStep.copyWith(clearImageError: true),
        ),
      );
    }
    if (_isTest) {
      final updated = state.currentDocStep.copyWith(
        frontCaptured: true,
        frontType: DocumentUploadType.document,
      );
      emit(state.copyWithDocStep(updated));
      return;
    }

    _isPicking = true;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'doc', 'docx'],
        withData: false,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      if (!_validateFileSize(file.size)) {
        emit(
          state.copyWithDocStep(
            state.currentDocStep.copyWith(
              imageError: 'File size must be under 5 MB',
            ),
          ),
        );
        return;
      }

      DocumentProgressStore.setFrontImagePath(
        _mapStepToDocType(state.currentDocStep.step),
        file.path,
      );
      final updated = state.currentDocStep.copyWith(
        frontCaptured: true,
        frontPath: file.path,
        frontType: DocumentUploadType.document,
      );
      emit(state.copyWithDocStep(updated));
    } finally {
      _isPicking = false;
    }
  }

  Future<void> captureBack({required ImageSource source}) async {
    if (state.isCurrentStepBank || state.isCurrentStepProfile) return;
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

      final fileSize = await File(picked.path).length();
      final pickedSize = await picked.length();
      final bytes = await picked.readAsBytes();
      final sizeBytes = [
        fileSize,
        pickedSize,
        bytes.length,
      ].reduce((a, b) => a > b ? a : b);
      if (!_validateFileSize(sizeBytes)) {
        emit(
          state.copyWithDocStep(
            state.currentDocStep.copyWith(
              imageError: 'File size must be under 5 MB',
            ),
          ),
        );
        return;
      }

      DocumentProgressStore.setBackImagePath(
        _mapStepToDocType(state.currentDocStep.step),
        picked.path,
      );
      final updated = state.currentDocStep.copyWith(
        backCaptured: true,
        backPath: picked.path,
        backType: DocumentUploadType.image,
      );
      emit(state.copyWithDocStep(updated));
    } finally {
      _isPicking = false;
    }
  }

  Future<void> captureBackDocument() async {
    if (state.isCurrentStepBank || state.isCurrentStepProfile) return;
    if (_isPicking) return;
    if (state.currentDocStep.imageError != null) {
      emit(
        state.copyWithDocStep(
          state.currentDocStep.copyWith(clearImageError: true),
        ),
      );
    }
    if (_isTest) {
      final updated = state.currentDocStep.copyWith(
        backCaptured: true,
        backType: DocumentUploadType.document,
      );
      emit(state.copyWithDocStep(updated));
      return;
    }

    _isPicking = true;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'doc', 'docx'],
        withData: false,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      if (!_validateFileSize(file.size)) {
        emit(
          state.copyWithDocStep(
            state.currentDocStep.copyWith(
              imageError: 'File size must be under 5 MB',
            ),
          ),
        );
        return;
      }

      DocumentProgressStore.setBackImagePath(
        _mapStepToDocType(state.currentDocStep.step),
        file.path,
      );
      final updated = state.currentDocStep.copyWith(
        backCaptured: true,
        backPath: file.path,
        backType: DocumentUploadType.document,
      );
      emit(state.copyWithDocStep(updated));
    } finally {
      _isPicking = false;
    }
  }

  void removeFront() {
    if (state.isCurrentStepBank || state.isCurrentStepProfile) return;
    DocumentProgressStore.setFrontImagePath(
      _mapStepToDocType(state.currentDocStep.step),
      null,
    );
    final updated = state.currentDocStep.copyWith(
      frontCaptured: false,
      clearFrontUpload: true,
      clearImageError: true,
    );
    emit(state.copyWithDocStep(updated));
  }

  void removeBack() {
    if (state.isCurrentStepBank || state.isCurrentStepProfile) return;
    DocumentProgressStore.setBackImagePath(
      _mapStepToDocType(state.currentDocStep.step),
      null,
    );
    final updated = state.currentDocStep.copyWith(
      backCaptured: false,
      clearBackUpload: true,
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
    if (state.isCurrentStepBank || state.isCurrentStepProfile) return;
    final raw = value.trim();
    final normalized = _normalizeDocumentNumber(state.currentDocStep.step, raw);
    final hasValue = raw.isNotEmpty;
    final error = hasValue
        ? _validateDocumentNumber(state.currentDocStep.step, normalized)
        : null;
    final updated = state.currentDocStep.copyWith(
      documentNumber: raw,
      numberError: error,
      clearError: error == null,
    );
    DocumentProgressStore.setDocumentNumber(
      _mapStepToDocType(updated.step),
      normalized,
    );
    emit(state.copyWithDocStep(updated));
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

  Future<void> captureBankDocument({required ImageSource source}) async {
    if (!state.isCurrentStepBank) return;
    if (_isPicking) return;
    if (!await _ensurePermission(source)) return;

    _isPicking = true;
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );
      if (picked == null) return;

      final fileSize = await File(picked.path).length();
      final pickedSize = await picked.length();
      final bytes = await picked.readAsBytes();
      final sizeBytes = [
        fileSize,
        pickedSize,
        bytes.length,
      ].reduce((a, b) => a > b ? a : b);
      if (!_validateFileSize(sizeBytes)) {
        emit(
          state.copyWith(
            bankData: state.bankData.copyWith(
              bankDocumentError: 'File size must be under 5 MB',
            ),
          ),
        );
        return;
      }

      DocumentProgressStore.setFrontImagePath(
        DocumentType.bankDetails,
        picked.path,
      );
      final updated = state.bankData.copyWith(
        bankDocumentPath: picked.path,
        bankDocumentType: DocumentUploadType.image,
        clearBankDocumentError: true,
      );
      emit(state.copyWith(bankData: updated));
    } finally {
      _isPicking = false;
    }
  }

  Future<void> captureBankDocumentFile() async {
    if (!state.isCurrentStepBank) return;
    if (_isPicking) return;

    _isPicking = true;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'doc', 'docx'],
        withData: false,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      if (!_validateFileSize(file.size)) {
        emit(
          state.copyWith(
            bankData: state.bankData.copyWith(
              bankDocumentError: 'File size must be under 5 MB',
            ),
          ),
        );
        return;
      }

      DocumentProgressStore.setFrontImagePath(
        DocumentType.bankDetails,
        file.path,
      );
      final updated = state.bankData.copyWith(
        bankDocumentPath: file.path,
        bankDocumentType: DocumentUploadType.document,
        clearBankDocumentError: true,
      );
      emit(state.copyWith(bankData: updated));
    } finally {
      _isPicking = false;
    }
  }

  void removeBankDocument() {
    if (!state.isCurrentStepBank) return;
    DocumentProgressStore.setFrontImagePath(DocumentType.bankDetails, null);
    final updated = state.bankData.copyWith(
      clearBankDocument: true,
      clearBankDocumentError: true,
    );
    emit(state.copyWith(bankData: updated));
  }

  bool _validateDocStep() {
    final step = state.currentDocStep;
    if (step.step == DocumentStep.profilePhoto) {
      if (step.frontCaptured) {
        DocumentProgressStore.setProfileImagePath(step.frontPath);
        return true;
      }
      emit(
        state.copyWithDocStep(
          step.copyWith(
            imageError: 'Please upload your profile picture before proceeding.',
            clearError: true,
          ),
        ),
      );
      return false;
    }
    if (!step.frontCaptured || !step.backCaptured) {
      final updated = step.copyWith(
        numberError: 'Please upload both front and back documents',
        imageError: 'Please upload both front and back documents',
      );
      emit(state.copyWithDocStep(updated));
      DocumentProgressStore.setCompleted(_mapStepToDocType(step.step), false);
      return false;
    }

    final rawValue = step.documentNumber.trim();
    if (rawValue.isEmpty) {
      final updated = step.copyWith(numberError: 'Document number is required');
      emit(state.copyWithDocStep(updated));
      DocumentProgressStore.setCompleted(_mapStepToDocType(step.step), false);
      return false;
    }

    final normalized = _normalizeDocumentNumber(step.step, rawValue);
    final error = _validateDocumentNumber(step.step, normalized);
    if (error != null) {
      final updated = step.copyWith(numberError: error);
      emit(state.copyWithDocStep(updated));
      DocumentProgressStore.setCompleted(_mapStepToDocType(step.step), false);
      return false;
    }

    if (normalized != step.documentNumber) {
      final updated = step.copyWith(
        documentNumber: normalized,
        clearError: true,
        clearImageError: true,
      );
      emit(state.copyWithDocStep(updated));
    }
    if (step.imageError != null) {
      emit(state.copyWithDocStep(step.copyWith(clearImageError: true)));
    }
    // Step validity is fully verified above, so persist completion directly.
    DocumentProgressStore.setCompleted(_mapStepToDocType(step.step), true);

    return true;
  }

  String _normalizeDocumentNumber(DocumentStep step, String value) {
    switch (step) {
      case DocumentStep.profilePhoto:
        return value.trim();
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
      case DocumentStep.profilePhoto:
        return null;
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

    if (b.accountHolderName.trim().isNotEmpty &&
        !RegExp(r'^[A-Z ]+$')
            .hasMatch(b.accountHolderName.trim().toUpperCase())) {
      updated = updated.copyWith(
        nameError: 'Only alphabets are allowed',
      );
      valid = false;
    } else {
      final profileName = UserCacheStore.read()?.fullName ?? '';
      final enteredName = _normalizePersonName(b.accountHolderName);
      final savedName = _normalizePersonName(profileName);
      if (savedName.isNotEmpty && enteredName != savedName) {
        updated = updated.copyWith(
          nameError: 'Account holder name must match your profile full name',
        );
        valid = false;
      }
    }
    if (b.bankName.trim().isEmpty) {
      updated = updated.copyWith(bankNameError: 'Bank name is required');
      valid = false;
    } else if (!RegExp(
      r'^[A-Z ]+$',
    ).hasMatch(b.bankName.trim().toUpperCase())) {
      updated = updated.copyWith(bankNameError: 'Only alphabets are allowed');
      valid = false;
    }
    if (b.accountNumber.trim().isEmpty) {
      updated = updated.copyWith(
        accountNumberError: 'Account number is required',
      );
      valid = false;
    } else if (!RegExp(
      r'^[A-Z0-9]+$',
    ).hasMatch(b.accountNumber.trim().toUpperCase())) {
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
    } else if (!RegExp(
      r'^[A-Z0-9]+$',
    ).hasMatch(b.confirmAccountNumber.trim().toUpperCase())) {
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
    if (b.bankDocumentPath == null || b.bankDocumentPath!.trim().isEmpty) {
      updated = updated.copyWith(
        bankDocumentError: 'Please upload bank document',
      );
      valid = false;
    }

    if (!valid) {
      emit(state.copyWith(bankData: updated));
    }
    return valid;
  }

  String _normalizePersonName(String value) {
    return value.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<void> saveAndNext() async {
    if (state.isSubmitting || _isPicking || state.isProfileImageProcessing) {
      return;
    }
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
      emit(state.copyWith(isSubmitting: true));
      if (!_validateDocStep()) {
        emit(state.copyWith(isSubmitting: false));
        return;
      }
      emit(
        state.copyWith(
          isSubmitting: false,
          currentStepIndex: state.currentStepIndex + 1,
        ),
      );
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
