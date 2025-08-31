import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';
import '../../providers/events_provider.dart';
import '../../services/gesture_service.dart';
import '../../services/platform_interactions.dart';
import '../../services/cache_service.dart';
import '../../config/modern_theme.dart';
import '../../widgets/mobile/swipeable_feed_card.dart';
import '../../widgets/mobile/mobile_bottom_sheet.dart';
import '../events/event_details_screen.dart';

class VerticalFeedScreen extends StatefulWidget {
  final List<Event>? initialEvents;

  const VerticalFeedScreen({
    super.key,
    this.initialEvents,
  });

  @override
  State<VerticalFeedScreen> createState() => _VerticalFeedScreenState();
}

class _VerticalFeedScreenState extends State<VerticalFeedScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _overlayController;
  late Animation<double> _overlayOpacity;

  int _currentIndex = 0;
  bool _showOverlay = false;
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _overlayOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeOut,
    ));

    _loadEvents();
    
    // Preload images for better performance
    _preloadImages();
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _loadEvents() {
    if (widget.initialEvents != null) {
      setState(() {
        _events = widget.initialEvents!;
      });
    } else {
      final eventsProvider = context.read<EventsProvider>();
      setState(() {
        _events = eventsProvider.events;
      });
    }
  }

  void _preloadImages() {
    final imageUrls = _events
        .expand((event) => event.imageUrls)
        .take(10) // Only preload first 10 images
        .toList();
    CacheService.instance.preloadImages(imageUrls);
  }

  void _handleSwipe(SwipeDirection direction, double velocity) {
    switch (direction) {
      case SwipeDirection.up:
        _nextEvent();
        break;
      case SwipeDirection.down:
        _previousEvent();
        break;
      case SwipeDirection.left:
        _handleLeftSwipe();
        break;
      case SwipeDirection.right:
        _handleRightSwipe();
        break;
    }
  }

  void _nextEvent() {
    if (_currentIndex < _events.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      // Load more events
      context.read<EventsProvider>().loadMoreEvents();
    }
  }

  void _previousEvent() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleLeftSwipe() {
    // Share event
    final event = _events[_currentIndex];
    _shareEvent(event);
  }

  void _handleRightSwipe() {
    // Like/favorite event
    final event = _events[_currentIndex];
    _toggleFavorite(event);
  }

  void _shareEvent(Event event) {
    PlatformInteractions.mediumImpact();
    
    PlatformInteractions.showPlatformActionSheet(
      context: context,
      title: 'Share Event',
      message: event.title,
      actions: [
        PlatformAction(
          title: 'Share Link',
          icon: Icons.link,
          onPressed: () {
            // Implement share link
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

  void _toggleFavorite(Event event) async {
    PlatformInteractions.mediumImpact();
    
    // Cache favorite locally first (for offline support)
    await CacheService.instance.cacheFavoriteEvent(event.id);
    
    PlatformInteractions.showToast(
      context: context,
      message: 'Added to favorites',
      icon: Icons.favorite,
      backgroundColor: Colors.pink,
    );
  }

  void _showEventDetails(Event event) {
    PlatformInteractions.lightImpact();
    
    MobileBottomSheet.show(
      context: context,
      isScrollable: true,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      child: EventDetailsBottomSheet(event: event),
    );
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
    
    if (_showOverlay) {
      _overlayController.forward();
    } else {
      _overlayController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _toggleOverlay,
          ),
        ],
      ),
      body: Consumer<EventsProvider>(
        builder: (context, eventsProvider, child) {
          final allEvents = eventsProvider.events;
          if (allEvents.isNotEmpty && allEvents != _events) {
            setState(() {
              _events = allEvents;
            });
          }

          if (_events.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return Stack(
            children: [
              // Main feed
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  
                  // Load more events when approaching the end
                  if (index >= _events.length - 3) {
                    eventsProvider.loadMoreEvents();
                  }
                },
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final event = _events[index];
                  return SwipeableFeedCard(
                    event: event,
                    onSwipeUp: _nextEvent,
                    onSwipeDown: _previousEvent,
                    onSwipeLeft: () => _shareEvent(event),
                    onSwipeRight: () => _toggleFavorite(event),
                    onTap: () => _showEventDetails(event),
                    onDoubleTap: () => _toggleFavorite(event),
                  );
                },
              ),
              
              // Overlay menu
              if (_showOverlay) _buildOverlay(),
            ],
          );
        },
      ),
    );
  }





  Widget _buildOverlay() {
    return AnimatedBuilder(
      animation: _overlayOpacity,
      builder: (context, child) {
        return Opacity(
          opacity: _overlayOpacity.value,
          child: Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(40),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Feed Controls',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    _buildOverlayAction(
                      icon: Icons.swipe_up_rounded,
                      title: 'Swipe Up',
                      subtitle: 'Next event',
                    ),
                    _buildOverlayAction(
                      icon: Icons.swipe_down_rounded,
                      title: 'Swipe Down',
                      subtitle: 'Previous event',
                    ),
                    _buildOverlayAction(
                      icon: Icons.swipe_left_rounded,
                      title: 'Swipe Left',
                      subtitle: 'Share event',
                    ),
                    _buildOverlayAction(
                      icon: Icons.swipe_right_rounded,
                      title: 'Swipe Right',
                      subtitle: 'Like event',
                    ),
                    _buildOverlayAction(
                      icon: Icons.tap_and_play_rounded,
                      title: 'Tap',
                      subtitle: 'View details',
                    ),
                    
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _toggleOverlay,
                      child: const Text('Got it!'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverlayAction({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}