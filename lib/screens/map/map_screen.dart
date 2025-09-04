import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/event.dart';
import '../../providers/events_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/universal_map.dart';

class MapScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final List<Event>? events;

  const MapScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.events,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final LocationService _locationService = LocationService();

  late AnimationController _slideController;
  late AnimationController _fabController;

  double? _currentLatitude;
  double? _currentLongitude;
  double _mapCenterLat = 37.7749;
  double _mapCenterLng = -122.4194;
  bool _isLoading = false;
  final bool _showEventsList = false;
  bool _isLocationEnabled = false;

  EventCategory? _selectedCategory;
  Event? _selectedEvent;

  final PageController _eventPageController = PageController();
  final int _currentEventIndex = 0;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _mapCenterLat = widget.initialLatitude!;
      _mapCenterLng = widget.initialLongitude!;
    } else {
      _getCurrentLocation();
    }

    _fabController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.events == null) {
        // Events will be loaded after location is obtained in _getCurrentLocation
        print('MapScreen: Events will be loaded after location is obtained');
      } else {
        _setEventsMarkers(widget.events!);
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fabController.dispose();
    _eventPageController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Requesting location permission...');
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        print('Location obtained: ${position.latitude}, ${position.longitude}');
        setState(() {
          _currentLatitude = position.latitude;
          _currentLongitude = position.longitude;
          _mapCenterLat = _currentLatitude!;
          _mapCenterLng = _currentLongitude!;
          _isLocationEnabled = true;
        });

        // Update map center
        _updateMapCenter(_currentLatitude!, _currentLongitude!);

        // Use Future.microtask to avoid calling during build
        Future.microtask(() {
          if (mounted) {
            print(
              'Setting user location in EventsProvider: ${position.latitude}, ${position.longitude}',
            );
            context.read<EventsProvider>().setUserLocation(
              position.latitude,
              position.longitude,
            );
            // Load events after location is set
            _loadEvents();
          }
        });
      } else {
        print('Location position is null');
      }
    } catch (e) {
      print('Location error: $e');
      // Fallback to default location
      setState(() {
        _currentLatitude = 37.7749; // San Francisco
        _currentLongitude = -122.4194;
        _mapCenterLat = _currentLatitude!;
        _mapCenterLng = _currentLongitude!;
        _isLocationEnabled = false;
      });

      // Still try to load events with default location
      Future.microtask(() {
        if (mounted) {
          print(
            'Using default location for events: $_currentLatitude, $_currentLongitude',
          );
          context.read<EventsProvider>().setUserLocation(
            _currentLatitude!,
            _currentLongitude!,
          );
          _loadEvents();
        }
      });

      _showLocationError();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateMapCenter(double latitude, double longitude) {
    setState(() {
      _mapCenterLat = latitude;
      _mapCenterLng = longitude;
    });
  }

  void _showLocationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Unable to get your location. Please check your location settings and permissions.',
        ),
        action: SnackBarAction(label: 'Retry', onPressed: _getCurrentLocation),
      ),
    );
  }

  Future<void> _loadEvents() async {
    final eventsProvider = context.read<EventsProvider>();

    if (_currentLatitude != null && _currentLongitude != null) {
      eventsProvider.setUserLocation(_currentLatitude!, _currentLongitude!);
      await eventsProvider.loadNearbyEvents();
    } else {
      await eventsProvider.loadEvents();
    }
  }

  void _setEventsMarkers(List<Event> events) {
    // Events are now handled directly by UniversalMapWidget
    // No need to manually create markers
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<EventsProvider>(
        builder: (context, eventsProvider, child) {
          List<Event> events;
          if (widget.events != null) {
            events = widget.events!;
          } else {
            events = eventsProvider.nearbyEvents.isNotEmpty
                ? eventsProvider.nearbyEvents
                : eventsProvider.events;
          }

          return UniversalMapWidget(
            events: events,
            onEventSelected: (event) {
              // Handle event selection
            },
            currentLatitude: _currentLatitude,
            currentLongitude: _currentLongitude,
          );
        },
      ),
    );
  }
}
