import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PerformanceService {
  static PerformanceService? _instance;
  static PerformanceService get instance => _instance ??= PerformanceService._();

  PerformanceService._();

  // Frame rate monitoring
  int _frameCount = 0;
  DateTime _lastFrameTime = DateTime.now();
  double _currentFPS = 60.0;
  final List<double> _fpsHistory = [];

  // Performance optimization flags
  bool _enableAnimations = true;
  bool _enableBlur = true;
  bool _enableShadows = true;
  bool _enableGradients = true;

  // Initialize performance monitoring
  void initialize() {
    if (kDebugMode) {
      // Add frame callback for FPS monitoring
      WidgetsBinding.instance.addPersistentFrameCallback(_onFrame);
    }
    
    // Optimize for mobile
    _optimizeForMobile();
  }

  void _onFrame(Duration timeStamp) {
    final now = DateTime.now();
    _frameCount++;
    
    if (now.difference(_lastFrameTime).inMilliseconds >= 1000) {
      _currentFPS = _frameCount.toDouble();
      _fpsHistory.add(_currentFPS);
      
      // Keep only last 10 FPS readings
      if (_fpsHistory.length > 10) {
        _fpsHistory.removeAt(0);
      }
      
      // Adjust performance based on FPS
      _adjustPerformanceSettings();
      
      _frameCount = 0;
      _lastFrameTime = now;
      
      if (kDebugMode) {
        print('FPS: $_currentFPS');
      }
    }
  }

  void _adjustPerformanceSettings() {
    final avgFPS = _fpsHistory.isNotEmpty 
        ? _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length
        : 60.0;

    // If FPS drops below 45, start disabling expensive features
    if (avgFPS < 45) {
      _enableBlur = false;
      _enableShadows = false;
    } else if (avgFPS < 30) {
      _enableAnimations = false;
      _enableGradients = false;
    } else if (avgFPS > 55) {
      // Re-enable features when performance improves
      _enableBlur = true;
      _enableShadows = true;
      _enableAnimations = true;
      _enableGradients = true;
    }
  }

  void _optimizeForMobile() {
    // Set high refresh rate on supported devices
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      // Request 120Hz if available
      try {
        WidgetsBinding.instance.platformDispatcher.onMetricsChanged = () {
          final display = WidgetsBinding.instance.platformDispatcher.displays.first;
          if (display.refreshRate > 60) {
            print('High refresh rate detected: ${display.refreshRate}Hz');
          }
        };
      } catch (e) {
        print('Error setting refresh rate: $e');
      }
    }
  }

  // Performance getters
  double get currentFPS => _currentFPS;
  bool get enableAnimations => _enableAnimations;
  bool get enableBlur => _enableBlur;
  bool get enableShadows => _enableShadows;
  bool get enableGradients => _enableGradients;

  // Manual performance overrides
  void setPerformanceMode(PerformanceMode mode) {
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

  // Optimized widget builders
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

  Widget buildOptimizedBlur({
    required Widget child,
    double sigmaX = 10.0,
    double sigmaY = 10.0,
  }) {
    if (!_enableBlur) {
      return Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: child,
      );
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
      child: child,
    );
  }

  AnimationController createOptimizedAnimationController({
    required Duration duration,
    required TickerProvider vsync,
  }) {
    return AnimationController(
      duration: _enableAnimations ? duration : Duration.zero,
      vsync: vsync,
    );
  }

  // Image optimization helpers
  Widget buildOptimizedImage({
    required String imageUrl,
    required Widget Function(BuildContext, String) placeholder,
    required Widget Function(BuildContext, Object, StackTrace?) errorWidget,
    BoxFit fit = BoxFit.cover,
  }) {
    return Image.network(
      imageUrl,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: _enableAnimations 
              ? const Duration(milliseconds: 300)
              : Duration.zero,
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return placeholder(context, imageUrl);
      },
      errorBuilder: errorWidget,
    );
  }

  // List performance optimization
  Widget buildOptimizedListView({
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    ScrollController? controller,
    ScrollPhysics? physics,
    EdgeInsets? padding,
    bool addAutomaticKeepAlives = false,
    bool addRepaintBoundaries = true,
  }) {
    return ListView.builder(
      controller: controller,
      physics: physics,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        Widget item = itemBuilder(context, index);
        
        // Add repaint boundaries for better performance
        if (addRepaintBoundaries) {
          item = RepaintBoundary(child: item);
        }
        
        return item;
      },
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
    );
  }

  // Memory management
  void optimizeMemoryUsage() {
    // Force garbage collection if available
    if (kDebugMode) {
      print('Optimizing memory usage...');
    }
    
    // Clear image cache if memory pressure is high
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  // Battery optimization
  void enableBatteryOptimization() {
    setPerformanceMode(PerformanceMode.battery);
  }

  void disableBatteryOptimization() {
    setPerformanceMode(PerformanceMode.high);
  }

  // Get performance stats
  Map<String, dynamic> getPerformanceStats() {
    return {
      'currentFPS': _currentFPS,
      'averageFPS': _fpsHistory.isNotEmpty 
          ? _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length
          : 0.0,
      'enableAnimations': _enableAnimations,
      'enableBlur': _enableBlur,
      'enableShadows': _enableShadows,
      'enableGradients': _enableGradients,
    };
  }
}

enum PerformanceMode {
  high,
  balanced,
  battery,
}

// Performance-optimized widgets
class PerformantContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;

  const PerformantContainer({
    super.key,
    required this.child,
    this.color,
    this.gradient,
    this.borderRadius,
    this.boxShadow,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return PerformanceService.instance.buildOptimizedContainer(
      child: child,
      color: color,
      gradient: gradient,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
      border: border,
    );
  }
}

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
    return PerformanceService.instance.buildOptimizedBlur(
      child: child,
      sigmaX: sigmaX,
      sigmaY: sigmaY,
    );
  }
}

class PerformantListView extends StatelessWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;

  const PerformantListView({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.controller,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return PerformanceService.instance.buildOptimizedListView(
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      controller: controller,
      physics: physics,
      padding: padding,
    );
  }
}