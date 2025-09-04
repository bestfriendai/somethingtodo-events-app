import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/event.dart';
import '../../config/theme.dart';
import '../../config/app_config.dart';
import '../../config/glass_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import 'loading_shimmer.dart';

class EventCard extends StatefulWidget {
  final Event event;
  final VoidCallback? onTap;
  final bool compact;
  final bool showFavoriteButton;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.compact = false,
    this.showFavoriteButton = true,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isFavorited = false;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
  }

  void _checkIfFavorited() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      _isFavorited = authProvider.currentUser!.favoriteEventIds.contains(
        widget.event.id,
      );
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isToggling) return;

    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    setState(() {
      _isToggling = true;
    });

    try {
      if (_isFavorited) {
        if (!AppConfig.demoMode && !authProvider.isDemoMode) {
          await _firestoreService.removeFromFavorites(
            authProvider.currentUser!.id,
            widget.event.id,
          );
        }
        await authProvider.removeFavoriteEvent(widget.event.id);
      } else {
        if (!AppConfig.demoMode && !authProvider.isDemoMode) {
          await _firestoreService.addToFavorites(
            authProvider.currentUser!.id,
            widget.event.id,
          );
        }
        await authProvider.addFavoriteEvent(widget.event.id);
      }

      setState(() {
        _isFavorited = !_isFavorited;
      });
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${_isFavorited ? 'remove from' : 'add to'} favorites',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isToggling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactCard();
    }
    return _buildFullCard();
  }

  Widget _buildFullCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GlassTheme.glassCard(
        borderRadius: 16,
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.event.imageUrls.isNotEmpty
                      ? widget.event.imageUrls.first
                      : 'https://via.placeholder.com/400x200',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const LoadingShimmer(height: 160),
                  errorWidget: (context, url, error) => Container(
                    height: 160,
                    color: Colors.black.withValues(alpha: 0.1),
                    child: const Center(
                      child: Icon(Icons.image, size: 40, color: Colors.white70),
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date and Time
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat(
                            'MMM dd, yyyy • h:mm a',
                          ).format(widget.event.startDateTime),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      widget.event.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Organizer
                    Text(
                      'by ${widget.event.organizerName}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    // Location and Price
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.event.venue.name,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: widget.event.pricing.isFree
                                ? AppTheme.successColor.withValues(alpha: 0.1)
                                : AppTheme.warningColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.event.pricing.isFree
                                ? 'Free'
                                : '\$${widget.event.pricing.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: widget.event.pricing.isFree
                                  ? AppTheme.successColor
                                  : AppTheme.warningColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: widget.event.imageUrls.isNotEmpty
                      ? widget.event.imageUrls.first
                      : 'https://via.placeholder.com/80x80',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const LoadingShimmer(width: 60, height: 60),
                  errorWidget: (context, url, error) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.event.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Date
                    Text(
                      DateFormat(
                        'MMM dd • h:mm a',
                      ).format(widget.event.startDateTime),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            widget.event.venue.name,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Price and Favorite
              Column(
                children: [
                  if (widget.showFavoriteButton)
                    GestureDetector(
                      onTap: _toggleFavorite,
                      child: _isToggling
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _isFavorited
                                  ? Icons.favorite
                                  : Icons.favorite_outline,
                              color: _isFavorited
                                  ? AppTheme.errorColor
                                  : Colors.grey[400],
                              size: 20,
                            ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.pricing.isFree
                        ? 'Free'
                        : '\$${widget.event.pricing.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: widget.event.pricing.isFree
                          ? AppTheme.successColor
                          : AppTheme.warningColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
