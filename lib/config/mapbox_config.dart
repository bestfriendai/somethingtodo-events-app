class MapboxConfig {
  static const String accessToken = 'pk.eyJ1IjoidHJhcHBhdCIsImEiOiJjbTMzODBqYTYxbHcwMmpwdXpxeWljNXJ3In0.xKUEW2C1kjFBu7kr7Uxfow';
  
  // San Francisco center coordinates
  static const double defaultLatitude = 37.7749;
  static const double defaultLongitude = -122.4194;
  static const double defaultZoom = 12.0;
  
  // Map styles
  static const String streetsStyle = 'mapbox://styles/mapbox/streets-v12';
  static const String darkStyle = 'mapbox://styles/mapbox/dark-v11';
  static const String lightStyle = 'mapbox://styles/mapbox/light-v11';
  static const String satelliteStyle = 'mapbox://styles/mapbox/satellite-streets-v12';
}