import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/event.dart';
import '../../config/theme.dart';
import '../../providers/events_provider.dart';
import '../../widgets/common/event_card.dart';
import '../../widgets/common/loading_shimmer.dart';
import 'event_details_screen.dart';
import '../map/map_screen.dart';

class EventListScreen extends StatefulWidget {
  final EventCategory? category;
  final String? title;

  const EventListScreen({
    super.key,
    this.category,
    this.title,
  });

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen>
    with TickerProviderStateMixin {
  late AnimationController _filterAnimationController;
  late ScrollController _scrollController;
  
  bool _isGridView = false;
  bool _showFilters = false;
  String _sortBy = 'date'; // date, name, price, distance
  bool _sortAscending = true;
  
  // Filters
  bool? _isFreeFilter;
  DateTime? _startDate;
  DateTime? _endDate;
  double _maxDistance = 50.0;
  RangeValues _priceRange = const RangeValues(0, 200);

  @override
  void initState() {
    super.initState();
    
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
    });
  }

  @override
  void dispose() {
    _filterAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<EventsProvider>().loadMoreEvents();
    }
  }

  Future<void> _loadEvents() async {
    final eventsProvider = context.read<EventsProvider>();
    
    if (widget.category != null) {
      eventsProvider.setCategory(widget.category);
    }
    
    await eventsProvider.loadEvents(refresh: true);
  }

  List<Event> _getSortedEvents(List<Event> events) {
    final filteredEvents = _getFilteredEvents(events);
    
    switch (_sortBy) {
      case 'name':
        filteredEvents.sort((a, b) => _sortAscending 
            ? a.title.compareTo(b.title)
            : b.title.compareTo(a.title));
        break;
      case 'price':
        filteredEvents.sort((a, b) {
          final aPrice = a.pricing.isFree ? 0.0 : a.pricing.price;
          final bPrice = b.pricing.isFree ? 0.0 : b.pricing.price;
          return _sortAscending 
              ? aPrice.compareTo(bPrice)
              : bPrice.compareTo(aPrice);
        });
        break;
      case 'distance':
        // For now, sort by venue name as a proxy for distance
        filteredEvents.sort((a, b) => _sortAscending 
            ? a.venue.name.compareTo(b.venue.name)
            : b.venue.name.compareTo(a.venue.name));
        break;
      case 'date':
      default:
        filteredEvents.sort((a, b) => _sortAscending 
            ? a.startDateTime.compareTo(b.startDateTime)
            : b.startDateTime.compareTo(a.startDateTime));
        break;
    }
    
    return filteredEvents;
  }

  List<Event> _getFilteredEvents(List<Event> events) {
    return events.where((event) {
      // Free filter
      if (_isFreeFilter == true && !event.pricing.isFree) return false;
      if (_isFreeFilter == false && event.pricing.isFree) return false;
      
      // Date range filter
      if (_startDate != null && event.startDateTime.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && event.startDateTime.isAfter(_endDate!)) {
        return false;
      }
      
      // Price range filter (for paid events)
      if (!event.pricing.isFree) {
        if (event.pricing.price < _priceRange.start || 
            event.pricing.price > _priceRange.end) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
    
    if (_showFilters) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }

  void _clearFilters() {
    setState(() {
      _isFreeFilter = null;
      _startDate = null;
      _endDate = null;
      _maxDistance = 50.0;
      _priceRange = const RangeValues(0, 200);
    });
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort Events',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            
            _buildSortOption('Date', 'date', Icons.calendar_today),
            _buildSortOption('Name', 'name', Icons.sort_by_alpha),
            _buildSortOption('Price', 'price', Icons.attach_money),
            _buildSortOption('Distance', 'distance', Icons.location_on),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                const Text('Sort Order:'),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('Ascending'),
                  selected: _sortAscending,
                  onSelected: (selected) {
                    setState(() => _sortAscending = true);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Descending'),
                  selected: !_sortAscending,
                  onSelected: (selected) {
                    setState(() => _sortAscending = false);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value, IconData icon) {
    final isSelected = _sortBy == value;
    
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primaryColor : null),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : null,
          color: isSelected ? AppTheme.primaryColor : null,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
      onTap: () {
        setState(() => _sortBy = value);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildToolbar(),
          if (_showFilters) _buildFilters(),
          Expanded(child: _buildEventsList()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.title ?? widget.category?.displayName ?? 'Events'),
      actions: [
        IconButton(
          onPressed: () {
            final eventsProvider = context.read<EventsProvider>();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapScreen(events: eventsProvider.events),
              ),
            );
          },
          icon: const Icon(Icons.map),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Consumer<EventsProvider>(
            builder: (context, eventsProvider, child) {
              final eventCount = _getSortedEvents(eventsProvider.events).length;
              return Text(
                '$eventCount events',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              );
            },
          ),
          const Spacer(),
          IconButton(
            onPressed: _showSortDialog,
            icon: Icon(
              Icons.sort,
              color: AppTheme.primaryColor,
            ),
            tooltip: 'Sort',
          ),
          IconButton(
            onPressed: _toggleFilters,
            icon: Icon(
              Icons.filter_list,
              color: _showFilters || _hasActiveFilters() 
                  ? AppTheme.primaryColor 
                  : null,
            ),
            tooltip: 'Filters',
          ),
          IconButton(
            onPressed: _toggleViewMode,
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildFilters() {
    return AnimatedBuilder(
      animation: _filterAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -20 * (1 - _filterAnimationController.value)),
          child: Opacity(
            opacity: _filterAnimationController.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Filters',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      if (_hasActiveFilters())
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Clear All'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Price filter
                  _buildPriceFilter(),
                  const SizedBox(height: 16),
                  
                  // Date filter
                  _buildDateFilter(),
                  const SizedBox(height: 16),
                  
                  // Distance filter
                  _buildDistanceFilter(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            FilterChip(
              label: const Text('Free'),
              selected: _isFreeFilter == true,
              onSelected: (selected) {
                setState(() {
                  _isFreeFilter = selected ? true : null;
                });
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Paid'),
              selected: _isFreeFilter == false,
              onSelected: (selected) {
                setState(() {
                  _isFreeFilter = selected ? false : null;
                });
              },
            ),
          ],
        ),
        if (_isFreeFilter != true) ...[
          const SizedBox(height: 8),
          Text(
            'Price Range: \$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 500,
            divisions: 50,
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDateFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _startDate = date);
                  }
                },
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(_startDate != null 
                    ? '${_startDate!.day}/${_startDate!.month}'
                    : 'From'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? DateTime.now().add(const Duration(days: 7)),
                    firstDate: _startDate ?? DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _endDate = date);
                  }
                },
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(_endDate != null 
                    ? '${_endDate!.day}/${_endDate!.month}'
                    : 'To'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDistanceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Maximum Distance: ${_maxDistance.round()} km',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        Slider(
          value: _maxDistance,
          min: 1,
          max: 100,
          divisions: 99,
          onChanged: (value) {
            setState(() {
              _maxDistance = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildEventsList() {
    return Consumer<EventsProvider>(
      builder: (context, eventsProvider, child) {
        if (eventsProvider.isLoading && eventsProvider.events.isEmpty) {
          return _buildLoadingState();
        }

        final sortedEvents = _getSortedEvents(eventsProvider.events);

        if (sortedEvents.isEmpty) {
          return _buildEmptyState();
        }

        if (_isGridView) {
          return _buildGridView(sortedEvents, eventsProvider);
        }

        return _buildListView(sortedEvents, eventsProvider);
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _isGridView 
            ? const EventCardShimmer()
            : const LoadingShimmer(height: 120),
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
              Icons.event_busy,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No events found',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your filters or check back later for new events.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_hasActiveFilters())
                  OutlinedButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear Filters'),
                  ),
                if (_hasActiveFilters()) const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _loadEvents,
                  child: const Text('Refresh'),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildListView(List<Event> events, EventsProvider eventsProvider) {
    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: events.length + (eventsProvider.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == events.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final event = events[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
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
          ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 50));
        },
      ),
    );
  }

  Widget _buildGridView(List<Event> events, EventsProvider eventsProvider) {
    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: events.length + (eventsProvider.isLoadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= events.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final event = events[index];
          return EventCard(
            event: event,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailsScreen(event: event),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 50));
        },
      ),
    );
  }

  bool _hasActiveFilters() {
    return _isFreeFilter != null ||
           _startDate != null ||
           _endDate != null ||
           _maxDistance != 50.0 ||
           (_priceRange.start != 0 || _priceRange.end != 200);
  }
}