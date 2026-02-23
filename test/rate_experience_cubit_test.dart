import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/ride_complete/domain/entities/ride_completion_summary.dart';
import 'package:goapp/features/ride_complete/domain/entities/ride_feedback.dart';
import 'package:goapp/features/ride_complete/domain/repositories/ride_complete_repository.dart';
import 'package:goapp/features/ride_complete/domain/usecases/get_feedback_tags.dart';
import 'package:goapp/features/ride_complete/domain/usecases/submit_ride_feedback.dart';
import 'package:goapp/features/ride_complete/presentation/cubit/rate_experience_cubit.dart';

class _FakeRideCompleteRepository implements RideCompleteRepository {
  RideFeedback? lastSubmittedFeedback;

  @override
  RideCompletionSummary getRideCompletionSummary() {
    return const RideCompletionSummary(
      totalEarnings: 0,
      distanceKm: 0,
      tripFare: 0,
      tips: 0,
      discountPercent: 0,
      discountAmount: 0,
      paymentLink: '',
      driverName: '',
      driverRating: 0,
      avatarAssetPath: '',
    );
  }

  @override
  List<String> getFeedbackTags() {
    return const <String>['Professional', 'Punctual'];
  }

  @override
  Future<void> submitFeedback(RideFeedback feedback) async {
    lastSubmittedFeedback = feedback;
  }
}

void main() {
  group('RateExperienceCubit', () {
    late _FakeRideCompleteRepository repository;
    late RateExperienceCubit cubit;

    setUp(() {
      repository = _FakeRideCompleteRepository();
      cubit = RateExperienceCubit(
        GetFeedbackTags(repository),
        SubmitRideFeedback(repository),
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('loads feedback tags on init', () {
      expect(cubit.state.feedbackTags, <String>['Professional', 'Punctual']);
      expect(cubit.state.selectedRating, 4);
    });

    test('selectRating updates rating', () {
      cubit.selectRating(5);
      expect(cubit.state.selectedRating, 5);
    });

    test('toggleTag adds and removes tag', () {
      cubit.toggleTag('Professional');
      expect(cubit.state.selectedTags.contains('Professional'), isTrue);

      cubit.toggleTag('Professional');
      expect(cubit.state.selectedTags.contains('Professional'), isFalse);
    });

    test('submitFeedback passes selected values to use case', () async {
      cubit.selectRating(3);
      cubit.toggleTag('Punctual');
      cubit.updateComment('Smooth ride');

      await cubit.submitFeedback();

      expect(repository.lastSubmittedFeedback, isNotNull);
      expect(repository.lastSubmittedFeedback!.rating, 3);
      expect(repository.lastSubmittedFeedback!.tags, <String>{'Punctual'});
      expect(repository.lastSubmittedFeedback!.comment, 'Smooth ride');
    });
  });
}
