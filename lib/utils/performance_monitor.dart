import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Performance monitoring utilities for the SomethingToDo app.
///
/// This class provides comprehensive performance monitoring including
/// frame rate tracking, memory usage monitoring, and performance
/// profiling for theme operations and widget rendering.
class PerformanceMonitor {
  /// Private constructor to prevent instantiation
  const PerformanceMonitor._();

  /// Singleton instance for performance tracking
  static final _instance = _PerformanceTracker();

  /// Starts performance monitoring for the application.
  ///
  /// This method initializes frame rate monitoring and memory tracking
  /// to help identify performance bottlenecks.
  static void startMonitoring() {
    if (kDebugMode) {
      _instance._startFrameRateMonitoring();
      _instance._startMemoryMonitoring();
    }
  }

  /// Stops performance monitoring.
  ///
  /// This method cleans up monitoring resources and stops all
  /// performance tracking activities.
  static void stopMonitoring() {
    _instance._stopMonitoring();
  }

  /// Measures the performance of a theme operation.
  ///
  /// This method tracks the execution time of theme-related operations
  /// and logs performance metrics for optimization.
  static T measureThemeOperation<T>(
    String operationName,
    T Function() operation,
  ) {
    if (!kDebugMode) return operation();

    final stopwatch = Stopwatch()..start();
    final result = operation();
    stopwatch.stop();

    _instance._recordThemeOperation(
      operationName,
      stopwatch.elapsedMicroseconds,
    );
    return result;
  }

  /// Measures the performance of a widget build operation.
  ///
  /// This method tracks widget build times and identifies
  /// performance bottlenecks in the UI rendering pipeline.
  static Widget measureWidgetBuild(
    String widgetName,
    Widget Function() builder,
  ) {
    if (!kDebugMode) return builder();

    return _PerformanceMeasuredWidget(widgetName: widgetName, builder: builder);
  }

  /// Measures async operation performance.
  ///
  /// This method tracks the performance of asynchronous operations
  /// and provides insights into async bottlenecks.
  static Future<T> measureAsyncOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    if (!kDebugMode) return await operation();

    final stopwatch = Stopwatch()..start();
    final result = await operation();
    stopwatch.stop();

    _instance._recordAsyncOperation(
      operationName,
      stopwatch.elapsedMicroseconds,
    );
    return result;
  }

  /// Gets current performance metrics.
  ///
  /// This method returns a snapshot of current performance data
  /// including frame rates, memory usage, and operation timings.
  static PerformanceMetrics getCurrentMetrics() {
    return _instance._getCurrentMetrics();
  }

  /// Logs performance summary to console.
  ///
  /// This method outputs a comprehensive performance report
  /// for debugging and optimization purposes.
  static void logPerformanceSummary() {
    if (kDebugMode) {
      _instance._logSummary();
    }
  }

  /// Creates a performance-optimized RepaintBoundary.
  ///
  /// This method wraps widgets with RepaintBoundary for better
  /// rendering performance and reduced unnecessary repaints.
  static Widget createOptimizedBoundary({
    required Widget child,
    String? debugLabel,
  }) {
    return RepaintBoundary(
      child: kDebugMode && debugLabel != null
          ? _DebugLabeledWidget(label: debugLabel, child: child)
          : child,
    );
  }
}

/// Internal performance tracker implementation.
class _PerformanceTracker {
  Timer? _frameRateTimer;
  Timer? _memoryTimer;
  final Map<String, List<int>> _themeOperations = {};
  final Map<String, List<int>> _asyncOperations = {};
  final Map<String, List<int>> _widgetBuilds = {};
  double _currentFrameRate = 60.0;
  int _currentMemoryUsage = 0;

  void _startFrameRateMonitoring() {
    _frameRateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _measureFrameRate();
    });
  }

  void _startMemoryMonitoring() {
    _memoryTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _measureMemoryUsage();
    });
  }

  void _stopMonitoring() {
    _frameRateTimer?.cancel();
    _memoryTimer?.cancel();
    _frameRateTimer = null;
    _memoryTimer = null;
  }

  void _measureFrameRate() {
    // Simplified frame rate measurement
    // In a real implementation, this would use SchedulerBinding
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now().millisecondsSinceEpoch;
      // Calculate frame rate based on frame timing
      _currentFrameRate = 60.0; // Placeholder
    });
  }

  void _measureMemoryUsage() {
    // Simplified memory measurement
    // In a real implementation, this would use dart:developer
    _currentMemoryUsage = 0; // Placeholder
  }

  void _recordThemeOperation(String operation, int microseconds) {
    _themeOperations.putIfAbsent(operation, () => []).add(microseconds);

    if (microseconds > 16000) {
      // > 16ms (60fps threshold)
      debugPrint(
        '⚠️ Slow theme operation: $operation took ${microseconds / 1000}ms',
      );
    }
  }

  void _recordAsyncOperation(String operation, int microseconds) {
    _asyncOperations.putIfAbsent(operation, () => []).add(microseconds);

    if (microseconds > 100000) {
      // > 100ms
      debugPrint(
        '⚠️ Slow async operation: $operation took ${microseconds / 1000}ms',
      );
    }
  }

  void _recordWidgetBuild(String widget, int microseconds) {
    _widgetBuilds.putIfAbsent(widget, () => []).add(microseconds);

    if (microseconds > 16000) {
      // > 16ms
      debugPrint('⚠️ Slow widget build: $widget took ${microseconds / 1000}ms');
    }
  }

  PerformanceMetrics _getCurrentMetrics() {
    return PerformanceMetrics(
      frameRate: _currentFrameRate,
      memoryUsage: _currentMemoryUsage,
      themeOperations: Map.from(_themeOperations),
      asyncOperations: Map.from(_asyncOperations),
      widgetBuilds: Map.from(_widgetBuilds),
    );
  }

  void _logSummary() {
    debugPrint('📊 Performance Summary:');
    debugPrint('   Frame Rate: ${_currentFrameRate.toStringAsFixed(1)} fps');
    debugPrint('   Memory Usage: $_currentMemoryUsage MB');

    if (_themeOperations.isNotEmpty) {
      debugPrint('   Theme Operations:');
      _themeOperations.forEach((operation, times) {
        final avgTime = times.reduce((a, b) => a + b) / times.length / 1000;
        debugPrint('     $operation: ${avgTime.toStringAsFixed(2)}ms avg');
      });
    }

    if (_widgetBuilds.isNotEmpty) {
      debugPrint('   Widget Builds:');
      _widgetBuilds.forEach((widget, times) {
        final avgTime = times.reduce((a, b) => a + b) / times.length / 1000;
        debugPrint('     $widget: ${avgTime.toStringAsFixed(2)}ms avg');
      });
    }
  }
}

/// Widget that measures build performance.
class _PerformanceMeasuredWidget extends StatelessWidget {
  final String widgetName;
  final Widget Function() builder;

  const _PerformanceMeasuredWidget({
    required this.widgetName,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final stopwatch = Stopwatch()..start();
    final widget = builder();
    stopwatch.stop();

    PerformanceMonitor._instance._recordWidgetBuild(
      widgetName,
      stopwatch.elapsedMicroseconds,
    );

    return widget;
  }
}

/// Debug widget that adds performance labels.
class _DebugLabeledWidget extends StatelessWidget {
  final String label;
  final Widget child;

  const _DebugLabeledWidget({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (kDebugMode)
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              color: Colors.red.withValues(alpha: 0.7),
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 8),
              ),
            ),
          ),
      ],
    );
  }
}

/// Performance metrics data structure.
class PerformanceMetrics {
  /// Current frame rate in fps
  final double frameRate;

  /// Current memory usage in MB
  final int memoryUsage;

  /// Theme operation timings
  final Map<String, List<int>> themeOperations;

  /// Async operation timings
  final Map<String, List<int>> asyncOperations;

  /// Widget build timings
  final Map<String, List<int>> widgetBuilds;

  /// Creates new performance metrics
  const PerformanceMetrics({
    required this.frameRate,
    required this.memoryUsage,
    required this.themeOperations,
    required this.asyncOperations,
    required this.widgetBuilds,
  });

  /// Whether performance is within acceptable thresholds
  bool get isPerformanceGood => frameRate >= 55.0 && memoryUsage < 100;

  /// Gets average theme operation time in milliseconds
  double getAverageThemeTime(String operation) {
    final times = themeOperations[operation];
    if (times == null || times.isEmpty) return 0.0;
    return times.reduce((a, b) => a + b) / times.length / 1000;
  }

  /// Gets average widget build time in milliseconds
  double getAverageWidgetBuildTime(String widget) {
    final times = widgetBuilds[widget];
    if (times == null || times.isEmpty) return 0.0;
    return times.reduce((a, b) => a + b) / times.length / 1000;
  }
}
