import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/help_support/domain/entities/help_entities.dart';

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

  const ComplaintFormState({
    this.selectedCategoryId,
    this.description = '',
    this.showCategoryPicker = false,
    this.isSubmitting = false,
  });

  ComplaintFormState copyWith({
    String? selectedCategoryId,
    String? description,
    bool? showCategoryPicker,
    bool? isSubmitting,
  }) {
    return ComplaintFormState(
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      description: description ?? this.description,
      showCategoryPicker: showCategoryPicker ?? this.showCategoryPicker,
      isSubmitting: isSubmitting ?? this.isSubmitting,
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
  ];
}

class ComplaintSubmitted extends ComplaintState {
  final String ticketId;

  const ComplaintSubmitted({required this.ticketId});

  @override
  List<Object?> get props => [ticketId];
}

class ComplaintCubit extends Cubit<ComplaintState> {
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

  Future<void> submitComplaint() async {
    if (state is! ComplaintFormState) return;
    final formState = state as ComplaintFormState;
    if (!formState.isValid) return;

    emit(formState.copyWith(isSubmitting: true));
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    emit(const ComplaintSubmitted(ticketId: '#GP-BB421'));
  }

  void reset() {
    emit(const ComplaintFormState());
  }
}
