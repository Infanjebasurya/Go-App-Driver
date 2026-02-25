import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class TripBackgroundService {
  TripBackgroundService._();

  static const String _startTripEvent = 'start_trip';
  static const String _stopTripEvent = 'stop_trip';
  static const int _serviceNotificationId = 4101;

  static final FlutterBackgroundService _service = FlutterBackgroundService();
  static bool _configured = false;
  static bool _observerAttached = false;

  static Future<void> initialize() async {
    if (_configured) return;

    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        autoStartOnBoot: false,
        isForegroundMode: true,
        initialNotificationTitle: 'GoApp Driver',
        initialNotificationContent: 'Trip tracking idle',
        foregroundServiceNotificationId: _serviceNotificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
      ),
    );

    _configured = true;
    _attachLifecycleObserver();
  }

  static Future<void> startTrip({
    required String title,
    required String subtitle,
    required Duration duration,
  }) async {
    await initialize();
    if (!await _service.isRunning()) {
      await _service.startService();
    }
    _service.invoke(_startTripEvent, <String, dynamic>{
      'title': title,
      'subtitle': subtitle,
      'duration_ms': duration.inMilliseconds,
    });
  }

  static Future<void> stopTrip() async {
    if (!_configured) return;
    if (!await _service.isRunning()) return;
    _service.invoke(_stopTripEvent);
  }

  static void _attachLifecycleObserver() {
    if (_observerAttached) return;
    WidgetsBinding.instance.addObserver(_TripServiceLifecycleObserver());
    _observerAttached = true;
  }

  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) {
    WidgetsFlutterBinding.ensureInitialized();

    Timer? ticker;

    void updateForegroundNotification({
      required String title,
      required String content,
    }) {
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(title: title, content: content);
      }
    }

    void setIdleState() {
      updateForegroundNotification(
        title: 'GoApp Driver',
        content: 'Trip tracking stopped',
      );
    }

    service.on(_startTripEvent).listen((Map<String, dynamic>? data) {
      ticker?.cancel();
      final String title = (data?['title'] as String?) ?? 'Trip in progress';
      final String subtitle =
          (data?['subtitle'] as String?) ?? 'Driver is moving';
      final int durationMs = (data?['duration_ms'] as int?) ?? 10000;
      final int safeDurationMs = math.max(1000, durationMs);
      final Stopwatch stopwatch = Stopwatch()..start();

      updateForegroundNotification(title: title, content: '$subtitle (0%)');

      ticker = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        final int progress =
            ((stopwatch.elapsedMilliseconds / safeDurationMs) * 100)
                .round()
                .clamp(0, 100);

        if (progress >= 100) {
          updateForegroundNotification(
            title: title,
            content: '$subtitle (100%)',
          );
          timer.cancel();
          return;
        }

        updateForegroundNotification(
          title: title,
          content: '$subtitle ($progress%)',
        );
      });
    });

    service.on(_stopTripEvent).listen((_) {
      ticker?.cancel();
      setIdleState();
      service.stopSelf();
    });

    service.on('stopService').listen((_) {
      ticker?.cancel();
      service.stopSelf();
    });

    setIdleState();
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
