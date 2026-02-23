import 'native_network_service.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final NativeNetworkService nativeNetworkService;

  NetworkInfoImpl(this.nativeNetworkService);

  @override
  Future<bool> get isConnected async {
    return nativeNetworkService.isConnected();
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return nativeNetworkService.connectivityStream();
  }
}
