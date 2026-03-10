import 'dart:io';

import 'package:path_provider/path_provider.dart' as path_provider;

/// Wrapper so feature code doesn't import `path_provider`.
class PathProviderService {
  const PathProviderService();

  Future<Directory> getApplicationDocumentsDirectory() {
    return path_provider.getApplicationDocumentsDirectory();
  }
}

