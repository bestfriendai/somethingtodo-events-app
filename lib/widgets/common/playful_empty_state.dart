import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../../services/delight_service.dart';
import '../../services/platform_interactions.dart';
import 'dart:math';

class PlayfulEmptyState extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? lottieAsset;
  final VoidCallback? onTap;
  final String? actionText;
  final List<String>? funFacts;
  final EmptyStateType type;
  
  const PlayfulEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.lottieAsset,
    this.onTap,
    this.actionText,
    this.funFacts,
    this.type = EmptyStateType.general,
  });
  
  @override
  State<PlayfulEmptyState> createState() => _PlayfulEmptyStateState();
}

enum EmptyStateType {
  general,
  favorites,
  events,
  search,
  notifications,
  offline,
}

class _PlayfulEmptyStateState extends State<PlayfulEmptyState> 
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _wiggleController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _wiggleAnimation;
  
  int _tapCount = 0;
  String _currentFunFact = '';
  final Random _random = Random();
  
  @override
  void initState() {
    super.initState();
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _wiggleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _floatingAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
    
    _wiggleAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _wiggleController,
      curve: Curves.elasticInOut,
    ));
    
    _floatingController.repeat(reverse: true);
    _selectRandomFunFact();
  }
  
  @override
  void dispose() {
    _floatingController.dispose();
    _wiggleController.dispose();
    super.dispose();
  }
  
  void _selectRandomFunFact() {
    final facts = widget.funFacts ?? _getDefaultFunFacts();
    setState(() {
      _currentFunFact = facts[_random.nextInt(facts.length)];
    });
  }
  
  List<String> _getDefaultFunFacts() {
    switch (widget.type) {
      case EmptyStateType.favorites:
        return [
          'Pro tip: Double-tap events to like them instantly!',
          'Your favorite events will appear here like magic ✨',
          'Fun fact: People who save events are 73% more fun at parties!',
          'Empty favorites = endless possibilities!',
          'Your future weekend plans will thank you!',
        ];
      case EmptyStateType.events:
        return [
          'Events are like buses - wait a bit and more will come!',
          'Perfect time to plan your own epic gathering!',
          'The calm before the party storm 🌪️',
          'Your social calendar is having a zen moment',
          'Plot twist: This is the perfect time to be spontaneous!',
        ];
      case EmptyStateType.search:
        return [
          'Not all who wander are lost... but your search terms might be!',
          'Try being more specific, or more random - both work!',
          'Maybe what you are looking for is looking for you too?',
          'Sometimes the best events are the ones you do not search for',
          'Expand your horizons - try a different keyword!',
        ];
      case EmptyStateType.notifications:
        return [
          'Notifications are like compliments - the good ones are worth waiting for',
          'Enjoy the peace while it lasts!',
          'Silence is golden... and sometimes necessary',
          'Your phone is taking a well-deserved break',
          'This empty space is full of potential!',
        ];
      case EmptyStateType.offline:
        return [
          'WiFi is down but your spirits do not have to be!',
          'Perfect time to plan that outdoor adventure!',
          'The internet is taking a coffee break ☕',
          'Old school mode: activated!',
          'Sometimes disconnecting helps you reconnect',
        ];
      default:
        return [
          'Every masterpiece starts with a blank canvas',
          'Great things are coming, we can feel it!',
          'This emptiness is just potential in disguise',
          'Plot twist: You are exactly where you need to be',
          'Sometimes less is more... but more is coming soon!',
        ];
    }
  }
  
  void _handleTap() {
    _tapCount++;
    PlatformInteractions.lightImpact();
    
    // Wiggle animation
    _wiggleController.forward().then((_) {
      _wiggleController.reset();
    });
    
    // Easter egg for persistent tappers
    if (_tapCount >= 7) {
      DelightService.instance.triggerEasterEgg(context, 'persistent_tapper');
      _tapCount = 0;
    } else if (_tapCount == 3) {
      // Change fun fact
      _selectRandomFunFact();
    }
    
    widget.onTap?.call();
  }
  
  IconData _getDefaultIcon() {
    switch (widget.type) {
      case EmptyStateType.favorites:
        return Icons.favorite_border_rounded;
      case EmptyStateType.events:
        return Icons.event_available_rounded;
      case EmptyStateType.search:
        return Icons.search_off_rounded;
      case EmptyStateType.notifications:
        return Icons.notifications_off_rounded;
      case EmptyStateType.offline:
        return Icons.wifi_off_rounded;
      default:
        return Icons.lightbulb_outline_rounded;
    }
  }
  
  Color _getAccentColor() {
    switch (widget.type) {
      case EmptyStateType.favorites:
        return Colors.pink;
      case EmptyStateType.events:
        return Colors.blue;
      case EmptyStateType.search:
        return Colors.orange;
      case EmptyStateType.notifications:
        return Colors.green;
      case EmptyStateType.offline:
        return Colors.red;
      default:
        return Colors.purple;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = _getAccentColor();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating icon or lottie animation
            GestureDetector(
              onTap: _handleTap,
              child: AnimatedBuilder(
                animation: Listenable.merge([_floatingAnimation, _wiggleAnimation]),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatingAnimation.value),
                    child: Transform.rotate(
                      angle: _wiggleAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(60),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: widget.lottieAsset != null
                            ? Lottie.asset(
                                widget.lottieAsset!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                              )
                            : Icon(
                                widget.icon ?? _getDefaultIcon(),
                                size: 60,
                                color: accentColor,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ).animate(delay: 500.ms)
              .fadeIn(duration: 800.ms)
              .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),
            
            const SizedBox(height: 32),
            
            // Title
            Text(
              widget.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ).animate(delay: 700.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.3),
            
            if (widget.subtitle != null) ..[
              const SizedBox(height: 16),
              Text(
                widget.subtitle!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 900.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3),
            ],
            
            const SizedBox(height: 24),
            
            // Fun fact bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      _currentFunFact,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ).animate(delay: 1100.ms)
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8)),
            
            if (widget.actionText != null && widget.onTap != null) ..[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _handleTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 8,
                  shadowColor: accentColor.withValues(alpha: 0.3),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.rocket_launch_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.actionText!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 1300.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3)
                .shimmer(delay: 2.seconds, duration: 2.seconds),
            ],
            
            // Secret instruction
            const SizedBox(height: 40),
            Text(
              'Psst... tap the icon above for surprises! 😉',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ).animate(delay: 2.seconds)
              .fadeIn(duration: 1.seconds)
              .then(delay: 1.seconds)
              .fadeOut(duration: 1.seconds)
              .animate(onComplete: (controller) => controller.repeat()),
          ],
        ),
      ),
    );
  }
}

// Specialized empty states for different screens
class FavoritesEmptyState extends StatelessWidget {
  final VoidCallback? onExplore;
  
  const FavoritesEmptyState({super.key, this.onExplore});
  
  @override
  Widget build(BuildContext context) {
    return PlayfulEmptyState(
      type: EmptyStateType.favorites,
      title: 'No Favorites Yet!',
      subtitle: 'Your heart is an empty canvas waiting for the perfect events to fill it with joy',
      onTap: onExplore,
      actionText: 'Find Amazing Events',
      funFacts: [
        'Did you know? The average person attends 12 events per year!',
        'Studies show planning events increases happiness by 25%!',
        'Your first favorite event is always the most special 💫',
        'People who attend events have 40% more interesting stories!',
      ],
    );
  }
}

class EventsEmptyState extends StatelessWidget {
  final VoidCallback? onRefresh;
  final String? locationHint;
  
  const EventsEmptyState({super.key, this.onRefresh, this.locationHint});
  
  @override
  Widget build(BuildContext context) {
    return PlayfulEmptyState(
      type: EmptyStateType.events,
      title: 'No Events Found',
      subtitle: locationHint != null 
          ? 'No events in $locationHint right now, but great things are coming!'
          : 'The event calendar is taking a quick break',
      onTap: onRefresh,
      actionText: 'Refresh & Search',
    );
  }
}

class SearchEmptyState extends StatelessWidget {
  final String searchTerm;
  final VoidCallback? onTryDifferent;
  
  const SearchEmptyState({
    super.key, 
    required this.searchTerm,
    this.onTryDifferent,
  });
  
  @override
  Widget build(BuildContext context) {
    return PlayfulEmptyState(
      type: EmptyStateType.search,
      title: 'No Results Found',
      subtitle: 'Could not find any events for "$searchTerm" but the search continues!',
      onTap: onTryDifferent,
      actionText: 'Try Different Search',
    );
  }
}

class OfflineEmptyState extends StatelessWidget {
  final VoidCallback? onRetry;
  
  const OfflineEmptyState({super.key, this.onRetry});
  
  @override
  Widget build(BuildContext context) {
    return PlayfulEmptyState(
      type: EmptyStateType.offline,
      title: 'You are Offline!',
      subtitle: 'No internet? No problem! Perfect time to plan that outdoor adventure you have been thinking about',
      onTap: onRetry,
      actionText: 'Try Again',
    );
  }
}