import '../../domain/repositories/internet_repository.dart';
import '../services/network_service.dart';

class InternetRepositoryImpl implements InternetRepository {
  InternetRepositoryImpl(this._networkService);

  final NetworkService _networkService;

  @override
  Future<bool> isConnected() => _networkService.isConnected();

  @override
  Stream<bool> onConnectivityChanged() =>
      _networkService.onConnectivityChanged();
}
