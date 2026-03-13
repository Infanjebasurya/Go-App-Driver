import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/help_support/domain/entities/help_entities.dart';

enum ComplaintMediaType { image, document, video }

abstract class ComplaintState extends Equatable {
  const ComplaintState();

  @override
  List<Object?> get props => [];
}

class ComplaintInitial extends ComplaintState {}

class ComplaintFormState extends ComplaintState {
  final String? selectedCategoryId;
  final String description;
  final bool showCategoryPicker;
  final bool isSubmitting;
  final String? mediaPath;
  final String? mediaName;
  final ComplaintMediaType? mediaType;
  final String? mediaValidationMessage;

  const ComplaintFormState({
    this.selectedCategoryId,
    this.description = '',
    this.showCategoryPicker = false,
    this.isSubmitting = false,
    this.mediaPath,
    this.mediaName,
    this.mediaType,
    this.mediaValidationMessage,
  });

  ComplaintFormState copyWith({
    String? selectedCategoryId,
    String? description,
    bool? showCategoryPicker,
    bool? isSubmitting,
    String? mediaPath,
    String? mediaName,
    ComplaintMediaType? mediaType,
    String? mediaValidationMessage,
  }) {
    return ComplaintFormState(
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      description: description ?? this.description,
      showCategoryPicker: showCategoryPicker ?? this.showCategoryPicker,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      mediaPath: mediaPath ?? this.mediaPath,
      mediaName: mediaName ?? this.mediaName,
      mediaType: mediaType ?? this.mediaType,
      mediaValidationMessage:
          mediaValidationMessage ?? this.mediaValidationMessage,
    );
  }

  bool get isValid =>
      selectedCategoryId != null && description.trim().isNotEmpty;

  String get categoryName {
    if (selectedCategoryId == null) return 'Select Issue Category';
    return kComplaintCategories
        .firstWhere(
          (c) => c.id == selectedCategoryId,
          orElse: () =>
              const ComplaintCategory(id: '', name: 'Select Issue Category'),
        )
        .name;
  }

  @override
  List<Object?> get props => [
    selectedCategoryId,
    description,
    showCategoryPicker,
    isSubmitting,
    mediaPath,
    mediaName,
    mediaType,
    mediaValidationMessage,
  ];
}

class ComplaintSubmitted extends ComplaintState {
  final SupportTicket ticket;
  final List<SupportTicket> recentTickets;

  const ComplaintSubmitted({required this.ticket, required this.recentTickets});

  @override
  List<Object?> get props => [ticket, recentTickets];
}

class ComplaintCubit extends Cubit<ComplaintState> {
  static final List<SupportTicket> _recentTickets = <SupportTicket>[];
  static List<SupportTicket> get recentTickets =>
      List<SupportTicket>.unmodifiable(_recentTickets);

  ComplaintCubit() : super(const ComplaintFormState());

  void openCategoryPicker() {
    if (state is ComplaintFormState) {
      emit((state as ComplaintFormState).copyWith(showCategoryPicker: true));
    }
  }

  void closeCategoryPicker() {
    if (state is ComplaintFormState) {
      emit((state as ComplaintFormState).copyWith(showCategoryPicker: false));
    }
  }

  void selectCategory(String categoryId) {
    if (state is ComplaintFormState) {
      emit(
        (state as ComplaintFormState).copyWith(
          selectedCategoryId: categoryId,
          showCategoryPicker: false,
        ),
      );
    }
  }

  void updateDescription(String text) {
    if (state is ComplaintFormState) {
      emit((state as ComplaintFormState).copyWith(description: text));
    }
  }

  void attachMedia({
    required String path,
    required String name,
    required ComplaintMediaType mediaType,
  }) {
    if (state is! ComplaintFormState) return;
    final current = state as ComplaintFormState;
    emit(
      current.copyWith(
        mediaPath: path,
        mediaName: name,
        mediaType: mediaType,
        mediaValidationMessage: '',
      ),
    );
  }

  void removeMedia() {
    if (state is! ComplaintFormState) return;
    final current = state as ComplaintFormState;
    emit(
      ComplaintFormState(
        selectedCategoryId: current.selectedCategoryId,
        description: current.description,
        showCategoryPicker: current.showCategoryPicker,
        isSubmitting: current.isSubmitting,
      ),
    );
  }

  void setMediaValidationError(String message) {
    if (state is! ComplaintFormState) return;
    final current = state as ComplaintFormState;
    emit(current.copyWith(mediaValidationMessage: message));
  }

  Future<void> submitComplaint() async {
    if (state is! ComplaintFormState) return;
    final formState = state as ComplaintFormState;
    if (!formState.isValid) return;

    emit(formState.copyWith(isSubmitting: true));
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    final categoryName = _categoryName(formState.selectedCategoryId);
    final ticket = SupportTicket(
      id: _nextTicketId(),
      title: categoryName,
      description: formState.description.trim(),
      status: TicketStatus.open,
      createdAt: DateTime.now(),
    );
    _recentTickets
      ..removeWhere((t) => t.id == ticket.id)
      ..insert(0, ticket);
    emit(
      ComplaintSubmitted(
        ticket: ticket,
        recentTickets: List<SupportTicket>.unmodifiable(_recentTickets),
      ),
    );
  }

  void reset() {
    emit(const ComplaintFormState());
  }

  String _categoryName(String? selectedCategoryId) {
    if (selectedCategoryId == null) {
      return 'General Support';
    }
    final match = kComplaintCategories.where((c) => c.id == selectedCategoryId);
    if (match.isNotEmpty) {
      return match.first.name;
    }
    return 'General Support';
  }

  String _nextTicketId() {
    final stamp = DateTime.now().microsecondsSinceEpoch % 100000;
    final serial = stamp.toString().padLeft(5, '0');
    return 'GP-$serial';
  }
}
