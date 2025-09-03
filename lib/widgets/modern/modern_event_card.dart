import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'dart:math';
import '../../models/event.dart';
import '../../config/modern_theme.dart';
import '../../services/gesture_service.dart';
import '../../services/platform_interactions.dart';
import '../mobile/mobile_bottom_sheet.dart';

class ModernEventCard extends StatefulWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final bool showFavoriteButton;
  final bool isHorizontal;
  final bool enableSwipeActions;

  const ModernEventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onFavorite,
    this.onShare,
    this.showFavoriteButton = true,
    this.isHorizontal = true,
    this.enableSwipeActions = true,
  });

  @override
  State<ModernEventCard> createState() => _ModernEventCardState();
}

class _ModernEventCardState extends State<ModernEventCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Haptic feedback for modern feel
    PlatformInteractions.lightImpact();
    widget.onTap?.call();
  }

  void _handleFavorite() {
    // Haptic feedback
    PlatformInteractions.mediumImpact();
    widget.onFavorite?.call();
  }

  void _showEventDetails(BuildContext context) {
    PlatformInteractions.lightImpact();
    MobileBottomSheet.show(
      context: context,
      isScrollable: true,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      child: EventDetailsBottomSheet(event: widget.event),
    );
  }

  void _showShareOptions(BuildContext context) {
    PlatformInteractions.lightImpact();

    PlatformInteractions.showPlatformActionSheet(
      context: context,
      title: 'Share Event',
      message: widget.event.title,
      actions: [
        PlatformAction(
          title: 'Copy Link',
          icon: Icons.link,
          onPressed: () {
            PlatformInteractions.showToast(
              context: context,
              message: 'Link copied to clipboard',
              icon: Icons.check_circle,
            );
          },
        ),
        PlatformAction(
          title: 'Share to Social Media',
          icon: Icons.share,
          onPressed: () {
            // Implement social media share
          },
        ),
        PlatformAction(
          title: 'Send to Friends',
          icon: Icons.send,
          onPressed: () {
            // Implement direct sharing
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget cardWidget = AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child:
          Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: GlassmorphicContainer(
                      width: double.infinity,
                      height: widget.isHorizontal ? 180 : 320,
                      borderRadius: 28,
                      blur: 15,
                      alignment: Alignment.bottomCenter,
                      border: 1.5,
                      linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                      borderGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          ModernTheme.getCategoryGradient(
                            widget.event.category.name,
                          )[0].withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                      ),
                      child: widget.isHorizontal
                          ? _buildHorizontalCard()
                          : _buildVerticalCard(),
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms, curve: Curves.easeOut)
              .slideY(begin: 0.3, duration: 800.ms, curve: Curves.elasticOut),
    );

    if (widget.enableSwipeActions) {
      return SwipeableEventCard(
        onSwipeLeft: () {
          if (widget.onShare != null) {
            widget.onShare!();
          } else {
            _showShareOptions(context);
          }
        },
        onSwipeRight: () {
          if (widget.onFavorite != null) {
            widget.onFavorite!();
          } else {
            _handleFavorite();
          }
        },
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          } else {
            _showEventDetails(context);
          }
        },
        leftActionColor: Colors.blue,
        rightActionColor: Colors.pink,
        leftActionIcon: Icons.share_rounded,
        rightActionIcon: Icons.favorite_rounded,
        leftActionLabel: 'Share',
        rightActionLabel: 'Like',
        child: cardWidget,
      );
    } else {
      return GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _animationController.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _animationController.reverse();
          _handleTap();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _animationController.reverse();
        },
        child: cardWidget,
      );
    }
  }

  Widget _buildHorizontalCard() {
    final theme = Theme.of(context);
    final categoryGradient = ModernTheme.getCategoryGradient(
      widget.event.category.name,
    );

    return SizedBox(
      height: 180,
      child: Row(
        children: [
          // Image section with modern styling
          Container(
            width: 160,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: categoryGradient,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      bottomLeft: Radius.circular(28),
                    ),
                  ),
                ),

                // Image with rounded corners
                if (widget.event.imageUrls.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      bottomLeft: Radius.circular(28),
                    ),
                    child: Hero(
                      tag: 'event-image-${widget.event.id}',
                      child: CachedNetworkImage(
                        imageUrl: widget.event.imageUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildImagePlaceholder(),
                        errorWidget: (context, url, error) =>
                            _buildImageError(),
                      ),
                    ),
                  )
                else
                  _buildImageError(),

                // Sophisticated gradient overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      bottomLeft: Radius.circular(28),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),

                // Modern floating category chip
                Positioned(
                  top: 16,
                  left: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          _getCategoryIcon(),
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content section with modern styling
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Modern category pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: categoryGradient,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: categoryGradient[0].withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.event.category.displayName.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Enhanced title
                      Text(
                        widget.event.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  // Modern info row with enhanced styling
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date row
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.schedule_rounded,
                                    size: 14,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    DateFormat(
                                      'MMM d • h:mm a',
                                    ).format(widget.event.startDateTime),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Location row
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    size: 14,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    widget.event.venue.name,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontWeight: FontWeight.w600,
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
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Ultra-modern price chip with glow
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: widget.event.pricing.isFree
                                    ? [
                                        const Color(0xFF000000),
                                        const Color(0xFF1A1A1A),
                                      ]
                                    : [
                                        const Color(0xFF000000),
                                        const Color(0xFF1A1A1A),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF000000,
                                  ).withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.event.pricing.isFree
                                  ? 'FREE'
                                  : '\$${widget.event.pricing.price.toStringAsFixed(0)}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          // Modern favorite button
                          if (widget.showFavoriteButton) ...[
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () {
                                if (widget.onFavorite != null) {
                                  widget.onFavorite!();
                                } else {
                                  _handleFavorite();
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.favorite_border_rounded,
                                      size: 18,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalCard() {
    final theme = Theme.of(context);
    final categoryGradient = ModernTheme.getCategoryGradient(
      widget.event.category.name,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image section
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: categoryGradient,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.event.imageUrls.isNotEmpty)
                Hero(
                  tag: 'event-image-${widget.event.id}',
                  child: CachedNetworkImage(
                    imageUrl: widget.event.imageUrls.first,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildImagePlaceholder(),
                    errorWidget: (context, url, error) => _buildImageError(),
                  ),
                )
              else
                _buildImageError(),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                    ],
                  ),
                ),
              ),
              // Category chip and favorite
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        widget.event.category.displayName.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    if (widget.showFavoriteButton)
                      GestureDetector(
                        onTap: () {
                          if (widget.onFavorite != null) {
                            widget.onFavorite!();
                          } else {
                            _handleFavorite();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.favorite_border_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Content section
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.event.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat(
                      'MMM d • h:mm a',
                    ).format(widget.event.startDateTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.event.venue.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.event.pricing.isFree
                          ? ModernTheme.accentColor
                          : ModernTheme.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.event.pricing.isFree
                          ? 'FREE'
                          : '\$${widget.event.pricing.price.toStringAsFixed(0)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ModernTheme.getCategoryGradient(widget.event.category.name),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageError() {
    final categoryGradient = ModernTheme.getCategoryGradient(
      widget.event.category.name,
    );
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: categoryGradient,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(_getCategoryIcon(), color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              widget.event.category.displayName,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (widget.event.category) {
      case EventCategory.music:
        return Icons.music_note_rounded;
      case EventCategory.food:
        return Icons.restaurant_rounded;
      case EventCategory.sports:
        return Icons.sports_soccer_rounded;
      case EventCategory.arts:
        return Icons.palette_rounded;
      case EventCategory.business:
        return Icons.business_center_rounded;
      case EventCategory.education:
        return Icons.school_rounded;
      case EventCategory.technology:
        return Icons.computer_rounded;
      case EventCategory.health:
        return Icons.local_hospital_rounded;
      case EventCategory.community:
        return Icons.group_rounded;
      default:
        return Icons.event_rounded;
    }
  }
}
