import 'package:equatable/equatable.dart';

import '../model/document_model.dart';

abstract class DocumentsState extends Equatable {
  const DocumentsState();

  @override
  List<Object?> get props => [];
}

class DocumentsInitial extends DocumentsState {
  const DocumentsInitial();
}

class DocumentsLoading extends DocumentsState {
  const DocumentsLoading();
}

class DocumentsLoaded extends DocumentsState {
  final List<DocumentModel> documents;
  final bool allVerified;

  const DocumentsLoaded({required this.documents, required this.allVerified});

  @override
  List<Object?> get props => [documents, allVerified];
}

class DocumentsError extends DocumentsState {
  final String message;

  const DocumentsError(this.message);

  @override
  List<Object?> get props => [message];
}
