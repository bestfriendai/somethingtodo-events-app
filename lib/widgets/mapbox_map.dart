import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/event.dart';
import '../config/mapbox_config.dart';
import '../config/theme.dart';
import '../config/glass_theme.dart';

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
  MapController? mapController;
  Event? selectedEvent;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: LatLng(
              widget.currentLatitude ?? MapboxConfig.defaultLatitude,
              widget.currentLongitude ?? MapboxConfig.defaultLongitude,
            ),
            initialZoom: MapboxConfig.defaultZoom,
            onTap: (tapPosition, point) => _onMapTapped(),
          ),
          children: [
            TileLayer(
              urlTemplate: isDarkMode
                  ? 'https://api.mapbox.com/styles/v1/mapbox/dark-v10/tiles/{z}/{x}/{y}?access_token=${MapboxConfig.accessToken}'
                  : 'https://api.mapbox.com/styles/v1/mapbox/light-v10/tiles/{z}/{x}/{y}?access_token=${MapboxConfig.accessToken}',
              additionalOptions: const {
                'accessToken': MapboxConfig.accessToken,
                'id': 'mapbox.mapbox-streets-v8',
              },
            ),
            MarkerLayer(markers: _buildEventMarkers()),
            if (widget.currentLatitude != null &&
                widget.currentLongitude != null)
              MarkerLayer(markers: [_buildCurrentLocationMarker()]),
          ],
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
              _buildMapControl(icon: Icons.add, onTap: () => _zoomIn()),
              const SizedBox(height: 8),
              _buildMapControl(icon: Icons.remove, onTap: () => _zoomOut()),
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

  List<Marker> _buildEventMarkers() {
    return widget.events.map((event) {
      return Marker(
        point: LatLng(event.venue.latitude, event.venue.longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _onEventMarkerTapped(event),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.event, color: Colors.white, size: 20),
          ),
        ),
      );
    }).toList();
  }

  Marker _buildCurrentLocationMarker() {
    return Marker(
      point: LatLng(widget.currentLatitude!, widget.currentLongitude!),
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(Icons.my_location, color: Colors.white, size: 20),
      ),
    );
  }

  void _onEventMarkerTapped(Event event) {
    setState(() {
      selectedEvent = event;
    });
    widget.onEventSelected?.call(event);
  }

  void _onMapTapped() {
    setState(() {
      selectedEvent = null;
    });
  }

  void _zoomIn() {
    final currentZoom = mapController?.camera.zoom ?? MapboxConfig.defaultZoom;
    mapController?.move(
      mapController?.camera.center ??
          LatLng(MapboxConfig.defaultLatitude, MapboxConfig.defaultLongitude),
      currentZoom + 1,
    );
  }

  void _zoomOut() {
    final currentZoom = mapController?.camera.zoom ?? MapboxConfig.defaultZoom;
    mapController?.move(
      mapController?.camera.center ??
          LatLng(MapboxConfig.defaultLatitude, MapboxConfig.defaultLongitude),
      currentZoom - 1,
    );
  }

  void _goToCurrentLocation() {
    if (widget.currentLatitude != null && widget.currentLongitude != null) {
      mapController?.move(
        LatLng(widget.currentLatitude!, widget.currentLongitude!),
        14.0,
      );
    }
  }

  Widget _buildMapControl({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GlassTheme.glassCard(
      width: 44,
      height: 44,
      borderRadius: 12,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Icon(
            icon,
            size: 20,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return GlassTheme.glassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      child: InkWell(
        onTap: () => widget.onEventSelected?.call(event),
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            // Icon badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(event.category),
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 14),

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
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.venue.name,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.pricing.isFree
                        ? 'FREE'
                        : '\$${event.pricing.price.toStringAsFixed(0)}+',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: event.pricing.isFree
                          ? const Color(0xFF10B981)
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Navigate button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: IconButton(
                tooltip: 'Directions',
                icon: const Icon(Icons.directions, size: 20),
                color: Colors.white,
                onPressed: () => widget.onEventSelected?.call(event),
              ),
            ),
          ],
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
