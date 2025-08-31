import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/event.dart';
import '../../config/modern_theme.dart';
import '../../providers/events_provider.dart';
import '../../widgets/mobile/optimized_event_list.dart';
import '../../widgets/modern/modern_skeleton.dart';
import '../../widgets/modern/modern_event_card.dart';
import '../../services/platform_interactions.dart';
import '../../services/cache_service.dart';
import '../../services/navigation_service.dart';
import '../events/event_details_screen.dart';
import '../map/map_screen.dart';
import '../feed/vertical_feed_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  late AnimationController _filterAnimationController;
  late AnimationController _resultsAnimationController;
  
  bool _showFilters = false;
  bool _isSearching = false;
  
  // Filters
  EventCategory? _selectedCategory;
  bool? _isFreeFilter;
  DateTime? _startDate;
  DateTime? _endDate;
  double _maxDistance = 25.0;
  
  List<String> _recentSearches = [];
  List<String> _trendingSearches = [
    'Music festivals',
    'Food trucks',
    'Art galleries',
    'Networking events',
    'Weekend activities',
    'Free concerts',
  ];

  @override
  void initState() {
    super.initState();
    
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _resultsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _searchFocusNode.requestFocus();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _filterAnimationController.dispose();
    _resultsAnimationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadRecentSearches() {
    // In a real app, you'd load this from local storage
    setState(() {
      _recentSearches = ['Jazz music', 'Food festival', 'Art show'];
    });
  }

  void _saveSearch(String query) {
    if (query.trim().isEmpty || _recentSearches.contains(query)) return;
    
    setState(() {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList();
      }
    });
    
    // In a real app, you'd save this to local storage
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _isSearching = true;
    });
    
    _saveSearch(query);
    _searchFocusNode.unfocus();
    
    try {
      await context.read<EventsProvider>().searchEvents(query);
      
      _resultsAnimationController.reset();
      _resultsAnimationController.forward();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Search failed. Please try again.'),
          backgroundColor: ModernTheme.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<EventsProvider>().clearSearch();
    _searchFocusNode.requestFocus();
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
      _selectedCategory = null;
      _isFreeFilter = null;
      _startDate = null;
      _endDate = null;
      _maxDistance = 25.0;
    });
    
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  void _clearRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_showFilters) _buildFilters(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Search Events'),
      actions: [
        Consumer<EventsProvider>(
          builder: (context, eventsProvider, child) {
            if (eventsProvider.searchResults.isNotEmpty) {
              return IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                      events: eventsProvider.searchResults,
                    ),
                  ),
                ),
                icon: const Icon(Icons.map),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search input
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search events, locations, keywords...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear),
                    ),
                  IconButton(
                    onPressed: _toggleFilters,
                    icon: Icon(
                      Icons.tune,
                      color: _showFilters || _hasActiveFilters() 
                          ? ModernTheme.primaryColor 
                          : null,
                    ),
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: _performSearch,
            onChanged: (value) => setState(() {}),
          ),
          
          // Active filters chips
          if (_hasActiveFilters()) ...[
            const SizedBox(height: 12),
            _buildActiveFilters(),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.5);
  }

  Widget _buildActiveFilters() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (_selectedCategory != null)
            _buildFilterChip(
              _selectedCategory!.displayName,
              () => setState(() => _selectedCategory = null),
            ),
          if (_isFreeFilter == true)
            _buildFilterChip(
              'Free only',
              () => setState(() => _isFreeFilter = null),
            ),
          if (_isFreeFilter == false)
            _buildFilterChip(
              'Paid only',
              () => setState(() => _isFreeFilter = null),
            ),
          if (_startDate != null)
            _buildFilterChip(
              'From: ${_startDate!.day}/${_startDate!.month}',
              () => setState(() => _startDate = null),
            ),
          if (_endDate != null)
            _buildFilterChip(
              'Until: ${_endDate!.day}/${_endDate!.month}',
              () => setState(() => _endDate = null),
            ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        onDeleted: onRemove,
        deleteIcon: const Icon(Icons.close, size: 16),
        backgroundColor: ModernTheme.primaryColor.withOpacity(0.1),
        side: BorderSide(color: ModernTheme.primaryColor),
      ),
    );
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
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category filter
                  _buildCategoryFilter(),
                  const SizedBox(height: 16),
                  
                  // Price filter
                  _buildPriceFilter(),
                  const SizedBox(height: 16),
                  
                  // Date filter
                  _buildDateFilter(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: EventCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            return FilterChip(
              label: Text(category.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : null;
                });
              },
            );
          }).toList(),
        ),
      ],
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
                    : 'Start Date'),
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
                    : 'End Date'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Consumer<EventsProvider>(
      builder: (context, eventsProvider, child) {
        if (_isSearching) {
          return _buildLoadingState();
        }
        
        if (_searchController.text.isEmpty) {
          return _buildSearchSuggestions();
        }
        
        if (eventsProvider.searchResults.isEmpty && !_isSearching) {
          return _buildNoResults();
        }
        
        return _buildSearchResults(eventsProvider.searchResults);
      },
    );
  }

  Widget _buildSearchSuggestions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_recentSearches.isNotEmpty) ...[
          Row(
            children: [
              Text(
                'Recent Searches',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearRecentSearches,
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._recentSearches.map((search) => 
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(search),
              onTap: () {
                _searchController.text = search;
                _performSearch(search);
              },
              trailing: IconButton(
                onPressed: () {
                  setState(() {
                    _recentSearches.remove(search);
                  });
                },
                icon: const Icon(Icons.close, size: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        
        Text(
          'Trending Searches',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ..._trendingSearches.map((search) => 
          ListTile(
            leading: const Icon(Icons.trending_up, color: ModernTheme.primaryColor),
            title: Text(search),
            onTap: () {
              _searchController.text = search;
              _performSearch(search);
            },
          ),
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'Quick Searches',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Today',
            'This weekend',
            'Free events',
            'Near me',
            'Music',
            'Food',
          ].map((query) => 
            ActionChip(
              label: Text(query),
              onPressed: () {
                _searchController.text = query;
                _performSearch(query);
              },
            ),
          ).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: const ModernEventCardSkeleton(),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
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
              'Try adjusting your search terms or filters to find more events.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear Filters'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _clearSearch,
                  child: const Text('New Search'),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildSearchResults(List<Event> events) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          color: Theme.of(context).cardColor,
          child: Text(
            '${events.length} events found',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: ModernTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        
        Expanded(
          child: AnimatedBuilder(
            animation: _resultsAnimationController,
            builder: (context, child) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - _resultsAnimationController.value)),
                    child: Opacity(
                      opacity: _resultsAnimationController.value,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ModernEventCard(
                          event: event,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailsScreen(event: event),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  bool _hasActiveFilters() {
    return _selectedCategory != null ||
           _isFreeFilter != null ||
           _startDate != null ||
           _endDate != null;
  }
}