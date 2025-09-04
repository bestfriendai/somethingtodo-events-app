import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:ui';

class GlassBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int unreadCount;

  const GlassBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.unreadCount = 0,
  });

  @override
  State<GlassBottomNavigation> createState() => _GlassBottomNavigationState();
}

class _GlassBottomNavigationState extends State<GlassBottomNavigation>
    with TickerProviderStateMixin {
  late List<AnimationController> _itemControllers;
  late AnimationController _indicatorController;
  late AnimationController _rippleController;

  final List<_NavItem> _items = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      gradient: [Colors.purple, Colors.blue],
    ),
    _NavItem(
      icon: Icons.map_outlined,
      activeIcon: Icons.map_rounded,
      label: 'Map',
      gradient: [Colors.blue, Colors.cyan],
    ),
    _NavItem(
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      label: 'Chat',
      gradient: [Colors.cyan, Colors.teal],
    ),
    _NavItem(
      icon: Icons.favorite_outline_rounded,
      activeIcon: Icons.favorite_rounded,
      label: 'Favorites',
      gradient: [Colors.pink, Colors.red],
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
      gradient: [Colors.orange, Colors.amber],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _itemControllers = List.generate(
      _items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _itemControllers[widget.currentIndex].forward();
  }

  @override
  void didUpdateWidget(GlassBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _itemControllers[oldWidget.currentIndex].reverse();
      _itemControllers[widget.currentIndex].forward();
      _indicatorController.forward(from: 0);
      _rippleController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    _indicatorController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 30,
              offset: const Offset(0, -10),
              spreadRadius: 5,
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            const indicatorWidth = 60.0;
            final segmentWidth = barWidth / _items.length;

            return Stack(
              children: [
                // Main glass container
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.8),
                          ],
                        ),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Glass morphism overlay
                GlassmorphicContainer(
                  width: double.infinity,
                  height: 90,
                  borderRadius: 0,
                  blur: 20,
                  alignment: Alignment.center,
                  border: 0,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.05),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
                  borderGradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.transparent, Colors.transparent],
                  ),
                  child: Stack(
                    children: [
                      // Animated indicator
                      AnimatedBuilder(
                        animation: _indicatorController,
                        builder: (context, child) {
                          final left = segmentWidth * widget.currentIndex +
                              (segmentWidth / 2) -
                              (indicatorWidth / 2);
                          return Positioned(
                            left: left,
                            bottom: 8,
                            child: Container(
                              width: indicatorWidth,
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: LinearGradient(
                                  colors: _items[widget.currentIndex].gradient,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _items[widget.currentIndex]
                                        .gradient[0]
                                        .withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Ripple effect
                      AnimatedBuilder(
                        animation: _rippleController,
                        builder: (context, child) {
                          final left = segmentWidth * widget.currentIndex;
                          return Positioned(
                            left: left,
                            top: 0,
                            child: SizedBox(
                              width: segmentWidth,
                              height: 90,
                              child: Center(
                                child: Transform.scale(
                                  scale: _rippleController.value * 2,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          _items[widget.currentIndex]
                                              .gradient[0]
                                              .withValues(
                                                alpha: 0.3 *
                                                    (1 -
                                                        _rippleController
                                                            .value),
                                              ),
                                          _items[widget.currentIndex]
                                              .gradient[1]
                                              .withValues(
                                                alpha: 0.1 *
                                                    (1 -
                                                        _rippleController
                                                            .value),
                                              ),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Navigation items
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children:
                            List.generate(_items.length, (index) => _buildNavItem(index)),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _items[index];
    final isSelected = widget.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 90,
          child: Stack(
            children: [
              // Glass item background when selected
              if (isSelected)
                Center(
                  child: AnimatedBuilder(
                    animation: _itemControllers[index],
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.9 + (_itemControllers[index].value * 0.1),
                        child: Container(
                          width: 65,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                item.gradient[0].withValues(
                                  alpha: 0.2 * _itemControllers[index].value,
                                ),
                                item.gradient[1].withValues(
                                  alpha: 0.1 * _itemControllers[index].value,
                                ),
                              ],
                            ),
                            border: Border.all(
                              color: item.gradient[0].withValues(
                                alpha: 0.3 * _itemControllers[index].value,
                              ),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: item.gradient[0].withValues(
                                  alpha: 0.3 * _itemControllers[index].value,
                                ),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Icon and label
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      AnimatedBuilder(
                        animation: _itemControllers[index],
                        builder: (context, child) {
                          return Transform.scale(
                            scale: isSelected
                                ? 1.0 + (_itemControllers[index].value * 0.2)
                                : 1.0,
                            child: Transform.rotate(
                              angle: isSelected
                                  ? _itemControllers[index].value * 0.1
                                  : 0,
                              child: Icon(
                                isSelected ? item.activeIcon : item.icon,
                                size: 28,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                          );
                        },
                      ),

                      // Badge for chat
                      if (index == 2 && widget.unreadCount > 0)
                        Positioned(
                          right: -8,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.red, Colors.orange],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              widget.unreadCount > 99
                                  ? '99+'
                                  : widget.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: isSelected ? 12 : 10,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                    child: Text(item.label),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final List<Color> gradient;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.gradient,
  });
}
