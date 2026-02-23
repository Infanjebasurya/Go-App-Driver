import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/ride_complete/domain/entities/ride_completion_summary.dart';
import 'package:goapp/features/ride_complete/domain/entities/ride_feedback.dart';
import 'package:goapp/features/ride_complete/domain/repositories/ride_complete_repository.dart';
import 'package:goapp/features/ride_complete/domain/usecases/get_ride_completion_summary.dart';
import 'package:goapp/features/ride_complete/presentation/cubit/ride_completed_cubit.dart';

class _FakeRideCompleteRepository implements RideCompleteRepository {
  @override
  RideCompletionSummary getRideCompletionSummary() {
    return const RideCompletionSummary(
      totalEarnings: 1250.50,
      distanceKm: 2.5,
      tripFare: 1300.0,
      tips: 50.0,
      discountPercent: 10,
      discountAmount: 100.0,
      paymentLink: 'https://example.com',
      driverName: 'Sam Yogi',
      driverRating: 4.9,
      avatarAssetPath: 'assets/image/profile.png',
    );
  }

  @override
  List<String> getFeedbackTags() => const <String>[];

  @override
  Future<void> submitFeedback(RideFeedback feedback) async {}
}

void main() {
  group('RideCompletedCubit', () {
    late RideCompletedCubit cubit;

    setUp(() {
      cubit = RideCompletedCubit(
        GetRideCompletionSummary(_FakeRideCompleteRepository()),
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('loads ride summary on init', () {
      expect(cubit.state.summary.driverName, 'Sam Yogi');
      expect(cubit.state.summary.totalEarnings, 1250.50);
      expect(cubit.state.isQrExpanded, isFalse);
    });

    test('toggleQrExpanded flips expanded state', () {
      cubit.toggleQrExpanded();
      expect(cubit.state.isQrExpanded, isTrue);

      cubit.toggleQrExpanded();
      expect(cubit.state.isQrExpanded, isFalse);
    });
  });
}
