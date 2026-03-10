import '../../domain/repositories/internet_repository.dart';
import 'package:goapp/core/network/network_info.dart';

class InternetRepositoryImpl implements InternetRepository {
  InternetRepositoryImpl(this._networkInfo);

  final NetworkInfo _networkInfo;

  @override
  Future<bool> isConnected() => _networkInfo.isConnected;

  @override
  Stream<bool> onConnectivityChanged() => _networkInfo.onConnectivityChanged;
}
