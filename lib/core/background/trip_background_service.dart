import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:goapp/core/service/background_service.dart';
class TripBackgroundService {
  TripBackgroundService._();

  static const bool _enabled = bool.fromEnvironment(
    'ENABLE_TRIP_BG_SERVICE',
    defaultValue: false,
  );

  static bool _configured = false;
  static bool _observerAttached = false;

  static Future<void> initialize() async {
    if (!_enabled) return;
    if (_configured) return;

    await BackgroundService.configure();

    _configured = true;
    _attachLifecycleObserver();
  }

  static Future<void> startTrip({
    required String title,
    required String subtitle,
    required Duration duration,
  }) async {
    if (!_enabled) return;
    await initialize();
    if (!await BackgroundService.instance.isRunning()) {
      await BackgroundService.instance.startService();
    }
    BackgroundService.instance.invoke(BackgroundService.startTripEvent, <String, dynamic>{
      'title': title,
      'subtitle': subtitle,
      'duration_ms': duration.inMilliseconds,
    });
  }

  static Future<void> stopTrip() async {
    if (!_enabled) return;
    if (!_configured) return;
    if (!await BackgroundService.instance.isRunning()) return;
    BackgroundService.instance.invoke(BackgroundService.stopTripEvent);
  }

  static void _attachLifecycleObserver() {
    if (_observerAttached) return;
    WidgetsBinding.instance.addObserver(_TripServiceLifecycleObserver());
    _observerAttached = true;
  }
}

class _TripServiceLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      unawaited(TripBackgroundService.stopTrip());
    }
  }
}
