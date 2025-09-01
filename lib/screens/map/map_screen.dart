import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';

import '../../models/event.dart';
import '../../config/theme.dart';
import '../../config/app_config.dart';
import '../../providers/events_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/common/event_card.dart';
import '../../widgets/universal_map.dart';
import '../../data/sample_events.dart';
import '../events/event_details_screen.dart';

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
  double _mapCenterLat = 37.7749; // Default: San Francisco
  double _mapCenterLng = -122.4194;
  
  bool _isLoading = false;
  bool _showEventsList = false;
  bool _isLocationEnabled = false;
  EventCategory? _selectedCategory;
  Event? _selectedEvent;
  
  final PageController _eventPageController = PageController();
  int _currentEventIndex = 0;
  
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
        _loadEvents();
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
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
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
            context.read<EventsProvider>().setUserLocation(
              position.latitude,
              position.longitude,
            );
          }
        });
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
      _showLocationError();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEvents() async {
    final eventsProvider = context.read<EventsProvider>();

    if (_currentLatitude != null && _currentLongitude != null) {
      eventsProvider.setUserLocation(_currentLatitude!, _currentLongitude!);
      await eventsProvider.loadNearbyEvents();
      _setEventsMarkers(eventsProvider.nearbyEvents);
    } else {
      await eventsProvider.loadEvents();
      _setEventsMarkers(eventsProvider.events);
    }
  }

  void _setEventsMarkers(List<Event> events) {
    // Events are now handled directly by MapboxMapWidget
    // No need to manually create markers
  }

  void _onMarkerTapped(Event event) {
    setState(() {
      _selectedEvent = event;
    });
    
    // Navigation to event location is handled by MapboxMapWidget
    _showEventDetails(event);
  }

  void _showEventDetails(Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEventBottomSheet(event),
    );
  }

  // Location changes are now handled by MapboxMapWidget

  void _toggleEventsList() {
    setState(() {
      _showEventsList = !_showEventsList;
    });
    
    if (_showEventsList) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  void _filterByCategory(EventCategory? category) {
    setState(() {
      _selectedCategory = category;
    });
    
    context.read<EventsProvider>().setCategory(category);
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Universal Map Widget - Works on all platforms
          Consumer<EventsProvider>(
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
                onEventSelected: _onMarkerTapped,
                currentLatitude: _currentLatitude,
                currentLongitude: _currentLongitude,
              );
            },
          ),
          
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          
          // Top controls
          _buildTopControls(),
          
          // Floating action buttons
          _buildFloatingButtons(),
          
          // Events list
          _buildEventsList(),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search and filters
            Row(
              children: [
                // Back button (only show if we have initial location)
                if (widget.initialLatitude != null && widget.initialLongitude != null)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                if (widget.initialLatitude != null && widget.initialLongitude != null) const SizedBox(width: 8),
                
                // Search bar
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Search this area...',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Filter button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _showFilterBottomSheet,
                    icon: Icon(
                      Icons.tune,
                      color: _selectedCategory != null 
                          ? AppTheme.primaryColor 
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.5),
            
            // Category chips
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: EventCategory.values.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildCategoryChip('All', null);
                  }
                  final category = EventCategory.values[index - 1];
                  return _buildCategoryChip(category.displayName, category);
                },
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, EventCategory? category) {
    final isSelected = _selectedCategory == category;
    
    return GestureDetector(
      onTap: () => _filterByCategory(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryColor 
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Positioned(
      bottom: 20,
      right: 16,
      child: AnimatedBuilder(
        animation: _fabController,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabController.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // My location button
                FloatingActionButton(
                  mini: true,
                  heroTag: 'map_location_fab',
                  onPressed: _getCurrentLocation,
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  child: const Icon(Icons.my_location),
                ),
                
                const SizedBox(height: 12),
                
                // Events list toggle button
                Consumer<EventsProvider>(
                  builder: (context, eventsProvider, child) {
                    int eventCount;
                    if (widget.events != null) {
                      eventCount = widget.events!.length;
                    } else {
                      eventCount = eventsProvider.nearbyEvents.isNotEmpty
                          ? eventsProvider.nearbyEvents.length
                          : eventsProvider.events.length;
                    }

                    return FloatingActionButton(
                      heroTag: 'map_events_list_fab',
                      onPressed: _toggleEventsList,
                      backgroundColor: AppTheme.primaryColor,
                      child: Stack(
                        children: [
                          Icon(
                            _showEventsList ? Icons.map : Icons.list,
                            color: Colors.white,
                          ),
                          if (eventCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  eventCount > 99 ? '99+' : eventCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventsList() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, MediaQuery.of(context).size.height * (1 - _slideController.value)),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Events in this area',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _toggleEventsList,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                
                // Events list
                Expanded(
                  child: Consumer<EventsProvider>(
                    builder: (context, eventsProvider, child) {
                      List<Event> events;
                      if (widget.events != null) {
                        events = widget.events!;
                      } else {
                        events = eventsProvider.nearbyEvents.isNotEmpty
                            ? eventsProvider.nearbyEvents
                            : eventsProvider.events;
                      }

                      if (events.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_busy, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No events in this area'),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EventCard(
                              event: event,
                              compact: true,
                              onTap: () {
                                _onMarkerTapped(event);
                                _toggleEventsList();
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventBottomSheet(Event event) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: EventCard(
                      event: event,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetailsScreen(event: event),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Events',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            
            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip('All', null),
                ...EventCategory.values.map(
                  (category) => _buildFilterChip(
                    category.displayName,
                    category,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _loadEvents();
              },
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, EventCategory? category) {
    final isSelected = _selectedCategory == category;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
    );
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
        content: const Text('Unable to get your location. Please check your location settings and permissions.'),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: _getCurrentLocation,
        ),
      ),
    );
  }
}