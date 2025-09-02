import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

import '../models/event.dart';
import '../config/theme.dart';

class DemoMap extends StatefulWidget {
  final List<Event> events;
  final Function(Event)? onEventTapped;
  final double? currentLatitude;
  final double? currentLongitude;

  const DemoMap({
    super.key,
    required this.events,
    this.onEventTapped,
    this.currentLatitude,
    this.currentLongitude,
  });

  @override
  State<DemoMap> createState() => _DemoMapState();
}

class _DemoMapState extends State<DemoMap> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _zoomController;
  
  Event? _selectedEvent;
  Offset? _mapCenter;
  double _zoomLevel = 1.0;
  Offset _panOffset = Offset.zero;
  
  // San Francisco area bounds for demo
  static const double minLat = 37.7;
  static const double maxLat = 37.8;
  static const double minLng = -122.5;
  static const double maxLng = -122.4;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _zoomController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _mapCenter ??= Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedEvent = null;
            });
          },
          onScaleUpdate: (details) {
            setState(() {
              // Scale gesture includes pan functionality
              if (details.scale != 1.0) {
                _zoomLevel = math.max(0.5, math.min(3.0, _zoomLevel * details.scale));
              }
              _panOffset += details.focalPointDelta;
            });
          },
          child: ClipRect(
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: CustomPaint(
                painter: DemoMapPainter(
                  events: widget.events,
                  selectedEvent: _selectedEvent,
                  zoomLevel: _zoomLevel,
                  panOffset: _panOffset,
                  pulseAnimation: _pulseController,
                  currentLatitude: widget.currentLatitude,
                  currentLongitude: widget.currentLongitude,
                ),
                child: Stack(
                  children: [
                    // Event pins overlay
                    ...widget.events.map((event) => _buildEventPin(
                      event,
                      constraints.maxWidth,
                      constraints.maxHeight,
                    )),
                    
                    // Current location indicator
                    if (widget.currentLatitude != null && widget.currentLongitude != null)
                      _buildCurrentLocationPin(constraints.maxWidth, constraints.maxHeight),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventPin(Event event, double mapWidth, double mapHeight) {
    // Convert lat/lng to screen coordinates
    final position = _latLngToScreen(
      event.venue.latitude,
      event.venue.longitude,
      mapWidth,
      mapHeight,
    );
    
    if (position == null) return const SizedBox.shrink();
    
    final isSelected = _selectedEvent?.id == event.id;
    final color = _getCategoryColor(event.category);
    
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: position.dx - (isSelected ? 20 : 15),
      top: position.dy - (isSelected ? 40 : 30),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedEvent = event;
          });
          widget.onEventTapped?.call(event);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isSelected ? 40 : 30,
          height: isSelected ? 40 : 30,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pin shadow
              Positioned(
                bottom: 0,
                child: Container(
                  width: isSelected ? 16 : 12,
                  height: isSelected ? 8 : 6,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              
              // Pin body
              Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(isSelected ? 20 : 15),
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
                    size: isSelected ? 20 : 16,
                  ),
                ),
              ),
              
              // Pulse animation for selected pin
              if (isSelected)
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.3 * (1 - _pulseController.value)),
                        borderRadius: BorderRadius.circular(
                          20 + (20 * _pulseController.value)
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ).animate(delay: Duration(milliseconds: widget.events.indexOf(event) * 100))
        .scale(begin: const Offset(0, 0), duration: 600.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildCurrentLocationPin(double mapWidth, double mapHeight) {
    final position = _latLngToScreen(
      widget.currentLatitude!,
      widget.currentLongitude!,
      mapWidth,
      mapHeight,
    );
    
    if (position == null) return const SizedBox.shrink();
    
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: position.dx - 12,
      top: position.dy - 12,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
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

  Offset? _latLngToScreen(double lat, double lng, double mapWidth, double mapHeight) {
    // Normalize coordinates to [0,1]
    final normalizedX = (lng - minLng) / (maxLng - minLng);
    final normalizedY = 1.0 - (lat - minLat) / (maxLat - minLat); // Invert Y
    
    // Convert to screen coordinates with zoom and pan
    final baseX = normalizedX * mapWidth;
    final baseY = normalizedY * mapHeight;
    
    final centeredX = (baseX - mapWidth / 2) * _zoomLevel + mapWidth / 2;
    final centeredY = (baseY - mapHeight / 2) * _zoomLevel + mapHeight / 2;
    
    final finalX = centeredX + _panOffset.dx;
    final finalY = centeredY + _panOffset.dy;
    
    // Check if point is visible
    if (finalX < -50 || finalX > mapWidth + 50 || finalY < -50 || finalY > mapHeight + 50) {
      return null;
    }
    
    return Offset(finalX, finalY);
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

class DemoMapPainter extends CustomPainter {
  final List<Event> events;
  final Event? selectedEvent;
  final double zoomLevel;
  final Offset panOffset;
  final Animation<double> pulseAnimation;
  final double? currentLatitude;
  final double? currentLongitude;

  DemoMapPainter({
    required this.events,
    this.selectedEvent,
    required this.zoomLevel,
    required this.panOffset,
    required this.pulseAnimation,
    this.currentLatitude,
    this.currentLongitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw water (San Francisco Bay)
    final waterPaint = Paint()
      ..color = const Color(0xFF4A90E2)
      ..style = PaintingStyle.fill;
    
    // Main bay area
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), waterPaint);
    
    // Draw land masses
    final landPaint = Paint()
      ..color = const Color(0xFFF0F8E8)
      ..style = PaintingStyle.fill;
    
    // San Francisco peninsula
    final sfPeninsula = Path();
    sfPeninsula.moveTo(size.width * 0.1, size.height * 0.2);
    sfPeninsula.lineTo(size.width * 0.6, size.height * 0.2);
    sfPeninsula.lineTo(size.width * 0.7, size.height * 0.8);
    sfPeninsula.lineTo(size.width * 0.1, size.height * 0.9);
    sfPeninsula.close();
    canvas.drawPath(sfPeninsula, landPaint);
    
    // East Bay
    final eastBay = Path();
    eastBay.moveTo(size.width * 0.8, size.height * 0.1);
    eastBay.lineTo(size.width, size.height * 0.1);
    eastBay.lineTo(size.width, size.height * 0.9);
    eastBay.lineTo(size.width * 0.8, size.height * 0.8);
    eastBay.close();
    canvas.drawPath(eastBay, landPaint);
    
    // Draw parks (green areas)
    final parkPaint = Paint()
      ..color = const Color(0xFF90C695)
      ..style = PaintingStyle.fill;
    
    // Golden Gate Park
    final ggPark = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.35, size.width * 0.3, size.height * 0.1),
      const Radius.circular(8),
    );
    canvas.drawRRect(ggPark, parkPaint);
    
    // Presidio
    final presidio = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.12, size.height * 0.2, size.width * 0.15, size.height * 0.12),
      const Radius.circular(6),
    );
    canvas.drawRRect(presidio, parkPaint);
    
    // Draw streets (grid pattern)
    final streetPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    // Vertical streets
    for (double x = size.width * 0.15; x < size.width * 0.6; x += size.width * 0.05) {
      canvas.drawLine(
        Offset(x, size.height * 0.2),
        Offset(x, size.height * 0.8),
        streetPaint,
      );
    }
    
    // Horizontal streets
    for (double y = size.height * 0.25; y < size.height * 0.8; y += size.height * 0.05) {
      canvas.drawLine(
        Offset(size.width * 0.15, y),
        Offset(size.width * 0.6, y),
        streetPaint,
      );
    }
    
    // Draw major landmarks as small squares
    final landmarkPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    
    // Financial District (skyscrapers)
    for (int i = 0; i < 8; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * 0.45 + (i * 8),
          size.height * 0.52,
          4,
          12,
        ),
        landmarkPaint,
      );
    }
    
    // Draw bridges
    final bridgePaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    
    // Golden Gate Bridge
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.25),
      Offset(size.width * 0.2, size.height * 0.22),
      bridgePaint,
    );
    
    // Bay Bridge
    canvas.drawLine(
      Offset(size.width * 0.55, size.height * 0.6),
      Offset(size.width * 0.8, size.height * 0.55),
      bridgePaint,
    );
    
    // Draw compass
    _drawCompass(canvas, size);
    
    // Draw scale
    _drawScale(canvas, size);
  }

  void _drawCompass(Canvas canvas, Size size) {
    final center = Offset(size.width - 40, 40);
    const radius = 20.0;
    
    final compassPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, Paint()..color = Colors.white.withValues(alpha: 0.9));
    canvas.drawCircle(center, radius, Paint()..color = Colors.black.withValues(alpha: 0.1)..style = PaintingStyle.stroke);
    
    // North arrow
    final northPath = Path();
    northPath.moveTo(center.dx, center.dy - radius + 5);
    northPath.lineTo(center.dx - 4, center.dy);
    northPath.lineTo(center.dx + 4, center.dy);
    northPath.close();
    canvas.drawPath(northPath, compassPaint);
    
    // N label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'N',
        style: TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - 4, center.dy - radius - 5));
  }

  void _drawScale(Canvas canvas, Size size) {
    const scaleLength = 60.0;
    final startPoint = Offset(20, size.height - 40);
    final endPoint = Offset(20 + scaleLength, size.height - 40);
    
    final scalePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..strokeWidth = 2.0;
    
    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(15, size.height - 50, scaleLength + 20, 20),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    
    // Scale line
    canvas.drawLine(startPoint, endPoint, scalePaint);
    
    // Tick marks
    canvas.drawLine(
      startPoint,
      Offset(startPoint.dx, startPoint.dy - 5),
      scalePaint,
    );
    canvas.drawLine(
      endPoint,
      Offset(endPoint.dx, endPoint.dy - 5),
      scalePaint,
    );
    
    // Scale text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '1 km',
        style: TextStyle(
          color: Colors.black,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(startPoint.dx + scaleLength/2 - 8, startPoint.dy + 5));
  }

  @override
  bool shouldRepaint(DemoMapPainter oldDelegate) {
    return oldDelegate.selectedEvent != selectedEvent ||
           oldDelegate.zoomLevel != zoomLevel ||
           oldDelegate.panOffset != panOffset ||
           oldDelegate.pulseAnimation.value != pulseAnimation.value;
  }
}