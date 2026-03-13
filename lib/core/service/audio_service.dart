import 'package:flutter/services.dart';

class AudioService {
  static const MethodChannel _channel = MethodChannel('app/audio_service');

  AudioService();

  Future<void> stop() {
    return _channel.invokeMethod<void>('stop');
  }

  Future<void> playAsset(String assetPath, {double volume = 1.0}) {
    return _channel.invokeMethod<void>('playAsset', <String, Object>{
      'assetPath': assetPath,
      'volume': volume,
    });
  }

  Future<void> dispose() {
    return _channel.invokeMethod<void>('dispose');
  }
}
