import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'dart:math';
import 'package:glassmorphism/glassmorphism.dart';

import '../../providers/events_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/event.dart';
import '../../config/modern_theme.dart';
import '../../widgets/modern/modern_event_card.dart';
import '../../widgets/modern/modern_skeleton.dart';
import '../../widgets/mobile/optimized_event_list.dart';
import '../../widgets/common/delightful_refresh.dart';
import '../../services/platform_interactions.dart';
import '../../services/cache_service.dart';
import '../../services/delight_service.dart';
import '../events/event_details_screen.dart';
import '../search/search_screen.dart';
import '../notifications/notifications_screen.dart';
import '../feed/vertical_feed_screen.dart';

class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final PageController _featuredPageController = PageController(
    viewportFraction: 0.9,
  );
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late AnimationController _headerAnimationController;
  
  int _currentFeaturedIndex = 0;
  EventCategory? _selectedCategory;
  double _scrollOffset = 0.0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
      _headerAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _headerAnimationController.dispose();
    _featuredPageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
    
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<EventsProvider>().loadMoreEvents();
    }
  }

  Future<void> _refreshData() async {
    PlatformInteractions.lightImpact();
    final eventsProvider = context.read<EventsProvider>();
    await eventsProvider.loadEvents(refresh: true);
    await eventsProvider.loadFeaturedEvents();
    
    // Preload images for better performance
    eventsProvider.preloadEventImages();
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Animated gradient background
          _buildAnimatedBackground(),
          
          // Main content with delightful pull to refresh
          DelightfulRefresh(
            onRefresh: _refreshData,
            refreshMessage: 'Summoning epic events from the cosmos...',
            child: CustomScrollView(
              controller: _scrollController,
              physics: PlatformInteractions.platformScrollPhysics,
              slivers: [
                _buildModernAppBar(),
                _buildSearchSection(),
                _buildFeedViewPromo(),
                _buildFeaturedEvents(),
                _buildQuickStats(),
                _buildCategoryFilters(),
                _buildEventsSection(),
                // Bottom padding for FAB
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: ModernTheme.modernBackgroundDecoration(
        useAuroraEffect: true,
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            children: [
              // Aurora Borealis effect with animated gradients
              Positioned.fill(
                child: CustomPaint(
                  painter: AuroraBoreailisPainter(
                    animation: _animationController,
                    colors: ModernTheme.auroraGradient,
                  ),
                ),
              ),
              
              // Floating electric purple orb
              Positioned(
                top: 80 + (60 * sin(_animationController.value * 2 * pi)),
                left: -80 + (40 * cos(_animationController.value * pi)),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF7C3AED).withOpacity(0.3), // Electric Purple
                        const Color(0xFF7C3AED).withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              
              // Floating neon pink orb
              Positioned(
                bottom: 150 - (80 * cos(_animationController.value * 1.5 * pi)),
                right: -100 - (60 * sin(_animationController.value * 1.2 * pi)),
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFEC4899).withOpacity(0.25), // Neon Pink
                        const Color(0xFFEC4899).withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              
              // Cyber blue orb
              Positioned(
                top: 200 + (40 * cos(_animationController.value * 0.8 * pi)),
                right: 50 + (30 * sin(_animationController.value * 1.3 * pi)),
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF06B6D4).withOpacity(0.2), // Cyber Blue
                        const Color(0xFF06B6D4).withOpacity(0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              
              // Particle effects overlay
              Positioned.fill(
                child: CustomPaint(
                  painter: ParticleEffectPainter(
                    animation: _animationController,
                    particleCount: 30,
                  ),
                ),
              ),
              
              // Mesh gradient overlay for depth
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFF0A0A0B).withOpacity(0.3),
                        const Color(0xFF0A0A0B).withOpacity(0.7),
                        const Color(0xFF0A0A0B),
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModernAppBar() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SliverAppBar(
          floating: false,
          pinned: true,
          snap: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          expandedHeight: 140,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.0),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time-based greeting with animation
                      AnimatedBuilder(
                        animation: _headerAnimationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 30 * (1 - _headerAnimationController.value)),
                            child: Opacity(
                              opacity: _headerAnimationController.value,
                              child: GestureDetector(
                                onLongPress: () {
                                  DelightService.instance.triggerEasterEgg(context, 'greeting');
                                },
                                child: Text(
                                  'Good ${_getTimeOfDay()} 👋',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      // User name with slide animation
                      AnimatedBuilder(
                        animation: _headerAnimationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 40 * (1 - _headerAnimationController.value)),
                            child: Opacity(
                              opacity: _headerAnimationController.value,
                              child: Text(
                                authProvider.currentUser?.displayName ?? 'Explorer',
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: [
            // Modern notification button
            AnimatedBuilder(
              animation: _headerAnimationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(20 * (1 - _headerAnimationController.value), 0),
                  child: Opacity(
                    opacity: _headerAnimationController.value,
                    child: Container(
                      margin: const EdgeInsets.only(right: 20, top: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          PlatformInteractions.lightImpact();
                          Navigator.push(
                            context,
                            PlatformInteractions.createPlatformRoute(
                              page: const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: GestureDetector(
          onTap: () {
            PlatformInteractions.lightImpact();
            DelightService.instance.showConfetti(
              context,
              customMessage: 'Search mode activated! Find your next adventure! 🔍',
            );
            Navigator.push(
              context,
              PlatformInteractions.createPlatformRoute(
                page: const SearchScreen(),
              ),
            );
          },
          onLongPress: () {
            DelightService.instance.triggerEasterEgg(context, 'search_master');
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: GlassmorphicContainer(
                width: double.infinity,
                height: 60,
                borderRadius: 28,
                blur: 20,
                alignment: Alignment.centerLeft,
                border: 1,
                linearGradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderGradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: ModernTheme.neonGradient,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          [
                            'Search events, venues...',
                            'What adventure calls to you?',
                            'Find your next favorite thing...',
                            'Discover something amazing...',
                          ][Random().nextInt(4)],
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedViewPromo() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: ModernTheme.modernCardDecoration(
          isDark: Theme.of(context).brightness == Brightness.dark,
          gradient: ModernTheme.primaryGradient,
          borderRadius: 20,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'New: TikTok-Style Feed',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'HOT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ).animate()
                        .fadeIn(delay: 1.seconds)
                        .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut)
                        .then()
                        .shimmer(duration: 2.seconds),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Swipe through events like a social media pro! 📱',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                PlatformInteractions.mediumImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VerticalFeedScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: ModernTheme.modernCardDecoration(
                  isDark: Theme.of(context).brightness == Brightness.dark,
                  borderRadius: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: ModernTheme.forestGradient,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.event_available_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Consumer<EventsProvider>(
                      builder: (context, provider, _) {
                        return Text(
                          '${provider.events.length}+',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
                    Text(
                      'Events',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: ModernTheme.modernCardDecoration(
                  isDark: Theme.of(context).brightness == Brightness.dark,
                  borderRadius: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: ModernTheme.pinkGradient,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '24',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Favorites',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedEvents() {
    return Consumer<EventsProvider>(
      builder: (context, eventsProvider, child) {
        if (eventsProvider.isLoading && eventsProvider.featuredEvents.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              height: 320,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: PageView.builder(
                itemCount: 3,
                itemBuilder: (context, index) => const ModernFeaturedEventSkeleton(),
              ),
            ),
          );
        }

        final featuredEvents = eventsProvider.featuredEvents;
        if (featuredEvents.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: ModernTheme.sunsetGradient,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Featured Events',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Featured events carousel
              SizedBox(
                height: 320,
                child: PageView.builder(
                  controller: _featuredPageController,
                  itemCount: featuredEvents.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentFeaturedIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final event = featuredEvents[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildFeaturedEventCard(event),
                    );
                  },
                ),
              ),
              
              // Page indicators
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  featuredEvents.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentFeaturedIndex == index ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentFeaturedIndex == index
                          ? ModernTheme.primaryColor
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturedEventCard(Event event) {
    final categoryGradient = ModernTheme.getCategoryGradient(event.category.name);
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailsScreen(event: event),
          ),
        );
      },
      child: Container(
        decoration: ModernTheme.modernCardDecoration(
          isDark: true,
          borderRadius: 28,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              if (event.imageUrls.isNotEmpty)
                Hero(
                  tag: 'featured-event-${event.id}',
                  child: CachedNetworkImage(
                    imageUrl: event.imageUrls.first,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: categoryGradient),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: categoryGradient),
                      ),
                      child: const Icon(
                        Icons.event_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: categoryGradient),
                  ),
                  child: const Icon(
                    Icons.event_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              
              // Gradient overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black87,
                    ],
                  ),
                ),
              ),
              
              // Content
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: categoryGradient),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event.category.displayName.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            event.venue.name,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: ModernTheme.neonGradient,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.category_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Categories',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: EventCategory.values.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildCategoryChip(null, 'All', 0);
                }
                final category = EventCategory.values[index - 1];
                return _buildCategoryChip(category, category.displayName, index);
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(EventCategory? category, String label, int index) {
    final isSelected = _selectedCategory == category;
    final gradient = category != null 
        ? ModernTheme.getCategoryGradient(category.name)
        : ModernTheme.purpleGradient;
    
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          PlatformInteractions.lightImpact();
          setState(() {
            _selectedCategory = category;
          });
          context.read<EventsProvider>().setCategory(category);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? LinearGradient(colors: gradient) : null,
            color: isSelected ? null : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected 
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventsSection() {
    return Consumer<EventsProvider>(
      builder: (context, eventsProvider, child) {
        if (eventsProvider.isLoading && eventsProvider.events.isEmpty) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: ModernEventCardSkeleton(),
              ),
              childCount: 5,
            ),
          );
        }

        final events = eventsProvider.events;
        if (events.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(40),
              decoration: ModernTheme.modernCardDecoration(
                isDark: Theme.of(context).brightness == Brightness.dark,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.event_busy_rounded,
                      size: 48,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No events found',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters or check back later',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: OptimizedEventList(
              events: events,
              enablePullToRefresh: false, // Already handled by main refresh
              enableSwipeActions: true,
              showFeedButton: false, // Already shown above
              padding: const EdgeInsets.symmetric(horizontal: 24),
              onRefresh: _refreshData,
            ),
          ),
        );
      },
    );
  }
}

// Aurora Borealis Painter for stunning animated backgrounds
class AuroraBoreailisPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Color> colors;
  
  AuroraBoreailisPainter({required this.animation, required this.colors});
  
  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Create flowing aurora waves
    for (int i = 0; i < 3; i++) {
      final path = Path();
      final waveHeight = size.height * 0.3;
      final waveOffset = (progress + i * 0.3) * 2 * pi;
      
      path.moveTo(0, size.height);
      
      for (double x = 0; x <= size.width; x += 5) {
        final y = size.height - waveHeight + 
            (sin(x / 100 + waveOffset) * 50) +
            (sin(x / 200 + waveOffset * 0.5) * 30);
        path.lineTo(x, y);
      }
      
      path.lineTo(size.width, size.height);
      path.close();
      
      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors[i % colors.length].withOpacity(0.1 - i * 0.02),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      
      canvas.drawPath(path, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Particle Effect Painter for ambient magic
class ParticleEffectPainter extends CustomPainter {
  final Animation<double> animation;
  final int particleCount;
  
  ParticleEffectPainter({
    required this.animation,
    required this.particleCount,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    final paint = Paint()..style = PaintingStyle.fill;
    
    final random = Random(42); // Seeded for consistent particle positions
    
    for (int i = 0; i < particleCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      
      // Animate particles in a subtle floating motion
      final x = baseX + (sin(progress * 2 * pi + i * 0.1) * 20);
      final y = baseY + (cos(progress * 1.5 * pi + i * 0.15) * 15);
      
      final particleSize = 1 + random.nextDouble() * 2;
      final opacity = 0.3 + (sin(progress * 4 * pi + i * 0.2) * 0.2);
      
      paint.color = [
        const Color(0xFF7C3AED), // Electric Purple
        const Color(0xFFEC4899), // Neon Pink
        const Color(0xFF06B6D4), // Cyber Blue
        Colors.white,
      ][i % 4].withOpacity(opacity);
      
      canvas.drawCircle(Offset(x, y), particleSize, paint);
      
      // Add a subtle glow effect
      paint.color = paint.color.withOpacity(opacity * 0.3);
      canvas.drawCircle(Offset(x, y), particleSize * 2, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}