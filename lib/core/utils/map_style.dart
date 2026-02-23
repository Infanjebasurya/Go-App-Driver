import 'package:flutter/services.dart';

import 'app_assets.dart';

class MapStyle {
  const MapStyle._();

  static Future<String> load() {
    return rootBundle.loadString(AppAssets.mapStyleDefault);
  }

  static Future<String> loadBooking() {
    return rootBundle.loadString(AppAssets.mapStyleBooking);
  }
}
