import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../config/modern_theme.dart';
import 'premium_button.dart';
import 'premium_text_animator.dart';
import 'premium_empty_state.dart';

class PremiumErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails)? errorWidgetBuilder;
  final void Function(FlutterErrorDetails)? onError;
  
  const PremiumErrorBoundary({
    super.key,
    required this.child,
    this.errorWidgetBuilder,
    this.onError,
  });
  
  @override
  State<PremiumErrorBoundary> createState() => _PremiumErrorBoundaryState();
}

class _PremiumErrorBoundaryState extends State<PremiumErrorBoundary> {
  FlutterErrorDetails? _errorDetails;
  
  @override
  void initState() {
    super.initState();
    
    // Override Flutter's error widget builder for this subtree
    final originalBuilder = ErrorWidget.builder;
    
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      setState(() {
        _errorDetails = errorDetails;
      });
      
      widget.onError?.call(errorDetails);
      
      if (widget.errorWidgetBuilder != null) {
        return widget.errorWidgetBuilder!(errorDetails);
      }
      
      return PremiumErrorWidget(
        error: errorDetails,
        onRetry: _retry,
      );
    };
    
    // Restore original builder when widget is disposed
    addPostFrameCallback(() {
      return () {
        ErrorWidget.builder = originalBuilder;
      };
    });
  }
  
  void addPostFrameCallback(VoidCallback Function() callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cleanup = callback();
      if (cleanup != null) {
        // Store cleanup function to call on dispose
      }
    });
  }
  
  void _retry() {
    setState(() {
      _errorDetails = null;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      if (widget.errorWidgetBuilder != null) {
        return widget.errorWidgetBuilder!(_errorDetails!);
      }
      return PremiumErrorWidget(
        error: _errorDetails!,
        onRetry: _retry,
      );
    }
    
    return widget.child;
  }
}

class PremiumErrorWidget extends StatefulWidget {
  final FlutterErrorDetails error;
  final VoidCallback? onRetry;
  final ErrorStyle style;
  
  const PremiumErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.style = ErrorStyle.delightful,
  });
  
  @override
  State<PremiumErrorWidget> createState() => _PremiumErrorWidgetState();
}

class _PremiumErrorWidgetState extends State<PremiumErrorWidget>
    with TickerProviderStateMixin {
  late AnimationController _glitchController;
  late AnimationController _floatController;
  
  @override
  void initState() {
    super.initState();
    
    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _floatController.repeat(reverse: true);
    
    // Trigger glitch effect periodically
    _startGlitchEffect();
  }
  
  void _startGlitchEffect() {
    Future.delayed(Duration(seconds: 2 + math.Random().nextInt(3)), () {
      if (mounted) {
        _glitchController.forward().then((_) {
          _glitchController.reverse();
          _startGlitchEffect();
        });
      }
    });
  }
  
  @override
  void dispose() {
    _glitchController.dispose();
    _floatController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    switch (widget.style) {
      case ErrorStyle.delightful:
        return _buildDelightfulError();
      case ErrorStyle.minimal:
        return _buildMinimalError();
      case ErrorStyle.glitch:
        return _buildGlitchError();
      case ErrorStyle.cosmic:
        return _buildCosmicError();
    }
  }
  
  Widget _buildDelightfulError() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernTheme.darkBackground,
            ModernTheme.errorColor.withValues(alpha: 0.1),
            ModernTheme.darkBackground,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Floating error icon with particles
              AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      10 * math.sin(_floatController.value * math.pi),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Floating particles
                        ...List.generate(8, (index) {
                          final angle = (index * 45.0) * (math.pi / 180) + 
                              (_floatController.value * 2 * math.pi);
                          final radius = 50 + (10 * math.sin(_floatController.value * 2 * math.pi + index));
                          
                          return Transform.translate(
                            offset: Offset(
                              radius * math.cos(angle),
                              radius * math.sin(angle),
                            ),
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ModernTheme.errorColor.withValues(alpha: 0.6),
                                boxShadow: [
                                  BoxShadow(
                                    color: ModernTheme.errorColor.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        
                        // Main error icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                ModernTheme.errorColor,
                                ModernTheme.errorColor.withValues(alpha: 0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ModernTheme.errorColor.withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.sentiment_dissatisfied_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Error title
              PremiumTextAnimator(
                text: 'Oops! Something went sideways',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                animationType: TextAnimationType.fadeIn,
                delay: const Duration(milliseconds: 300),
              ),
              
              const SizedBox(height: 16),
              
              // Error description
              PremiumTextAnimator(
                text: 'Don\'t worry, even the best apps have bad days. Let\'s try to fix this together!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  height: 1.5,
                ),
                animationType: TextAnimationType.slideUp,
                delay: const Duration(milliseconds: 500),
              ),
              
              const SizedBox(height: 32),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.onRetry != null)
                    PremiumButton(
                      text: 'Try Again',
                      onPressed: widget.onRetry,
                      icon: Icons.refresh,
                      width: 150,
                      gradient: [ModernTheme.errorColor, Colors.red.shade600],
                    ),
                  const SizedBox(width: 16),
                  PremiumButton(
                    text: 'Report Issue',
                    onPressed: () => _reportIssue(context),
                    icon: Icons.bug_report_outlined,
                    width: 150,
                    gradient: ModernTheme.oceanGradient,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Error details (expandable)
              ExpansionTile(
                title: const Text(
                  'Technical Details',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
                iconColor: Colors.white60,
                collapsedIconColor: Colors.white60,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      widget.error.toString(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 800.ms)
    .slideY(begin: 0.2, curve: Curves.easeOut);
  }
  
  Widget _buildMinimalError() {
    return PremiumEmptyState(
      title: 'Something went wrong',
      subtitle: 'We encountered an error while loading this content.',
      icon: Icons.error_outline,
      actionText: 'Try Again',
      onAction: widget.onRetry,
      type: EmptyStateType.error,
      showFloatingElements: false,
    );
  }
  
  Widget _buildGlitchError() {
    return AnimatedBuilder(
      animation: _glitchController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _glitchController.value * 10 * (math.Random().nextDouble() - 0.5),
            _glitchController.value * 5 * (math.Random().nextDouble() - 0.5),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  ModernTheme.errorColor.withValues(alpha: 0.2),
                  Colors.black,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Glitch overlay
                if (_glitchController.value > 0)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.red.withValues(alpha: _glitchController.value * 0.3),
                            Colors.blue.withValues(alpha: _glitchController.value * 0.2),
                            Colors.green.withValues(alpha: _glitchController.value * 0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                
                // Content
                _buildDelightfulError(),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCosmicError() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0A0A),
            Color(0xFF1A0A1A),
            Color(0xFF0A0A0A),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Stars background
          Positioned.fill(
            child: CustomPaint(
              painter: StarFieldPainter(),
            ),
          ),
          
          // Main content
          _buildDelightfulError(),
        ],
      ),
    );
  }
  
  void _reportIssue(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernTheme.darkCardSurface,
        title: const Text(
          'Report Issue',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Thank you for helping us improve! This error has been logged and our team will investigate.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          PremiumButton(
            text: 'Got it',
            onPressed: () => Navigator.of(context).pop(),
            width: 100,
          ),
        ],
      ),
    );
  }
}

class StarFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    final random = math.Random(42); // Fixed seed for consistent stars
    
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;
  
  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.customMessage,
  });
  
  @override
  Widget build(BuildContext context) {
    return PremiumEmptyState(
      title: 'No Internet Connection',
      subtitle: customMessage ?? 
          'It looks like you\'re offline. Check your connection and try again.',
      icon: Icons.wifi_off_rounded,
      actionText: 'Retry',
      onAction: onRetry,
      type: EmptyStateType.offline,
      customColors: [Colors.grey.shade600, Colors.grey.shade800],
    );
  }
}

class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final int? statusCode;
  
  const ServerErrorWidget({
    super.key,
    this.onRetry,
    this.statusCode,
  });
  
  @override
  Widget build(BuildContext context) {
    String title = 'Server Error';
    String subtitle = 'Our servers are having a moment. Please try again.';
    
    if (statusCode != null) {
      switch (statusCode) {
        case 404:
          title = 'Page Not Found';
          subtitle = 'The page you\'re looking for doesn\'t exist.';
          break;
        case 500:
          title = 'Server Error';
          subtitle = 'Something went wrong on our end.';
          break;
        case 403:
          title = 'Access Denied';
          subtitle = 'You don\'t have permission to view this content.';
          break;
      }
    }
    
    return PremiumEmptyState(
      title: title,
      subtitle: subtitle,
      icon: Icons.cloud_off_rounded,
      actionText: 'Try Again',
      onAction: onRetry,
      type: EmptyStateType.error,
    );
  }
}

enum ErrorStyle {
  delightful,
  minimal,
  glitch,
  cosmic,
}