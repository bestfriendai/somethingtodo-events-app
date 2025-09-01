import 'dart:async';
import 'package:geolocator/geolocator.dart' as geolocator;
import '../models/user.dart';
import 'location_service.dart';
import 'logging_service.dart';

/// Enhanced location service with automatic event loading and geofencing
class EnhancedLocationService {
  static final EnhancedLocationService _instance =
      EnhancedLocationService._internal();
  factory EnhancedLocationService() => _instance;
  EnhancedLocationService._internal();

  // Base location service
  final LocationService _baseLocationService = LocationService();

  // Geofencing and automatic loading
  final List<GeofenceRegion> _geofences = [];
  Timer? _backgroundLocationTimer;
  StreamSubscription<geolocator.Position>? _positionSubscription;

  // Location change callbacks
  final List<Function(geolocator.Position)> _locationChangeCallbacks = [];
  final List<Function(GeofenceEvent)> _geofenceCallbacks = [];

  // Configuration
  static const Duration _backgroundUpdateInterval = Duration(minutes: 5);
  static const double _significantLocationChangeThreshold = 1.0; // km
  static const int _maxGeofences = 20;

  // State tracking
  geolocator.Position? _lastSignificantPosition;
  DateTime? _lastEventLoadTime;
  bool _isBackgroundLocationEnabled = false;

  // Delegate properties to base service
  geolocator.Position? get currentPosition =>
      _baseLocationService.currentPosition;
  UserLocation? get currentLocation => _baseLocationService.currentLocation;
  bool get isListening => _baseLocationService.isListening;

  /// Start automatic location-based event loading
  Future<void> startAutomaticEventLoading({
    required Function(geolocator.Position) onLocationChanged,
    required Function(GeofenceEvent) onGeofenceEvent,
    Duration updateInterval = _backgroundUpdateInterval,
  }) async {
    LoggingService.info(
      'Starting automatic event loading',
      tag: 'LocationService',
    );

    // Add callbacks
    _locationChangeCallbacks.add(onLocationChanged);
    _geofenceCallbacks.add(onGeofenceEvent);

    // Request permissions
    if (!await _baseLocationService.requestLocationPermission()) {
      throw Exception(
        'Location permission required for automatic event loading',
      );
    }

    // Get initial position
    final initialPosition = await _baseLocationService.getCurrentPosition();
    if (initialPosition != null) {
      _lastSignificantPosition = initialPosition;
      _lastEventLoadTime = DateTime.now();
      onLocationChanged(initialPosition);
    }

    // Start continuous location monitoring
    await _startContinuousLocationMonitoring();

    // Start background location updates
    _startBackgroundLocationUpdates(updateInterval);

    _isBackgroundLocationEnabled = true;
    LoggingService.info(
      'Automatic event loading started successfully',
      tag: 'LocationService',
    );
  }

  /// Stop automatic location-based event loading
  void stopAutomaticEventLoading() {
    LoggingService.info(
      'Stopping automatic event loading',
      tag: 'LocationService',
    );

    _positionSubscription?.cancel();
    _backgroundLocationTimer?.cancel();
    _locationChangeCallbacks.clear();
    _geofenceCallbacks.clear();
    _isBackgroundLocationEnabled = false;

    LoggingService.info(
      'Automatic event loading stopped',
      tag: 'LocationService',
    );
  }

  /// Add a geofence region
  void addGeofence(GeofenceRegion region) {
    if (_geofences.length >= _maxGeofences) {
      // Remove oldest geofence
      _geofences.removeAt(0);
      LoggingService.warning(
        'Maximum geofences reached, removed oldest',
        tag: 'Geofence',
      );
    }

    _geofences.add(region);
    LoggingService.info('Added geofence: ${region.name}', tag: 'Geofence');
  }

  /// Remove a geofence region
  void removeGeofence(String regionId) {
    _geofences.removeWhere((region) => region.id == regionId);
    LoggingService.info('Removed geofence: $regionId', tag: 'Geofence');
  }

  /// Clear all geofences
  void clearGeofences() {
    _geofences.clear();
    LoggingService.info('Cleared all geofences', tag: 'Geofence');
  }

  /// Get all active geofences
  List<GeofenceRegion> get activeGeofences => List.unmodifiable(_geofences);

  /// Check if location change is significant enough to trigger event reload
  bool _isSignificantLocationChange(geolocator.Position newPosition) {
    if (_lastSignificantPosition == null) return true;

    final distance = _baseLocationService.calculateDistance(
      startLatitude: _lastSignificantPosition!.latitude,
      startLongitude: _lastSignificantPosition!.longitude,
      endLatitude: newPosition.latitude,
      endLongitude: newPosition.longitude,
    );

    return distance >= _significantLocationChangeThreshold;
  }

  /// Start continuous location monitoring
  Future<void> _startContinuousLocationMonitoring() async {
    _positionSubscription =
        geolocator.Geolocator.getPositionStream(
          locationSettings: geolocator.LocationSettings(
            accuracy: geolocator.LocationAccuracy.high,
            distanceFilter: (_significantLocationChangeThreshold * 1000)
                .toInt(), // Convert to meters
            timeLimit: const Duration(seconds: 30),
          ),
        ).listen(
          (position) => _handleLocationUpdate(position),
          onError: (error) {
            LoggingService.error(
              'Location stream error',
              error: error,
              tag: 'LocationService',
            );
            // Attempt to restart monitoring after a delay
            Timer(const Duration(seconds: 30), () {
              if (_isBackgroundLocationEnabled) {
                _startContinuousLocationMonitoring();
              }
            });
          },
        );
  }

  /// Handle location updates
  void _handleLocationUpdate(geolocator.Position position) {
    LoggingService.debug(
      'Location update: ${position.latitude}, ${position.longitude}',
      tag: 'LocationService',
    );

    // Check for significant location change
    if (_isSignificantLocationChange(position)) {
      LoggingService.info(
        'Significant location change detected',
        tag: 'LocationService',
      );
      _lastSignificantPosition = position;

      // Notify location change callbacks
      for (final callback in _locationChangeCallbacks) {
        try {
          callback(position);
        } catch (e) {
          LoggingService.error(
            'Error in location change callback',
            error: e,
            tag: 'LocationService',
          );
        }
      }
    }

    // Check geofences
    _checkGeofences(position);
  }

  /// Start background location updates
  void _startBackgroundLocationUpdates(Duration interval) {
    _backgroundLocationTimer?.cancel();
    _backgroundLocationTimer = Timer.periodic(interval, (timer) async {
      if (!_isBackgroundLocationEnabled) {
        timer.cancel();
        return;
      }

      try {
        final position = await _baseLocationService.getCurrentPositionCached();
        if (position != null) {
          _handleLocationUpdate(position);
        }
      } catch (e) {
        LoggingService.error(
          'Background location update failed',
          error: e,
          tag: 'LocationService',
        );
      }
    });
  }

  /// Check if position triggers any geofences
  void _checkGeofences(geolocator.Position position) {
    for (final geofence in _geofences) {
      final distance = _baseLocationService.calculateDistance(
        startLatitude: position.latitude,
        startLongitude: position.longitude,
        endLatitude: geofence.latitude,
        endLongitude: geofence.longitude,
      );

      final isInside = distance <= geofence.radiusKm;
      final wasInside = geofence.isInside;

      if (isInside != wasInside) {
        geofence.isInside = isInside;
        final event = GeofenceEvent(
          region: geofence,
          position: position,
          eventType: isInside
              ? GeofenceEventType.enter
              : GeofenceEventType.exit,
          timestamp: DateTime.now(),
        );

        LoggingService.info(
          'Geofence ${isInside ? "entered" : "exited"}: ${geofence.name}',
          tag: 'Geofence',
        );

        // Notify geofence callbacks
        for (final callback in _geofenceCallbacks) {
          try {
            callback(event);
          } catch (e) {
            LoggingService.error(
              'Error in geofence callback',
              error: e,
              tag: 'Geofence',
            );
          }
        }
      }
    }
  }

  /// Create geofence for popular event locations
  void createEventLocationGeofences(List<EventLocation> locations) {
    clearGeofences();

    for (final location in locations.take(_maxGeofences)) {
      final geofence = GeofenceRegion(
        id: 'event_location_${location.id}',
        name: location.name,
        latitude: location.latitude,
        longitude: location.longitude,
        radiusKm: 2.0, // 2km radius for event locations
        metadata: {'type': 'event_location', 'venue_id': location.id},
      );

      addGeofence(geofence);
    }

    LoggingService.info(
      'Created ${_geofences.length} event location geofences',
      tag: 'Geofence',
    );
  }

  /// Get location-based search parameters
  Map<String, dynamic> getLocationSearchParams() {
    if (currentPosition == null) return {};

    return {
      'latitude': currentPosition!.latitude,
      'longitude': currentPosition!.longitude,
      'location_string':
          '${currentPosition!.latitude},${currentPosition!.longitude}',
      'accuracy': currentPosition!.accuracy,
      'timestamp': currentPosition!.timestamp.toIso8601String(),
    };
  }

  /// Check if it's time to reload events based on location and time
  bool shouldReloadEvents() {
    if (_lastEventLoadTime == null) return true;

    final timeSinceLastLoad = DateTime.now().difference(_lastEventLoadTime!);

    // Reload if it's been more than 30 minutes
    if (timeSinceLastLoad > const Duration(minutes: 30)) return true;

    // Reload if location has changed significantly
    return _lastSignificantPosition != null &&
        currentPosition != null &&
        _isSignificantLocationChange(currentPosition!);
  }

  /// Mark events as reloaded
  void markEventsReloaded() {
    _lastEventLoadTime = DateTime.now();
  }

  /// Get current location status
  LocationServiceStatus get status {
    if (!_isBackgroundLocationEnabled) return LocationServiceStatus.disabled;
    if (currentPosition == null) return LocationServiceStatus.disabled;
    return LocationServiceStatus.enabled;
  }

  /// Delegate methods to base service
  Future<bool> requestLocationPermission() =>
      _baseLocationService.requestLocationPermission();
  Future<bool> isLocationServiceEnabled() =>
      _baseLocationService.isLocationServiceEnabled();
  Future<UserLocation?> getCurrentLocation() =>
      _baseLocationService.getCurrentLocation();
  Future<geolocator.Position?> getCurrentPosition() =>
      _baseLocationService.getCurrentPosition();
  Future<geolocator.Position?> getCurrentPositionCached() =>
      _baseLocationService.getCurrentPositionCached();

  /// Dispose resources
  void dispose() {
    stopAutomaticEventLoading();
    _baseLocationService.dispose();
  }
}

/// Geofence region definition
class GeofenceRegion {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusKm;
  final Map<String, dynamic> metadata;
  bool isInside;

  GeofenceRegion({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    this.metadata = const {},
    this.isInside = false,
  });
}

/// Geofence event types
enum GeofenceEventType { enter, exit }

/// Geofence event
class GeofenceEvent {
  final GeofenceRegion region;
  final geolocator.Position position;
  final GeofenceEventType eventType;
  final DateTime timestamp;

  const GeofenceEvent({
    required this.region,
    required this.position,
    required this.eventType,
    required this.timestamp,
  });
}

/// Event location for geofencing
class EventLocation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  const EventLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}
