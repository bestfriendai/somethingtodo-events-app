import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/user.dart';
import '../models/analytics.dart';
import '../config/app_config.dart';

enum LocationServiceStatus {
  disabled,
  enabled,
}

// Extension to convert from Geolocator's ServiceStatus
extension LocationServiceStatusExtension on LocationServiceStatus {
  static LocationServiceStatus fromGeolocatorStatus(geolocator.ServiceStatus status) {
    switch (status) {
      case geolocator.ServiceStatus.enabled:
        return LocationServiceStatus.enabled;
      case geolocator.ServiceStatus.disabled:
        return LocationServiceStatus.disabled;
    }
  }
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  geolocator.Position? _currentPosition;
  UserLocation? _currentLocation;
  bool _isListening = false;

  geolocator.Position? get currentPosition => _currentPosition;
  UserLocation? get currentLocation => _currentLocation;
  bool get isListening => _isListening;

  // Check and request location permissions
  Future<bool> requestLocationPermission() async {
    try {
      geolocator.LocationPermission permission = await geolocator.Geolocator.checkPermission();
      
      if (permission == geolocator.LocationPermission.denied) {
        permission = await geolocator.Geolocator.requestPermission();
      }

      if (permission == geolocator.LocationPermission.deniedForever) {
        // Show dialog to open app settings
        await openAppSettings();
        return false;
      }

      final isGranted = permission == geolocator.LocationPermission.whileInUse || 
                       permission == geolocator.LocationPermission.always;

      // Log permission status
      await _analytics.logEvent(
        name: AnalyticsEvents.locationPermission,
        parameters: {
          'granted': isGranted,
          'permission_level': permission.name,
        },
      );

      return isGranted;
    } catch (e) {
      throw Exception('Failed to request location permission: $e');
    }
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await geolocator.Geolocator.isLocationServiceEnabled();
  }

  // Get current location (alias for getCurrentPosition for consistency)
  Future<UserLocation?> getCurrentLocation() async {
    await getCurrentPosition();
    return _currentLocation;
  }

  // Get current position
  Future<geolocator.Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      if (!await isLocationServiceEnabled()) {
        throw Exception('Location services are disabled');
      }

      // Check permissions
      if (!await requestLocationPermission()) {
        throw Exception('Location permission not granted');
      }

      // Get position
      _currentPosition = await geolocator.Geolocator.getCurrentPosition(
        locationSettings: geolocator.LocationSettings(
          accuracy: geolocator.LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        ),
      );

      // Get address information
      if (_currentPosition != null) {
        _currentLocation = await _getLocationFromPosition(_currentPosition!);
      }

      return _currentPosition;
    } catch (e) {
      throw Exception('Failed to get current position: $e');
    }
  }

  // Get position with caching
  Future<geolocator.Position?> getCurrentPositionCached() async {
    // Return cached position if recent enough (5 minutes)
    if (_currentPosition != null) {
      final age = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(
          _currentPosition!.timestamp.millisecondsSinceEpoch,
        ),
      );
      
      if (age < const Duration(minutes: 5)) {
        return _currentPosition;
      }
    }

    // Get fresh position
    return await getCurrentPosition();
  }

  // Start listening to position changes
  Future<void> startLocationUpdates({
    Function(geolocator.Position)? onPositionChanged,
    Function(LocationServiceStatus)? onServiceStatusChanged,
  }) async {
    if (_isListening) return;

    // Check permissions
    if (!await requestLocationPermission()) {
      throw Exception('Location permission required for updates');
    }

    _isListening = true;

    // Listen to position updates
    geolocator.Geolocator.getPositionStream(
      locationSettings: geolocator.LocationSettings(
        accuracy: geolocator.LocationAccuracy.high,
        distanceFilter: AppConfig.locationAccuracy.toInt(),
        timeLimit: const Duration(seconds: 30),
      ),
    ).listen(
      (geolocator.Position position) async {
        _currentPosition = position;
        _currentLocation = await _getLocationFromPosition(position);
        onPositionChanged?.call(position);
      },
      onError: (error) {
        _isListening = false;
        throw Exception('Location stream error: $error');
      },
    );

    // Listen to service status changes
    geolocator.Geolocator.getServiceStatusStream().listen(
      (geolocator.ServiceStatus status) {
        final locationStatus = LocationServiceStatusExtension.fromGeolocatorStatus(status);
        onServiceStatusChanged?.call(locationStatus);
        if (locationStatus == LocationServiceStatus.disabled) {
          _isListening = false;
        }
      },
    );
  }

  // Stop listening to position changes
  void stopLocationUpdates() {
    _isListening = false;
    // Note: Geolocator streams are managed automatically
  }

  // Calculate distance between two points
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return geolocator.Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    ) / 1000; // Convert to kilometers
  }

  // Calculate bearing between two points
  double calculateBearing({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return geolocator.Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Get address from coordinates
  Future<UserLocation?> getLocationFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final position = geolocator.Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
      
      return await _getLocationFromPosition(position);
    } catch (e) {
      throw Exception('Failed to get location from coordinates: $e');
    }
  }

  // Get coordinates from address
  Future<List<Location>> getCoordinatesFromAddress(String address) async {
    try {
      return await locationFromAddress(address);
    } catch (e) {
      throw Exception('Failed to get coordinates from address: $e');
    }
  }

  // Get nearby locations (mock implementation)
  Future<List<UserLocation>> getNearbyLocations({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    // This would typically call a places API
    // For now, return an empty list
    return [];
  }

  // Check if position is within bounds
  bool isWithinBounds({
    required geolocator.Position position,
    required double centerLatitude,
    required double centerLongitude,
    required double radiusKm,
  }) {
    final distance = calculateDistance(
      startLatitude: position.latitude,
      startLongitude: position.longitude,
      endLatitude: centerLatitude,
      endLongitude: centerLongitude,
    );
    
    return distance <= radiusKm;
  }

  // Get position accuracy description
  String getAccuracyDescription(double accuracy) {
    if (accuracy <= 5) {
      return 'Excellent';
    } else if (accuracy <= 10) {
      return 'Good';
    } else if (accuracy <= 20) {
      return 'Fair';
    } else {
      return 'Poor';
    }
  }

  // Format distance for display
  String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()}m';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceInKm.round()}km';
    }
  }

  // Format coordinates for display
  String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  // Check if location is valid
  bool isValidLocation(double latitude, double longitude) {
    return latitude >= -90 && 
           latitude <= 90 && 
           longitude >= -180 && 
           longitude <= 180;
  }

  // Get location mock for testing
  UserLocation getMockLocation() {
    return const UserLocation(
      latitude: 37.7749,
      longitude: -122.4194,
      address: '123 Main St',
      city: 'San Francisco',
      state: 'CA',
      country: 'USA',
      lastUpdated: null,
    );
  }

  // Private helper method to get location details from position
  Future<UserLocation> _getLocationFromPosition(geolocator.Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        
        return UserLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          address: _buildAddressString(placemark),
          city: placemark.locality,
          state: placemark.administrativeArea,
          country: placemark.country,
          lastUpdated: DateTime.now(),
        );
      } else {
        return UserLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          address: formatCoordinates(position.latitude, position.longitude),
          lastUpdated: DateTime.now(),
        );
      }
    } catch (e) {
      // Return basic location without address details
      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: formatCoordinates(position.latitude, position.longitude),
        lastUpdated: DateTime.now(),
      );
    }
  }

  // Build readable address string from placemark
  String _buildAddressString(Placemark placemark) {
    final components = <String>[];
    
    if (placemark.subThoroughfare != null) {
      components.add(placemark.subThoroughfare!);
    }
    if (placemark.thoroughfare != null) {
      components.add(placemark.thoroughfare!);
    }
    if (placemark.locality != null) {
      components.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null) {
      components.add(placemark.administrativeArea!);
    }
    if (placemark.postalCode != null) {
      components.add(placemark.postalCode!);
    }
    
    return components.join(', ');
  }

  // Utility methods for specific location operations
  Future<bool> isLocationWithinCity({
    required geolocator.Position position,
    required String cityName,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      return placemarks.any((placemark) => 
        placemark.locality?.toLowerCase() == cityName.toLowerCase());
    } catch (e) {
      return false;
    }
  }

  Future<String?> getCityFromPosition(geolocator.Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      return placemarks.isNotEmpty ? placemarks.first.locality : null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getCountryFromPosition(geolocator.Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      return placemarks.isNotEmpty ? placemarks.first.country : null;
    } catch (e) {
      return null;
    }
  }
}