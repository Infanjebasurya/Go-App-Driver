class Env {
  const Env._();

  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.dev.goapp.com',
  );

  static const bool mockApi = bool.fromEnvironment(
    'MOCK_API',
    defaultValue: true,
  );

  static const bool newUser = bool.fromEnvironment(
    'NEW_USER',
    defaultValue: false,
  );

  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyA_EShs05GD76mc2Mjy1l2ByyO2FMHn3yA',
  );

  static const String googlePlacesApiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
    defaultValue: 'AIzaSyA_EShs05GD76mc2Mjy1l2ByyO2FMHn3yA',
  );

  static const String googleGeocodingApiKey = String.fromEnvironment(
    'GOOGLE_GEOCODING_API_KEY',
    defaultValue: 'AIzaSyA_EShs05GD76mc2Mjy1l2ByyO2FMHn3yA',
  );
}
