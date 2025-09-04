import 'package:flutter/material.dart';
import '../../services/performance_service.dart';

/// Optimized list view with performance enhancements
///
/// Features:
/// - Automatic performance adaptation
/// - Viewport caching optimization
/// - Smart repaint boundaries
/// - Lazy loading support
/// - Memory-efficient rendering
class OptimizedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final double? itemExtent;
  final Widget? separator;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final VoidCallback? onLoadMore;
  final bool enablePullToRefresh;
  final Future<void> Function()? onRefresh;
  final int cacheExtentMultiplier;

  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.itemExtent,
    this.separator,
    this.loadingWidget,
    this.emptyWidget,
    this.onLoadMore,
    this.enablePullToRefresh = true,
    this.onRefresh,
    this.cacheExtentMultiplier = 2,
  });

  @override
  State<OptimizedListView<T>> createState() => _OptimizedListViewState<T>();
}

class _OptimizedListViewState<T> extends State<OptimizedListView<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;
  final Set<int> _visibleIndices = {};

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();

    if (widget.onLoadMore != null) {
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && widget.onLoadMore != null) {
        setState(() {
          _isLoadingMore = true;
        });

        widget.onLoadMore!();

        // Reset loading state after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isLoadingMore = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }

    Widget listView = _buildOptimizedList();

    if (widget.enablePullToRefresh && widget.onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: listView,
      );
    }

    return listView;
  }

  Widget _buildOptimizedList() {
    final performanceService = PerformanceService.instance;

    // Calculate optimal cache extent based on performance
    final baseExtent = MediaQuery.of(context).size.height;
    final cacheExtent = performanceService.enableAnimations
        ? baseExtent * widget.cacheExtentMultiplier
        : baseExtent; // Reduce cache when performance is poor

    if (widget.separator != null) {
      return ListView.separated(
        controller: _scrollController,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
        cacheExtent: cacheExtent,
        itemCount: widget.items.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => widget.separator!,
        itemBuilder: _buildItem,
        addAutomaticKeepAlives: false, // Manually control
        addRepaintBoundaries: false, // Manually add where needed
      );
    }

    if (widget.itemExtent != null) {
      // Use fixed extent list for better performance
      return ListView.builder(
        controller: _scrollController,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
        cacheExtent: cacheExtent,
        itemExtent: widget.itemExtent!,
        itemCount: widget.items.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: _buildItem,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
      cacheExtent: cacheExtent,
      itemCount: widget.items.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: _buildItem,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    // Show loading widget at the end
    if (index >= widget.items.length) {
      return widget.loadingWidget ?? _buildDefaultLoadingWidget();
    }

    final item = widget.items[index];
    Widget child = widget.itemBuilder(context, item, index);

    // Add repaint boundary for every 3rd item to balance performance
    if (index % 3 == 0) {
      child = RepaintBoundary(child: child);
    }

    // Track visible items for analytics or preloading
    return NotificationListener<UserScrollNotification>(
      onNotification: (_) {
        _visibleIndices.add(index);
        return false;
      },
      child: child,
    );
  }

  Widget _buildDefaultLoadingWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }
}

/// Optimized sliver list for custom scroll views
class OptimizedSliverList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? separator;
  final double? itemExtent;

  const OptimizedSliverList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.separator,
    this.itemExtent,
  });

  @override
  Widget build(BuildContext context) {
    if (itemExtent != null) {
      return SliverFixedExtentList(
        itemExtent: itemExtent!,
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildItem(context, index),
          childCount: items.length,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
        ),
      );
    }

    if (separator != null) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final itemIndex = index ~/ 2;
            if (index.isEven) {
              return _buildItem(context, itemIndex);
            }
            return separator!;
          },
          childCount: items.length * 2 - 1,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildItem(context, index),
        childCount: items.length,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    if (index >= items.length) return const SizedBox.shrink();

    Widget child = itemBuilder(context, items[index], index);

    // Add repaint boundary for expensive items
    if (index % 3 == 0) {
      child = RepaintBoundary(child: child);
    }

    return child;
  }
}

/// Animated list with performance optimizations
class OptimizedAnimatedList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(
    BuildContext context,
    T item,
    int index,
    Animation<double> animation,
  )
  itemBuilder;
  final Duration insertDuration;
  final Duration removeDuration;
  final ScrollController? controller;
  final EdgeInsets? padding;

  const OptimizedAnimatedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.insertDuration = const Duration(milliseconds: 300),
    this.removeDuration = const Duration(milliseconds: 300),
    this.controller,
    this.padding,
  });

  @override
  State<OptimizedAnimatedList<T>> createState() =>
      _OptimizedAnimatedListState<T>();
}

class _OptimizedAnimatedListState<T> extends State<OptimizedAnimatedList<T>> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<T> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  @override
  void didUpdateWidget(OptimizedAnimatedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.items.length != oldWidget.items.length) {
      _updateItems();
    }
  }

  void _updateItems() {
    final performanceService = PerformanceService.instance;
    final enableAnimations = performanceService.enableAnimations;

    // Add new items
    for (int i = _items.length; i < widget.items.length; i++) {
      _items.add(widget.items[i]);
      _listKey.currentState?.insertItem(
        i,
        duration: enableAnimations ? widget.insertDuration : Duration.zero,
      );
    }

    // Remove extra items
    while (_items.length > widget.items.length) {
      final index = _items.length - 1;
      final item = _items.removeAt(index);

      _listKey.currentState?.removeItem(
        index,
        (context, animation) =>
            widget.itemBuilder(context, item, index, animation),
        duration: enableAnimations ? widget.removeDuration : Duration.zero,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      controller: widget.controller,
      padding: widget.padding,
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) {
        if (index >= _items.length) return const SizedBox.shrink();

        Widget child = widget.itemBuilder(
          context,
          _items[index],
          index,
          animation,
        );

        // Add repaint boundary for complex animated items
        if (index % 3 == 0) {
          child = RepaintBoundary(child: child);
        }

        return child;
      },
    );
  }
}

/// Infinite scroll list with automatic pagination
class InfiniteScrollList<T> extends StatefulWidget {
  final Future<List<T>> Function(int page) onLoadMore;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final Widget? errorWidget;

  const InfiniteScrollList({
    super.key,
    required this.onLoadMore,
    required this.itemBuilder,
    this.controller,
    this.padding,
    this.loadingWidget,
    this.emptyWidget,
    this.errorWidget,
  });

  @override
  State<InfiniteScrollList<T>> createState() => _InfiniteScrollListState<T>();
}

class _InfiniteScrollListState<T> extends State<InfiniteScrollList<T>> {
  final List<T> _items = [];
  late ScrollController _scrollController;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _hasError = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final newItems = await widget.onLoadMore(_currentPage);

      setState(() {
        _items.addAll(newItems);
        _currentPage++;
        _hasMore = newItems.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && !_isLoading) {
      return widget.emptyWidget ?? const Center(child: Text('No items'));
    }

    return OptimizedListView<T>(
      items: _items,
      itemBuilder: widget.itemBuilder,
      controller: _scrollController,
      padding: widget.padding,
      loadingWidget: _isLoading ? widget.loadingWidget : null,
      emptyWidget: widget.emptyWidget,
    );
  }
}
