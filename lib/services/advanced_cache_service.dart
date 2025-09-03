import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Advanced cache service with performance monitoring and statistics
class AdvancedCacheService {
  static final AdvancedCacheService _instance = AdvancedCacheService._internal();
  factory AdvancedCacheService() => _instance;
  AdvancedCacheService._internal();

  // Cache boxes
  Box? _cacheBox;
  Box? _metadataBox;
  
  // Statistics tracking
  int _hitCount = 0;
  int _missCount = 0;
  int _writeCount = 0;
  int _deleteCount = 0;
  int _totalSize = 0;
  
  // Performance metrics
  final List<Duration> _readTimes = [];
  final List<Duration> _writeTimes = [];
  
  bool _isInitialized = false;

  /// Initialize the advanced cache service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize cache boxes
      _cacheBox = await Hive.openBox('advanced_cache');
      _metadataBox = await Hive.openBox('cache_metadata');
      
      // Load existing statistics
      await _loadStatistics();
      
      _isInitialized = true;
      
      if (kDebugMode) {
        print('AdvancedCacheService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize AdvancedCacheService: $e');
      }
      rethrow;
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getStatistics() {
    return {
      'hitCount': _hitCount,
      'missCount': _missCount,
      'writeCount': _writeCount,
      'deleteCount': _deleteCount,
      'totalSize': _totalSize,
      'hitRate': _hitCount + _missCount > 0 
          ? _hitCount / (_hitCount + _missCount) 
          : 0.0,
      'averageReadTime': _readTimes.isNotEmpty
          ? _readTimes.map((d) => d.inMicroseconds).reduce((a, b) => a + b) / _readTimes.length
          : 0.0,
      'averageWriteTime': _writeTimes.isNotEmpty
          ? _writeTimes.map((d) => d.inMicroseconds).reduce((a, b) => a + b) / _writeTimes.length
          : 0.0,
      'cacheEntries': _cacheBox?.length ?? 0,
      'isInitialized': _isInitialized,
    };
  }

  /// Get cached data with performance tracking
  Future<T?> get<T>(String key) async {
    if (!_isInitialized || _cacheBox == null) {
      await initialize();
    }

    final stopwatch = Stopwatch()..start();
    
    try {
      final data = _cacheBox!.get(key);
      stopwatch.stop();
      
      _readTimes.add(stopwatch.elapsed);
      if (_readTimes.length > 100) {
        _readTimes.removeAt(0);
      }
      
      if (data != null) {
        _hitCount++;
        
        // Check if data is expired
        final metadata = _metadataBox!.get('${key}_meta');
        if (metadata != null && metadata['expiry'] != null) {
          final expiry = DateTime.fromMillisecondsSinceEpoch(metadata['expiry']);
          if (DateTime.now().isAfter(expiry)) {
            await delete(key);
            _missCount++;
            return null;
          }
        }
        
        return data as T?;
      } else {
        _missCount++;
        return null;
      }
    } catch (e) {
      stopwatch.stop();
      _missCount++;
      if (kDebugMode) {
        print('Cache get error for key $key: $e');
      }
      return null;
    }
  }

  /// Set cached data with performance tracking
  Future<void> set<T>(String key, T data, {Duration? expiry}) async {
    if (!_isInitialized || _cacheBox == null) {
      await initialize();
    }

    final stopwatch = Stopwatch()..start();
    
    try {
      await _cacheBox!.put(key, data);
      
      // Store metadata if expiry is provided
      if (expiry != null) {
        final expiryTime = DateTime.now().add(expiry);
        await _metadataBox!.put('${key}_meta', {
          'expiry': expiryTime.millisecondsSinceEpoch,
          'size': _calculateSize(data),
        });
      }
      
      stopwatch.stop();
      _writeTimes.add(stopwatch.elapsed);
      if (_writeTimes.length > 100) {
        _writeTimes.removeAt(0);
      }
      
      _writeCount++;
      _updateTotalSize();
      
    } catch (e) {
      stopwatch.stop();
      if (kDebugMode) {
        print('Cache set error for key $key: $e');
      }
      rethrow;
    }
  }

  /// Delete cached data
  Future<void> delete(String key) async {
    if (!_isInitialized || _cacheBox == null) return;
    
    try {
      await _cacheBox!.delete(key);
      await _metadataBox!.delete('${key}_meta');
      _deleteCount++;
      _updateTotalSize();
    } catch (e) {
      if (kDebugMode) {
        print('Cache delete error for key $key: $e');
      }
    }
  }

  /// Clear all cached data
  Future<void> clear() async {
    if (!_isInitialized) return;
    
    try {
      await _cacheBox?.clear();
      await _metadataBox?.clear();
      _resetStatistics();
    } catch (e) {
      if (kDebugMode) {
        print('Cache clear error: $e');
      }
    }
  }

  /// Clean expired entries
  Future<void> cleanExpired() async {
    if (!_isInitialized || _metadataBox == null) return;
    
    final now = DateTime.now();
    final keysToDelete = <String>[];
    
    for (final key in _metadataBox!.keys) {
      if (key.toString().endsWith('_meta')) {
        final metadata = _metadataBox!.get(key);
        if (metadata != null && metadata['expiry'] != null) {
          final expiry = DateTime.fromMillisecondsSinceEpoch(metadata['expiry']);
          if (now.isAfter(expiry)) {
            final originalKey = key.toString().replaceAll('_meta', '');
            keysToDelete.add(originalKey);
          }
        }
      }
    }
    
    for (final key in keysToDelete) {
      await delete(key);
    }
  }

  /// Load statistics from persistent storage
  Future<void> _loadStatistics() async {
    try {
      final stats = _metadataBox!.get('cache_statistics');
      if (stats != null) {
        _hitCount = stats['hitCount'] ?? 0;
        _missCount = stats['missCount'] ?? 0;
        _writeCount = stats['writeCount'] ?? 0;
        _deleteCount = stats['deleteCount'] ?? 0;
      }
      _updateTotalSize();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load cache statistics: $e');
      }
    }
  }

  /// Save statistics to persistent storage
  Future<void> _saveStatistics() async {
    try {
      await _metadataBox!.put('cache_statistics', {
        'hitCount': _hitCount,
        'missCount': _missCount,
        'writeCount': _writeCount,
        'deleteCount': _deleteCount,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save cache statistics: $e');
      }
    }
  }

  /// Reset statistics
  void _resetStatistics() {
    _hitCount = 0;
    _missCount = 0;
    _writeCount = 0;
    _deleteCount = 0;
    _totalSize = 0;
    _readTimes.clear();
    _writeTimes.clear();
  }

  /// Update total cache size
  void _updateTotalSize() {
    if (_cacheBox == null) return;
    
    _totalSize = 0;
    for (final key in _cacheBox!.keys) {
      final data = _cacheBox!.get(key);
      _totalSize += _calculateSize(data);
    }
  }

  /// Calculate approximate size of data
  int _calculateSize(dynamic data) {
    try {
      if (data == null) return 0;
      if (data is String) return data.length * 2; // Approximate UTF-16 encoding
      if (data is List) return data.length * 8; // Approximate
      if (data is Map) return jsonEncode(data).length * 2;
      return 8; // Default size for primitives
    } catch (e) {
      return 8; // Fallback size
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _saveStatistics();
    await _cacheBox?.close();
    await _metadataBox?.close();
    _isInitialized = false;
  }
}
