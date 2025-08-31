import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';
import '../../config/theme.dart';
import '../../config/glass_theme.dart';

class GlassEventCard extends StatefulWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool showFavoriteButton;

  const GlassEventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onFavorite,
    this.showFavoriteButton = true,
  });

  @override
  State<GlassEventCard> createState() => _GlassEventCardState();
}

class _GlassEventCardState extends State<GlassEventCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 140,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.5),
              Colors.white.withOpacity(0.2),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                // Image section
                if (widget.event.imageUrls.isNotEmpty)
                  Container(
                    width: 120,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.event.imageUrls.first,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey.withOpacity(0.3),
                                  Colors.grey.withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getCategoryColor().withOpacity(0.5),
                                  _getCategoryColor().withOpacity(0.2),
                                ],
                              ),
                            ),
                            child: Icon(
                              _getCategoryIcon(),
                              color: Colors.white.withOpacity(0.5),
                              size: 40,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getCategoryColor().withOpacity(0.5),
                          _getCategoryColor().withOpacity(0.2),
                        ],
                      ),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      color: Colors.white.withOpacity(0.7),
                      size: 40,
                    ),
                  ),
                
                // Content section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title and category
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor().withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    widget.event.category.displayName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (widget.showFavoriteButton)
                                  IconButton(
                                    icon: Icon(
                                      Icons.favorite_border,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: widget.onFavorite,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.event.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        
                        // Date, time and price
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM d').format(widget.event.startDateTime),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('h:mm a').format(widget.event.startDateTime),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: widget.event.pricing.isFree
                                    ? LinearGradient(colors: GlassTheme.successGradient)
                                    : LinearGradient(colors: GlassTheme.primaryGradient),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.event.pricing.isFree
                                    ? 'FREE'
                                    : '\$${widget.event.pricing.price.toStringAsFixed(0)}+',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.event.venue.name,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (widget.event.category) {
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

  IconData _getCategoryIcon() {
    switch (widget.event.category) {
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
        return Icons.event;
    }
  }
}