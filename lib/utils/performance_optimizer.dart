import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Performance optimization utilities for the app
class PerformanceOptimizer {
  static final PerformanceOptimizer _instance = PerformanceOptimizer._internal();
  factory PerformanceOptimizer() => _instance;
  PerformanceOptimizer._internal();

  // Debounce timers
  final Map<String, Timer> _debounceTimers = {};
  final Map<String, Timer> _throttleTimers = {};
  final Map<String, DateTime> _throttleLastRun = {};

  /// Debounce function calls to prevent excessive executions
  void debounce(
    String id,
    Duration duration,
    VoidCallback action,
  ) {
    _debounceTimers[id]?.cancel();
    _debounceTimers[id] = Timer(duration, action);
  }

  /// Throttle function calls to limit execution frequency
  void throttle(
    String id,
    Duration duration,
    VoidCallback action,
  ) {
    final lastRun = _throttleLastRun[id];
    final now = DateTime.now();
    
    if (lastRun == null || now.difference(lastRun) >= duration) {
      action();
      _throttleLastRun[id] = now;
    }
  }

  /// Cancel all pending debounced actions
  void cancelDebounce(String id) {
    _debounceTimers[id]?.cancel();
    _debounceTimers.remove(id);
  }

  /// Cancel all pending throttled actions
  void cancelThrottle(String id) {
    _throttleTimers[id]?.cancel();
    _throttleTimers.remove(id);
    _throttleLastRun.remove(id);
  }

  /// Dispose all timers
  void dispose() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    for (final timer in _throttleTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _throttleTimers.clear();
    _throttleLastRun.clear();
  }

  /// Run expensive computation in isolate
  static Future<T> runInIsolate<T>(ComputeCallback<dynamic, T> callback, dynamic message) {
    return compute(callback, message);
  }

  /// Batch multiple operations into a single frame
  static void batchOperations(List<VoidCallback> operations) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      for (final operation in operations) {
        operation();
      }
    });
  }

  /// Check if we should skip frame for performance
  static bool shouldSkipFrame() {
    final renderTime = SchedulerBinding.instance.window.onReportTimings;
    // Skip if frame is taking too long
    return false; // Implement based on actual frame timing
  }
}

/// Memoization helper for expensive computations
class Memoizer<T> {
  final Map<String, T> _cache = {};
  final Duration? ttl;
  final Map<String, DateTime> _timestamps = {};

  Memoizer({this.ttl});

  T memoize(String key, T Function() compute) {
    if (_cache.containsKey(key)) {
      if (ttl != null) {
        final timestamp = _timestamps[key]!;
        if (DateTime.now().difference(timestamp) < ttl!) {
          return _cache[key]!;
        }
      } else {
        return _cache[key]!;
      }
    }

    final result = compute();
    _cache[key] = result;
    _timestamps[key] = DateTime.now();
    return result;
  }

  void clear() {
    _cache.clear();
    _timestamps.clear();
  }

  void remove(String key) {
    _cache.remove(key);
    _timestamps.remove(key);
  }
}

/// Widget that only rebuilds when necessary
class OptimizedBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final List<Object?> dependencies;

  const OptimizedBuilder({
    super.key,
    required this.builder,
    this.dependencies = const [],
  });

  @override
  State<OptimizedBuilder> createState() => _OptimizedBuilderState();
}

class _OptimizedBuilderState extends State<OptimizedBuilder> {
  late List<Object?> _lastDependencies;
  late Widget _cachedWidget;

  @override
  void initState() {
    super.initState();
    _lastDependencies = List.from(widget.dependencies);
    _cachedWidget = widget.builder(context);
  }

  @override
  Widget build(BuildContext context) {
    bool shouldRebuild = false;
    
    if (_lastDependencies.length != widget.dependencies.length) {
      shouldRebuild = true;
    } else {
      for (int i = 0; i < widget.dependencies.length; i++) {
        if (_lastDependencies[i] != widget.dependencies[i]) {
          shouldRebuild = true;
          break;
        }
      }
    }

    if (shouldRebuild) {
      _lastDependencies = List.from(widget.dependencies);
      _cachedWidget = widget.builder(context);
    }

    return _cachedWidget;
  }
}

/// Lazy loading wrapper for heavy widgets
class LazyLoadWidget extends StatefulWidget {
  final Widget child;
  final Widget placeholder;
  final Duration delay;

  const LazyLoadWidget({
    super.key,
    required this.child,
    this.placeholder = const SizedBox.shrink(),
    this.delay = const Duration(milliseconds: 100),
  });

  @override
  State<LazyLoadWidget> createState() => _LazyLoadWidgetState();
}

class _LazyLoadWidgetState extends State<LazyLoadWidget> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoaded ? widget.child : widget.placeholder;
  }
}

/// Performance monitoring widget
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final String tag;
  final bool enabled;

  const PerformanceMonitor({
    super.key,
    required this.child,
    required this.tag,
    this.enabled = true,
  });

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  late DateTime _buildStartTime;
  int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.enabled && kDebugMode) {
      _buildStartTime = DateTime.now();
      _buildCount++;
      
      SchedulerBinding.instance.addPostFrameCallback((_) {
        final buildTime = DateTime.now().difference(_buildStartTime);
        if (buildTime.inMilliseconds > 16) {
          debugPrint('⚠️ [${widget.tag}] Slow build: ${buildTime.inMilliseconds}ms (Build #$_buildCount)');
        }
      });
    }

    return widget.child;
  }
}