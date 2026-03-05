import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/storage/text_field_store.dart';
import 'package:goapp/features/rate_app/data/repositories/rate_app_repository_impl.dart';
import 'package:goapp/features/rate_app/domain/usecases/submit_rate_app_review_usecase.dart';
import 'package:goapp/features/rate_app/presentation/cubit/rate_app_state.dart';

class RateAppCubit extends Cubit<RateAppState> {
  RateAppCubit({SubmitRateAppReviewUseCase? submitRateAppReview})
    : _submitRateAppReview =
          submitRateAppReview ??
          SubmitRateAppReviewUseCase(const RateAppRepositoryImpl()),
      super(const RateAppState()) {
    final stored = TextFieldStore.read('rate_app.feedback') ?? '';
    if (stored.isNotEmpty) {
      updateFeedback(stored);
    }
  }

  final SubmitRateAppReviewUseCase _submitRateAppReview;

  void selectRating(int rating) {
    if (state.status == RateAppStatus.submitting ||
        state.status == RateAppStatus.submitted) {
      return;
    }
    emit(state.copyWith(selectedRating: rating, status: RateAppStatus.idle));
  }

  void updateFeedback(String text) {
    if (state.status == RateAppStatus.submitting ||
        state.status == RateAppStatus.submitted) {
      return;
    }
    unawaited(TextFieldStore.write('rate_app.feedback', text));
    emit(state.copyWith(feedbackText: text));
  }

  Future<void> submitReview() async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: RateAppStatus.submitting));

    try {
      await _submitRateAppReview(
        rating: state.selectedRating,
        feedback: state.feedbackText,
      );
      emit(state.copyWith(status: RateAppStatus.submitted));
    } catch (_) {
      emit(
        state.copyWith(
          status: RateAppStatus.error,
          errorMessage: 'Failed to submit review. Please try again.',
        ),
      );
    }
  }

  void reset() {
    emit(const RateAppState());
  }
}
