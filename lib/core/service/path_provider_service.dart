import 'dart:io';

import 'package:flutter/services.dart';

/// Wrapper so feature code doesn't import `path_provider`.
class PathProviderService {
  const PathProviderService();

  static const MethodChannel _channel =
      MethodChannel('app/path_provider_service');

  Future<Directory> getApplicationDocumentsDirectory() async {
    final String? path = await _channel.invokeMethod<String>(
      'getApplicationDocumentsDirectory',
    );
    if (path == null || path.isEmpty) {
      throw StateError('Unable to resolve documents directory.');
    }
    return Directory(path);
  }
}

