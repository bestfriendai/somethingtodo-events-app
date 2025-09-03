import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../utils/performance_optimizer.dart';

/// Optimized list view with virtualization and performance improvements
class OptimizedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Widget? separatorBuilder;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final VoidCallback? onLoadMore;
  final bool enableLoadMore;
  final double loadMoreThreshold;
  final int? itemExtent;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final int cacheExtent;

  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.separatorBuilder,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.loadingWidget,
    this.emptyWidget,
    this.onLoadMore,
    this.enableLoadMore = false,
    this.loadMoreThreshold = 200,
    this.itemExtent,
    this.addAutomaticKeepAlives = false,
    this.addRepaintBoundaries = true,
    this.cacheExtent = 250,
  });

  @override
  State<OptimizedListView<T>> createState() => _OptimizedListViewState<T>();
}

class _OptimizedListViewState<T> extends State<OptimizedListView<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;
  final PerformanceOptimizer _optimizer = PerformanceOptimizer();

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();

    if (widget.enableLoadMore) {
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
        _scrollController.position.maxScrollExtent - widget.loadMoreThreshold) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (!_isLoadingMore && widget.onLoadMore != null) {
      _optimizer.throttle(
        'load_more_list',
        const Duration(milliseconds: 500),
        () {
          setState(() {
            _isLoadingMore = true;
          });

          widget.onLoadMore!();

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _isLoadingMore = false;
              });
            }
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }

    final itemCount =
        widget.items.length + (widget.enableLoadMore && _isLoadingMore ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics ?? const ClampingScrollPhysics(),
      itemCount: itemCount,
      cacheExtent: widget.cacheExtent.toDouble(),
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return widget.loadingWidget ??
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
        }

        final item = widget.items[index];
        Widget itemWidget = widget.itemBuilder(context, item, index);

        // Add repaint boundary for complex items
        if (widget.addRepaintBoundaries) {
          itemWidget = RepaintBoundary(child: itemWidget);
        }

        if (widget.separatorBuilder != null &&
            index < widget.items.length - 1) {
          return Column(children: [itemWidget, widget.separatorBuilder!]);
        }

        return itemWidget;
      },
    );
  }
}

/// Sliver list with optimizations
class OptimizedSliverList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Widget? separatorBuilder;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;

  const OptimizedSliverList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.separatorBuilder,
    this.addAutomaticKeepAlives = false,
    this.addRepaintBoundaries = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= items.length) return null;

          final item = items[index];
          Widget itemWidget = itemBuilder(context, item, index);

          if (addRepaintBoundaries) {
            itemWidget = RepaintBoundary(child: itemWidget);
          }

          if (separatorBuilder != null && index < items.length - 1) {
            return Column(children: [itemWidget, separatorBuilder!]);
          }

          return itemWidget;
        },
        childCount: items.length,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
      ),
    );
  }
}

/// Grid view with optimizations
class OptimizedGridView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final VoidCallback? onLoadMore;
  final bool enableLoadMore;
  final double loadMoreThreshold;

  const OptimizedGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.onLoadMore,
    this.enableLoadMore = false,
    this.loadMoreThreshold = 200,
  });

  @override
  State<OptimizedGridView<T>> createState() => _OptimizedGridViewState<T>();
}

class _OptimizedGridViewState<T> extends State<OptimizedGridView<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();

    if (widget.enableLoadMore) {
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
        _scrollController.position.maxScrollExtent - widget.loadMoreThreshold) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (!_isLoadingMore && widget.onLoadMore != null) {
      setState(() {
        _isLoadingMore = true;
      });

      widget.onLoadMore!();

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemCount =
        widget.items.length + (widget.enableLoadMore && _isLoadingMore ? 1 : 0);

    return GridView.builder(
      controller: _scrollController,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics ?? const ClampingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: itemCount,
      cacheExtent: 500,
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final item = widget.items[index];
        return RepaintBoundary(child: widget.itemBuilder(context, item, index));
      },
    );
  }
}

/// Animated list with optimizations
class OptimizedAnimatedList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int, Animation<double>) itemBuilder;
  final Duration insertDuration;
  final Duration removeDuration;
  final Curve insertCurve;
  final Curve removeCurve;

  const OptimizedAnimatedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.insertDuration = const Duration(milliseconds: 300),
    this.removeDuration = const Duration(milliseconds: 300),
    this.insertCurve = Curves.easeInOut,
    this.removeCurve = Curves.easeInOut,
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

    // Handle item additions
    for (int i = 0; i < widget.items.length; i++) {
      if (i >= _items.length || widget.items[i] != _items[i]) {
        _items.insert(i, widget.items[i]);
        _listKey.currentState?.insertItem(i, duration: widget.insertDuration);
      }
    }

    // Handle item removals
    for (int i = _items.length - 1; i >= widget.items.length; i--) {
      final removedItem = _items[i];
      _items.removeAt(i);
      _listKey.currentState?.removeItem(
        i,
        (context, animation) =>
            widget.itemBuilder(context, removedItem, i, animation),
        duration: widget.removeDuration,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) {
        if (index >= _items.length) return const SizedBox.shrink();

        return RepaintBoundary(
          child: widget.itemBuilder(context, _items[index], index, animation),
        );
      },
    );
  }
}
