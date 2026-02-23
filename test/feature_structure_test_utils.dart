import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void runFeatureStructureTests({
  required String featureName,
  required List<String> expectedTopLevelDirs,
  bool requireDartFiles = true,
}) {
  group('$featureName feature structure', () {
    final root = Directory('lib/features/$featureName');

    test('feature directory exists', () {
      expect(root.existsSync(), isTrue);
    });

    test('contains Dart source files', () {
      final dartFiles = root
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      if (requireDartFiles) {
        expect(dartFiles.isNotEmpty, isTrue);
      } else {
        expect(dartFiles.length, greaterThanOrEqualTo(0));
      }
    });

    for (final dir in expectedTopLevelDirs) {
      test('contains top-level "$dir" directory', () {
        expect(Directory('lib/features/$featureName/$dir').existsSync(), isTrue);
      });
    }
  });
}
