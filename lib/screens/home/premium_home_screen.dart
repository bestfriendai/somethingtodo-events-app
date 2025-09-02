import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../providers/events_provider.dart';
import '../../models/event.dart';
import '../../screens/events/event_details_screen.dart';
import '../../screens/search/enhanced_search_screen.dart';
import '../../screens/map/map_screen.dart';
import '../../screens/chat/chat_screen.dart';
import '../../screens/profile/profile_screen.dart';

class PremiumHomeScreen extends StatefulWidget {
  const PremiumHomeScreen({super.key});

  @override
  State<PremiumHomeScreen> createState() => _PremiumHomeScreenState();
}

class _PremiumHomeScreenState extends State<PremiumHomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _parallaxController;
  late final AnimationController _shimmerController;
  late final AnimationController _pulseController;
  late final AnimationController _bounceController;
  late final AnimationController _rotateController;
  
  final ScrollController _scrollController = ScrollController();
  final PageController _carouselController = PageController(viewportFraction: 0.85);
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey();
  
  double _scrollOffset = 0.0;
  int _selectedNavIndex = 0;
  
  // Categories with icons and colors
  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.dashboard_rounded, 'color': Colors.purple},
    {'name': 'Music', 'icon': Icons.music_note_rounded, 'color': Colors.pink},
    {'name': 'Sports', 'icon': Icons.sports_basketball_rounded, 'color': Colors.orange},
    {'name': 'Food', 'icon': Icons.restaurant_rounded, 'color': Colors.green},
    {'name': 'Art', 'icon': Icons.palette_rounded, 'color': Colors.blue},
    {'name': 'Tech', 'icon': Icons.computer_rounded, 'color': Colors.cyan},
    {'name': 'Business', 'icon': Icons.business_rounded, 'color': Colors.indigo},
    {'name': 'Health', 'icon': Icons.favorite_rounded, 'color': Colors.red},
  ];
  
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
    _loadInitialData();
  }
  
  void _initializeAnimations() {
    _parallaxController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }
  
  void _setupScrollListener() {
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
        // Trigger parallax animation based on scroll
        _parallaxController.value = (_scrollOffset / 200).clamp(0.0, 1.0);
      });
    });
  }
  
  Future<void> _loadInitialData() async {
    final eventsProvider = context.read<EventsProvider>();
    await eventsProvider.loadEvents();
  }
  
  @override
  void dispose() {
    _parallaxController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _bounceController.dispose();
    _rotateController.dispose();
    _scrollController.dispose();
    _carouselController.dispose();
    super.dispose();
  }
  
  Future<void> _onRefresh() async {
    // Trigger haptic feedback
    HapticFeedback.mediumImpact();
    
    final eventsProvider = context.read<EventsProvider>();
    await eventsProvider.loadEvents(); // Use loadEvents instead of refreshEvents
  }
  
  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
    _bounceController.forward(from: 0);
    HapticFeedback.lightImpact();
    
    // Filter events based on category
    final eventsProvider = context.read<EventsProvider>();
    if (index == 0) {
      eventsProvider.setCategory(null); // Clear filter
    } else {
      // Map category name to EventCategory enum
      final categoryMap = {
        'Music': EventCategory.music,
        'Sports': EventCategory.sports,
        'Food': EventCategory.food,
        'Art': EventCategory.arts,
        'Tech': EventCategory.technology,
        'Business': EventCategory.business,
        'Health': EventCategory.health,
      };
      final categoryName = _categories[index]['name'];
      eventsProvider.setCategory(categoryMap[categoryName]);
    }
  }
  
  void _onNavItemTapped(int index) {
    setState(() => _selectedNavIndex = index);
    HapticFeedback.selectionClick();
    
    // Navigate to respective screens
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.push(context, 
          MaterialPageRoute(builder: (_) => const EnhancedSearchScreen()));
        break;
      case 2:
        Navigator.push(context, 
          MaterialPageRoute(builder: (_) => const MapScreen()));
        break;
      case 3:
        Navigator.push(context, 
          MaterialPageRoute(builder: (_) => const ChatScreen()));
        break;
      case 4:
        Navigator.push(context, 
          MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final eventsProvider = context.watch<EventsProvider>();
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated gradient background
          _buildAnimatedBackground(),
          
          // Main content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Floating glassmorphic app bar
              _buildFloatingAppBar(theme),
              
              // Refresh indicator wrapper
              SliverToBoxAdapter(
                child: RefreshIndicator(
                  key: _refreshKey,
                  onRefresh: _onRefresh,
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  color: theme.primaryColor,
                  child: SizedBox(
                    height: size.height * 2, // Ensure scrollable area
                    child: Column(
                      children: [
                        // Hero carousel section
                        _buildHeroCarousel(eventsProvider, size),
                        
                        // Animated category pills
                        _buildCategoryPills(),
                        
                        // Quick action buttons
                        _buildQuickActions(theme),
                        
                        // Trending events section
                        _buildTrendingSection(eventsProvider),
                        
                        // Recommended for you
                        _buildRecommendedSection(eventsProvider),
                        
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Premium floating bottom navigation
          _buildFloatingBottomNav(theme),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedBackground() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Stack(
        children: [
          // Animated particles
          ...List.generate(20, (index) {
            return Positioned(
              left: math.Random().nextDouble() * 400,
              top: math.Random().nextDouble() * 800,
              child: AnimatedBuilder(
                animation: _rotateController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotateController.value * 2 * math.pi,
                    child: Container(
                      width: math.Random().nextDouble() * 100 + 20,
                      height: math.Random().nextDouble() * 100 + 20,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.purple.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ).animate(
                      onPlay: (controller) => controller.repeat(),
                    ).scale(
                      duration: Duration(seconds: 3 + index % 3),
                      begin: Offset(0.8, 0.8),
                      end: Offset(1.2, 1.2),
                    ),
                  );
                },
              ),
            );
          }),
          
          // Blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFloatingAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      snap: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: GlassmorphicContainer(
          width: double.infinity,
          height: 120,
          borderRadius: 0,
          blur: 20,
          alignment: Alignment.center,
          border: 0,
          linearGradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          borderGradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.1),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo and greeting
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good ${_getTimeOfDay()}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ).animate().fadeIn(duration: 600.ms),
                      const SizedBox(height: 4),
                      const Text(
                        'SomethingToDo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ).animate()
                        .fadeIn(delay: 200.ms)
                        .slideX(begin: -0.2, end: 0),
                    ],
                  ),
                  
                  // Action buttons
                  Row(
                    children: [
                      _buildAppBarAction(Icons.notifications_rounded),
                      const SizedBox(width: 12),
                      _buildAppBarAction(Icons.bookmark_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppBarAction(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: () {
          HapticFeedback.lightImpact();
        },
      ),
    ).animate()
      .scale(delay: 400.ms, duration: 400.ms)
      .fadeIn();
  }
  
  Widget _buildHeroCarousel(EventsProvider provider, Size size) {
    final featuredEvents = provider.featuredEvents.take(5).toList();
    
    if (featuredEvents.isEmpty) {
      return _buildCarouselSkeleton(size);
    }
    
    return SizedBox(
      height: size.height * 0.45,
      child: PageView.builder(
        controller: _carouselController,
        onPageChanged: (index) {
          HapticFeedback.selectionClick();
        },
        itemCount: featuredEvents.length,
        itemBuilder: (context, index) {
          final event = featuredEvents[index];
          
          return AnimatedBuilder(
            animation: _parallaxController,
            builder: (context, child) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventDetailsScreen(event: event),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                  child: Stack(
                    children: [
                      // Parallax background image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            Transform.translate(
                              offset: Offset(0, _scrollOffset * 0.5),
                              child: CachedNetworkImage(
                                imageUrl: event.imageUrls.isNotEmpty 
                                  ? event.imageUrls.first 
                                  : 'https://picsum.photos/400/600',
                                width: double.infinity,
                                height: size.height * 0.45,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.8),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Content overlay
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                event.category.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Title
                            Text(
                              event.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            
                            // Date and location
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(event.startDateTime),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    event.venue.name,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
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
                      
                      // Premium badge
                      if (event.isPremium)
                        Positioned(
                          top: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ).animate(
                            onPlay: (controller) => controller.repeat(),
                          ).scale(
                            duration: 2.seconds,
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1.1, 1.1),
                          ),
                        ),
                    ],
                  ),
                ).animate()
                  .fadeIn(delay: (index * 100).ms)
                  .slideY(begin: 0.1, end: 0),
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildCarouselSkeleton(Size size) {
    return SizedBox(
      height: size.height * 0.45,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade800,
              highlightColor: Colors.grey.shade600,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildCategoryPills() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategoryIndex == index;
          
          return GestureDetector(
            onTap: () => _onCategorySelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          category['color'].withValues(alpha: 0.8),
                          category['color'].withValues(alpha: 0.6),
                        ],
                      )
                    : null,
                color: isSelected ? null : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected 
                    ? Colors.transparent 
                    : Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    category['icon'],
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ).animate()
              .fadeIn(delay: (index * 50).ms)
              .slideX(begin: 0.2, end: 0),
          );
        },
      ),
    );
  }
  
  Widget _buildQuickActions(ThemeData theme) {
    final actions = [
      {'icon': Icons.today_rounded, 'label': 'Today', 'color': Colors.blue},
      {'icon': Icons.weekend_rounded, 'label': 'Weekend', 'color': Colors.purple},
      {'icon': Icons.local_fire_department_rounded, 'label': 'Trending', 'color': Colors.orange},
      {'icon': Icons.attach_money_rounded, 'label': 'Free', 'color': Colors.green},
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.asMap().entries.map((entry) {
          final action = entry.value;
          final index = entry.key;
          
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _bounceController.forward(from: 0);
            },
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _bounceController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_bounceController.value * 0.1),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              (action['color'] as Color).withValues(alpha: 0.8),
                              (action['color'] as Color).withValues(alpha: 0.4),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (action['color'] as Color).withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          action['icon'] as IconData,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  action['label'] as String,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ).animate()
              .fadeIn(delay: (index * 100).ms)
              .slideY(begin: 0.2, end: 0),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildTrendingSection(EventsProvider provider) {
    final trendingEvents = provider.events.take(5).toList();
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.orange.shade400,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Trending Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Popular events in your area',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                  },
                  child: Text(
                    'See all',
                    style: TextStyle(
                      color: Colors.blue.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 16),
          
          if (trendingEvents.isEmpty)
            _buildTrendingSkeleton()
          else
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: trendingEvents.length,
                itemBuilder: (context, index) {
                  final event = trendingEvents[index];
                  
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailsScreen(event: event),
                        ),
                      );
                    },
                    child: Container(
                      width: 180,
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Event image with shimmer loading
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CachedNetworkImage(
                                  imageUrl: event.imageUrls.isNotEmpty
                                      ? event.imageUrls.first
                                      : 'https://picsum.photos/180/120',
                                  width: 180,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Shimmer.fromColors(
                                    baseColor: Colors.grey.shade800,
                                    highlightColor: Colors.grey.shade600,
                                    child: Container(
                                      width: 180,
                                      height: 120,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              // Price tag
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: event.pricing.isFree
                                        ? Colors.green
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    event.pricing.isFree
                                        ? 'FREE'
                                        : '\$${event.pricing.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: event.pricing.isFree
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Event details
                          Text(
                            event.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: Colors.white.withValues(alpha: 0.5),
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(event.startDateTime),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          
                          Row(
                            children: [
                              Icon(
                                Icons.people_outline,
                                color: Colors.white.withValues(alpha: 0.5),
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${event.attendeeCount} attending',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate()
                      .fadeIn(delay: (index * 100).ms)
                      .slideX(begin: 0.2, end: 0),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildTrendingSkeleton() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 180,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade800,
                  highlightColor: Colors.grey.shade600,
                  child: Container(
                    width: 180,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade800,
                  highlightColor: Colors.grey.shade600,
                  child: Container(
                    width: 140,
                    height: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade800,
                  highlightColor: Colors.grey.shade600,
                  child: Container(
                    width: 100,
                    height: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildRecommendedSection(EventsProvider provider) {
    final recommendedEvents = provider.nearbyEvents.take(5).toList();
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.recommend_rounded,
                          color: Colors.blue.shade400,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Recommended For You',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Based on your interests',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),
          
          const SizedBox(height: 16),
          
          // Vertical list of recommended events
          ...recommendedEvents.asMap().entries.map<Widget>((entry) {
            final event = entry.value;
            final index = entry.key;
            
            return GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventDetailsScreen(event: event),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: GlassmorphicContainer(
                  width: double.infinity,
                  height: 100,
                  borderRadius: 16,
                  blur: 10,
                  alignment: Alignment.center,
                  border: 1,
                  linearGradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                  borderGradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Event image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: event.imageUrls.isNotEmpty
                                ? event.imageUrls.first
                                : 'https://picsum.photos/80/80',
                            width: 76,
                            height: 76,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Event details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                event.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event.venue.name,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.white.withValues(alpha: 0.5),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatTime(event.startDateTime),
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: event.pricing.isFree
                                          ? Colors.green.withValues(alpha: 0.3)
                                          : Colors.orange.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      event.pricing.isFree
                                          ? 'FREE'
                                          : '\$${event.pricing.price.toStringAsFixed(0)}+',
                                      style: TextStyle(
                                        color: event.pricing.isFree
                                            ? Colors.green.shade300
                                            : Colors.orange.shade300,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Bookmark button
                        IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                          },
                          icon: Icon(
                            Icons.bookmark_border_rounded,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ).animate()
                  .fadeIn(delay: (index * 100 + 600).ms)
                  .slideX(begin: 0.1, end: 0),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildFloatingBottomNav(ThemeData theme) {
    final navItems = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.search_rounded, 'label': 'Search'},
      {'icon': Icons.map_rounded, 'label': 'Map'},
      {'icon': Icons.chat_bubble_rounded, 'label': 'Chat'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];
    
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 70,
        borderRadius: 20,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: navItems.asMap().entries.map((entry) {
            final item = entry.value;
            final index = entry.key;
            final isSelected = _selectedNavIndex == index;
            
            return GestureDetector(
              onTap: () => _onNavItemTapped(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 16 : 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        item['icon'] as IconData,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                        size: isSelected ? 28 : 24,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 4),
                      Text(
                        item['label'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ).animate()
                .fadeIn(delay: (index * 50).ms)
                .scale(delay: (index * 50).ms),
            );
          }).toList(),
        ),
      ).animate()
        .fadeIn(delay: 800.ms)
        .slideY(begin: 1, end: 0),
    );
  }
  
  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference < 7) return '${date.day}/${date.month}';
    
    return '${date.day}/${date.month}/${date.year}';
  }
  
  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }
}