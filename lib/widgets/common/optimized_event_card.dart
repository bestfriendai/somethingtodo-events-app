import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';
import '../../providers/events_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/modern_theme.dart';
import 'optimized_image.dart';
import '../../services/platform_interactions.dart';

/// Optimized event card that minimizes rebuilds
class OptimizedEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final bool showFavoriteButton;
  final bool isCompact;

  const OptimizedEventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.showFavoriteButton = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: _EventCardContent(
        event: event,
        onTap: onTap,
        showFavoriteButton: showFavoriteButton,
        isCompact: isCompact,
      ),
    );
  }
}

class _EventCardContent extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final bool showFavoriteButton;
  final bool isCompact;

  const _EventCardContent({
    required this.event,
    required this.onTap,
    required this.showFavoriteButton,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardHeight = isCompact ? 120.0 : 280.0;
    final imageHeight = isCompact ? 120.0 : 180.0;

    return GestureDetector(
      onTap: () {
        PlatformInteractions.lightImpact();
        onTap();
      },
      child: Container(
        height: cardHeight,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? ModernTheme.darkCardSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: isCompact
              ? _buildCompactLayout(imageHeight, theme, isDark)
              : _buildStandardLayout(imageHeight, theme, isDark),
        ),
      ),
    );
  }

  Widget _buildCompactLayout(double imageHeight, ThemeData theme, bool isDark) {
    return Row(
      children: [
        // Image
        SizedBox(
          width: 120,
          height: imageHeight,
          child: OptimizedImage(
            imageUrl: event.imageUrl,
            width: 120,
            height: imageHeight,
            fit: BoxFit.cover,
          ),
        ),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTitle(theme, maxLines: 2),
                _buildDateLocationRow(theme, isDark),
                if (showFavoriteButton) _buildActionRow(isDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStandardLayout(
    double imageHeight,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image with gradient overlay
        Stack(
          children: [
            OptimizedImage(
              imageUrl: event.imageUrl,
              width: double.infinity,
              height: imageHeight,
              fit: BoxFit.cover,
            ),
            // Gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Category badge
            Positioned(
              top: 12,
              left: 12,
              child: _CategoryBadge(
                category: event.category.toString().split('.').last,
              ),
            ),
            // Price badge
            Positioned(
              top: 12,
              right: 12,
              child: _PriceBadge(price: event.price, currency: event.currency),
            ),
          ],
        ),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTitle(theme),
                _buildDateLocationRow(theme, isDark),
                if (showFavoriteButton) _buildActionRow(isDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(ThemeData theme, {int maxLines = 2}) {
    return Text(
      event.title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDateLocationRow(ThemeData theme, bool isDark) {
    final dateFormat = DateFormat('MMM d • h:mm a');

    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: 14,
          color: isDark ? Colors.white70 : Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            dateFormat.format(event.startDate),
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (event.venue.city != null) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.location_on,
            size: 14,
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              event.venue.city!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Attendees count
        if (event.attendees > 0)
          Row(
            children: [
              Icon(
                Icons.people,
                size: 16,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '${event.attendees} going',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ],
          ),
        const Spacer(),
        // Favorite button
        _FavoriteButton(eventId: event.id, isFavorite: event.isFavorite),
      ],
    );
  }
}

/// Category badge widget
class _CategoryBadge extends StatelessWidget {
  final String category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    // Return black for all categories to match the black theme
    return Colors.black;
  }
}

/// Price badge widget
class _PriceBadge extends StatelessWidget {
  final double price;
  final String currency;

  const _PriceBadge({required this.price, required this.currency});

  @override
  Widget build(BuildContext context) {
    final priceText = price == 0
        ? 'FREE'
        : '$currency${price.toStringAsFixed(price % 1 == 0 ? 0 : 2)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: price == 0 ? Colors.green : Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priceText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Optimized favorite button that doesn't rebuild the entire card
class _FavoriteButton extends StatefulWidget {
  final String eventId;
  final bool isFavorite;

  const _FavoriteButton({required this.eventId, required this.isFavorite});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late bool _isFavorite;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      setState(() {
        _isFavorite = widget.isFavorite;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _isFavorite = !_isFavorite;
    });

    // Animate
    await _animationController.forward();
    await _animationController.reverse();

    // Haptic feedback
    PlatformInteractions.lightImpact();

    try {
      // Update in provider
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        await context.read<EventsProvider>().toggleFavorite(
          widget.eventId,
          authProvider.currentUser?.id ?? '',
        );
      }
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFavorite,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isFavorite
                ? Colors.red.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: _isFavorite ? Colors.red : Colors.grey,
          ),
        ),
      ),
    );
  }
}
