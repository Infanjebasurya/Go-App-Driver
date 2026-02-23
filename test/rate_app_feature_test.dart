import 'package:flutter_test/flutter_test.dart';

import 'feature_structure_test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  runFeatureStructureTests(
    featureName: 'rate_app',
    expectedTopLevelDirs: <String>['presentation'],
  );
}
