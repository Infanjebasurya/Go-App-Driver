abstract class InternetRepository {
  Future<bool> isConnected();
  Stream<bool> onConnectivityChanged();
}
