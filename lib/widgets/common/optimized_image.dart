import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:shimmer/shimmer.dart';

/// Optimized image widget with caching, lazy loading, and memory management
class OptimizedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final bool enableMemoryCache;
  final Duration fadeInDuration;
  final BorderRadius? borderRadius;
  final bool showShimmer;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.memCacheWidth,
    this.memCacheHeight,
    this.enableMemoryCache = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.borderRadius,
    this.showShimmer = true,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildErrorWidget();
    }

    // Calculate optimal cache size based on device pixel ratio
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheWidth = memCacheWidth ?? 
        (width != null ? (width! * devicePixelRatio).round() : null);
    final cacheHeight = memCacheHeight ?? 
        (height != null ? (height! * devicePixelRatio).round() : null);

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: const Duration(milliseconds: 150),
      maxWidthDiskCache: cacheWidth,
      maxHeightDiskCache: cacheHeight,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      imageBuilder: (context, imageProvider) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          image: DecorationImage(
            image: imageProvider,
            fit: fit,
          ),
        ),
      ),
    );

    // Add memory optimization for large images
    if (width != null && width! > 300 || height != null && height! > 300) {
      imageWidget = RepaintBoundary(child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) {
      return placeholder!;
    }

    if (!showShimmer) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius,
        ),
      );
    }

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey[400],
        size: width != null && width! < 100 ? 24 : 48,
      ),
    );
  }
}

/// Hero image with optimized loading
class OptimizedHeroImage extends StatelessWidget {
  final String tag;
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const OptimizedHeroImage({
    super.key,
    required this.tag,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      transitionOnUserGestures: true,
      child: OptimizedImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        borderRadius: borderRadius,
        fadeInDuration: Duration.zero, // No fade for hero animations
      ),
    );
  }
}

/// Lazy loading image that only loads when visible
class LazyImage extends StatefulWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double visibilityThreshold;

  const LazyImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.visibilityThreshold = 0.1,
  });

  @override
  State<LazyImage> createState() => _LazyImageState();
}

class _LazyImageState extends State<LazyImage> {
  bool _isVisible = false;
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  void _checkVisibility() {
    if (!mounted) return;

    final RenderObject? renderObject = _key.currentContext?.findRenderObject();
    if (renderObject == null) return;

    final viewport = RenderAbstractViewport.of(renderObject);
    if (viewport == null) return;

    final RevealedOffset offsetToReveal = 
        viewport.getOffsetToReveal(renderObject, 0.0);
    
    final Size size = renderObject.semanticBounds.size;
    final double visibleFraction = 
        (size.height - offsetToReveal.offset.abs()) / size.height;

    if (visibleFraction >= widget.visibilityThreshold) {
      setState(() {
        _isVisible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!_isVisible) {
          _checkVisibility();
        }
        return false;
      },
      child: Container(
        key: _key,
        width: widget.width,
        height: widget.height,
        child: _isVisible
            ? OptimizedImage(
                imageUrl: widget.imageUrl,
                width: widget.width,
                height: widget.height,
                fit: widget.fit,
                borderRadius: widget.borderRadius,
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: widget.borderRadius,
                ),
              ),
      ),
    );
  }
}

/// Image cache manager for preloading
class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;
  ImageCacheManager._internal();

  /// Preload images for smoother scrolling
  Future<void> preloadImages(BuildContext context, List<String?> imageUrls) async {
    final validUrls = imageUrls.where((url) => url != null && url.isNotEmpty);
    
    await Future.wait(
      validUrls.map((url) => 
        precacheImage(
          CachedNetworkImageProvider(url!),
          context,
        ),
      ),
      eagerError: false,
    );
  }

  /// Clear image cache to free memory
  void clearCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Set cache size limits
  void configureCacheLimits({
    int? maximumSize,
    int? maximumSizeBytes,
  }) {
    final ImageCache cache = PaintingBinding.instance.imageCache;
    
    if (maximumSize != null) {
      cache.maximumSize = maximumSize;
    }
    
    if (maximumSizeBytes != null) {
      cache.maximumSizeBytes = maximumSizeBytes;
    }
  }
}