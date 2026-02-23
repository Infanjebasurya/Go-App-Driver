import 'package:goapp/features/ride_complete/domain/entities/ride_completion_summary.dart';
import 'package:goapp/features/ride_complete/domain/entities/ride_feedback.dart';
import 'package:goapp/features/ride_complete/domain/repositories/ride_complete_repository.dart';

class RideCompleteRepositoryImpl implements RideCompleteRepository {
  @override
  RideCompletionSummary getRideCompletionSummary() {
    return const RideCompletionSummary(
      totalEarnings: 1250.50,
      distanceKm: 2.5,
      tripFare: 1300.00,
      tips: 50.00,
      discountPercent: 10,
      discountAmount: 100.00,
      paymentLink: 'https://your-payment-link.com/ride123',
      driverName: 'Sam Yogi',
      driverRating: 4.9,
      avatarAssetPath: 'assets/image/profile.png',
    );
  }

  @override
  List<String> getFeedbackTags() {
    return const <String>['Professional', 'Punctual', 'Polite', 'Quiet Ride'];
  }

  @override
  Future<void> submitFeedback(RideFeedback feedback) async {}
}
