import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/logging_service.dart';

/// Enhanced search service with intelligent suggestions, semantic search, and advanced filtering
class EnhancedSearchService {
  static final EnhancedSearchService _instance =
      EnhancedSearchService._internal();
  factory EnhancedSearchService() => _instance;
  EnhancedSearchService._internal();

  static const String _recentSearchesKey = 'recent_searches';
  static const String _searchHistoryKey = 'search_history';
  static const int _maxRecentSearches = 20;
  static const int _maxSearchHistory = 100;

  SharedPreferences? _prefs;
  final List<String> _recentSearches = [];
  final List<SearchHistoryItem> _searchHistory = [];
  final Map<String, int> _searchFrequency = {};

  // Search suggestions and autocomplete
  final List<String> _trendingSearches = [
    'music festivals',
    'food trucks',
    'art galleries',
    'networking events',
    'weekend activities',
    'free concerts',
    'comedy shows',
    'outdoor activities',
    'cultural events',
    'sports events',
    'workshops',
    'conferences',
    'markets',
    'exhibitions',
    'live music',
  ];

  final Map<String, List<String>> _categoryKeywords = {
    'music': [
      'concert',
      'festival',
      'band',
      'dj',
      'live music',
      'acoustic',
      'jazz',
      'rock',
      'pop',
    ],
    'food': [
      'restaurant',
      'food truck',
      'cuisine',
      'dining',
      'tasting',
      'cooking',
      'chef',
      'brunch',
    ],
    'art': [
      'gallery',
      'exhibition',
      'museum',
      'painting',
      'sculpture',
      'photography',
      'artist',
    ],
    'sports': [
      'game',
      'match',
      'tournament',
      'fitness',
      'yoga',
      'running',
      'cycling',
      'gym',
    ],
    'business': [
      'networking',
      'conference',
      'seminar',
      'workshop',
      'meetup',
      'startup',
      'entrepreneur',
    ],
    'entertainment': [
      'comedy',
      'theater',
      'movie',
      'show',
      'performance',
      'dance',
      'circus',
    ],
    'education': [
      'class',
      'course',
      'lecture',
      'training',
      'skill',
      'learning',
      'tutorial',
    ],
    'outdoor': [
      'hiking',
      'camping',
      'beach',
      'park',
      'nature',
      'adventure',
      'outdoor',
    ],
  };

  // Getters
  List<String> get recentSearches => List.unmodifiable(_recentSearches);
  List<String> get trendingSearches => List.unmodifiable(_trendingSearches);
  List<SearchHistoryItem> get searchHistory =>
      List.unmodifiable(_searchHistory);

  /// Initialize the search service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadSearchData();
      LoggingService.info(
        'Enhanced search service initialized',
        tag: 'SearchService',
      );
    } catch (e) {
      LoggingService.error(
        'Failed to initialize search service',
        error: e,
        tag: 'SearchService',
      );
    }
  }

  /// Load search data from storage
  Future<void> _loadSearchData() async {
    if (_prefs == null) return;

    // Load recent searches
    final recentSearches = _prefs!.getStringList(_recentSearchesKey) ?? [];
    _recentSearches.clear();
    _recentSearches.addAll(recentSearches);

    // Load search history
    final historyJson = _prefs!.getStringList(_searchHistoryKey) ?? [];
    _searchHistory.clear();
    for (final json in historyJson) {
      try {
        final item = SearchHistoryItem.fromJson(json);
        _searchHistory.add(item);
      } catch (e) {
        LoggingService.error(
          'Failed to parse search history item',
          error: e,
          tag: 'SearchService',
        );
      }
    }

    // Calculate search frequency
    _searchFrequency.clear();
    for (final item in _searchHistory) {
      _searchFrequency[item.query] = (_searchFrequency[item.query] ?? 0) + 1;
    }

    LoggingService.info(
      'Loaded search data: ${_recentSearches.length} recent, ${_searchHistory.length} history',
      tag: 'SearchService',
    );
  }

  /// Save search data to storage
  Future<void> _saveSearchData() async {
    if (_prefs == null) return;

    try {
      await _prefs!.setStringList(_recentSearchesKey, _recentSearches);

      final historyJson = _searchHistory.map((item) => item.toJson()).toList();
      await _prefs!.setStringList(_searchHistoryKey, historyJson);
    } catch (e) {
      LoggingService.error(
        'Failed to save search data',
        error: e,
        tag: 'SearchService',
      );
    }
  }

  /// Add a search query to history
  Future<void> addSearchQuery(String query, {int? resultCount}) async {
    if (query.trim().isEmpty) return;

    final normalizedQuery = query.trim().toLowerCase();

    // Add to recent searches
    _recentSearches.remove(normalizedQuery);
    _recentSearches.insert(0, normalizedQuery);
    if (_recentSearches.length > _maxRecentSearches) {
      _recentSearches.removeRange(_maxRecentSearches, _recentSearches.length);
    }

    // Add to search history
    final historyItem = SearchHistoryItem(
      query: normalizedQuery,
      timestamp: DateTime.now(),
      resultCount: resultCount,
    );
    _searchHistory.insert(0, historyItem);
    if (_searchHistory.length > _maxSearchHistory) {
      _searchHistory.removeRange(_maxSearchHistory, _searchHistory.length);
    }

    // Update frequency
    _searchFrequency[normalizedQuery] =
        (_searchFrequency[normalizedQuery] ?? 0) + 1;

    await _saveSearchData();
    LoggingService.info(
      'Added search query: $normalizedQuery',
      tag: 'SearchService',
    );
  }

  /// Get search suggestions based on input
  List<String> getSearchSuggestions(String input, {int limit = 10}) {
    if (input.trim().isEmpty) {
      return _getDefaultSuggestions(limit);
    }

    final normalizedInput = input.trim().toLowerCase();
    final suggestions = <String>{};

    // Add recent searches that match
    for (final search in _recentSearches) {
      if (search.contains(normalizedInput) && suggestions.length < limit) {
        suggestions.add(search);
      }
    }

    // Add trending searches that match
    for (final trending in _trendingSearches) {
      if (trending.contains(normalizedInput) && suggestions.length < limit) {
        suggestions.add(trending);
      }
    }

    // Add category-based suggestions
    for (final category in _categoryKeywords.keys) {
      if (category.contains(normalizedInput) ||
          normalizedInput.contains(category)) {
        for (final keyword in _categoryKeywords[category]!) {
          if (keyword.contains(normalizedInput) && suggestions.length < limit) {
            suggestions.add(keyword);
          }
        }
      }
    }

    // Add semantic suggestions based on keywords
    _addSemanticSuggestions(normalizedInput, suggestions, limit);

    return suggestions.take(limit).toList();
  }

  /// Get default suggestions when no input
  List<String> _getDefaultSuggestions(int limit) {
    final suggestions = <String>[];

    // Add recent searches first
    suggestions.addAll(_recentSearches.take(limit ~/ 2));

    // Fill with trending searches
    final remaining = limit - suggestions.length;
    if (remaining > 0) {
      suggestions.addAll(_trendingSearches.take(remaining));
    }

    return suggestions.take(limit).toList();
  }

  /// Add semantic suggestions based on context
  void _addSemanticSuggestions(
    String input,
    Set<String> suggestions,
    int limit,
  ) {
    // Simple semantic matching based on common patterns
    final patterns = {
      'near': ['nearby events', 'local events', 'events around me'],
      'free': ['free events', 'no cost', 'complimentary'],
      'tonight': ['today', 'this evening', 'now'],
      'weekend': ['saturday', 'sunday', 'this weekend'],
      'outdoor': ['outside', 'park', 'garden', 'beach'],
      'indoor': ['inside', 'venue', 'hall', 'center'],
    };

    for (final pattern in patterns.keys) {
      if (input.contains(pattern)) {
        for (final suggestion in patterns[pattern]!) {
          if (suggestions.length < limit) {
            suggestions.add(suggestion);
          }
        }
      }
    }
  }

  /// Get popular searches based on frequency
  List<String> getPopularSearches({int limit = 10}) {
    final sortedEntries = _searchFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.take(limit).map((entry) => entry.key).toList();
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    _recentSearches.clear();
    await _saveSearchData();
    LoggingService.info('Cleared recent searches', tag: 'SearchService');
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    _searchHistory.clear();
    _searchFrequency.clear();
    await _saveSearchData();
    LoggingService.info('Cleared search history', tag: 'SearchService');
  }

  /// Remove a specific search from recent searches
  Future<void> removeRecentSearch(String query) async {
    _recentSearches.remove(query.trim().toLowerCase());
    await _saveSearchData();
    LoggingService.info('Removed recent search: $query', tag: 'SearchService');
  }

  /// Get search analytics
  SearchAnalytics getSearchAnalytics() {
    final totalSearches = _searchHistory.length;
    final uniqueQueries = _searchFrequency.keys.length;
    final averageResultsPerSearch = _searchHistory.isNotEmpty
        ? _searchHistory
                  .where((item) => item.resultCount != null)
                  .map((item) => item.resultCount!)
                  .fold(0, (sum, count) => sum + count) /
              _searchHistory.where((item) => item.resultCount != null).length
        : 0.0;

    return SearchAnalytics(
      totalSearches: totalSearches,
      uniqueQueries: uniqueQueries,
      averageResultsPerSearch: averageResultsPerSearch,
      mostPopularQuery: _searchFrequency.isNotEmpty
          ? _searchFrequency.entries
                .reduce((a, b) => a.value > b.value ? a : b)
                .key
          : null,
      searchFrequency: Map.from(_searchFrequency),
    );
  }
}

/// Search history item model
class SearchHistoryItem {
  final String query;
  final DateTime timestamp;
  final int? resultCount;

  SearchHistoryItem({
    required this.query,
    required this.timestamp,
    this.resultCount,
  });

  String toJson() {
    return '$query|${timestamp.millisecondsSinceEpoch}|${resultCount ?? ''}';
  }

  static SearchHistoryItem fromJson(String json) {
    final parts = json.split('|');
    if (parts.length < 2) {
      throw const FormatException('Invalid search history format');
    }

    return SearchHistoryItem(
      query: parts[0],
      timestamp: DateTime.fromMillisecondsSinceEpoch(int.parse(parts[1])),
      resultCount: parts.length > 2 && parts[2].isNotEmpty
          ? int.parse(parts[2])
          : null,
    );
  }
}

/// Search analytics model
class SearchAnalytics {
  final int totalSearches;
  final int uniqueQueries;
  final double averageResultsPerSearch;
  final String? mostPopularQuery;
  final Map<String, int> searchFrequency;

  SearchAnalytics({
    required this.totalSearches,
    required this.uniqueQueries,
    required this.averageResultsPerSearch,
    this.mostPopularQuery,
    required this.searchFrequency,
  });
}
