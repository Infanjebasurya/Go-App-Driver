import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/rate_app/presentation/cubit/rate_app_state.dart';

class RateAppCubit extends Cubit<RateAppState> {
  RateAppCubit() : super(const RateAppState());

  void selectRating(int rating) {
    if (state.status == RateAppStatus.submitting ||
        state.status == RateAppStatus.submitted) {
      return;
    }
    emit(
      state.copyWith(
        selectedRating: rating,
        status: RateAppStatus.idle,
      ),
    );
  }

  void updateFeedback(String text) {
    if (state.status == RateAppStatus.submitting ||
        state.status == RateAppStatus.submitted) {
      return;
    }
    emit(state.copyWith(feedbackText: text));
  }

  Future<void> submitReview() async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: RateAppStatus.submitting));

    await Future<void>.delayed(const Duration(milliseconds: 1200));
    emit(state.copyWith(status: RateAppStatus.submitted));
  }

  void reset() {
    emit(const RateAppState());
  }
}
