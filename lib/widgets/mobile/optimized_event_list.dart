import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';
import '../../providers/events_provider.dart';
import '../../services/platform_interactions.dart';
import '../../services/cache_service.dart';
import '../../config/modern_theme.dart';
import '../modern/modern_event_card.dart';
import '../modern/modern_skeleton.dart';
import '../../screens/feed/vertical_feed_screen.dart';

class OptimizedEventList extends StatefulWidget {
  final List<Event>? events;
  final VoidCallback? onRefresh;
  final bool enablePullToRefresh;
  final bool enableSwipeActions;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;
  final String? emptyMessage;
  final bool showFeedButton;

  const OptimizedEventList({
    super.key,
    this.events,
    this.onRefresh,
    this.enablePullToRefresh = true,
    this.enableSwipeActions = true,
    this.physics,
    this.padding,
    this.emptyMessage,
    this.showFeedButton = true,
  });

  @override
  State<OptimizedEventList> createState() => _OptimizedEventListState();
}

class _OptimizedEventListState extends State<OptimizedEventList>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<LiquidPullToRefreshState> _refreshKey =
      GlobalKey<LiquidPullToRefreshState>();

  bool _isLoadingMore = false;
  List<Event> _cachedEvents = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadCachedEvents();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadCachedEvents() async {
    final cachedEvents = await CacheService.instance.getCachedEvents();
    if (cachedEvents != null && mounted) {
      setState(() {
        _cachedEvents = cachedEvents;
      });
    }
  }

  void _onScroll() {
    // Infinite scroll with performance optimization
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreEvents();
    }
  }

  Future<void> _loadMoreEvents() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await context.read<EventsProvider>().loadMoreEvents();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    PlatformInteractions.lightImpact();

    if (widget.onRefresh != null) {
      widget.onRefresh!();
    } else {
      final eventsProvider = context.read<EventsProvider>();
      await eventsProvider.loadEvents(refresh: true);
      await eventsProvider.loadFeaturedEvents();
    }
  }

  void _openFeedView(List<Event> events, int startIndex) {
    PlatformInteractions.mediumImpact();

    Navigator.push(
      context,
      PlatformInteractions.createPlatformRoute(
        page: VerticalFeedScreen(initialEvents: events),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<EventsProvider>(
      builder: (context, eventsProvider, child) {
        final events = widget.events ?? eventsProvider.events;

        if (eventsProvider.isLoading &&
            events.isEmpty &&
            _cachedEvents.isEmpty) {
          return _buildLoadingState();
        }

        final displayEvents = events.isNotEmpty ? events : _cachedEvents;

        if (displayEvents.isEmpty) {
          return _buildEmptyState();
        }

        Widget listWidget = ListView.builder(
          controller: _scrollController,
          physics: widget.physics ?? PlatformInteractions.platformScrollPhysics,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24),
          itemCount:
              displayEvents.length +
              (eventsProvider.hasMoreEvents ? 1 : 0) +
              (widget.showFeedButton ? 1 : 0),
          itemBuilder: (context, index) {
            // Feed view button (first item)
            if (widget.showFeedButton && index == 0) {
              return _buildFeedViewButton(displayEvents);
            }

            final adjustedIndex = widget.showFeedButton ? index - 1 : index;

            // Loading indicator at the end
            if (adjustedIndex >= displayEvents.length) {
              return _buildLoadingMore();
            }

            final event = displayEvents[adjustedIndex];
            return _buildEventItem(event, adjustedIndex);
          },
        );

        if (widget.enablePullToRefresh) {
          return LiquidPullToRefresh(
            key: _refreshKey,
            onRefresh: _handleRefresh,
            color: ModernTheme.primaryColor,
            backgroundColor: Colors.white,
            height: 80,
            animSpeedFactor: 2,
            showChildOpacityTransition: false,
            child: listWidget,
          );
        }

        return listWidget;
      },
    );
  }

  Widget _buildFeedViewButton(List<Event> events) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: ModernTheme.neonGradient),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ModernTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => _openFeedView(events, 0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Feed View',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Swipe through events like TikTok',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(Event event, int index) {
    return ModernEventCard(
      event: event,
      enableSwipeActions: widget.enableSwipeActions,
      onTap: () => _openFeedView(
        widget.events ?? context.read<EventsProvider>().events,
        index,
      ),
      onFavorite: () => _handleFavorite(event),
      onShare: () => _handleShare(event),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24),
      itemCount: 5,
      itemBuilder: (context, index) => const ModernEventCardSkeleton(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(40),
        decoration: ModernTheme.modernCardDecoration(
          isDark: Theme.of(context).brightness == Brightness.dark,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 48,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.emptyMessage ?? 'No events found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh or try adjusting your filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMore() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: const Center(
        child: CircularProgressIndicator(
          color: ModernTheme.primaryColor,
          strokeWidth: 2,
        ),
      ),
    );
  }

  void _handleFavorite(Event event) async {
    PlatformInteractions.mediumImpact();

    // Cache favorite locally first
    await CacheService.instance.cacheFavoriteEvent(event.id);

    PlatformInteractions.showToast(
      context: context,
      message: 'Added to favorites',
      icon: Icons.favorite,
      backgroundColor: Colors.pink,
    );
  }

  void _handleShare(Event event) {
    PlatformInteractions.showPlatformActionSheet(
      context: context,
      title: 'Share Event',
      message: event.title,
      actions: [
        PlatformAction(
          title: 'Copy Link',
          icon: Icons.link,
          onPressed: () {
            // Copy event link to clipboard
            Clipboard.setData(
              ClipboardData(text: 'Check out this event: ${event.title}'),
            );
            PlatformInteractions.showToast(
              context: context,
              message: 'Link copied to clipboard',
              icon: Icons.check_circle,
            );
          },
        ),
        PlatformAction(
          title: 'Share Image',
          icon: Icons.image,
          onPressed: () {
            // Share event image
            PlatformInteractions.showToast(
              context: context,
              message: 'Sharing image...',
              icon: Icons.share,
            );
          },
        ),
        PlatformAction(
          title: 'Share Details',
          icon: Icons.info_outline,
          onPressed: () {
            // Share event details
            final text =
                '''
${event.title}

📅 ${DateFormat('EEEE, MMMM d • h:mm a').format(event.startDateTime)}
📍 ${event.venue.name}
💰 ${event.pricing.isFree ? 'FREE' : '\$${event.pricing.price.toStringAsFixed(2)}'}

${event.description}
            ''';

            Clipboard.setData(ClipboardData(text: text));
            PlatformInteractions.showToast(
              context: context,
              message: 'Event details copied',
              icon: Icons.check_circle,
            );
          },
        ),
      ],
    );
  }
}

// Performance-optimized event grid for featured events
class OptimizedEventGrid extends StatefulWidget {
  final List<Event> events;
  final int crossAxisCount;
  final double childAspectRatio;
  final VoidCallback? onRefresh;
  final bool enableSwipeActions;

  const OptimizedEventGrid({
    super.key,
    required this.events,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.8,
    this.onRefresh,
    this.enableSwipeActions = true,
  });

  @override
  State<OptimizedEventGrid> createState() => _OptimizedEventGridState();
}

class _OptimizedEventGridState extends State<OptimizedEventGrid>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.events.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox(height: 200));
    }

    Widget gridWidget = SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final event = widget.events[index];
          return ModernEventCard(
            event: event,
            isHorizontal: false,
            enableSwipeActions: widget.enableSwipeActions,
            onTap: () => _openEventDetails(event),
            onFavorite: () => _handleFavorite(event),
            onShare: () => _handleShare(event),
          );
        },
        childCount: widget.events.length,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        childAspectRatio: widget.childAspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
    );

    if (widget.onRefresh != null) {
      return SliverToBoxAdapter(
        child: LiquidPullToRefresh(
          onRefresh: () async {
            widget.onRefresh?.call();
          },
          color: ModernTheme.primaryColor,
          backgroundColor: Colors.white,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.crossAxisCount,
              childAspectRatio: widget.childAspectRatio,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: widget.events.length,
            itemBuilder: (context, index) {
              final event = widget.events[index];
              return ModernEventCard(
                event: event,
                isHorizontal: false,
                enableSwipeActions: widget.enableSwipeActions,
                onTap: () => _openEventDetails(event),
                onFavorite: () => _handleFavorite(event),
                onShare: () => _handleShare(event),
              );
            },
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: gridWidget,
    );
  }

  void _openEventDetails(Event event) {
    // Open in feed view for immersive experience
    final events = widget.events;
    final startIndex = events.indexOf(event);

    Navigator.push(
      context,
      PlatformInteractions.createPlatformRoute(
        page: VerticalFeedScreen(initialEvents: events),
        fullscreenDialog: true,
      ),
    );
  }

  void _handleFavorite(Event event) async {
    PlatformInteractions.mediumImpact();

    // Cache favorite locally
    await CacheService.instance.cacheFavoriteEvent(event.id);

    PlatformInteractions.showToast(
      context: context,
      message: 'Added to favorites',
      icon: Icons.favorite,
      backgroundColor: Colors.pink,
    );
  }

  void _handleShare(Event event) {
    PlatformInteractions.showPlatformActionSheet(
      context: context,
      title: 'Share Event',
      message: event.title,
      actions: [
        PlatformAction(
          title: 'Copy Link',
          icon: Icons.link,
          onPressed: () {
            Clipboard.setData(
              ClipboardData(text: 'Check out this event: ${event.title}'),
            );
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
      ],
    );
  }
}

// Optimized horizontal event carousel
class OptimizedEventCarousel extends StatefulWidget {
  final List<Event> events;
  final String title;
  final VoidCallback? onSeeAll;

  const OptimizedEventCarousel({
    super.key,
    required this.events,
    required this.title,
    this.onSeeAll,
  });

  @override
  State<OptimizedEventCarousel> createState() => _OptimizedEventCarouselState();
}

class _OptimizedEventCarouselState extends State<OptimizedEventCarousel>
    with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.events.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (widget.onSeeAll != null)
                GestureDetector(
                  onTap: widget.onSeeAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'See All',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ModernTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Carousel
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.events.length,
            itemBuilder: (context, index) {
              final event = widget.events[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: ModernEventCard(
                  event: event,
                  isHorizontal: false,
                  enableSwipeActions: false, // Disable for carousel
                  onTap: () => _openEventDetails(event),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openEventDetails(Event event) {
    Navigator.push(
      context,
      PlatformInteractions.createPlatformRoute(
        page: VerticalFeedScreen(initialEvents: widget.events),
        fullscreenDialog: true,
      ),
    );
  }
}
