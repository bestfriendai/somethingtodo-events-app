import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../services/performance_service.dart';
import '../../services/cache_service.dart';

/// Optimized image widget with performance enhancements
///
/// Features:
/// - Progressive loading with blur effect
/// - Memory-efficient caching
/// - Lazy loading support
/// - Automatic quality adjustment based on performance
/// - Placeholder and error handling
class OptimizedImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableBlur;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final Duration fadeInDuration;
  final bool isLazyLoad;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableBlur = true,
    this.memCacheWidth,
    this.memCacheHeight,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.isLazyLoad = true,
  });

  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage>
    with AutomaticKeepAliveClientMixin {
  bool _isVisible = false;
  bool _hasError = false;

  @override
  bool get wantKeepAlive => !widget.isLazyLoad;

  @override
  void initState() {
    super.initState();
    if (!widget.isLazyLoad) {
      _isVisible = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.isLazyLoad && !_isVisible) {
      return VisibilityDetector(
        onVisibilityChanged: (info) {
          if (info.visibleFraction > 0 && !_isVisible) {
            setState(() {
              _isVisible = true;
            });
          }
        },
        child: _buildPlaceholder(),
      );
    }

    return _buildImage();
  }

  Widget _buildImage() {
    final performanceService = PerformanceService.instance;

    // Adjust quality based on performance
    final useHighQuality = performanceService.enableGradients;
    final enableAnimations = performanceService.enableAnimations;

    // Calculate optimal cache dimensions
    final cacheWidth =
        widget.memCacheWidth ??
        (widget.width != null ? (widget.width! * 2).round() : null);
    final cacheHeight =
        widget.memCacheHeight ??
        (widget.height != null ? (widget.height! * 2).round() : null);

    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      memCacheWidth: useHighQuality
          ? cacheWidth
          : (cacheWidth != null ? (cacheWidth * 0.7).round() : null),
      memCacheHeight: useHighQuality
          ? cacheHeight
          : (cacheHeight != null ? (cacheHeight * 0.7).round() : null),
      fadeInDuration: enableAnimations ? widget.fadeInDuration : Duration.zero,
      fadeOutDuration: enableAnimations
          ? const Duration(milliseconds: 150)
          : Duration.zero,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) {
        _hasError = true;
        return widget.errorWidget ?? _buildErrorWidget();
      },
      imageBuilder: (context, imageProvider) {
        if (widget.enableBlur && !_hasError) {
          return _buildProgressiveImage(imageProvider);
        }
        return Image(
          image: imageProvider,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
        );
      },
      cacheManager: DefaultCacheManager(),
      maxWidthDiskCache: useHighQuality ? null : 1000,
      maxHeightDiskCache: useHighQuality ? null : 1000,
    );
  }

  Widget _buildProgressiveImage(ImageProvider imageProvider) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Low quality blur background
        if (PerformanceService.instance.enableBlur)
          ClipRect(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Image(
                image: imageProvider,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
            ),
          ),

        // High quality image on top
        AnimatedOpacity(
          opacity: 1.0,
          duration: PerformanceService.instance.enableAnimations
              ? const Duration(milliseconds: 500)
              : Duration.zero,
          child: Image(
            image: imageProvider,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            gaplessPlayback: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: PerformanceService.instance.enableAnimations
          ? const _ShimmerPlaceholder()
          : const SizedBox.shrink(),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.broken_image_outlined,
        color: Theme.of(context).colorScheme.onErrorContainer,
        size: 32,
      ),
    );
  }
}

/// Visibility detector for lazy loading
class VisibilityDetector extends StatefulWidget {
  final Widget child;
  final Function(VisibilityInfo) onVisibilityChanged;

  const VisibilityDetector({
    super.key,
    required this.child,
    required this.onVisibilityChanged,
  });

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  void _checkVisibility() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      final offset = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      final screenHeight = MediaQuery.of(context).size.height;

      final isVisible =
          offset.dy < screenHeight && (offset.dy + size.height) > 0;

      if (isVisible) {
        widget.onVisibilityChanged(VisibilityInfo(visibleFraction: 1.0));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class VisibilityInfo {
  final double visibleFraction;

  VisibilityInfo({required this.visibleFraction});
}

/// Shimmer placeholder for loading state
class _ShimmerPlaceholder extends StatefulWidget {
  const _ShimmerPlaceholder();

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                Theme.of(context).colorScheme.surfaceContainerHighest,
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surfaceContainerHighest,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Optimized image list for galleries
class OptimizedImageGrid extends StatelessWidget {
  final List<String> imageUrls;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  const OptimizedImageGrid({
    super.key,
    required this.imageUrls,
    this.crossAxisCount = 3,
    this.mainAxisSpacing = 4.0,
    this.crossAxisSpacing = 4.0,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    // Pre-cache first few images
    if (imageUrls.isNotEmpty) {
      CacheService.instance.preloadImages(imageUrls.take(6).toList());
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        // Calculate optimal cache size for grid items
        final screenWidth = MediaQuery.of(context).size.width;
        final itemWidth =
            (screenWidth - (crossAxisSpacing * (crossAxisCount - 1))) /
            crossAxisCount;

        return OptimizedImage(
          imageUrl: imageUrls[index],
          fit: BoxFit.cover,
          memCacheWidth: (itemWidth * 2).round(),
          memCacheHeight: (itemWidth * 2 / childAspectRatio).round(),
          isLazyLoad: index > 5, // Eager load first 6 images
        );
      },
    );
  }
}
