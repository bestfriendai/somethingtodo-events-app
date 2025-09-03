class MapboxConfig {
  // Use environment variable for secure token management
  static const String accessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
    defaultValue: 'pk.eyJ1IjoiZGVtb3Rlc3QiLCJhIjoiY2tqN21sbGdvMDBzbjJwcDR4eWV1cWIyZSJ9.iI_XkvK-5BdAON8MQcB9hA', // Demo token
  );

  // San Francisco center coordinates
  static const double defaultLatitude = 37.7749;
  static const double defaultLongitude = -122.4194;
  static const double defaultZoom = 12.0;

  // Map styles
  static const String streetsStyle = 'mapbox://styles/mapbox/streets-v12';
  static const String darkStyle = 'mapbox://styles/mapbox/dark-v11';
  static const String lightStyle = 'mapbox://styles/mapbox/light-v11';
  static const String satelliteStyle =
      'mapbox://styles/mapbox/satellite-streets-v12';
}
