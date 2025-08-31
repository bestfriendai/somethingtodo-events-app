import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
// Google Maps import removed - using Mapbox instead
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/event.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/events_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/event_card.dart';
import '../map/map_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event? event;
  final String? eventId;

  const EventDetailsScreen({
    super.key,
    this.event,
    this.eventId,
  }) : assert(event != null || eventId != null, 
         'Either event or eventId must be provided');

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final PageController _imagePageController = PageController();
  final ScrollController _scrollController = ScrollController();
  
  late AnimationController _fabAnimationController;
  late AnimationController _heartAnimationController;
  
  Event? _event;
  bool _isLoading = false;
  bool _isFavorited = false;
  bool _isToggling = false;
  int _currentImageIndex = 0;
  bool _showFab = true;
  List<Event> _similarEvents = [];

  @override
  void initState() {
    super.initState();
    
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scrollController.addListener(_onScroll);
    
    _event = widget.event;
    if (_event == null && widget.eventId != null) {
      _loadEvent();
    } else if (_event != null) {
      _initializeEventData();
    }
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _heartAnimationController.dispose();
    _imagePageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && _showFab) {
      setState(() {
        _showFab = false;
      });
      _fabAnimationController.reverse();
    } else if (_scrollController.offset <= 100 && !_showFab) {
      setState(() {
        _showFab = true;
      });
      _fabAnimationController.forward();
    }
  }

  Future<void> _loadEvent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final event = await _firestoreService.getEvent(widget.eventId!);
      if (event != null) {
        setState(() {
          _event = event;
        });
        _initializeEventData();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load event details');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeEventData() {
    if (_event != null) {
      _checkIfFavorited();
      _loadSimilarEvents();
      _logEventView();
      _fabAnimationController.forward();
    }
  }

  void _checkIfFavorited() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null && _event != null) {
      _isFavorited = authProvider.currentUser!.favoriteEventIds
          .contains(_event!.id);
    }
  }

  Future<void> _loadSimilarEvents() async {
    if (_event == null) return;

    try {
      final events = await _firestoreService.getEvents(
        category: _event!.category,
        limit: 5,
      );
      setState(() {
        _similarEvents = events.where((e) => e.id != _event!.id).take(4).toList();
      });
    } catch (e) {
      // Silently handle error
    }
  }

  Future<void> _logEventView() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null && _event != null) {
      await context.read<EventsProvider>().logEventView(
        authProvider.currentUser!.id,
        _event!.id,
      );
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isToggling || _event == null) return;
    
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) {
      _showAuthRequiredSnackBar();
      return;
    }

    setState(() {
      _isToggling = true;
    });

    try {
      if (_isFavorited) {
        await _firestoreService.removeFromFavorites(
          authProvider.currentUser!.id,
          _event!.id,
        );
      } else {
        await _firestoreService.addToFavorites(
          authProvider.currentUser!.id,
          _event!.id,
        );
      }

      setState(() {
        _isFavorited = !_isFavorited;
      });

      if (_isFavorited) {
        _heartAnimationController.forward().then((_) {
          _heartAnimationController.reverse();
        });
      }

      HapticFeedback.lightImpact();
    } catch (e) {
      _showErrorSnackBar('Failed to update favorites');
    } finally {
      setState(() {
        _isToggling = false;
      });
    }
  }

  Future<void> _shareEvent() async {
    if (_event == null) return;

    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      await context.read<EventsProvider>().logEventShare(
        _event!.id,
        authProvider.currentUser!.id,
      );
    }

    await Share.share(
      '${_event!.title}\n\n'
      '📅 ${DateFormat('EEEE, MMMM d, yyyy \'at\' h:mm a').format(_event!.startDateTime)}\n'
      '📍 ${_event!.venue.name}\n'
      '💰 ${_event!.pricing.isFree ? 'Free' : '\$${_event!.pricing.price.toStringAsFixed(2)}'}\n\n'
      '${_event!.description}\n\n'
      'Organized by ${_event!.organizerName}',
      subject: _event!.title,
    );
  }

  Future<void> _openTicketUrl() async {
    if (_event?.ticketUrl != null) {
      final uri = Uri.parse(_event!.ticketUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _openMap() async {
    if (_event == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          initialLatitude: _event!.venue.latitude,
          initialLongitude: _event!.venue.longitude,
          events: [_event!],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Not Found')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Event not found', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          _buildEventInfo(),
          _buildDescription(),
          _buildVenueInfo(),
          _buildOrganizerInfo(),
          _buildSimilarEvents(),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimationController.value,
            child: _buildFloatingActionButtons(),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: _shareEvent,
          icon: const Icon(Icons.share),
        ),
        IconButton(
          onPressed: _toggleFavorite,
          icon: _isToggling
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : AnimatedBuilder(
                  animation: _heartAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_heartAnimationController.value * 0.3),
                      child: Icon(
                        _isFavorited ? Icons.favorite : Icons.favorite_outline,
                        color: _isFavorited ? Colors.red : Colors.white,
                      ),
                    );
                  },
                ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _event!.imageUrls.isNotEmpty
            ? _buildImageCarousel()
            : Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.image, size: 64, color: Colors.grey),
                ),
              ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        PageView.builder(
          controller: _imagePageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: _event!.imageUrls.length,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: _event!.imageUrls[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => const LoadingShimmer(height: 300),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                ),
              ),
            );
          },
        ),
        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
              ],
            ),
          ),
        ),
        // Image indicators
        if (_event!.imageUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_event!.imageUrls.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: _currentImageIndex == index ? 20 : 6,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildEventInfo() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _event!.category.displayName,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              _event!.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3),
            const SizedBox(height: 8),
            // Organizer
            Text(
              'by ${_event!.organizerName}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            // Date and time
            _buildInfoRow(
              Icons.calendar_today,
              'Date & Time',
              '${DateFormat('EEEE, MMMM d, yyyy').format(_event!.startDateTime)}\n'
              '${DateFormat('h:mm a').format(_event!.startDateTime)} - '
              '${DateFormat('h:mm a').format(_event!.endDateTime)}',
            ),
            const Divider(height: 32),
            // Location
            _buildInfoRow(
              Icons.location_on,
              'Location',
              '${_event!.venue.name}\n${_event!.venue.address}',
              onTap: _openMap,
            ),
            const Divider(height: 32),
            // Price
            _buildInfoRow(
              Icons.confirmation_number,
              'Price',
              _event!.pricing.isFree 
                  ? 'Free Event'
                  : '\$${_event!.pricing.price.toStringAsFixed(2)}',
            ),
            if (!_event!.pricing.isFree && _event!.pricing.tiers.isNotEmpty)
              ..._event!.pricing.tiers.map((tier) => Padding(
                    padding: const EdgeInsets.only(left: 40, top: 4),
                    child: Text(
                      '${tier.name}: \$${tier.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  )),
            if (_event!.attendeeCount > 0) ...[
              const Divider(height: 32),
              _buildInfoRow(
                Icons.people,
                'Attendees',
                '${_event!.attendeeCount} people attending',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String content, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    if (_event!.description.isEmpty) return const SliverToBoxAdapter();

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About This Event',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              _event!.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
    );
  }

  Widget _buildVenueInfo() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Venue',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: InkWell(
                onTap: _openMap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _event!.venue.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _event!.venue.address,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      if (_event!.venue.description?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 8),
                        Text(
                          _event!.venue.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.2),
    );
  }

  Widget _buildOrganizerInfo() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Organizer',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: _event!.organizerImageUrl != null
                          ? CachedNetworkImageProvider(_event!.organizerImageUrl!)
                          : null,
                      child: _event!.organizerImageUrl == null
                          ? Text(_event!.organizerName.substring(0, 1).toUpperCase())
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _event!.organizerName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Event Organizer',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2),
    );
  }

  Widget _buildSimilarEvents() {
    if (_similarEvents.isEmpty) return const SliverToBoxAdapter();

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Similar Events',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ..._similarEvents.map((event) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EventCard(
                    event: event,
                    compact: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailsScreen(event: event),
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ).animate().fadeIn(duration: 900.ms).slideY(begin: 0.2),
    );
  }

  Widget _buildFloatingActionButtons() {
    if (_event!.ticketUrl != null) {
      return FloatingActionButton.extended(
        heroTag: 'event_details_ticket_fab',
        onPressed: _openTicketUrl,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.confirmation_number, color: Colors.white),
        label: Text(
          _event!.pricing.isFree ? 'Get Tickets' : 'Buy Tickets',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return FloatingActionButton(
      heroTag: 'event_details_share_fab',
      onPressed: _shareEvent,
      backgroundColor: AppTheme.primaryColor,
      child: const Icon(Icons.share, color: Colors.white),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _showAuthRequiredSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please sign in to add favorites'),
        action: SnackBarAction(
          label: 'Sign In',
          onPressed: () => Navigator.pushNamed(context, '/auth'),
        ),
      ),
    );
  }
}