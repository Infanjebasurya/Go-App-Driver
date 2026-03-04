import 'package:goapp/features/rate_app/data/datasources/rate_app_mock_api.dart';
import 'package:goapp/features/rate_app/domain/repositories/rate_app_repository.dart';

class RateAppRepositoryImpl implements RateAppRepository {
  const RateAppRepositoryImpl({RateAppMockApi? api})
    : _api = api ?? const RateAppMockApi();

  final RateAppMockApi _api;

  @override
  Future<void> submitReview({
    required int rating,
    required String feedback,
  }) {
    return _api.submitReview(rating: rating, feedback: feedback);
  }
}
