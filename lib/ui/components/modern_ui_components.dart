import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/modern_theme.dart';
import 'modern_button.dart';

/// Modern card with glassmorphic styling
class ModernCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool isGlass;
  final List<Color>? gradient;
  final double? borderRadius;
  final double? elevation;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.isGlass = false,
    this.gradient,
    this.borderRadius,
    this.elevation,
  });

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = widget.borderRadius ?? ModernTheme.radiusXl;

    Widget content = Container(
      margin: widget.margin,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: ModernTheme.animationFast,
        curve: ModernTheme.curveEaseOut,
        child: widget.isGlass
            ? _buildGlassCard(radius)
            : _buildStandardCard(isDark, radius),
      ),
    );

    if (widget.onTap != null) {
      content = GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          HapticFeedback.lightImpact();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: content,
      );
    }

    return content;
  }

  Widget _buildGlassCard(double radius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: double.infinity,
          borderRadius: radius,
          blur: 20,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                widget.gradient ??
                [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.05),
                ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.3),
              Colors.white.withValues(alpha: 0.1),
            ],
          ),
          child: Container(
            padding: widget.padding ?? EdgeInsets.all(ModernTheme.spaceMd),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  Widget _buildStandardCard(bool isDark, double radius) {
    return Container(
      decoration: BoxDecoration(
        gradient: widget.gradient != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.gradient!,
              )
            : null,
        color: widget.gradient == null
            ? (isDark ? ModernTheme.darkCardSurface : Colors.white)
            : null,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: widget.elevation != null
            ? ModernTheme.elevationMd(Colors.black)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            padding: widget.padding ?? EdgeInsets.all(ModernTheme.spaceMd),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Modern dialog with glassmorphic styling
class ModernDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final Widget? content;
  final List<Widget>? actions;
  final bool isGlass;

  const ModernDialog({
    super.key,
    this.title,
    this.message,
    this.content,
    this.actions,
    this.isGlass = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    Widget? content,
    List<Widget>? actions,
    bool isGlass = true,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => ModernDialog(
        title: title,
        message: message,
        content: content,
        actions: actions,
        isGlass: isGlass,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.all(ModernTheme.spaceLg),
          child: ModernCard(
            isGlass: isGlass,
            borderRadius: ModernTheme.radius2xl,
            padding: EdgeInsets.all(ModernTheme.spaceLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? ModernTheme.darkOnSurface
                          : ModernTheme.lightOnSurface,
                    ),
                  ),
                if (title != null && (message != null || content != null))
                  SizedBox(height: ModernTheme.spaceMd),
                if (message != null)
                  Text(
                    message!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? ModernTheme.darkOnSurfaceVariant
                          : ModernTheme.lightOnSurfaceVariant,
                    ),
                  ),
                if (content != null) content!,
                if (actions != null) ...[
                  SizedBox(height: ModernTheme.spaceLg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!
                        .map(
                          (action) => Padding(
                            padding: EdgeInsets.only(left: ModernTheme.spaceSm),
                            child: action,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: ModernTheme.animationFast)
        .scale(
          begin: const Offset(0.9, 0.9),
          duration: ModernTheme.animationMedium,
          curve: ModernTheme.curveOvershoot,
        );
  }
}

/// Modern badge component
class ModernBadge extends StatelessWidget {
  final String? text;
  final int? count;
  final Color? color;
  final Color? textColor;
  final bool isGlass;

  const ModernBadge({
    super.key,
    this.text,
    this.count,
    this.color,
    this.textColor,
    this.isGlass = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayText = text ?? (count != null ? count.toString() : '');

    if (displayText.isEmpty) return const SizedBox.shrink();

    if (isGlass) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(ModernTheme.radiusFull),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ModernTheme.spaceSm,
              vertical: ModernTheme.space2xs,
            ),
            decoration: BoxDecoration(
              color: (color ?? ModernTheme.errorColor).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(ModernTheme.radiusFull),
              border: Border.all(
                color: (color ?? ModernTheme.errorColor).withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Text(
              displayText,
              style: theme.textTheme.labelSmall?.copyWith(
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ModernTheme.spaceSm,
        vertical: ModernTheme.space2xs,
      ),
      decoration: BoxDecoration(
        color: color ?? ModernTheme.errorColor,
        borderRadius: BorderRadius.circular(ModernTheme.radiusFull),
      ),
      child: Text(
        displayText,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Modern loading indicator
class ModernLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final String? message;

  const ModernLoadingIndicator({
    super.key,
    this.size = 48,
    this.color,
    this.message,
  });

  @override
  State<ModernLoadingIndicator> createState() => _ModernLoadingIndicatorState();
}

class _ModernLoadingIndicatorState extends State<ModernLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? ModernTheme.primaryColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * 3.14159,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: CustomPaint(
                  painter: _ModernLoadingPainter(
                    color: color,
                    progress: _controller.value,
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          SizedBox(height: ModernTheme.spaceMd),
          Text(
            widget.message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _ModernLoadingPainter extends CustomPainter {
  final Color color;
  final double progress;

  _ModernLoadingPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - paint.strokeWidth) / 2;

    // Draw background circle
    paint.color = color.withValues(alpha: 0.2);
    canvas.drawCircle(center, radius, paint);

    // Draw progress arc
    paint.color = color;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = -3.14159 / 2;
    final sweepAngle = progress * 2 * 3.14159 * 0.75;
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Modern empty state widget
class ModernEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const ModernEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
          child: Padding(
            padding: EdgeInsets.all(ModernTheme.spaceXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ModernTheme.primaryColor.withValues(alpha: 0.1),
                        ModernTheme.primaryLight.withValues(alpha: 0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 64,
                    color: ModernTheme.primaryColor.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: ModernTheme.spaceLg),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? ModernTheme.darkOnSurface
                        : ModernTheme.lightOnSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: ModernTheme.spaceSm),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? ModernTheme.darkOnSurfaceVariant
                          : ModernTheme.lightOnSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (action != null) ...[
                  SizedBox(height: ModernTheme.spaceXl),
                  action!,
                ],
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: ModernTheme.animationSlow)
        .slideY(begin: 0.1, duration: ModernTheme.animationMedium);
  }
}

/// Modern error state widget
class ModernErrorState extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;

  const ModernErrorState({super.key, this.title, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ModernEmptyState(
      icon: Icons.error_outline_rounded,
      title: title ?? 'Something went wrong',
      subtitle: message ?? 'An unexpected error occurred. Please try again.',
      action: onRetry != null
          ? ModernButton(
              text: 'Retry',
              onPressed: onRetry,
              variant: ModernButtonVariant.primary,
              leadingIcon: Icons.refresh_rounded,
            )
          : null,
    );
  }
}

/// Modern skeleton loader
class ModernSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final double? borderRadius;
  final bool isCircle;

  const ModernSkeleton({
    super.key,
    this.width,
    this.height = 20,
    this.borderRadius,
    this.isCircle = false,
  });

  @override
  State<ModernSkeleton> createState() => _ModernSkeletonState();
}

class _ModernSkeletonState extends State<ModernSkeleton>
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

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.5 + (_animation.value * 3), 0),
              end: Alignment(-0.5 + (_animation.value * 3), 0),
              colors: isDark
                  ? [
                      ModernTheme.darkSurface,
                      ModernTheme.darkSurfaceVariant,
                      ModernTheme.darkSurface,
                    ]
                  : [
                      Colors.grey.shade300,
                      Colors.grey.shade100,
                      Colors.grey.shade300,
                    ],
            ),
            borderRadius: widget.isCircle
                ? null
                : BorderRadius.circular(
                    widget.borderRadius ?? ModernTheme.radiusSm,
                  ),
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
          ),
        );
      },
    );
  }
}

/// Modern avatar component
class ModernAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final bool showBadge;
  final Color? badgeColor;
  final VoidCallback? onTap;

  const ModernAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 48,
    this.showBadge = false,
    this.badgeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ModernTheme.purpleGradient,
        ),
        boxShadow: ModernTheme.elevationMd(ModernTheme.primaryColor),
      ),
      child: ClipOval(
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholder(),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );

    if (showBadge) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badgeColor ?? ModernTheme.successColor,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildPlaceholder() {
    if (name != null && name!.isNotEmpty) {
      return Center(
        child: Text(
          name!.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Icon(Icons.person_rounded, color: Colors.white, size: size * 0.5);
  }
}
