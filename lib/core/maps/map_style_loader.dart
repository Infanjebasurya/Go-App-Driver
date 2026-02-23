import '../utils/map_style.dart';

class MapStyleLoader {
  const MapStyleLoader();

  Future<String> loadDefault() => MapStyle.load();

  Future<String> loadBooking() => MapStyle.loadBooking();
}
