import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/modern_theme.dart';
import 'modern_ui_components.dart';
import 'modern_button.dart';

/// State management enum for different UI states
enum ViewState { idle, loading, error, empty, success, offline }

/// Modern state wrapper for managing different UI states
class ModernStateWrapper extends StatefulWidget {
  final ViewState state;
  final Widget child;
  final VoidCallback? onRetry;
  final String? errorMessage;
  final String? emptyMessage;
  final String? emptyTitle;
  final IconData? emptyIcon;
  final Widget? emptyAction;
  final bool showOfflineBanner;
  final int skeletonCount;
  final Widget Function()? skeletonBuilder;
  final Future<void> Function()? onRefresh;

  const ModernStateWrapper({
    super.key,
    required this.state,
    required this.child,
    this.onRetry,
    this.errorMessage,
    this.emptyMessage,
    this.emptyTitle,
    this.emptyIcon,
    this.emptyAction,
    this.showOfflineBanner = false,
    this.skeletonCount = 5,
    this.skeletonBuilder,
    this.onRefresh,
  });

  @override
  State<ModernStateWrapper> createState() => _ModernStateWrapperState();
}

class _ModernStateWrapperState extends State<ModernStateWrapper>
    with TickerProviderStateMixin {
  late AnimationController _stateController;
  late AnimationController _successController;
  ViewState? _previousState;

  @override
  void initState() {
    super.initState();
    _stateController = AnimationController(
      duration: ModernTheme.animationMedium,
      vsync: this,
    );

    _successController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _previousState = widget.state;
    if (widget.state != ViewState.loading) {
      _stateController.forward();
    }
  }

  @override
  void didUpdateWidget(ModernStateWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.state != widget.state) {
      _previousState = oldWidget.state;

      // Trigger success animation when transitioning from loading to idle
      if (_previousState == ViewState.loading &&
          widget.state == ViewState.idle) {
        _successController.forward(from: 0);
        HapticFeedback.mediumImpact();
      }

      // Reset and play state animation
      _stateController.reset();
      _stateController.forward();
    }
  }

  @override
  void dispose() {
    _stateController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content with refresh indicator if enabled
        if (widget.onRefresh != null)
          RefreshIndicator(
            onRefresh: widget.onRefresh!,
            color: ModernTheme.primaryColor,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            child: _buildContent(),
          )
        else
          _buildContent(),

        // Offline banner
        if (widget.showOfflineBanner) _buildOfflineBanner(),

        // Success overlay animation
        if (widget.state == ViewState.idle &&
            _previousState == ViewState.loading)
          _buildSuccessOverlay(),
      ],
    );
  }

  Widget _buildContent() {
    return AnimatedSwitcher(
      duration: ModernTheme.animationMedium,
      switchInCurve: ModernTheme.curveEaseOut,
      switchOutCurve: ModernTheme.curveEaseInOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(
              Tween(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).chain(CurveTween(curve: ModernTheme.curveEaseOut)),
            ),
            child: child,
          ),
        );
      },
      child: _buildStateContent(),
    );
  }

  Widget _buildStateContent() {
    switch (widget.state) {
      case ViewState.loading:
        return _buildLoadingState();
      case ViewState.error:
        return _buildErrorState();
      case ViewState.empty:
        return _buildEmptyState();
      case ViewState.offline:
        return _buildOfflineState();
      case ViewState.idle:
      case ViewState.success:
      default:
        return widget.child;
    }
  }

  Widget _buildLoadingState() {
    if (widget.skeletonBuilder != null) {
      return widget.skeletonBuilder!();
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(ModernTheme.spaceMd),
      itemCount: widget.skeletonCount,
      itemBuilder: (context, index) {
        return Padding(
              padding: EdgeInsets.only(bottom: ModernTheme.spaceMd),
              child: _buildSkeletonCard(),
            )
            .animate(delay: Duration(milliseconds: index * 50))
            .fadeIn()
            .slideX(begin: -0.1);
      },
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ModernTheme.radiusLg),
        color: Theme.of(context).brightness == Brightness.dark
            ? ModernTheme.darkCardSurface
            : Colors.grey.shade100,
      ),
      padding: EdgeInsets.all(ModernTheme.spaceMd),
      child: Row(
        children: [
          ModernSkeleton(
            width: 80,
            height: 80,
            borderRadius: ModernTheme.radiusMd,
          ),
          SizedBox(width: ModernTheme.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ModernSkeleton(height: 20, borderRadius: ModernTheme.radiusXs),
                SizedBox(height: ModernTheme.spaceSm),
                ModernSkeleton(
                  height: 16,
                  width: 150,
                  borderRadius: ModernTheme.radiusXs,
                ),
                SizedBox(height: ModernTheme.spaceSm),
                Row(
                  children: [
                    ModernSkeleton(
                      height: 14,
                      width: 60,
                      borderRadius: ModernTheme.radiusXs,
                    ),
                    SizedBox(width: ModernTheme.spaceMd),
                    ModernSkeleton(
                      height: 14,
                      width: 80,
                      borderRadius: ModernTheme.radiusXs,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: ModernErrorState(
        message: widget.errorMessage,
        onRetry: widget.onRetry,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ModernEmptyState(
        icon: widget.emptyIcon ?? Icons.inbox_rounded,
        title: widget.emptyTitle ?? 'No Data Available',
        subtitle: widget.emptyMessage,
        action: widget.emptyAction,
      ),
    );
  }

  Widget _buildOfflineState() {
    return Center(
      child: ModernEmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'You\'re Offline',
        subtitle: 'Please check your internet connection and try again.',
        action: widget.onRetry != null
            ? ModernButton(
                text: 'Retry',
                onPressed: widget.onRetry,
                variant: ModernButtonVariant.primary,
                leadingIcon: Icons.refresh_rounded,
              )
            : null,
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child:
            Container(
                  margin: EdgeInsets.all(ModernTheme.spaceMd),
                  padding: EdgeInsets.symmetric(
                    horizontal: ModernTheme.spaceMd,
                    vertical: ModernTheme.spaceSm,
                  ),
                  decoration: BoxDecoration(
                    color: ModernTheme.warningColor,
                    borderRadius: BorderRadius.circular(ModernTheme.radiusMd),
                    boxShadow: ModernTheme.elevationMd(
                      ModernTheme.warningColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: ModernTheme.spaceSm),
                      const Expanded(
                        child: Text(
                          'No internet connection',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onRetry,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: ModernTheme.spaceMd,
                            vertical: ModernTheme.spaceXs,
                          ),
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .slideY(begin: -1, duration: ModernTheme.animationMedium)
                .fadeIn(),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _successController,
        builder: (context, child) {
          final opacity = Tween<double>(begin: 0.0, end: 1.0)
              .chain(
                CurveTween(
                  curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
                ),
              )
              .evaluate(_successController);

          final fadeOut = Tween<double>(begin: 1.0, end: 0.0)
              .chain(
                CurveTween(
                  curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
                ),
              )
              .evaluate(_successController);

          return Opacity(
            opacity: opacity * fadeOut,
            child: Center(
              child:
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: ModernTheme.successColor.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ModernTheme.successColor.withValues(
                            alpha: 0.4,
                          ),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 60,
                    ),
                  ).animate().scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: const Duration(milliseconds: 400),
                    curve: ModernTheme.curveOvershoot,
                  ),
            ),
          );
        },
      ),
    );
  }
}

/// Modern list wrapper with automatic state management
class ModernListWrapper<T> extends StatelessWidget {
  final List<T>? items;
  final bool isLoading;
  final String? error;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final VoidCallback? onRetry;
  final Future<void> Function()? onRefresh;
  final String emptyTitle;
  final String? emptyMessage;
  final IconData emptyIcon;
  final Widget? emptyAction;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ModernListWrapper({
    super.key,
    required this.items,
    required this.isLoading,
    required this.itemBuilder,
    this.error,
    this.onRetry,
    this.onRefresh,
    this.emptyTitle = 'No items found',
    this.emptyMessage,
    this.emptyIcon = Icons.inbox_rounded,
    this.emptyAction,
    this.scrollController,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  ViewState get _state {
    if (isLoading) return ViewState.loading;
    if (error != null) return ViewState.error;
    if (items == null || items!.isEmpty) return ViewState.empty;
    return ViewState.idle;
  }

  @override
  Widget build(BuildContext context) {
    return ModernStateWrapper(
      state: _state,
      onRetry: onRetry,
      onRefresh: onRefresh,
      errorMessage: error,
      emptyTitle: emptyTitle,
      emptyMessage: emptyMessage,
      emptyIcon: emptyIcon,
      emptyAction: emptyAction,
      child: ListView.builder(
        controller: scrollController,
        padding: padding ?? EdgeInsets.all(ModernTheme.spaceMd),
        shrinkWrap: shrinkWrap,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        itemCount: items?.length ?? 0,
        itemBuilder: (context, index) {
          return itemBuilder(context, items![index], index)
              .animate(delay: Duration(milliseconds: index * 50))
              .fadeIn(duration: ModernTheme.animationMedium)
              .slideY(begin: 0.1, duration: ModernTheme.animationMedium);
        },
      ),
    );
  }
}
