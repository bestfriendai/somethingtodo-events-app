import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/event.dart';
import '../../config/unified_design_system.dart';
import '../../providers/events_provider.dart';
import '../../services/enhanced_search_service.dart';
import '../../widgets/modern/modern_event_card.dart';
import '../events/event_details_screen.dart';
import '../map/map_screen.dart';
import '../../widgets/common/delightful_refresh.dart';

/// Enhanced search screen with intelligent suggestions and advanced filtering
class EnhancedSearchScreen extends StatefulWidget {
  const EnhancedSearchScreen({super.key});

  @override
  State<EnhancedSearchScreen> createState() => _EnhancedSearchScreenState();
}

class _EnhancedSearchScreenState extends State<EnhancedSearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final EnhancedSearchService _searchService = EnhancedSearchService();

  late AnimationController _filterAnimationController;
  late AnimationController _resultsAnimationController;
  late AnimationController _suggestionsAnimationController;

  bool _showFilters = false;
  bool _showSuggestions = false;
  bool _isSearching = false;
  Timer? _debounceTimer;

  // Filters
  EventCategory? _selectedCategory;
  bool? _isFreeFilter;
  double _maxDistance = 25.0;
  String _sortBy = 'relevance'; // relevance, date, distance, popularity

  List<String> _currentSuggestions = [];

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

    _suggestionsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);

    // Initialize search service
    _initializeSearchService();
  }

  Future<void> _initializeSearchService() async {
    await _searchService.initialize();
    if (mounted) {
      setState(() {
        _currentSuggestions = _searchService.getSearchSuggestions('');
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _filterAnimationController.dispose();
    _resultsAnimationController.dispose();
    _suggestionsAnimationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        final suggestions = _searchService.getSearchSuggestions(
          _searchController.text,
        );
        setState(() {
          _currentSuggestions = suggestions;
        });
      }
    });
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions =
          _searchFocusNode.hasFocus && _searchController.text.isEmpty;
    });

    if (_showSuggestions) {
      _suggestionsAnimationController.forward();
    } else {
      _suggestionsAnimationController.reverse();
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _showSuggestions = false;
    });

    _searchFocusNode.unfocus();
    _suggestionsAnimationController.reverse();

    try {
      // Add to search service
      await _searchService.addSearchQuery(query);

      // Perform search (filters will be applied in future enhancement)
      if (mounted) {
        await context.read<EventsProvider>().searchEvents(query);
      }

      // Update search service with result count
      if (mounted) {
        final resultCount = context.read<EventsProvider>().searchResults.length;
        await _searchService.addSearchQuery(query, resultCount: resultCount);
      }

      _resultsAnimationController.reset();
      _resultsAnimationController.forward();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _performSearch(suggestion);
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<EventsProvider>().clearSearch();
    _searchFocusNode.requestFocus();
    setState(() {
      _showSuggestions = true;
      _currentSuggestions = _searchService.getSearchSuggestions('');
    });
    _suggestionsAnimationController.forward();
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
      _maxDistance = 25.0;
      _sortBy = 'relevance';
    });

    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_showFilters) _buildFilters(),
          if (_showSuggestions) _buildSuggestions(),
          Consumer<EventsProvider>(
            builder: (context, provider, child) {
              final error = provider.error;
              if (error == null) return const SizedBox.shrink();
              return _buildErrorBanner(error, onRetry: () => _refreshSearch());
            },
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Enhanced Search'),
      actions: [
        Consumer<EventsProvider>(
          builder: (context, eventsProvider, child) {
            if (eventsProvider.searchResults.isNotEmpty) {
              return IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MapScreen(events: eventsProvider.searchResults),
                  ),
                ),
                icon: const Icon(Icons.map),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'clear_recent':
                _searchService.clearRecentSearches();
                break;
              case 'clear_history':
                _searchService.clearSearchHistory();
                break;
              case 'analytics':
                _showSearchAnalytics();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'clear_recent',
              child: Text('Clear Recent Searches'),
            ),
            const PopupMenuItem(
              value: 'clear_history',
              child: Text('Clear Search History'),
            ),
            const PopupMenuItem(
              value: 'analytics',
              child: Text('Search Analytics'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(UnifiedDesignSystem.spacingMd),
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
                      _showFilters ? Icons.filter_list_off : Icons.filter_list,
                      color: _showFilters
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  UnifiedDesignSystem.radiusLg,
                ),
              ),
            ),
            onSubmitted: _performSearch,
            textInputAction: TextInputAction.search,
          ),

          // Search stats
          if (_searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                top: UnifiedDesignSystem.spacingSm,
              ),
              child: Consumer<EventsProvider>(
                builder: (context, provider, child) {
                  final resultCount = provider.searchResults.length;
                  return Text(
                    '$resultCount results found',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return AnimatedBuilder(
      animation: _suggestionsAnimationController,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _suggestionsAnimationController,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: Card(
              margin: const EdgeInsets.symmetric(
                horizontal: UnifiedDesignSystem.spacingMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_searchController.text.isEmpty) ...[
                    _buildSuggestionSection(
                      'Recent Searches',
                      _searchService.recentSearches,
                      Icons.history,
                    ),
                    _buildSuggestionSection(
                      'Trending',
                      _searchService.trendingSearches,
                      Icons.trending_up,
                    ),
                  ] else ...[
                    _buildSuggestionSection(
                      'Suggestions',
                      _currentSuggestions,
                      Icons.lightbulb_outline,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestionSection(
    String title,
    List<String> suggestions,
    IconData icon,
  ) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(UnifiedDesignSystem.spacingMd),
          child: Row(
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: UnifiedDesignSystem.spacingSm),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
        ...suggestions
            .take(5)
            .map(
              (suggestion) => ListTile(
                dense: true,
                leading: const Icon(Icons.search, size: 16),
                title: Text(suggestion),
                onTap: () => _selectSuggestion(suggestion),
                trailing: IconButton(
                  icon: const Icon(Icons.north_west, size: 16),
                  onPressed: () {
                    _searchController.text = suggestion;
                    _searchFocusNode.requestFocus();
                  },
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildFilters() {
    return AnimatedBuilder(
      animation: _filterAnimationController,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _filterAnimationController,
          child: Card(
            margin: const EdgeInsets.symmetric(
              horizontal: UnifiedDesignSystem.spacingMd,
            ),
            child: Padding(
              padding: const EdgeInsets.all(UnifiedDesignSystem.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: UnifiedDesignSystem.spacingMd),

                  // Category filter
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: UnifiedDesignSystem.spacingSm),
                  Wrap(
                    spacing: UnifiedDesignSystem.spacingSm,
                    children: EventCategory.values.map((category) {
                      final isSelected = _selectedCategory == category;
                      return FilterChip(
                        label: Text(category.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : null;
                          });
                          if (_searchController.text.isNotEmpty) {
                            _performSearch(_searchController.text);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: UnifiedDesignSystem.spacingMd),

                  // Price filter
                  Text('Price', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: UnifiedDesignSystem.spacingSm),
                  Row(
                    children: [
                      FilterChip(
                        label: const Text('Free Only'),
                        selected: _isFreeFilter == true,
                        onSelected: (selected) {
                          setState(() {
                            _isFreeFilter = selected ? true : null;
                          });
                          if (_searchController.text.isNotEmpty) {
                            _performSearch(_searchController.text);
                          }
                        },
                      ),
                      const SizedBox(width: UnifiedDesignSystem.spacingSm),
                      FilterChip(
                        label: const Text('Paid Only'),
                        selected: _isFreeFilter == false,
                        onSelected: (selected) {
                          setState(() {
                            _isFreeFilter = selected ? false : null;
                          });
                          if (_searchController.text.isNotEmpty) {
                            _performSearch(_searchController.text);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: UnifiedDesignSystem.spacingMd),

                  // Distance filter
                  Text(
                    'Distance: ${_maxDistance.round()} km',
                    style: Theme.of(context).textTheme.titleSmall,
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
                    onChangeEnd: (value) {
                      if (_searchController.text.isNotEmpty) {
                        _performSearch(_searchController.text);
                      }
                    },
                  ),
                  const SizedBox(height: UnifiedDesignSystem.spacingMd),

                  // Sort by
                  Text(
                    'Sort By',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: UnifiedDesignSystem.spacingSm),
                  DropdownButtonFormField<String>(
                    value: _sortBy,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: UnifiedDesignSystem.spacingMd,
                        vertical: UnifiedDesignSystem.spacingSm,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'relevance',
                        child: Text('Relevance'),
                      ),
                      DropdownMenuItem(value: 'date', child: Text('Date')),
                      DropdownMenuItem(
                        value: 'distance',
                        child: Text('Distance'),
                      ),
                      DropdownMenuItem(
                        value: 'popularity',
                        child: Text('Popularity'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _sortBy = value;
                        });
                        if (_searchController.text.isNotEmpty) {
                          _performSearch(_searchController.text);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Consumer<EventsProvider>(
      builder: (context, provider, child) {
        if (_isSearching) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_searchController.text.isEmpty) {
          return _buildEmptyState();
        }

        if (provider.searchResults.isEmpty) {
          return _buildNoResults();
        }

        return _buildSearchResults(provider.searchResults);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: UnifiedDesignSystem.spacingMd),
          Text(
            'Search for Events',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: UnifiedDesignSystem.spacingSm),
          Text(
            'Find events near you or search by keywords',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: UnifiedDesignSystem.spacingMd),
          Text(
            'No Results Found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: UnifiedDesignSystem.spacingSm),
          Text(
            'Try adjusting your search terms or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UnifiedDesignSystem.spacingMd),
          ElevatedButton(
            onPressed: _clearFilters,
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<Event> events) {
    return AnimatedBuilder(
      animation: _resultsAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _resultsAnimationController,
          child: DelightfulRefresh(
            onRefresh: _refreshSearch,
            child: ListView.builder(
              padding: const EdgeInsets.all(UnifiedDesignSystem.spacingMd),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ModernEventCard(
                      event: event,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EventDetailsScreen(eventId: event.id),
                        ),
                      ),
                    )
                    .animate(delay: Duration(milliseconds: index * 50))
                    .slideX(begin: 0.2, duration: 300.ms)
                    .fadeIn(duration: 300.ms);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorBanner(String error, {VoidCallback? onRetry}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(UnifiedDesignSystem.spacingMd),
      padding: const EdgeInsets.all(UnifiedDesignSystem.spacingMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(UnifiedDesignSystem.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: UnifiedDesignSystem.spacingMd),
          Expanded(
            child: Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  Future<void> _refreshSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    await _performSearch(query);
  }

  void _showSearchAnalytics() {
    final analytics = _searchService.getSearchAnalytics();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Analytics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Searches: ${analytics.totalSearches}'),
            Text('Unique Queries: ${analytics.uniqueQueries}'),
            Text(
              'Avg Results: ${analytics.averageResultsPerSearch.toStringAsFixed(1)}',
            ),
            if (analytics.mostPopularQuery != null)
              Text('Most Popular: ${analytics.mostPopularQuery}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
