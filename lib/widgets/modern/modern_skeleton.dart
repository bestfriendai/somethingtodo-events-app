import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ModernSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final bool isCircular;

  const ModernSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.margin,
    this.isCircular = false,
  });

  const ModernSkeleton.circular({super.key, required double size, this.margin})
    : width = size,
      height = size,
      borderRadius = 50,
      isCircular = true;

  const ModernSkeleton.rectangular({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.margin,
  }) : isCircular = false;

  @override
  State<ModernSkeleton> createState() => _ModernSkeletonState();
}

class _ModernSkeletonState extends State<ModernSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(
        milliseconds: 2000,
      ), // Slower animation for better performance
      vsync: this,
    );
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear, // Linear for smoother performance
      ),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use LayoutBuilder to handle infinite width constraints properly
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate actual width based on constraints
        final double actualWidth;
        if (widget.width != null) {
          actualWidth = widget.width!;
        } else if (constraints.maxWidth.isFinite) {
          actualWidth = constraints.maxWidth;
        } else {
          actualWidth = 200.0; // Fallback width
        }

        return RepaintBoundary(
          // Add RepaintBoundary for performance
          child: Container(
            width: actualWidth,
            height: widget.height ?? 16.0,
            margin: widget.margin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        left: _animation.value * actualWidth,
                        top: 0,
                        bottom: 0,
                        width: actualWidth * 0.5,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent,
                                isDark
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : Colors.white.withValues(alpha: 0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class ModernEventCardSkeleton extends StatelessWidget {
  final bool isHorizontal;
  final bool isPlayful;
  final String? loadingMessage;

  const ModernEventCardSkeleton({
    super.key,
    this.isHorizontal = true,
    this.isPlayful = false,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? const Color(0xFF16213E) : const Color(0xFFF8FAFC),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: Offset(0, isDark ? 10 : 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: isHorizontal
            ? _buildHorizontalSkeleton(context)
            : _buildVerticalSkeleton(),
      ),
    );
  }

  Widget _buildHorizontalSkeleton(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Row(
        children: [
          // Image skeleton - use Container with explicit size
          Container(
            width: 140,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.2),
            ),
            child: const ModernSkeleton(
              width: 140,
              height: 160, // Fixed height for horizontal layout
              borderRadius: 0,
            ),
          ),
          // Content skeleton with better spacing
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Category chip skeleton
                        const ModernSkeleton(
                          width: 80,
                          height: 20,
                          borderRadius: 20,
                        ),
                        const SizedBox(height: 8),
                        // Title skeleton
                        const ModernSkeleton(
                          width: null,
                          height: 16,
                          borderRadius: 8,
                        ),
                        const SizedBox(height: 6),
                        const ModernSkeleton(
                          width: 120,
                          height: 16,
                          borderRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  // Bottom row skeleton with reduced height
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const ModernSkeleton(
                              width: 100,
                              height: 12,
                              borderRadius: 6,
                            ),
                            const SizedBox(height: 4),
                            const ModernSkeleton(
                              width: 80,
                              height: 12,
                              borderRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const ModernSkeleton(
                        width: 50,
                        height: 24,
                        borderRadius: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image skeleton - removed double.infinity
        const ModernSkeleton(
          width: null, // Let LayoutBuilder handle it
          height: 200,
          borderRadius: 0,
        ),
        // Content skeleton
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ModernSkeleton(
                width: null, // Let LayoutBuilder handle it
                height: 24,
                borderRadius: 8,
              ),
              const SizedBox(height: 8),
              const ModernSkeleton(width: 200, height: 24, borderRadius: 8),
              const SizedBox(height: 16),
              const ModernSkeleton(width: 150, height: 16, borderRadius: 6),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const ModernSkeleton(width: 120, height: 16, borderRadius: 6),
                  const ModernSkeleton(width: 50, height: 28, borderRadius: 16),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ModernFeaturedEventSkeleton extends StatelessWidget {
  const ModernFeaturedEventSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 320,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: isDark ? const Color(0xFF16213E) : const Color(0xFFF8FAFC),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: Offset(0, isDark ? 10 : 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Background skeleton - use Positioned.fill for Stack
            Positioned.fill(
              child: const ModernSkeleton(
                width: null, // Let LayoutBuilder handle it
                height: null, // Will use parent height
                borderRadius: 0,
              ),
            ),
            // Content at bottom
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ModernSkeleton(
                    width: 100,
                    height: 24,
                    borderRadius: 20,
                  ),
                  const SizedBox(height: 12),
                  const ModernSkeleton(
                    width: null, // Let LayoutBuilder handle it
                    height: 28,
                    borderRadius: 8,
                  ),
                  const SizedBox(height: 8),
                  const ModernSkeleton(width: 200, height: 28, borderRadius: 8),
                  const SizedBox(height: 16),
                  const ModernSkeleton(width: 150, height: 20, borderRadius: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Shimmer List with Personality
class PlayfulShimmerList extends StatelessWidget {
  final int itemCount;
  final String loadingMessage;

  const PlayfulShimmerList({
    super.key,
    this.itemCount = 5,
    required this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PlayfulLoadingMessage(message: loadingMessage),
        ...List.generate(
          itemCount,
          (index) => ModernEventCardSkeleton(
            isPlayful: true,
            loadingMessage: index == 0
                ? '🔥 Hot event coming up!'
                : index == 1
                ? '🎪 Something fun this way comes!'
                : index == 2
                ? '🚀 Preparing awesome stuff!'
                : null,
          ), // Removed animations for better performance
        ),
      ],
    );
  }
}

// Playful Loading Messages Widget
class PlayfulLoadingMessage extends StatelessWidget {
  final String message;

  const PlayfulLoadingMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ), // Removed animate() - CircularProgressIndicator already animates
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ModernSkeletonGroup extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const ModernSkeletonGroup({
    super.key,
    required this.children,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .map(
            (child) => [
              child,
              if (child != children.last) SizedBox(height: spacing),
            ],
          )
          .expand((widget) => widget)
          .toList(),
    );
  }
}

class ModernListSkeleton extends StatelessWidget {
  final int itemCount;

  const ModernListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Container(
          margin: EdgeInsets.only(bottom: index < itemCount - 1 ? 16 : 0),
          child: const ModernEventCardSkeleton(),
        ),
      ),
    );
  }
}

class ModernProfileSkeleton extends StatelessWidget {
  const ModernProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        // Profile picture skeleton
        ModernSkeleton.circular(size: 80),
        SizedBox(height: 16),
        // Name skeleton
        ModernSkeleton(width: 120, height: 20),
        SizedBox(height: 8),
        // Bio skeleton
        ModernSkeleton(width: 200, height: 16),
        SizedBox(height: 4),
        ModernSkeleton(width: 150, height: 16),
      ],
    );
  }
}
