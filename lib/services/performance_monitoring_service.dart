import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../services/logging_service.dart';
import '../services/advanced_cache_service.dart';

/// Performance monitoring service for tracking app performance metrics and optimization
class PerformanceMonitoringService {
  static final PerformanceMonitoringService _instance =
      PerformanceMonitoringService._internal();
  factory PerformanceMonitoringService() => _instance;
  PerformanceMonitoringService._internal();

  // Performance metrics
  final Map<String, PerformanceMetric> _metrics = {};
  final Map<String, Stopwatch> _activeTimers = {};
  final List<PerformanceEvent> _events = [];

  // Device and app info
  DeviceInfo? _deviceInfo;
  AppInfo? _appInfo;

  // Performance thresholds (in milliseconds)
  static const int _slowOperationThreshold = 1000;
  static const int _verySlowOperationThreshold = 3000;
  static const int _maxEventsToKeep = 1000;

  // Memory monitoring
  Timer? _memoryMonitorTimer;
  final List<MemorySnapshot> _memorySnapshots = [];
  static const int _maxMemorySnapshots = 100;

  // Network performance
  final Map<String, NetworkMetric> _networkMetrics = {};

  // Frame rate monitoring
  final List<double> _frameRates = [];
  static const int _maxFrameRateEntries = 60;

  /// Initialize performance monitoring
  Future<void> initialize() async {
    try {
      await _loadDeviceInfo();
      await _loadPackageInfo();
      _startMemoryMonitoring();
      _startFrameRateMonitoring();

      LoggingService.info(
        'Performance monitoring service initialized',
        tag: 'Performance',
      );
    } catch (e) {
      LoggingService.error(
        'Failed to initialize performance monitoring',
        error: e,
        tag: 'Performance',
      );
    }
  }

  /// Load device information
  Future<void> _loadDeviceInfo() async {
    try {
      // Simplified device info without external dependencies
      _deviceInfo = DeviceInfo(
        platform: Platform.operatingSystem,
        model: 'Unknown',
        version: Platform.operatingSystemVersion,
        manufacturer: 'Unknown',
        isPhysicalDevice: true,
      );
    } catch (e) {
      LoggingService.error(
        'Failed to load device info',
        error: e,
        tag: 'Performance',
      );
    }
  }

  /// Load app information
  Future<void> _loadPackageInfo() async {
    try {
      // Simplified app info without external dependencies
      _appInfo = AppInfo(
        appName: 'SomethingToDo',
        version: '1.0.0',
        buildNumber: '1',
      );
    } catch (e) {
      LoggingService.error(
        'Failed to load app info',
        error: e,
        tag: 'Performance',
      );
    }
  }

  /// Start monitoring memory usage
  void _startMemoryMonitoring() {
    _memoryMonitorTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _captureMemorySnapshot();
    });
  }

  /// Start monitoring frame rate
  void _startFrameRateMonitoring() {
    if (kDebugMode) {
      // Frame rate monitoring is only available in debug mode
      WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
        _recordFrameRate();
      });
    }
  }

  /// Start timing an operation
  void startTimer(String operationName) {
    final stopwatch = Stopwatch()..start();
    _activeTimers[operationName] = stopwatch;

    LoggingService.debug(
      'Started timer for: $operationName',
      tag: 'Performance',
    );
  }

  /// Stop timing an operation and record the metric
  void stopTimer(String operationName, {Map<String, dynamic>? metadata}) {
    final stopwatch = _activeTimers.remove(operationName);
    if (stopwatch == null) {
      LoggingService.warning(
        'No active timer found for: $operationName',
        tag: 'Performance',
      );
      return;
    }

    stopwatch.stop();
    final duration = stopwatch.elapsedMilliseconds;

    _recordMetric(operationName, duration, metadata: metadata);
    _recordEvent(
      PerformanceEvent(
        name: operationName,
        duration: duration,
        timestamp: DateTime.now(),
        metadata: metadata,
        severity: _getSeverityForDuration(duration),
      ),
    );

    LoggingService.debug(
      'Completed $operationName in ${duration}ms',
      tag: 'Performance',
    );
  }

  /// Record a performance metric
  void _recordMetric(
    String name,
    int duration, {
    Map<String, dynamic>? metadata,
  }) {
    final existing = _metrics[name];
    if (existing == null) {
      _metrics[name] = PerformanceMetric(
        name: name,
        totalDuration: duration,
        count: 1,
        minDuration: duration,
        maxDuration: duration,
        metadata: metadata,
      );
    } else {
      _metrics[name] = existing.copyWith(
        totalDuration: existing.totalDuration + duration,
        count: existing.count + 1,
        minDuration: duration < existing.minDuration
            ? duration
            : existing.minDuration,
        maxDuration: duration > existing.maxDuration
            ? duration
            : existing.maxDuration,
      );
    }
  }

  /// Record a performance event
  void _recordEvent(PerformanceEvent event) {
    _events.add(event);

    // Keep only the most recent events
    if (_events.length > _maxEventsToKeep) {
      _events.removeRange(0, _events.length - _maxEventsToKeep);
    }

    // Log slow operations
    if (event.severity == PerformanceSeverity.slow) {
      LoggingService.warning(
        'Slow operation detected: ${event.name} took ${event.duration}ms',
        tag: 'Performance',
      );
    } else if (event.severity == PerformanceSeverity.verySlow) {
      LoggingService.error(
        'Very slow operation detected: ${event.name} took ${event.duration}ms',
        tag: 'Performance',
      );
    }
  }

  /// Get severity level for operation duration
  PerformanceSeverity _getSeverityForDuration(int duration) {
    if (duration >= _verySlowOperationThreshold) {
      return PerformanceSeverity.verySlow;
    } else if (duration >= _slowOperationThreshold) {
      return PerformanceSeverity.slow;
    } else {
      return PerformanceSeverity.normal;
    }
  }

  /// Capture memory snapshot
  void _captureMemorySnapshot() {
    try {
      // This is a simplified memory monitoring
      // In a real app, you might use more sophisticated memory profiling
      final snapshot = MemorySnapshot(
        timestamp: DateTime.now(),
        // These would be actual memory measurements in a real implementation
        heapUsage: 0, // Placeholder
        stackUsage: 0, // Placeholder
      );

      _memorySnapshots.add(snapshot);

      if (_memorySnapshots.length > _maxMemorySnapshots) {
        _memorySnapshots.removeAt(0);
      }
    } catch (e) {
      LoggingService.error(
        'Failed to capture memory snapshot',
        error: e,
        tag: 'Performance',
      );
    }
  }

  /// Record frame rate
  void _recordFrameRate() {
    // This is a simplified frame rate calculation
    // In a real implementation, you would calculate actual FPS
    final frameRate = 60.0; // Placeholder

    _frameRates.add(frameRate);

    if (_frameRates.length > _maxFrameRateEntries) {
      _frameRates.removeAt(0);
    }
  }

  /// Record network operation
  void recordNetworkOperation(
    String operation,
    int duration,
    int bytes, {
    bool success = true,
  }) {
    final existing = _networkMetrics[operation];
    if (existing == null) {
      _networkMetrics[operation] = NetworkMetric(
        operation: operation,
        totalDuration: duration,
        totalBytes: bytes,
        requestCount: 1,
        successCount: success ? 1 : 0,
        minDuration: duration,
        maxDuration: duration,
      );
    } else {
      _networkMetrics[operation] = existing.copyWith(
        totalDuration: existing.totalDuration + duration,
        totalBytes: existing.totalBytes + bytes,
        requestCount: existing.requestCount + 1,
        successCount: existing.successCount + (success ? 1 : 0),
        minDuration: duration < existing.minDuration
            ? duration
            : existing.minDuration,
        maxDuration: duration > existing.maxDuration
            ? duration
            : existing.maxDuration,
      );
    }
  }

  /// Get performance summary
  PerformanceSummary getPerformanceSummary() {
    final slowOperations = _events
        .where((e) => e.severity != PerformanceSeverity.normal)
        .length;

    final averageFrameRate = _frameRates.isNotEmpty
        ? _frameRates.reduce((a, b) => a + b) / _frameRates.length
        : 0.0;

    final cacheStats = AdvancedCacheService().getStatistics();

    return PerformanceSummary(
      deviceInfo: _deviceInfo,
      appInfo: _appInfo,
      metrics: Map.from(_metrics),
      networkMetrics: Map.from(_networkMetrics),
      slowOperationsCount: slowOperations,
      averageFrameRate: averageFrameRate,
      cacheHitRate: cacheStats['hitRate'] ?? 0.0,
      memorySnapshots: List.from(_memorySnapshots),
      recentEvents: _events.take(20).toList(),
    );
  }

  /// Get metrics for specific operation
  PerformanceMetric? getMetric(String operationName) {
    return _metrics[operationName];
  }

  /// Clear all performance data
  void clearData() {
    _metrics.clear();
    _events.clear();
    _networkMetrics.clear();
    _memorySnapshots.clear();
    _frameRates.clear();

    LoggingService.info('Performance data cleared', tag: 'Performance');
  }

  /// Export performance data for analysis
  Map<String, dynamic> exportData() {
    return {
      'deviceInfo': _deviceInfo?.toJson(),
      'appInfo': _appInfo?.toJson(),
      'metrics': _metrics.map((key, value) => MapEntry(key, value.toJson())),
      'networkMetrics': _networkMetrics.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'events': _events.map((e) => e.toJson()).toList(),
      'memorySnapshots': _memorySnapshots.map((s) => s.toJson()).toList(),
      'frameRates': _frameRates,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Dispose resources
  void dispose() {
    _memoryMonitorTimer?.cancel();
    _activeTimers.clear();
    LoggingService.info(
      'Performance monitoring service disposed',
      tag: 'Performance',
    );
  }
}

/// Device information model
class DeviceInfo {
  final String platform;
  final String model;
  final String version;
  final String manufacturer;
  final bool isPhysicalDevice;

  DeviceInfo({
    required this.platform,
    required this.model,
    required this.version,
    required this.manufacturer,
    required this.isPhysicalDevice,
  });

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'model': model,
      'version': version,
      'manufacturer': manufacturer,
      'isPhysicalDevice': isPhysicalDevice,
    };
  }
}

/// Performance metric model
class PerformanceMetric {
  final String name;
  final int totalDuration;
  final int count;
  final int minDuration;
  final int maxDuration;
  final Map<String, dynamic>? metadata;

  PerformanceMetric({
    required this.name,
    required this.totalDuration,
    required this.count,
    required this.minDuration,
    required this.maxDuration,
    this.metadata,
  });

  double get averageDuration => count > 0 ? totalDuration / count : 0.0;

  PerformanceMetric copyWith({
    String? name,
    int? totalDuration,
    int? count,
    int? minDuration,
    int? maxDuration,
    Map<String, dynamic>? metadata,
  }) {
    return PerformanceMetric(
      name: name ?? this.name,
      totalDuration: totalDuration ?? this.totalDuration,
      count: count ?? this.count,
      minDuration: minDuration ?? this.minDuration,
      maxDuration: maxDuration ?? this.maxDuration,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'totalDuration': totalDuration,
      'count': count,
      'minDuration': minDuration,
      'maxDuration': maxDuration,
      'averageDuration': averageDuration,
      'metadata': metadata,
    };
  }
}

/// Performance event model
class PerformanceEvent {
  final String name;
  final int duration;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final PerformanceSeverity severity;

  PerformanceEvent({
    required this.name,
    required this.duration,
    required this.timestamp,
    this.metadata,
    required this.severity,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'duration': duration,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'severity': severity.name,
    };
  }
}

/// Performance severity levels
enum PerformanceSeverity { normal, slow, verySlow }

/// Memory snapshot model
class MemorySnapshot {
  final DateTime timestamp;
  final int heapUsage;
  final int stackUsage;

  MemorySnapshot({
    required this.timestamp,
    required this.heapUsage,
    required this.stackUsage,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'heapUsage': heapUsage,
      'stackUsage': stackUsage,
    };
  }
}

/// Network metric model
class NetworkMetric {
  final String operation;
  final int totalDuration;
  final int totalBytes;
  final int requestCount;
  final int successCount;
  final int minDuration;
  final int maxDuration;

  NetworkMetric({
    required this.operation,
    required this.totalDuration,
    required this.totalBytes,
    required this.requestCount,
    required this.successCount,
    required this.minDuration,
    required this.maxDuration,
  });

  double get averageDuration =>
      requestCount > 0 ? totalDuration / requestCount : 0.0;
  double get successRate =>
      requestCount > 0 ? successCount / requestCount : 0.0;
  double get averageBytes => requestCount > 0 ? totalBytes / requestCount : 0.0;

  NetworkMetric copyWith({
    String? operation,
    int? totalDuration,
    int? totalBytes,
    int? requestCount,
    int? successCount,
    int? minDuration,
    int? maxDuration,
  }) {
    return NetworkMetric(
      operation: operation ?? this.operation,
      totalDuration: totalDuration ?? this.totalDuration,
      totalBytes: totalBytes ?? this.totalBytes,
      requestCount: requestCount ?? this.requestCount,
      successCount: successCount ?? this.successCount,
      minDuration: minDuration ?? this.minDuration,
      maxDuration: maxDuration ?? this.maxDuration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'operation': operation,
      'totalDuration': totalDuration,
      'totalBytes': totalBytes,
      'requestCount': requestCount,
      'successCount': successCount,
      'minDuration': minDuration,
      'maxDuration': maxDuration,
      'averageDuration': averageDuration,
      'successRate': successRate,
      'averageBytes': averageBytes,
    };
  }
}

/// App information model
class AppInfo {
  final String appName;
  final String version;
  final String buildNumber;

  AppInfo({
    required this.appName,
    required this.version,
    required this.buildNumber,
  });

  Map<String, dynamic> toJson() {
    return {'appName': appName, 'version': version, 'buildNumber': buildNumber};
  }
}

/// Performance summary model
class PerformanceSummary {
  final DeviceInfo? deviceInfo;
  final AppInfo? appInfo;
  final Map<String, PerformanceMetric> metrics;
  final Map<String, NetworkMetric> networkMetrics;
  final int slowOperationsCount;
  final double averageFrameRate;
  final double cacheHitRate;
  final List<MemorySnapshot> memorySnapshots;
  final List<PerformanceEvent> recentEvents;

  PerformanceSummary({
    this.deviceInfo,
    this.appInfo,
    required this.metrics,
    required this.networkMetrics,
    required this.slowOperationsCount,
    required this.averageFrameRate,
    required this.cacheHitRate,
    required this.memorySnapshots,
    required this.recentEvents,
  });
}
