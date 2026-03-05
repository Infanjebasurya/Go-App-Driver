import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../document_verify/presentation/model/document_progress_store.dart';
import '../../../document_verify/presentation/model/document_model.dart'
    show DocumentType;
import '../model/document_model.dart';
import 'documents_state.dart';

class DocumentsCubit extends Cubit<DocumentsState> {
  DocumentsCubit() : super(const DocumentsInitial()) {
    loadDocuments();
  }

  static const String _bankAccountId = 'bank_account';

  static const List<DocumentModel> _defaultDocuments = [
    DocumentModel(
      id: 'driving_license',
      title: 'Driving License',
      subtitle: 'STANDARD CLASSA',
      iconAsset: 'driving_license',
      status: DocumentStatus.verified,
    ),
    DocumentModel(
      id: 'vehicle_rc',
      title: 'Vehicle RC',
      subtitle: 'REGISTRATION CARD',
      iconAsset: 'vehicle_rc',
      status: DocumentStatus.verified,
    ),
    DocumentModel(
      id: 'aadhaar_card',
      title: 'Aadhaar Card',
      subtitle: 'IDENTITY PROOF',
      iconAsset: 'aadhaar_card',
      status: DocumentStatus.verified,
    ),
    DocumentModel(
      id: 'pan_card',
      title: 'PAN Card',
      subtitle: 'TAX IDENTIFICATION',
      iconAsset: 'pan_card',
      status: DocumentStatus.verified,
    ),
    DocumentModel(
      id: _bankAccountId,
      title: 'Linked Bank Account',
      subtitle: 'BANK TRANSFER',
      iconAsset: _bankAccountId,
      status: DocumentStatus.verified,
    ),
  ];

  Future<void> loadDocuments() async {
    emit(const DocumentsLoading());
    await Future.delayed(const Duration(milliseconds: 800));
    final docs = _defaultDocuments.map(_applyProgress).toList();
    final allVerified = docs.every((d) => d.status == DocumentStatus.verified);
    emit(DocumentsLoaded(documents: docs, allVerified: allVerified));
  }

  void updateDocumentStatus(String id, DocumentStatus newStatus) {
    if (state is! DocumentsLoaded) return;
    final current = state as DocumentsLoaded;
    final updated = current.documents.map((doc) {
      if (doc.id == id) return doc.copyWith(status: newStatus);
      return doc;
    }).toList();
    final allVerified = updated.every(
      (d) => d.status == DocumentStatus.verified,
    );
    emit(DocumentsLoaded(documents: updated, allVerified: allVerified));
  }

  void refresh() => loadDocuments();

  DocumentModel _applyProgress(DocumentModel doc) {
    switch (doc.id) {
      case 'driving_license':
        return _withProgress(
          doc,
          DocumentProgressStore.frontImagePath(DocumentType.drivingLicense),
          DocumentProgressStore.backImagePath(DocumentType.drivingLicense),
          DocumentProgressStore.documentNumber(DocumentType.drivingLicense),
        );
      case 'vehicle_rc':
        return _withProgress(
          doc,
          DocumentProgressStore.frontImagePath(DocumentType.vehicleRC),
          DocumentProgressStore.backImagePath(DocumentType.vehicleRC),
          DocumentProgressStore.documentNumber(DocumentType.vehicleRC),
        );
      case 'aadhaar_card':
        return _withProgress(
          doc,
          DocumentProgressStore.frontImagePath(DocumentType.aadhaarCard),
          DocumentProgressStore.backImagePath(DocumentType.aadhaarCard),
          DocumentProgressStore.documentNumber(DocumentType.aadhaarCard),
        );
      case 'pan_card':
        return _withProgress(
          doc,
          DocumentProgressStore.frontImagePath(DocumentType.panCard),
          DocumentProgressStore.backImagePath(DocumentType.panCard),
          DocumentProgressStore.documentNumber(DocumentType.panCard),
        );
      case _bankAccountId:
        final accountNumber = DocumentProgressStore.bankDraftValue(
          'accountNumber',
        );
        final bankDocPath = DocumentProgressStore.frontImagePath(
          DocumentType.bankDetails,
        );
        final completed = DocumentProgressStore.isCompleted(
          DocumentType.bankDetails,
        );
        final status = completed
            ? DocumentStatus.verified
            : DocumentStatus.notUploaded;
        return doc.copyWith(
          status: status,
          frontImagePath: bankDocPath?.trim().isEmpty ?? true
              ? null
              : bankDocPath,
          documentNumber: accountNumber.trim().isEmpty
              ? null
              : accountNumber,
        );
      default:
        return doc;
    }
  }

  DocumentModel _withProgress(
    DocumentModel doc,
    String? frontPath,
    String? backPath,
    String? number,
  ) {
    final hasImages =
        (frontPath?.isNotEmpty ?? false) && (backPath?.isNotEmpty ?? false);
    final status = hasImages
        ? DocumentStatus.verified
        : DocumentStatus.notUploaded;
    return doc.copyWith(
      status: status,
      frontImagePath: frontPath,
      backImagePath: backPath,
      documentNumber: number?.trim().isEmpty ?? true ? null : number,
    );
  }

}
