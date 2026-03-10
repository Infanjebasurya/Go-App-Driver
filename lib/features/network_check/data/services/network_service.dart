import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NetworkService {
  static const MethodChannel _method = MethodChannel('native_network');
  static const EventChannel _events = EventChannel('native_network_updates');

  Future<bool> isConnected() async {
    if (const bool.fromEnvironment('FLUTTER_TEST') || kIsWeb) {
      return true;
    }
    try {
      return (await _method.invokeMethod<bool>('isConnected')) ?? true;
    } on MissingPluginException {
      return true;
    } on PlatformException {
      return true;
    }
  }

  Stream<bool> onConnectivityChanged() {
    if (const bool.fromEnvironment('FLUTTER_TEST') || kIsWeb) {
      return const Stream<bool>.empty();
    }
    final controller = StreamController<bool>();
    StreamSubscription? subscription;

    controller.onListen = () {
      try {
        subscription = _events.receiveBroadcastStream().listen(
          (event) => controller.add(event == true),
          onError: (_) {},
        );
      } catch (_) {
        controller.add(true);
        controller.close();
      }
    };

    controller.onCancel = () async {
      await subscription?.cancel();
    };

    return controller.stream;
  }
}
