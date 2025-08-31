import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../models/event.dart';
import '../config/mapbox_config.dart';
import '../config/theme.dart';

class MapboxMapWidget extends StatefulWidget {
  final List<Event> events;
  final Function(Event)? onEventSelected;
  final double? currentLatitude;
  final double? currentLongitude;

  const MapboxMapWidget({
    super.key,
    required this.events,
    this.onEventSelected,
    this.currentLatitude,
    this.currentLongitude,
  });

  @override
  State<MapboxMapWidget> createState() => _MapboxMapWidgetState();
}

class _MapboxMapWidgetState extends State<MapboxMapWidget> {
  MapboxMap? mapboxMap;
  Event? selectedEvent;
  
  @override
  void initState() {
    super.initState();
    MapboxOptions.setAccessToken(MapboxConfig.accessToken);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        MapWidget(
          onMapCreated: _onMapCreated,
          styleUri: isDarkMode ? MapboxConfig.darkStyle : MapboxConfig.lightStyle,
          cameraOptions: CameraOptions(
            center: Point(
              coordinates: Position(
                widget.currentLongitude ?? MapboxConfig.defaultLongitude,
                widget.currentLatitude ?? MapboxConfig.defaultLatitude,
              ),
            ),
            zoom: MapboxConfig.defaultZoom,
          ),
          onTapListener: (coordinate) {
            _onMapTapped();
          },
        ),
        
        // Selected event info card
        if (selectedEvent != null)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildEventCard(selectedEvent!),
          ),
          
        // Map controls
        Positioned(
          right: 20,
          top: 20,
          child: Column(
            children: [
              _buildMapControl(
                icon: Icons.add,
                onTap: () => _zoomIn(),
              ),
              const SizedBox(height: 8),
              _buildMapControl(
                icon: Icons.remove,
                onTap: () => _zoomOut(),
              ),
              const SizedBox(height: 8),
              _buildMapControl(
                icon: Icons.my_location,
                onTap: () => _goToCurrentLocation(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onMapCreated(MapboxMap map) async {
    mapboxMap = map;
    await _addEventMarkers();
    if (widget.currentLatitude != null && widget.currentLongitude != null) {
      await _addCurrentLocationMarker();
    }
  }

  Future<void> _addEventMarkers() async {
    if (mapboxMap == null) return;
    
    for (final event in widget.events) {
      final point = Point(
        coordinates: Position(
          event.venue.longitude,
          event.venue.latitude,
        ),
      );
      
      // Create annotation for each event
      final annotation = PointAnnotationOptions(
        geometry: point,
        iconImage: 'event-marker',
        iconSize: 1.5,
        textField: event.title,
        textSize: 12.0,
        textOffset: [0, -2],
      );
      
      await mapboxMap!.annotations.createPointAnnotationManager().then((manager) async {
        await manager.create(annotation);
        
        // Tap handling will be implemented separately
      });
    }
  }

  Future<void> _addCurrentLocationMarker() async {
    if (mapboxMap == null || widget.currentLatitude == null || widget.currentLongitude == null) return;
    
    final point = Point(
      coordinates: Position(
        widget.currentLongitude!,
        widget.currentLatitude!,
      ),
    );
    
    final annotation = PointAnnotationOptions(
      geometry: point,
      iconImage: 'current-location',
      iconSize: 1.0,
    );
    
    await mapboxMap!.annotations.createPointAnnotationManager().then((manager) async {
      await manager.create(annotation);
    });
  }

  void _onMapTapped() {
    setState(() {
      selectedEvent = null;
    });
  }

  void _zoomIn() {
    mapboxMap?.flyTo(
      CameraOptions(zoom: 1.0),
      MapAnimationOptions(duration: 300),
    );
  }

  void _zoomOut() {
    mapboxMap?.flyTo(
      CameraOptions(zoom: -1.0),
      MapAnimationOptions(duration: 300),
    );
  }

  void _goToCurrentLocation() {
    if (widget.currentLatitude != null && widget.currentLongitude != null) {
      mapboxMap?.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(
              widget.currentLongitude!,
              widget.currentLatitude!,
            ),
          ),
          zoom: 14.0,
        ),
        MapAnimationOptions(duration: 1000),
      );
    }
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
              // Event image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _getCategoryColor(event.category).withOpacity(0.1),
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
                    Text(
                      event.pricing.isFree ? 'FREE' : '\$${event.pricing.price.toStringAsFixed(0)}+',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: event.pricing.isFree ? Colors.green : AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Navigate button
              IconButton(
                icon: const Icon(Icons.directions),
                color: AppTheme.primaryColor,
                onPressed: () {
                  // Open in maps
                  widget.onEventSelected?.call(event);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryColorString(EventCategory category) {
    switch (category) {
      case EventCategory.music:
        return '#F44336';
      case EventCategory.food:
        return '#FF9800';
      case EventCategory.sports:
        return '#4CAF50';
      case EventCategory.arts:
        return '#9C27B0';
      case EventCategory.business:
        return '#2196F3';
      case EventCategory.education:
        return '#009688';
      case EventCategory.technology:
        return '#3F51B5';
      case EventCategory.health:
        return '#E91E63';
      case EventCategory.community:
        return '#795548';
      default:
        return '#9E9E9E';
    }
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