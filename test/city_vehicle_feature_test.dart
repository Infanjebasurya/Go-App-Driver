import 'package:flutter_test/flutter_test.dart';

import 'feature_structure_test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  runFeatureStructureTests(
    featureName: 'city_vehicle',
    expectedTopLevelDirs: <String>[
      'city_selection',
      'vehicle_details',
      'vehicle_selection',
    ],
  );
}
