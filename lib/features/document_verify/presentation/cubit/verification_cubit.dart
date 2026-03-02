import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/document_verify/presentation/cubit/verification_state.dart';

import '../model/document_model.dart';
import '../model/document_progress_store.dart';

class VerificationCubit extends Cubit<VerificationState> {
  VerificationCubit() : super(VerificationState.initial()) {
    syncFromStore();
  }

  void syncFromStore() {
    final updatedDocs = state.documents.map((doc) {
      final completed = DocumentProgressStore.isCompleted(doc.type);
      return doc.copyWith(
        status: completed ? DocumentStatus.completed : DocumentStatus.required,
      );
    }).toList();
    emit(state.copyWith(documents: updatedDocs));
  }

  Future<void> uploadDocument(DocumentType type) async {
    final updatedDocs = state.documents.map((doc) {
      if (doc.type == type) {
        return doc.copyWith(status: DocumentStatus.uploading);
      }
      return doc;
    }).toList();

    emit(state.copyWith(documents: updatedDocs, clearError: true));

    await Future.delayed(const Duration(seconds: 2));

    final completedDocs = state.documents.map((doc) {
      if (doc.type == type) {
        return doc.copyWith(
          status: DocumentStatus.completed,
          filePath:
          'uploaded/${type.name}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }
      return doc;
    }).toList();

    emit(state.copyWith(documents: completedDocs));
  }


  void completeBankDetails(BankDetails details) {
    final updatedDocs = state.documents.map((doc) {
      if (doc.type == DocumentType.bankDetails) {
        return doc.copyWith(
          status: DocumentStatus.completed,
          bankDetails: details,
        );
      }
      return doc;
    }).toList();
    emit(state.copyWith(documents: updatedDocs, clearError: true));
  }

  void removeDocument(DocumentType type) {
    final updatedDocs = state.documents.map((doc) {
      if (doc.type == type && doc.isCompleted) {

        return doc.copyWith(
          status: DocumentStatus.required,
          filePath: null,
          clearBankDetails: type == DocumentType.bankDetails,
        );
      }
      return doc;
    }).toList();
    emit(state.copyWith(documents: updatedDocs));
  }

  Future<void> submitForReview() async {
    final syncedDocs = state.documents.map((doc) {
      final completed = DocumentProgressStore.isCompleted(doc.type);
      return doc.copyWith(
        status: completed ? DocumentStatus.completed : DocumentStatus.required,
      );
    }).toList();
    final canSubmit = syncedDocs.every((doc) => doc.isCompleted);

    if (!canSubmit) {
      // Clear stale error first so repeated invalid submits emit a new state.
      emit(
        state.copyWith(
          documents: syncedDocs,
          clearError: true,
        ),
      );
      emit(
        state.copyWith(
          documents: syncedDocs,
          errorMessage:
          'Please complete all required documents before submitting.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        documents: syncedDocs,
        isSubmitting: true,
        clearError: true,
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    emit(state.copyWith(isSubmitting: false, isSubmitted: true));
  }

  void reset() {
    emit(VerificationState.initial());
  }

  void clearSubmitted() {
    emit(state.copyWith(isSubmitted: false));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
