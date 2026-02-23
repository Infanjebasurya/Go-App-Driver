import 'package:flutter/services.dart';

class NativeNetworkService {
  static const MethodChannel _method = MethodChannel('native_network');
  static const EventChannel _events = EventChannel('native_network_updates');

  Future<bool> isConnected() async {
    if (const bool.fromEnvironment('FLUTTER_TEST')) return true;
    return (await _method.invokeMethod<bool>('isConnected')) ?? true;
  }

  Stream<bool> connectivityStream() {
    if (const bool.fromEnvironment('FLUTTER_TEST')) {
      return const Stream<bool>.empty();
    }
    return _events.receiveBroadcastStream().map((event) => event == true);
  }
}
