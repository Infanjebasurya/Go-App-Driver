import 'package:flutter/material.dart';
import 'package:goapp/core/maps/map_types.dart';

import '../utils/app_assets.dart';

class VehicleIconLoader {
  static BitmapDescriptor? _bike;

  static Future<BitmapDescriptor> loadBikeIcon({
    Size size = const Size(36, 36),
  }) async {
    if (_bike != null) return _bike!;
    _bike = await BitmapDescriptor.asset(
      ImageConfiguration(size: size),
      AppAssets.mapBike,
    );
    return _bike!;
  }
}
