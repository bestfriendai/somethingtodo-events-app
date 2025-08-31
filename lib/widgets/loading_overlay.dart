import 'package:flutter/material.dart';
import '../config/theme.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final Color? barrierColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.barrierColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: barrierColor ?? Colors.black.withOpacity(0.5),
            child: Center(
              child: _buildDelightfulLoadingWidget(context),
            ),
          ),
      ],
    );
  }

  Widget _buildDelightfulLoadingWidget(BuildContext context) {
    final displayMessage = widget.message ?? _currentMessage;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Sparkle background
        if (widget.showSparkles)
          AnimatedBuilder(
            animation: _sparkleController,
            builder: (context, child) {
              return CustomPaint(
                painter: LoadingSparklePainter(
                  progress: _sparkleController.value,
                  sparkleCount: 25,
                ),
                size: const Size(300, 300),
              );
            },
          ),
        // Main loading container
        Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Enhanced loading indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                  ),
                  // Inner animated ring
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  ).animate()
                    .rotate(duration: 2.seconds)
                    .animate(onComplete: (controller) => controller.repeat()),
                  // Central icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryDarkColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.explore,
                      color: Colors.white,
                      size: 24,
                    ),
                  ).animate()
                    .scale(duration: 1.seconds, curve: Curves.easeInOut)
                    .then()
                    .scale(end: 1.2, duration: 1.seconds, curve: Curves.easeInOut)
                    .animate(onComplete: (controller) => controller.repeat(reverse: true)),
                ],
              ),
              
              if (displayMessage.isNotEmpty) ...[
                const SizedBox(height: 24),
                // Animated message
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.3, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    displayMessage,
                    key: ValueKey(displayMessage),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                // Progress dots
                _buildProgressDots(),
              ],
            ],
          ),
        ).animate()
          .fadeIn(duration: 400.ms)
          .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut)
          .then()
          .shimmer(duration: 3.seconds, color: AppTheme.primaryColor.withOpacity(0.1)),
      ],
    );
  }
  
  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
        ).animate(delay: (index * 200).ms)
          .fadeIn(duration: 600.ms)
          .scale(begin: const Offset(0.5, 0.5))
          .then(delay: 600.ms)
          .fadeOut(duration: 600.ms)
          .animate(onComplete: (controller) => controller.repeat());
      }),
    );
  }
}

class LoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final double? width;
  final double? height;

  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : child,
      ),
    );
  }
}

// Enhanced Loading Button
class DelightfulLoadingButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final double? width;
  final double? height;
  final bool showDelightOnPress;

  const DelightfulLoadingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.width,
    this.height,
    this.showDelightOnPress = true,
  });
  
  @override
  State<DelightfulLoadingButton> createState() => _DelightfulLoadingButtonState();
}

class _DelightfulLoadingButtonState extends State<DelightfulLoadingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }
  
  void _handleTapDown() {
    setState(() => _isPressed = true);
    _pressController.forward();
  }
  
  void _handleTapUp() {
    setState(() => _isPressed = false);
    _pressController.reverse();
    
    if (widget.showDelightOnPress && !widget.isLoading) {
      DelightService.instance.showConfetti(
        context,
        customMessage: 'Action initiated! 🚀',
      );
    }
    
    widget.onPressed?.call();
  }
  
  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pressController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1 - (_pressController.value * 0.05),
          child: SizedBox(
            width: widget.width,
            height: widget.height ?? 48,
            child: GestureDetector(
              onTapDown: widget.isLoading ? null : (_) => _handleTapDown(),
              onTapUp: widget.isLoading ? null : (_) => _handleTapUp(),
              onTapCancel: widget.isLoading ? null : _handleTapCancel,
              child: ElevatedButton(
                onPressed: null, // Handled by GestureDetector
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isLoading 
                      ? Theme.of(context).colorScheme.surface
                      : null,
                  elevation: _isPressed ? 2 : 8,
                  shadowColor: AppTheme.primaryColor.withOpacity(0.3),
                ),
                child: widget.isLoading
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ).animate()
                            .rotate(duration: 1.seconds)
                            .animate(onComplete: (controller) => controller.repeat()),
                          const SizedBox(width: 12),
                          Text(
                            'Working Magic...',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ).animate()
                            .fadeIn(duration: 600.ms)
                            .then(delay: 1.seconds)
                            .fadeOut(duration: 600.ms)
                            .animate(onComplete: (controller) => controller.repeat()),
                        ],
                      )
                    : widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Loading Sparkle Painter
class LoadingSparklePainter extends CustomPainter {
  final double progress;
  final int sparkleCount;
  
  LoadingSparklePainter({required this.progress, required this.sparkleCount});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (int i = 0; i < sparkleCount; i++) {
      final angle = (i * 2 * pi / sparkleCount) + (progress * 2 * pi * 0.5);
      final distance = 50 + (i % 3) * 30 + (20 * sin(progress * 3 * pi + i));
      final sparkleSize = 2 + (3 * sin(progress * 4 * pi + i * 0.5));
      
      final x = center.dx + (distance * cos(angle));
      final y = center.dy + (distance * sin(angle));
      
      paint.color = HSVColor.fromAHSV(
        0.8 * sin(progress * pi + i * 0.3),
        (progress * 360 + i * 15) % 360,
        0.9,
        1.0,
      ).toColor();
      
      // Draw sparkle as a star
      final starPath = Path();
      for (int j = 0; j < 5; j++) {
        final starAngle = (j * 2 * pi / 5) - pi / 2;
        final starX = x + (sparkleSize * cos(starAngle));
        final starY = y + (sparkleSize * sin(starAngle));
        if (j == 0) {
          starPath.moveTo(starX, starY);
        } else {
          starPath.lineTo(starX, starY);
        }
      }
      starPath.close();
      
      canvas.drawPath(starPath, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}