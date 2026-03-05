import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Home to Ride Complete flow files', () {
    const List<String> requiredFiles = <String>[
      // Home flow pages
      'lib/features/home/presentation/pages/home_page.dart',
      'lib/features/home/presentation/pages/available_orders_page.dart',
      'lib/features/home/presentation/pages/ride_arrived_page.dart',
      'lib/features/home/presentation/pages/enter_ride_code_page.dart',
      'lib/features/home/presentation/pages/passenger_onboard_page.dart',
      'lib/features/home/presentation/pages/trip_navigation_page.dart',
      // Home flow cubits/states
      'lib/features/home/presentation/cubit/driver_status_cubit.dart',
      'lib/features/home/presentation/cubit/driver_status_state.dart',
      'lib/features/home/presentation/cubit/available_orders_cubit.dart',
      'lib/features/home/presentation/cubit/available_orders_state.dart',
      'lib/features/home/presentation/cubit/enter_ride_code_cubit.dart',
      'lib/features/home/presentation/cubit/enter_ride_code_state.dart',
      'lib/features/home/presentation/cubit/trip_navigation_cubit.dart',
      'lib/features/home/presentation/cubit/trip_navigation_state.dart',
      // Ride complete flow pages
      'lib/features/ride_complete/presentation/pages/ride_completed_screen.dart',
      'lib/features/ride_complete/presentation/pages/rate_experience_screen.dart',
      // Ride complete flow cubit/domain files
      'lib/features/ride_complete/presentation/cubit/ride_completed_cubit.dart',
      'lib/features/ride_complete/presentation/cubit/ride_completed_state.dart',
      'lib/features/ride_complete/domain/usecases/get_ride_completion_summary.dart',
      'lib/features/ride_complete/domain/usecases/submit_ride_feedback.dart',
    ];

    for (final String path in requiredFiles) {
      test('exists: $path', () {
        expect(File(path).existsSync(), isTrue);
      });
    }
  });
}
