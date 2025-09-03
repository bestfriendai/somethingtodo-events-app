import 'dart:async';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Performance monitoring and optimization service
class PerformanceService {
  static PerformanceService? _instance;
  static PerformanceService get instance =>
      _instance ??= PerformanceService._();

  PerformanceService._();

  // Frame rate monitoring
  int _frameCount = 0;
  DateTime _lastFrameTime = DateTime.now();
  double _currentFPS = 60.0;
  final List<double> _fpsHistory = [];

  // Performance metrics
  int _jankFrames = 0;
  double _averageFrameTime = 16.67; // Target 60fps
  final Map<String, Duration> _operationTimings = {};
  final Map<String, int> _operationCounts = {};

  // Memory monitoring
  int _lastMemoryUsage = 0;
  final List<int> _memoryHistory = [];

  // Network monitoring
  int _activeNetworkRequests = 0;
  int _totalNetworkRequests = 0;
  Duration _averageNetworkLatency = Duration.zero;
  final Map<String, DateTime> _networkRequestTimes = {};

  // Performance optimization flags
  bool _enableAnimations = true;
  bool _enableBlur = true;
  bool _enableShadows = true;
  bool _enableGradients = true;

  // Performance mode
  PerformanceMode _currentMode = PerformanceMode.balanced;

  bool _isInitialized = false;
  Timer? _performanceTimer;

  // Getters for performance flags
  bool get enableAnimations => _enableAnimations;
  bool get enableBlur => _enableBlur;
  bool get enableShadows => _enableShadows;
  bool get enableGradients => _enableGradients;
  double get currentFPS => _currentFPS;
  PerformanceMode get currentMode => _currentMode;

  /// Initialize performance monitoring with enhanced metrics
  void initialize() {
    if (_isInitialized) return;

    // Add frame callback for FPS monitoring (always monitor in release too)
    WidgetsBinding.instance.addPersistentFrameCallback(_onFrame);

    // Add timeline events listener for performance tracking
    WidgetsBinding.instance.addTimingsCallback(_onTimings);

    // Optimize for mobile
    _optimizeForMobile();

    if (kDebugMode) {
      _startPerformanceMonitoring();
    }

    _isInitialized = true;
  }

  /// Start performance monitoring
  void _startPerformanceMonitoring() {
    // Monitor frame rate every second
    _performanceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateFPS();
      _monitorMemory();
    });
  }

  /// Calculate current FPS
  void _calculateFPS() {
    final now = DateTime.now();
    final timeDiff = now.difference(_lastFrameTime).inMilliseconds;

    if (timeDiff > 0) {
      _currentFPS = (1000 / timeDiff).clamp(0.0, 120.0);
      _fpsHistory.add(_currentFPS);

      // Keep only last 60 samples (1 minute)
      if (_fpsHistory.length > 60) {
        _fpsHistory.removeAt(0);
      }

      // Count jank frames (< 55 FPS)
      if (_currentFPS < 55) {
        _jankFrames++;
      }
    }

    _lastFrameTime = now;
    _frameCount++;
  }

  /// Monitor memory usage
  void _monitorMemory() {
    // This is a simplified memory monitoring
    // In a real app, you'd use more sophisticated memory tracking
    final memoryUsage = _frameCount * 100; // Simplified metric
    _memoryHistory.add(memoryUsage);

    // Keep only last 60 samples
    if (_memoryHistory.length > 60) {
      _memoryHistory.removeAt(0);
    }

    _lastMemoryUsage = memoryUsage;
  }

  /// Track operation timing
  void startOperation(String operationName) {
    _operationTimings[operationName] = Duration.zero;
    _operationCounts[operationName] =
        (_operationCounts[operationName] ?? 0) + 1;
  }

  /// End operation timing
  void endOperation(String operationName) {
    final existingDuration = _operationTimings[operationName] ?? Duration.zero;
    _operationTimings[operationName] =
        existingDuration + const Duration(milliseconds: 1);
  }

  /// Track network request
  void startNetworkRequest(String requestId) {
    _activeNetworkRequests++;
    _networkRequestTimes[requestId] = DateTime.now();
  }

  /// End network request
  void endNetworkRequest(String requestId) {
    _activeNetworkRequests = (_activeNetworkRequests - 1).clamp(
      0,
      double.infinity.toInt(),
    );
    _networkRequestTimes.remove(requestId);
  }

  /// Get performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'fps': _currentFPS,
      'averageFPS': _fpsHistory.isEmpty
          ? 60.0
          : _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length,
      'jankFrames': _jankFrames,
      'averageFrameTime': _averageFrameTime,
      'memoryUsage': _lastMemoryUsage,
      'activeNetworkRequests': _activeNetworkRequests,
      'operationCounts': Map.from(_operationCounts),
    };
  }

  /// Frame callback for FPS monitoring
  void _onFrame(Duration timeStamp) {
    _frameCount++;
    final now = DateTime.now();
    final timeDiff = now.difference(_lastFrameTime).inMilliseconds;

    if (timeDiff > 0 && timeDiff < 1000) {
      // Reasonable frame time
      _currentFPS = (1000 / timeDiff).clamp(0.0, 120.0);
      _fpsHistory.add(_currentFPS);

      // Keep only last 60 samples (1 minute)
      if (_fpsHistory.length > 60) {
        _fpsHistory.removeAt(0);
      }

      // Count jank frames (< 55 FPS)
      if (_currentFPS < 55) {
        _jankFrames++;
      }
    }

    _lastFrameTime = now;
  }

  /// Timeline events callback for performance tracking
  void _onTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      final frameDuration = timing.totalSpan;
      _averageFrameTime = frameDuration.inMicroseconds / 1000.0;

      // Track jank frames (> 16.67ms for 60fps)
      if (_averageFrameTime > 16.67) {
        _jankFrames++;
      }
    }
  }

  /// Optimize for mobile platforms
  void _optimizeForMobile() {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      // Reduce visual effects on mobile for better performance
      _enableBlur = false;
      _enableShadows = false;
      _enableGradients = true; // Keep gradients as they're GPU accelerated
    }
  }

  /// Build optimized container widget
  Widget buildOptimizedContainer({
    required Widget child,
    Color? color,
    Gradient? gradient,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    Border? border,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        gradient: _enableGradients ? gradient : null,
        borderRadius: borderRadius,
        boxShadow: _enableShadows ? boxShadow : null,
        border: border,
      ),
      child: child,
    );
  }

  /// Build optimized blur widget
  Widget buildOptimizedBlur({
    required Widget child,
    double sigmaX = 10.0,
    double sigmaY = 10.0,
  }) {
    if (!_enableBlur) {
      return child;
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
      child: child,
    );
  }

  /// Update network latency tracking
  void updateNetworkLatency(Duration latency) {
    // Rolling average
    _averageNetworkLatency = Duration(
      milliseconds:
          ((_averageNetworkLatency.inMilliseconds * 0.9) +
                  (latency.inMilliseconds * 0.1))
              .round(),
    );
  }

  /// Set performance mode
  void setPerformanceMode(PerformanceMode mode) {
    _currentMode = mode;

    switch (mode) {
      case PerformanceMode.high:
        _enableAnimations = true;
        _enableBlur = true;
        _enableShadows = true;
        _enableGradients = true;
        break;
      case PerformanceMode.balanced:
        _enableAnimations = true;
        _enableBlur = false;
        _enableShadows = true;
        _enableGradients = true;
        break;
      case PerformanceMode.battery:
        _enableAnimations = false;
        _enableBlur = false;
        _enableShadows = false;
        _enableGradients = false;
        break;
    }
  }

  /// Get comprehensive performance stats
  Map<String, dynamic> getPerformanceStats() {
    return {
      'currentFPS': _currentFPS,
      'averageFPS': _fpsHistory.isEmpty
          ? 60.0
          : _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length,
      'jankFrames': _jankFrames,
      'averageFrameTime': _averageFrameTime,
      'memoryUsage': _lastMemoryUsage,
      'activeNetworkRequests': _activeNetworkRequests,
      'operationCounts': Map.from(_operationCounts),
      'enableAnimations': _enableAnimations,
      'enableBlur': _enableBlur,
      'enableShadows': _enableShadows,
      'enableGradients': _enableGradients,
      'currentMode': _currentMode.toString(),
    };
  }

  /// Enable battery optimization
  void enableBatteryOptimization() {
    setPerformanceMode(PerformanceMode.battery);
  }

  /// Disable battery optimization
  void disableBatteryOptimization() {
    setPerformanceMode(PerformanceMode.high);
  }

  /// Optimize memory usage
  void optimizeMemoryUsage() {
    // Clear old performance data
    if (_fpsHistory.length > 30) {
      _fpsHistory.removeRange(0, _fpsHistory.length - 30);
    }
    if (_memoryHistory.length > 30) {
      _memoryHistory.removeRange(0, _memoryHistory.length - 30);
    }

    // Clear old operation timings
    _operationTimings.clear();
    _operationCounts.clear();

    // Clear old network request times
    _networkRequestTimes.clear();
  }

  /// Create optimized animation controller
  AnimationController createOptimizedAnimationController({
    required Duration duration,
    required TickerProvider vsync,
    Duration? reverseDuration,
    String? debugLabel,
  }) {
    return AnimationController(
      duration: duration,
      reverseDuration: reverseDuration,
      vsync: vsync,
      debugLabel: debugLabel,
    );
  }

  /// Build optimized list view
  Widget buildOptimizedListView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollController? controller,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
  }) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics:
          physics ??
          (_enableAnimations
              ? const BouncingScrollPhysics()
              : const ClampingScrollPhysics()),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }

  /// Build optimized image widget
  Widget buildOptimizedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit? fit,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, Object, StackTrace?)? errorWidget,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Builder(
        builder: (context) =>
            placeholder?.call(context, imageUrl) ??
            const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  /// Dispose resources
  void dispose() {
    _performanceTimer?.cancel();
    _performanceTimer = null;
    _fpsHistory.clear();
    _memoryHistory.clear();
    _operationTimings.clear();
    _operationCounts.clear();
    _networkRequestTimes.clear();
    _isInitialized = false;
  }
}

/// Performance modes for optimization
enum PerformanceMode { high, balanced, battery }

/// Performance-optimized container widget
class PerformantContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const PerformantContainer({
    super.key,
    required this.child,
    this.color,
    this.width,
    this.height,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: color != null ? BoxDecoration(color: color) : null,
      child: child,
    );
  }
}

/// Performance-optimized blur widget
class PerformantBlur extends StatelessWidget {
  final Widget child;
  final double sigmaX;
  final double sigmaY;

  const PerformantBlur({
    super.key,
    required this.child,
    this.sigmaX = 10.0,
    this.sigmaY = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
      child: child,
    );
  }
}

/// Performance-optimized ListView
class PerformantListView extends StatelessWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const PerformantListView({
    super.key,
    required this.children,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}
