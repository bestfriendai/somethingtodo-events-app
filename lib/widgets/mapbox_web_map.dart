import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'dart:js' as js;
import '../models/event.dart';
import '../config/mapbox_config.dart';
import '../config/glass_theme.dart';

class MapboxWebMap extends StatefulWidget {
  final List<Event> events;
  final Function(Event)? onEventSelected;
  final double? currentLatitude;
  final double? currentLongitude;

  const MapboxWebMap({
    super.key,
    required this.events,
    this.onEventSelected,
    this.currentLatitude,
    this.currentLongitude,
  });

  @override
  State<MapboxWebMap> createState() => _MapboxWebMapState();
}

class _MapboxWebMapState extends State<MapboxWebMap> {
  late String _divId;
  Event? selectedEvent;

  @override
  void initState() {
    super.initState();
    _divId = 'mapbox-map-${DateTime.now().millisecondsSinceEpoch}';
    _initializeMap();
  }

  void _initializeMap() {
    // Create a unique view type
    final String viewType = 'mapbox-map-$_divId';

    // Register the HTML element
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final mapElement = html.DivElement()
        ..id = _divId
        ..style.width = '100%'
        ..style.height = '100%';

      // Initialize map after element is added to DOM
      Future.delayed(const Duration(milliseconds: 100), () {
        _createMap();
      });

      return mapElement;
    });
  }

  void _createMap() {
    final script =
        '''
      if (typeof mapboxgl !== 'undefined') {
        mapboxgl.accessToken = '${MapboxConfig.accessToken}';
        
        const map = new mapboxgl.Map({
          container: '$_divId',
          style: '${MapboxConfig.streetsStyle}',
          center: [${widget.currentLongitude ?? MapboxConfig.defaultLongitude}, 
                   ${widget.currentLatitude ?? MapboxConfig.defaultLatitude}],
          zoom: ${MapboxConfig.defaultZoom}
        });

        // Add navigation controls
        map.addControl(new mapboxgl.NavigationControl());

        // Add markers for events
        ${_generateMarkersScript()}

        // Add current location marker if available
        ${_generateCurrentLocationScript()}

        // Store map reference
        window.mapboxMaps = window.mapboxMaps || {};
        window.mapboxMaps['$_divId'] = map;
      }
    ''';

    js.context.callMethod('eval', [script]);
  }

  String _generateMarkersScript() {
    final markers = <String>[];
    for (final event in widget.events) {
      final color = _getCategoryColorHex(event.category);
      markers.add('''
        {
          const el = document.createElement('div');
          el.className = 'marker';
          el.style.backgroundColor = '$color';
          el.style.width = '30px';
          el.style.height = '30px';
          el.style.borderRadius = '50%';
          el.style.border = '3px solid white';
          el.style.cursor = 'pointer';
          el.style.boxShadow = '0 2px 4px rgba(0,0,0,0.3)';
          
          const popup = new mapboxgl.Popup({ offset: 25 })
            .setHTML('<h3>${event.title.replaceAll("'", "\\'")}</h3><p>${event.venue.name.replaceAll("'", "\\'")}</p>');
          
          new mapboxgl.Marker(el)
            .setLngLat([${event.venue.longitude}, ${event.venue.latitude}])
            .setPopup(popup)
            .addTo(map);
        }
      ''');
    }
    return markers.join('\n');
  }

  String _generateCurrentLocationScript() {
    if (widget.currentLatitude == null || widget.currentLongitude == null) {
      return '';
    }

    return '''
      {
        const el = document.createElement('div');
        el.className = 'current-location';
        el.style.backgroundColor = '#FF5722';
        el.style.width = '20px';
        el.style.height = '20px';
        el.style.borderRadius = '50%';
        el.style.border = '3px solid white';
        el.style.boxShadow = '0 0 0 10px rgba(255, 87, 34, 0.2)';
        
        new mapboxgl.Marker(el)
          .setLngLat([${widget.currentLongitude}, ${widget.currentLatitude}])
          .addTo(map);
      }
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HtmlElementView(viewType: 'mapbox-map-$_divId'),

        // Selected event info card
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
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.pricing.isFree
                        ? 'FREE'
                        : '\$${event.pricing.price.toStringAsFixed(0)}+',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
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

  String _getCategoryColorHex(EventCategory category) {
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

  @override
  void dispose() {
    // Cleanup map instance
    final script =
        '''
      if (window.mapboxMaps && window.mapboxMaps['$_divId']) {
        window.mapboxMaps['$_divId'].remove();
        delete window.mapboxMaps['$_divId'];
      }
    ''';
    js.context.callMethod('eval', [script]);
    super.dispose();
  }
}
