import 'package:goapp/features/rate_app/domain/repositories/rate_app_repository.dart';

class SubmitRateAppReviewUseCase {
  const SubmitRateAppReviewUseCase(this._repository);

  final RateAppRepository _repository;

  Future<void> call({
    required int rating,
    required String feedback,
  }) {
    return _repository.submitReview(rating: rating, feedback: feedback);
  }
}
