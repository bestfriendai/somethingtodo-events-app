import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/event.dart';
import '../config/mapbox_config.dart';
import '../config/theme.dart';

class UniversalMapWidget extends StatefulWidget {
  final List<Event> events;
  final Function(Event)? onEventSelected;
  final double? currentLatitude;
  final double? currentLongitude;

  const UniversalMapWidget({
    super.key,
    required this.events,
    this.onEventSelected,
    this.currentLatitude,
    this.currentLongitude,
  });

  @override
  State<UniversalMapWidget> createState() => _UniversalMapWidgetState();
}

class _UniversalMapWidgetState extends State<UniversalMapWidget> with TickerProviderStateMixin {
  late final MapController _mapController;
  Event? selectedEvent;
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(
      widget.currentLatitude ?? MapboxConfig.defaultLatitude,
      widget.currentLongitude ?? MapboxConfig.defaultLongitude,
    );

    // Update map center when location changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.currentLatitude != null && widget.currentLongitude != null) {
        _mapController.move(center, _mapController.camera.zoom);
      }
    });

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: MapboxConfig.defaultZoom,
            onTap: (tapPosition, point) {
              setState(() {
                selectedEvent = null;
              });
            },
          ),
          children: [
            // Mapbox Tile Layer
            TileLayer(
              urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}?access_token=${MapboxConfig.accessToken}',
              userAgentPackageName: 'com.somethingtodo.app',
            ),
            
            // Event Markers
            MarkerLayer(
              markers: _buildEventMarkers(),
            ),
            
            // Current Location Marker
            if (widget.currentLatitude != null && widget.currentLongitude != null)
              MarkerLayer(
                markers: [
                  _buildCurrentLocationMarker(),
                ],
              ),
          ],
        ),
        
        // Map Controls
        Positioned(
          right: 16,
          top: 100,
          child: Column(
            children: [
              _buildMapControl(
                icon: Icons.add,
                onTap: () {
                  final currentZoom = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, currentZoom + 1);
                },
              ),
              const SizedBox(height: 8),
              _buildMapControl(
                icon: Icons.remove,
                onTap: () {
                  final currentZoom = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, currentZoom - 1);
                },
              ),
              const SizedBox(height: 8),
              _buildMapControl(
                icon: Icons.my_location,
                onTap: () {
                  if (widget.currentLatitude != null && widget.currentLongitude != null) {
                    _mapController.move(
                      LatLng(widget.currentLatitude!, widget.currentLongitude!),
                      14.0,
                    );
                  }
                },
              ),
            ],
          ),
        ),
        
        // Selected Event Card
        if (selectedEvent != null)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildEventCard(selectedEvent!),
          ),
      ],
    );
  }

  List<Marker> _buildEventMarkers() {
    return widget.events.map((event) {
      final point = LatLng(event.venue.latitude, event.venue.longitude);
      final isSelected = selectedEvent?.id == event.id;

      return Marker(
        point: point,
        width: isSelected ? 50 : 40,
        height: isSelected ? 50 : 40,
        child: GestureDetector(
          onTap: () {
            setState(() {
              selectedEvent = event;
            });
            widget.onEventSelected?.call(event);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _getCategoryColor(event.category),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                _getCategoryIcon(event.category),
                color: Colors.white,
                size: isSelected ? 24 : 20,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Marker _buildCurrentLocationMarker() {
    return Marker(
      point: LatLng(widget.currentLatitude!, widget.currentLongitude!),
      width: 30,
      height: 30,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3 * (1 - _pulseController.value)),
                  blurRadius: 20 * _pulseController.value,
                  spreadRadius: 10 * _pulseController.value,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapControl({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => widget.onEventSelected?.call(event),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Event icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _getCategoryColor(event.category).withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(event.category),
                    color: _getCategoryColor(event.category),
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Event details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.venue.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${event.venue.city}, ${event.venue.state}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Price and navigation
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    event.pricing.isFree ? 'FREE' : '\$${event.pricing.price.toStringAsFixed(0)}+',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: event.pricing.isFree ? Colors.green : AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.directions),
                    color: AppTheme.primaryColor,
                    onPressed: () => widget.onEventSelected?.call(event),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(EventCategory category) {
    switch (category) {
      case EventCategory.music:
        return Colors.red;
      case EventCategory.food:
        return Colors.orange;
      case EventCategory.sports:
        return Colors.green;
      case EventCategory.arts:
        return Colors.purple;
      case EventCategory.business:
        return Colors.blue;
      case EventCategory.education:
        return Colors.teal;
      case EventCategory.technology:
        return Colors.indigo;
      case EventCategory.health:
        return Colors.pink;
      case EventCategory.community:
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(EventCategory category) {
    switch (category) {
      case EventCategory.music:
        return Icons.music_note;
      case EventCategory.food:
        return Icons.restaurant;
      case EventCategory.sports:
        return Icons.sports_soccer;
      case EventCategory.arts:
        return Icons.palette;
      case EventCategory.business:
        return Icons.business;
      case EventCategory.education:
        return Icons.school;
      case EventCategory.technology:
        return Icons.computer;
      case EventCategory.health:
        return Icons.local_hospital;
      case EventCategory.community:
        return Icons.group;
      default:
        return Icons.place;
    }
  }
}