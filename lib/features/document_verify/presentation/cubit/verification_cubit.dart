import 'package:flutter_bloc/flutter_bloc.dart';

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

  void removeDocument(DocumentType type) {
    final updatedDocs = state.documents.map((doc) {
      if (doc.type == type && doc.isCompleted) {
        return doc.copyWith(status: DocumentStatus.required, filePath: null);
      }
      return doc;
    }).toList();
    emit(state.copyWith(documents: updatedDocs));
  }

  Future<void> submitForReview() async {
    if (!state.canSubmit) {
      emit(
        state.copyWith(
          errorMessage:
              'Please complete all required documents before submitting.',
        ),
      );
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));

    await Future.delayed(const Duration(seconds: 2));

    emit(state.copyWith(isSubmitting: false, isSubmitted: true));
  }

  void reset() {
    emit(VerificationState.initial());
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
