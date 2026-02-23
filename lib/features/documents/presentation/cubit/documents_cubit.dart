import 'package:flutter_bloc/flutter_bloc.dart';

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
      title: 'Add Bank Account',
      subtitle: 'BANK TRANSFER',
      iconAsset: _bankAccountId,
      status: DocumentStatus.verified,
    ),
  ];

  Future<void> loadDocuments() async {
    emit(const DocumentsLoading());
    await Future.delayed(const Duration(milliseconds: 800));
    final docs = List<DocumentModel>.from(_defaultDocuments);
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
}
