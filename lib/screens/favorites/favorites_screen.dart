import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/event.dart';
import '../../config/theme.dart';
import '../../providers/events_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/event_card.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../events/event_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  bool _isGridView = false;
  bool _isSelectionMode = false;
  Set<String> _selectedEvents = {};
  String _sortBy = 'date'; // date, name, category

  @override
  void initState() {
    super.initState();
    
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
      _listAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final authProvider = context.read<AuthProvider>();
    final eventsProvider = context.read<EventsProvider>();
    
    if (authProvider.currentUser != null) {
      await eventsProvider.loadFavoriteEvents(authProvider.currentUser!.id);
    }
  }

  List<Event> _getSortedEvents(List<Event> events) {
    switch (_sortBy) {
      case 'name':
        events.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'category':
        events.sort((a, b) => a.category.displayName.compareTo(b.category.displayName));
        break;
      case 'date':
      default:
        events.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
        break;
    }
    return events;
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedEvents.clear();
      }
    });
  }

  void _selectEvent(String eventId) {
    setState(() {
      if (_selectedEvents.contains(eventId)) {
        _selectedEvents.remove(eventId);
      } else {
        _selectedEvents.add(eventId);
      }
    });
  }

  void _selectAllEvents() {
    final eventsProvider = context.read<EventsProvider>();
    setState(() {
      if (_selectedEvents.length == eventsProvider.favoriteEvents.length) {
        _selectedEvents.clear();
      } else {
        _selectedEvents = eventsProvider.favoriteEvents.map((e) => e.id).toSet();
      }
    });
  }

  Future<void> _removeSelectedFromFavorites() async {
    final eventsProvider = context.read<EventsProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.currentUser == null) return;
    
    try {
      for (final eventId in _selectedEvents) {
        // Remove from favorites
        // await firestoreService.removeFromFavorites(authProvider.currentUser!.id, eventId);
      }
      
      setState(() {
        _isSelectionMode = false;
        _selectedEvents.clear();
      });
      
      await _loadFavorites();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed ${_selectedEvents.length} events from favorites'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to remove events from favorites'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _shareSelectedEvents() async {
    final eventsProvider = context.read<EventsProvider>();
    final selectedEventsList = eventsProvider.favoriteEvents
        .where((event) => _selectedEvents.contains(event.id))
        .toList();
    
    if (selectedEventsList.isEmpty) return;
    
    String shareText = 'Check out these amazing events I found:\n\n';
    
    for (final event in selectedEventsList) {
      shareText += '${event.title}\n';
      shareText += '📅 ${event.startDateTime.toString().split(' ')[0]}\n';
      shareText += '📍 ${event.venue.name}\n\n';
    }
    
    shareText += 'Discover more events on SomethingToDo!';
    
    await Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.currentUser == null) {
            return _buildSignInPrompt();
          }
          
          return RefreshIndicator(
            onRefresh: _loadFavorites,
            child: Consumer<EventsProvider>(
              builder: (context, eventsProvider, child) {
                if (eventsProvider.isLoading && eventsProvider.favoriteEvents.isEmpty) {
                  return _buildLoadingState();
                }
                
                if (eventsProvider.favoriteEvents.isEmpty) {
                  return _buildEmptyState();
                }
                
                final sortedEvents = _getSortedEvents(
                  List.from(eventsProvider.favoriteEvents),
                );
                
                return _buildEventsList(sortedEvents);
              },
            ),
          );
        },
      ),
      floatingActionButton: _isSelectionMode ? null : _buildFloatingActionButton(),
      bottomNavigationBar: _isSelectionMode ? _buildSelectionBottomBar() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: _isSelectionMode 
          ? Text('${_selectedEvents.length} selected')
          : const Text('My Favorites'),
      leading: _isSelectionMode
          ? IconButton(
              onPressed: _toggleSelectionMode,
              icon: const Icon(Icons.close),
            )
          : null,
      actions: [
        if (_isSelectionMode) ...[
          IconButton(
            onPressed: _selectAllEvents,
            icon: const Icon(Icons.select_all),
          ),
        ] else ...[
          IconButton(
            onPressed: _toggleViewMode,
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'select') {
                _toggleSelectionMode();
              } else {
                setState(() {
                  _sortBy = value;
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'select',
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline),
                    SizedBox(width: 8),
                    Text('Select'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today),
                    SizedBox(width: 8),
                    Text('Sort by Date'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha),
                    SizedBox(width: 8),
                    Text('Sort by Name'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'category',
                child: Row(
                  children: [
                    Icon(Icons.category),
                    SizedBox(width: 8),
                    Text('Sort by Category'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSignInPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Sign in to save favorites',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Save events you love and access them from any device.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/auth'),
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3);
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _isGridView 
            ? const EventCardShimmer()
            : const LoadingShimmer(height: 100),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No favorites yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start exploring events and tap the heart icon to save your favorites here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.explore),
              label: const Text('Explore Events'),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3);
  }

  Widget _buildEventsList(List<Event> events) {
    if (_isGridView) {
      return AnimatedBuilder(
        animation: _listAnimationController,
        builder: (context, child) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _buildGridEventItem(event, index);
            },
          );
        },
      );
    }
    
    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return _buildListEventItem(event, index);
          },
        );
      },
    );
  }

  Widget _buildListEventItem(Event event, int index) {
    final isSelected = _selectedEvents.contains(event.id);
    
    return Transform.translate(
      offset: Offset(0, 50 * (1 - _listAnimationController.value)),
      child: Opacity(
        opacity: _listAnimationController.value,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              if (_isSelectionMode) {
                _selectEvent(event.id);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailsScreen(event: event),
                  ),
                );
              }
            },
            onLongPress: () {
              if (!_isSelectionMode) {
                _toggleSelectionMode();
                _selectEvent(event.id);
              }
            },
            child: Stack(
              children: [
                EventCard(
                  event: event,
                  compact: true,
                ),
                if (_isSelectionMode)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (_) => _selectEvent(event.id),
                        shape: const CircleBorder(),
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

  Widget _buildGridEventItem(Event event, int index) {
    final isSelected = _selectedEvents.contains(event.id);
    
    return Transform.scale(
      scale: _listAnimationController.value,
      child: InkWell(
        onTap: () {
          if (_isSelectionMode) {
            _selectEvent(event.id);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailsScreen(event: event),
              ),
            );
          }
        },
        onLongPress: () {
          if (!_isSelectionMode) {
            _toggleSelectionMode();
            _selectEvent(event.id);
          }
        },
        child: Stack(
          children: [
            EventCard(event: event),
            if (_isSelectionMode)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => _selectEvent(event.id),
                    shape: const CircleBorder(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<EventsProvider>(
      builder: (context, eventsProvider, child) {
        if (eventsProvider.favoriteEvents.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return FloatingActionButton.extended(
          heroTag: 'favorites_share_fab',
          onPressed: _shareAllFavorites,
          icon: const Icon(Icons.share),
          label: const Text('Share All'),
          backgroundColor: AppTheme.primaryColor,
        );
      },
    );
  }

  Widget _buildSelectionBottomBar() {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _selectedEvents.isNotEmpty ? _shareSelectedEvents : null,
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _selectedEvents.isNotEmpty ? _removeSelectedFromFavorites : null,
                icon: const Icon(Icons.favorite_border),
                label: const Text('Remove'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareAllFavorites() async {
    final eventsProvider = context.read<EventsProvider>();
    final events = eventsProvider.favoriteEvents;
    
    if (events.isEmpty) return;
    
    String shareText = 'Check out my favorite events:\n\n';
    
    for (final event in events.take(5)) {
      shareText += '${event.title}\n';
      shareText += '📅 ${event.startDateTime.toString().split(' ')[0]}\n';
      shareText += '📍 ${event.venue.name}\n\n';
    }
    
    if (events.length > 5) {
      shareText += 'And ${events.length - 5} more amazing events!\n\n';
    }
    
    shareText += 'Discover more events on SomethingToDo!';
    
    await Share.share(shareText);
  }
}