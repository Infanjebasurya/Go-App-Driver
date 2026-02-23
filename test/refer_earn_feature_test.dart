import 'package:flutter_test/flutter_test.dart';

import 'feature_structure_test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  runFeatureStructureTests(
    featureName: 'refer_earn',
    expectedTopLevelDirs: <String>['domain', 'presentation'],
  );
}
